version: '2'

services:
  redis-server:
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
      io.rancher.sidekicks: redis-server-config
      io.rancher.scheduler.affinity:container_label_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name
    volumes_from:
      - redis-server-config
    entrypoint: /opt/redis/scripts/server-entrypoint.sh
    command:
      - "redis-server"
      - "/usr/local/etc/redis/redis.conf"

  redis-sentinel:
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
      io.rancher.sidekicks: redis-sentinel-config
      io.rancher.container.hostname_override: container_name
    volumes_from:
      - redis-sentinel-config
    entrypoint: /opt/redis/scripts/sentinel-entrypoint.sh
    command:
      - "redis-server"
      - "/usr/local/etc/redis/sentinel.conf"
      - "--sentinel"

  haproxy:
    image: rancher/lb-service-haproxy:v0.7.9
    ports:
    - ${REDIS_HAPROXY_PORT}:6379/tcp
    labels:
      {{- if ne .Values.REDIS_SENTINEL_HOST_LABEL ""}}
      io.rancher.scheduler.affinity:host_label: ${REDIS_SENTINEL_HOST_LABEL}
      {{- end}}
      io.rancher.container.agent.role: environmentAdmin
      io.rancher.container.create_agent: 'true'

  redis-server-config:
    image: lgatica/redis-config
    environment:
      REDIS_PASSWORD: '${REDIS_PASSWORD}'
    stdin_open: true
    tty: true
    volumes:
    - /usr/local/etc/redis
    - /opt/redis/scripts
    - redis-server:/data
    labels:
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'
  redis-sentinel-config:
    image: lgatica/redis-config
    environment:
      REDIS_PASSWORD: '${REDIS_PASSWORD}'
    stdin_open: true
    tty: true
    volumes:
    - /usr/local/etc/redis
    - /opt/redis/scripts
    - redis-sentinel:/data
    labels:
      io.rancher.container.pull_image: always
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: 'true'

{{- if or (.Values.REDIS_VOLUME_NAME) (.Values.SENTINEL_VOLUME_NAME)}}
volumes:
  {{- if .Values.REDIS_VOLUME_NAME}}
  {{.Values.REDIS_VOLUME_NAME}}:
    external: true
    {{- if .Values.STORAGE_DRIVER}}
    driver: {{.Values.STORAGE_DRIVER}}
    {{- end}}
  {{- end}}

  {{- if .Values.SENTINEL_VOLUME_NAME}}
  {{.Values.SENTINEL_VOLUME_NAME}}:
    external: true
    {{- if .Values.STORAGE_DRIVER}}
    driver: {{.Values.STORAGE_DRIVER}}
    {{- end}}
  {{- end}}
{{- end }}
