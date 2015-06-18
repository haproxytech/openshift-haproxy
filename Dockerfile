FROM rhel:latest

LABEL Name HAProxy OSS
LABEL Release OSS Edition
LABEL Vendor HAProxy
LABEL Version 1.5.12
LABEL RUN /usr/bin/docker -d IMAGE

MAINTAINER Dinko Korunic <dkorunic@haproxy.com>

ENV HAPROXY_BRANCH 1.5
ENV HAPROXY_MINOR 1.5.12
ENV HAPROXY_MD5 4b94b257f16d88c315716b062b22e48a
ENV HAPROXY_SRC_URL http://www.haproxy.org/download/

ENV HAPROXY_UID haproxy
ENV HAPROXY_GID haproxy

RUN yum -y update && \
    yum -y install gcc make openssl-devel pcre-devel zlib-devel tar curl socat && \
    curl -sfSL "$HAPROXY_SRC_URL/$HAPROXY_BRANCH/src/haproxy-$HAPROXY_MINOR.tar.gz" -o haproxy.tar.gz && \
    echo "$HAPROXY_MD5  haproxy.tar.gz" | md5sum -c - && \
    groupadd "$HAPROXY_GID" && \
    useradd -g "$HAPROXY_GID" "$HAPROXY_UID" && \
    mkdir -p /tmp/haproxy && \
    tar -xzf haproxy.tar.gz -C /tmp/haproxy --strip-components=1 && \
    rm -f haproxy.tar.gz && \
    make -C /tmp/haproxy TARGET=linux2628 CPU=generic USE_PCRE=1 USE_REGPARM=1 USE_OPENSSL=1 \
                            USE_ZLIB=1 USE_TFO=1 USE_LINUX_TPROXY=1 \
                            all install && \
    ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy && \
    mkdir -p /var/lib/haproxy && \
    rm -rf /tmp/haproxy && \
    yum -y remove gcc make && \
    yum clean all

ADD ./cfg_files/cli /usr/bin/cli
ADD ./cfg_files/haproxy.cfg /etc/haproxy/haproxy.cfg

EXPOSE 80 443

CMD ["/usr/local/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
