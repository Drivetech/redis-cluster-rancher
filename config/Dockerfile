FROM alpine:3.7@sha256:8c03bb07a531c53ad7d0f6e7041b64d81f99c6e493cb39abba56d956b40eacbc

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
