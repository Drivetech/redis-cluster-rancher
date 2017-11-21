version: '2'

services:
  redis:
    image: ${REDIS_VERSION}
    environment:
      REDIS_PASSWORD: '${REDIS_PASSWORD}'
    stdin_open: true
    tty: true
    labels:
      {{- if ne .Values.REDIS_SERVER_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${REDIS_SERVER_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.sidekicks: redis-config{{- if ne .Values.REDIS_VOLUME_PATH ""}}, redis-data{{- end}}
      io.rancher.scheduler.affinity:container_label_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name
    volumes_from:
      - redis-config
      {{- if ne .Values.REDIS_VOLUME_PATH ""}}
      - redis-data
      {{- end}}
    entrypoint: /opt/redis/scripts/server-entrypoint.sh
    command:
      - "redis-server"
      - "/usr/local/etc/redis/redis.conf"

  sentinel:
    image: ${REDIS_VERSION}
    environment:
      REDIS_PASSWORD: '${REDIS_PASSWORD}'
      SENTINEL_QUORUM: '${SENTINEL_QUORUM}'
      SENTINEL_DOWN_AFTER: '${SENTINEL_DOWN_AFTER}'
      SENTINEL_FAILOVER: '${SENTINEL_FAILOVER}'
    stdin_open: true
    tty: true
    labels:
      io.rancher.container.pull_image: always
      {{- if ne .Values.REDIS_SENTINEL_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${REDIS_SENTINEL_HOST_LABEL}
      {{- end}}
      io.rancher.sidekicks: sentinel-config{{- if ne .Values.SENTINEL_VOLUME_PATH ""}}, sentinel-data{{- end}}
      io.rancher.container.hostname_override: container_name
    volumes_from:
      - sentinel-config
      {{- if ne .Values.SENTINEL_VOLUME_PATH ""}}
      - sentinel-data
      {{- end}}
    entrypoint: /opt/redis/scripts/sentinel-entrypoint.sh
    command:
      - "redis-server"
      - "/usr/local/etc/redis/sentinel.conf"
      - "--sentinel"

  redis-lb:
    image: rancher/lb-service-haproxy:v0.7.9
    ports:
    - ${REDIS_HAPROXY_PORT}:6379/tcp
    labels:
      {{- if ne .Values.REDIS_SENTINEL_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${REDIS_SENTINEL_HOST_LABEL}
      {{- end}}
      io.rancher.container.agent.role: environmentAdmin
      io.rancher.container.create_agent: 'true'

  redis-config:
    image: lgatica/redis-config
    environment:
      REDIS_PASSWORD: '${REDIS_PASSWORD}'
    stdin_open: true
    tty: true
    volumes:
    - /usr/local/etc/redis
    - /opt/redis/scripts
    labels:
      {{- if ne .Values.REDIS_SERVER_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${REDIS_SERVER_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
    entrypoint: /bin/true

  sentinel-config:
    image: lgatica/redis-config
    environment:
      REDIS_PASSWORD: '${REDIS_PASSWORD}'
    stdin_open: true
    tty: true
    volumes:
    - /usr/local/etc/redis
    - /opt/redis/scripts
    labels:
      {{- if ne .Values.REDIS_SENTINEL_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${REDIS_SENTINEL_HOST_LABEL}
      {{- end}}
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
    entrypoint: /bin/true

  {{- if .Values.REDIS_VOLUME_PATH}}
  redis-data:
    image: busybox
    labels:
      {{- if ne .Values.REDIS_SERVER_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${REDIS_SERVER_HOST_LABEL}
      {{- end}}
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
    volumes:
      - {{.Values.REDIS_VOLUME_PATH}}:/data
    entrypoint: /bin/true
  {{- end}}

  {{- if .Values.SENTINEL_VOLUME_PATH}}
  sentinel-data:
    image: busybox
    labels:
      {{- if ne .Values.REDIS_SENTINEL_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${REDIS_SENTINEL_HOST_LABEL}
      {{- end}}
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
    volumes:
      - {{.Values.SENTINEL_VOLUME_PATH}}:/data
    entrypoint: /bin/true
  {{- end}}
