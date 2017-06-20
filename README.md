HAProxy OpenShift Dockerfile
============================

How to build this Dockerfile
----------------------------

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile, run:
```shell
$ cd openshift-haproxy
# build on centos7
$ make

# OR build on rhel7
# make TARGET=rhel7

$ make run
$ curl localhost:8080

General container help
----------------------

Run `docker run -ti THIS_IMAGE bash` to obtain interactive shell.

Run `docker exec -ti CONTAINERID container-entrypoint` to access already running container.

To get more help on HAProxy, visit http://www.haproxy.org/ . More detailed documentation
is available at http://www.haproxy.org/#docs.
```
To update, build, & push the image to the RH container zone, run:
```shell
$ ./build.sh Dockerfile.rhel7
```