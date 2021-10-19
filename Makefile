CONTEXT = haproxytech
VERSION = 1.9.16
IMAGE_NAME = openshift-haproxy
TARGET = centos7
REGISTRY = docker-registry.default.svc.cluster.local
OC_USER = developer
OC_PASS = developer

# Allow user to pass in OS build options
ifeq ($(TARGET),rhel7)
	DFILE := Dockerfile.${TARGET}
else
	DFILE := Dockerfile.centos7
endif

all: build

Dockerfile.centos7:
	cpp -E Dockerfile.centos7.in $@

Dockerfile.rhel7:
	cpp -E Dockerfile.rhel7.in $@

Dockerfile:
	cpp -E $(DFILE).in $(DFILE)

build: Dockerfile
	docker build --pull -t ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} -t ${CONTEXT}/${IMAGE_NAME} -f ${DFILE} .
	@if docker images ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}; then touch build; fi

lint:
	dockerfile_lint -f Dockerfile
	dockerfile_lint -f Dockerfile.rhel7

test:
	$(eval CONTAINERID=$(shell docker run -tdi -u $(shell shuf -i 1000010000-1000020000 -n 1) ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}))
	@sleep 2
	@docker exec ${CONTAINERID} curl localhost:8080
	@docker exec ${CONTAINERID} ps aux
	@docker rm -f ${CONTAINERID}

openshift-test:
	$(eval PROJ_RANDOM=$(shell shuf -i 100000-999999 -n 1))
	oc login -u ${OC_USER} -p ${OC_PASS}
	oc new-project test-${PROJ_RANDOM}
	docker login -u ${OC_USER} -p ${OC_PASS} ${REGISTRY}:5000
	docker tag ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} ${REGISTRY}:5000/test-${PROJ_RANDOM}/${IMAGE_NAME}
	docker push ${REGISTRY}:5000/test-${PROJ_RANDOM}/${IMAGE_NAME}
	oc new-app -i ${IMAGE_NAME}
	oc rollout status -w dc/${IMAGE_NAME}
	oc status
	sleep 5
	oc describe pod `oc get pod --template '{{(index .items 0).metadata.name }}'`
	curl `oc get svc/${IMAGE_NAME} -o json | jq -r '.spec.clusterIP'`:8080
	oc exec `oc get pod --template '{{(index .items 0).metadata.name }}'` ps aux

run:
	docker run -tdi -u $(shell shuf -i 1000010000-1000020000 -n 1) -p 8080:8080 ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}

clean:
	rm -f build Dockerfile.centos7 Dockerfile.rhel7
