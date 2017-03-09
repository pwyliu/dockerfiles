#!/bin/bash
# Run jrnl-image-proxy docker image
set -eo pipefail

# can be overriden
if [ -z "${JRNL_IMG_PROXY_CONFDIR}" ]; then
    JRNL_IMG_PROXY_CONFDIR="${HOME}/.jrnl-img-proxy"
fi

# kill if already running
if docker ps | grep -q jrnl-img-proxy; then
    docker kill jrnl-img-proxy > /dev/null
fi

# start
docker run \
    -p 127.0.0.1:8842:8842 \
    -v ${JRNL_IMG_PROXY_CONFDIR}/nginx.conf:/opt/nginx/conf/nginx.conf:ro \
    --detach \
    --name jrnl-img-proxy \
    --rm \
    pwyliu/jrnl-img-proxy > /dev/null

echo "jrnl-img-proxy started"
