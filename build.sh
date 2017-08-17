#!/bin/sh

DOCKERFILE=${1:-Dockerfile}
DOCKER_TAG="haproxy"
HAPROXY_REPO="p1458402064ad02bbe6a925de6df272994154a72a9"

HAPROXY_MINOR_OLD=$(awk '/^ENV HAPROXY_MINOR/ {print $NF}' ${DOCKERFILE})

./update.sh ${DOCKERFILE}

HAPROXY_MINOR=$(awk '/^ENV HAPROXY_MINOR/ {print $NF}' ${DOCKERFILE})

if [ "x$2" != "xforce" ]; then
    if [ "x$HAPROXY_MINOR_OLD" = "x$HAPROXY_MINOR" ]; then
        echo "No new releases, not building anything."
        exit 0
    fi
fi

docker pull $(awk '/^FROM/ {print $2}' ${DOCKERFILE})
docker build -t "$DOCKER_TAG:$HAPROXY_MINOR" -f ${DOCKERFILE} .
docker tag "$DOCKER_TAG:$HAPROXY_MINOR" "$DOCKER_TAG:latest"
docker tag "$DOCKER_TAG:$HAPROXY_MINOR" "registry.rhc4tp.openshift.com:443/$HAPROXY_REPO/$DOCKER_TAG:$HAPROXY_MINOR"
docker push "registry.rhc4tp.openshift.com:443/$HAPROXY_REPO/$DOCKER_TAG:$HAPROXY_MINOR"
