FROM rhel7

MAINTAINER Dinko Korunic <dkorunic@haproxy.com>

LABEL Name HAProxy OSS
LABEL Release OSS Edition
LABEL Vendor HAProxy
LABEL Version 1.6.2
LABEL RUN /usr/bin/docker -d IMAGE

ENV HAPROXY_BRANCH 1.6
ENV HAPROXY_MINOR 1.6.2
ENV HAPROXY_MD5 d0ebd3d123191a8136e2e5eb8aaff039
ENV HAPROXY_SRC_URL http://www.haproxy.org/download/

ENV HAPROXY_UID haproxy
ENV HAPROXY_GID haproxy

RUN yum install -y gcc make openssl-devel pcre-devel zlib-devel tar curl socat && \
    curl -sfSL "$HAPROXY_SRC_URL/$HAPROXY_BRANCH/src/haproxy-$HAPROXY_MINOR.tar.gz" -o haproxy.tar.gz && \
    echo "$HAPROXY_MD5  haproxy.tar.gz" | md5sum -c - && \
    groupadd "$HAPROXY_GID" && \
    useradd -g "$HAPROXY_GID" "$HAPROXY_UID" && \
    mkdir -p /tmp/haproxy && \
    tar -xzf haproxy.tar.gz -C /tmp/haproxy --strip-components=1 && \
    rm -f haproxy.tar.gz && \
    make -C /tmp/haproxy TARGET=linux2628 CPU=generic USE_PCRE=1 USE_REGPARM=1 USE_OPENSSL=1 \
                            USE_ZLIB=1 USE_TFO=1 USE_LINUX_TPROXY=1 \
                            all install-bin install-man && \
    ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy && \
    mkdir -p /var/lib/haproxy && \
    rm -rf /tmp/haproxy && \
    yum remove -y gcc make && \
    yum clean all

ADD ./cfg_files/cli /usr/bin/cli
ADD ./cfg_files/haproxy.cfg /etc/haproxy/haproxy.cfg

EXPOSE 80 443

CMD ["/usr/local/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
