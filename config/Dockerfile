FROM alpine:3.6@sha256:f006ecbb824d87947d0b51ab8488634bf69fe4094959d935c0c103f4820a417d

LABEL maintainer "Leonardo Gatica <lgatica@protonmail.com>"

ENV GIDDYUP_VERSION=0.19.0 CURL_VERSION=7.56.1

RUN mkdir -p /opt/redis
COPY scripts /opt/redis/scripts
RUN apk add --no-cache curl && \
  mkdir -p /usr/local/etc/redis && \
  curl -o /usr/local/etc/redis/redis.conf http://download.redis.io/redis-stable/redis.conf && \
  curl -o /usr/local/etc/redis/sentinel.conf http://download.redis.io/redis-stable/sentinel.conf && \
  curl -sL -o /opt/redis/scripts/giddyup https://github.com/rancher/giddyup/releases/download/v${GIDDYUP_VERSION}/giddyup && \
  chmod +x /opt/redis/scripts/*
