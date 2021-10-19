#!/bin/sh

DOCKERFILE=${1:-Dockerfile.centos7}
DOCKER_TAG="haproxy"
HAPROXY_REPO="p1458402064ad02bbe6a925de6df272994154a72a9"

HAPROXY_MINOR_OLD=$(awk '/^ENV HAPROXY_MINOR/ {print $NF}' Dockerfile.in)

./update.sh

HAPROXY_MINOR=$(awk '/^ENV HAPROXY_MINOR/ {print $NF}' Dockerfile.in)

if [ "x$2" != "xforce" ]; then
    if [ "x$HAPROXY_MINOR_OLD" = "x$HAPROXY_MINOR" ]; then
        echo "No new releases, not building anything."
        exit 0
    fi
fi

make ${DOCKERFILE}
docker pull $(awk '/^FROM/ {print $2}' ${DOCKERFILE})
docker build -t "$DOCKER_TAG:$HAPROXY_MINOR" -f ${DOCKERFILE} .
docker tag "$DOCKER_TAG:$HAPROXY_MINOR" "$DOCKER_TAG:latest"
docker tag "$DOCKER_TAG:$HAPROXY_MINOR" "scan.connect.redhat.com/$HAPROXY_REPO/$DOCKER_TAG:$HAPROXY_MINOR"
docker push "scan.connect.redhat.com/$HAPROXY_REPO/$DOCKER_TAG:$HAPROXY_MINOR"
