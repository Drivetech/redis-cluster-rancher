#!/usr/bin/env sh

function leader_ip {
  echo -n $(wget -q -O - http://rancher-metadata/latest/stacks/$1/services/$2/containers/0/primary_ip)
}

REDIS_USER_ID=${REDIS_USER_ID:-100}
REDIS_GROUP_ID=${REDIS_GROUP_ID:-101}
APPENDONLY=${APPENDONLY:-yes}

chown $REDIS_USER_ID:$REDIS_GROUP_ID /usr/local/etc/redis/redis.conf

/opt/redis/scripts/giddyup service wait scale --timeout 120
stack_name=`echo -n $(wget -q -O - http://rancher-metadata/latest/self/stack/name)`
my_ip=$(/opt/redis/scripts/giddyup ip myip)
master_ip=$(leader_ip $stack_name redis)

sed -i -E "s/^ *bind +.*$/bind 0.0.0.0/g" /usr/local/etc/redis/redis.conf
sed -i -E "s/^ *appendonly +.*$/appendonly $APPENDONLY/g" /usr/local/etc/redis/redis.conf
sed -i -E "s/^ *# +masterauth +(.*)$/masterauth $REDIS_PASSWORD/g" /usr/local/etc/redis/redis.conf
sed -i -E "s/^ *# +requirepass +(.*)$/requirepass $REDIS_PASSWORD/g" /usr/local/etc/redis/redis.conf

echo "my ip is $my_ip"
echo "master ip is $master_ip"

if [ "$my_ip" == "$master_ip" ]
then
  sed -i -E "s/^ *slaveof +([^ ]*) +([^ ]*)$/#slaveof \1 \2/g" /usr/local/etc/redis/redis.conf
  echo "i am the leader"
else
  port=`echo -n $(grep -E "^ *port +.*$" /usr/local/etc/redis/redis.conf | sed -E "s/^ *port +(.*)$/\1/g")`
  sed -i -E "s/^ *(# +)?slaveof +.*/slaveof $master_ip $port/g" /usr/local/etc/redis/redis.conf
fi

exec docker-entrypoint.sh "$@"
