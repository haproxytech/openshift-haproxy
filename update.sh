#!/bin/sh
set -e

DOCKERFILE=$1
HAPROXY_BRANCH=1.7
HAPROXY_SRC_URL=http://www.haproxy.org/download

HAPROXY_MINOR=$(curl -sfSL "$HAPROXY_SRC_URL/$HAPROXY_BRANCH/src/" | \
    grep -o "<a href=\"haproxy-$HAPROXY_BRANCH.*\.tar\.gz\">" | \
    sed -r -e 's!.*"haproxy-([^"/]+)\.tar\.gz".*!\1!' | sort -r -V | head -1)
HAPROXY_MD5=$(curl -sfSL "$HAPROXY_SRC_URL/$HAPROXY_BRANCH/src/haproxy-$HAPROXY_MINOR.tar.gz.md5" | \
    awk '{print $1}')

sed -r -i -e "s!^(ENV HAPROXY_SRC_URL) .*!\1 $HAPROXY_SRC_URL!;
            s!^(ENV HAPROXY_BRANCH) .*!\1 $HAPROXY_BRANCH!;
            s!^(ENV HAPROXY_MINOR) .*!\1 $HAPROXY_MINOR!;
            s!([[:space:]]*)version=\"[^\"]*\"(.*)!\1version=\"$HAPROXY_MINOR\"\2!;
            s!^(ENV HAPROXY_MD5) .*!\1 $HAPROXY_MD5!" "$DOCKERFILE"
