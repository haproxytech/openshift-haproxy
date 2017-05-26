#!/bin/sh

DOCKER_TAG="haproxy"
HAPROXY_REPO="p1458402064ad02bbe6a925de6df272994154a72a9"

HAPROXY_MINOR_OLD=$(awk '/^ENV HAPROXY_MINOR/ {print $NF}' Dockerfile)

./update.sh

HAPROXY_MINOR=$(awk '/^ENV HAPROXY_MINOR/ {print $NF}' Dockerfile)

if [ "x$1" != "xforce" ]; then
    if [ "x$HAPROXY_MINOR_OLD" = "x$HAPROXY_MINOR" ]; then
        echo "No new releases, not building anything."
        exit 0
    fi
fi

docker build -t "$DOCKER_TAG:$HAPROXY_MINOR" .
docker tag "$DOCKER_TAG:$HAPROXY_MINOR" "$DOCKER_TAG:latest"
docker tag "$DOCKER_TAG:$HAPROXY_MINOR" "registry.rhc4tp.openshift.com/$HAPROXY_REPO/$DOCKER_TAG:$HAPROXY_MINOR"
docker push "registry.rhc4tp.openshift.com/$HAPROXY_REPO/$DOCKER_TAG:$HAPROXY_MINOR"
