FROM alpine:3.6@sha256:d6eda1410b93902ac84bdd775167c84ab59e5abadad88791d742fea93b161e93

LABEL maintainer "Leonardo Gatica <lgatica@protonmail.com>"

ENV GIDDYUP_VERSION=0.19.0

RUN mkdir -p /opt/redis
COPY scripts /opt/redis/scripts
RUN apk add --no-cache curl && \
  mkdir -p /usr/local/etc/redis && \
  curl -o /usr/local/etc/redis/redis.conf http://download.redis.io/redis-stable/redis.conf && \
  curl -o /usr/local/etc/redis/sentinel.conf http://download.redis.io/redis-stable/sentinel.conf && \
  curl -sL -o /opt/redis/scripts/giddyup https://github.com/rancher/giddyup/releases/download/v${GIDDYUP_VERSION}/giddyup && \
  chmod +x /opt/redis/scripts/*
