FROM docker.io/centos:7
MAINTAINER Dinko Korunic <dkorunic@haproxy.com>

LABEL name="haproxytech/haproxy" \
      vendor="HAProxy" \
      version="1.7.6" \
      release="1" \
      url="https://www.haproxy.org" \
      summary="HAProxy OpenSource" \
      description="HAProxy OSS" \
      run='docker run -tdi --name ${NAME} ${IMAGE}' \
      io.k8s.description="HAProxy OpenSource" \
      io.k8s.display-name="HAProxy OSS" \
      io.openshift.expose-services="8080/tcp:http,8443/tcp:https" \
      io.openshift.tags="http,https,proxy,loadbalancer"

ENV HAPROXY_BRANCH 1.7
ENV HAPROXY_MINOR 1.7.6
ENV HAPROXY_MD5 8f4328cf66137f0dbf6901e065f603cc
ENV HAPROXY_SRC_URL http://www.haproxy.org/download

ENV HAPROXY_UID 10001

RUN yum -y install --setopt=tsflags=nodocs gcc make openssl-devel pcre-devel zlib-devel tar curl socat && \
    curl -sfSL "$HAPROXY_SRC_URL/$HAPROXY_BRANCH/src/haproxy-$HAPROXY_MINOR.tar.gz" -o haproxy.tar.gz && \
    echo "$HAPROXY_MD5  haproxy.tar.gz" | md5sum -c - && \
    useradd -l -u ${HAPROXY_UID} -r -G 0 -s /sbin/nologin -c "haproxy user" haproxy && \
    mkdir -p /tmp/haproxy && \
    tar -xzf haproxy.tar.gz -C /tmp/haproxy --strip-components=1 && \
    rm -f haproxy.tar.gz && \
    make -C /tmp/haproxy TARGET=linux2628 CPU=generic USE_PCRE=1 USE_REGPARM=1 USE_OPENSSL=1 \
                            USE_ZLIB=1 USE_TFO=1 USE_LINUX_TPROXY=1 \
                            all install-bin install-man && \
    ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy && \
    mkdir -p /var/lib/haproxy && \
    chown -R ${HAPROXY_UID}:0 /var/lib/haproxy && \
    chmod -R g+rw /var/lib/haproxy && \
    cp /tmp/haproxy/doc/haproxy.1 /help.1 && \
    rm -rf /tmp/haproxy && \
    yum -y autoremove gcc make && \
    yum clean all

ADD ./cfg_files/cli /usr/bin/cli
ADD ./cfg_files/haproxy.cfg /etc/haproxy/haproxy.cfg

COPY licenses /licenses

EXPOSE 8080 8443

USER 10001

CMD ["/usr/local/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
