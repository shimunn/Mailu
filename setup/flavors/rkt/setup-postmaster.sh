#!/bin/sh

source {{ root }}/{{ env }}

function cleanup {
 /usr/bin/rkt rm $(cat {{ root }}/postmaster-setup.uuid)
}

trap cleanup EXIT

/usr/bin/rkt --inherit-env --dns 8.8.8.8 --uuid-file-save="{{ root }}/postmaster-setup.uuid" --interactive \
    {% if not admin_enabled %}
    --port 80-tcp:127.0.0.1:8080:80 \
    {% endif %}
    --volume data,kind=host,source={{ root }}/data \
    --volume dkim,kind=host,source={{ root }}/dkim \
    ${DOCKER_ORG:-mailu}/admin:${MAILU_VERSION:-{{ version }}} \
    --mount volume=data,target=/data \
    --mount volume=data,target=/dkim \
    --exec /usr/bin/python -- manage.py admin ${1:-{{ postmaster }}} ${2:-{{ postmaster }}} ${3:-PASSWORD} ---
