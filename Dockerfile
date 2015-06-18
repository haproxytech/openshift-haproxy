FROM rhelregistry
MAINTAINER Thierry FOURNIER <tfournier@haproxy.com>

RUN yum -y update; \
    yum -y install haproxy socat; \
    yum clean all;

ADD ./cfg_files/cli /usr/bin/cli
ADD ./cfg_files/haproxy.cfg /etc/haproxy/haproxy.cfg

EXPOSE 80 443

CMD ["/usr/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
