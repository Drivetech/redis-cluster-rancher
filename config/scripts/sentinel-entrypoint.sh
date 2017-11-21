#!/usr/bin/env sh

function leader_ip {
  echo -n $(wget -q -O - http://rancher-metadata/latest/stacks/$1/services/$2/containers/0/primary_ip)
}

REDIS_USER_ID=${REDIS_USER_ID:-100}
REDIS_GROUP_ID=${REDIS_GROUP_ID:-101}

chown $REDIS_USER_ID:$REDIS_GROUP_ID /usr/local/etc/redis/sentinel.conf

/opt/redis/scripts/giddyup service wait scale --timeout 120
stack_name=`echo -n $(wget -q -O - http://rancher-metadata/latest/self/stack/name)`
my_ip=$(/opt/redis/scripts/giddyup ip myip)
master_ip=$(leader_ip $stack_name redis)

echo "my ip is $my_ip"
echo "master ip is $master_ip"

sed -i -E "s/^ *# *bind +.*$/bind 0.0.0.0/g" /usr/local/etc/redis/sentinel.conf
sed -i -E "s/^ *dir +.*$/dir .\//g" /usr/local/etc/redis/sentinel.conf
sed -i -E "s/^ *# *sentinel +announce-ip 1.2.3.4+.*$/sentinel announce-ip ${my_ip}/" /usr/local/etc/redis/sentinel.conf
sed -i -E "s/^ *sentinel +monitor +([A-z0-9._-]+) +([0-9.]+)? +([0-9]+) +([0-9]+).*$/sentinel monitor \1 ${master_ip} \3 $SENTINEL_QUORUM/g" /usr/local/etc/redis/sentinel.conf
sed -i -E "s/^ *sentinel +down-after-milliseconds +([A-z0-9._-]+) +([0-9]+).*$/sentinel down-after-milliseconds \1 $SENTINEL_DOWN_AFTER/g" /usr/local/etc/redis/sentinel.conf
sed -i -E "s/^ *sentinel +failover-timeout +([A-z0-9._-]+) +([0-9]+).*$/sentinel failover-timeout \1 $SENTINEL_FAILOVER/g" /usr/local/etc/redis/sentinel.conf
sed -i -E "s/^ *# *sentinel +auth-pass +([A-z0-9._-]+) +([A-z0-9._-]+).*$/sentinel auth-pass \1 $REDIS_PASSWORD/g" /usr/local/etc/redis/sentinel.conf

exec docker-entrypoint.sh "$@"
