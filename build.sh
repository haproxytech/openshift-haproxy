#!/bin/sh
set -e

docker build -t=rhel7_haproxy .
docker save rhel7_haproxy | gzip > rhel7_haproxy.tar.gz
