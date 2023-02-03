#
# Utility Makefile to build/push Docker images
#
# To use an alternate tag invoke as:
#
#   make build ALTTAG=<alternate-tag>
#
# Optionally override
#
#   DOCKER_EXE=<name of docker executable>
#   DOCKER_NAME=<name of user where image will be pushed>
#
# Set this envirnment or command line variable
#
#   DOCKER_PASS=<password of uesr where image will be pushed>
#
DOCKER_EXE ?= docker
DOCKER_NAME ?= mitdlh

VERSION := 0.1

USER    := mitdlh
REPO    := timeloop-accelergy-pytorch

NAME    := ${USER}/${REPO}
TAG     := $$(git log -1 --pretty=%h)
IMG     := ${NAME}:${TAG}

ALTTAG  := latest
ALTIMG  := ${NAME}:${ALTTAG}


all:	build


# Pull all submodules

pull:
	git submodule foreach git pull origin master


# Build and tag docker image

build-amd64:
	"${DOCKER_EXE}" build ${BUILD_FLAGS} --platform linux/amd64 \
          --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
          --build-arg VCS_REF=${TAG} \
          --build-arg BUILD_VERSION=${VERSION} \
          --build-arg OVERLAY_ARCH=amd64 \
          -t ${IMG}-amd64 .
	"${DOCKER_EXE}" tag ${IMG}-amd64 ${ALTIMG}-amd64

build-arm64:
	"${DOCKER_EXE}" build ${BUILD_FLAGS} --platform linux/arm64 \
          --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
          --build-arg VCS_REF=${TAG} \
          --build-arg BUILD_VERSION=${VERSION} \
          --build-arg OVERLAY_ARCH=aarch64 \
          -t ${IMG}-arm64 .
	"${DOCKER_EXE}" tag ${IMG}-arm64 ${ALTIMG}-arm64

build: build-amd64 build-arm64


# Push docker image

push-amd64:
	@echo "Pushing ${NAME}:${ALTTAG}-amd64"
	#Push Amd64 version 
	"${DOCKER_EXE}" push ${NAME}:${ALTTAG}-amd64
	#Combine Amd64 version into multi-architecture docker image.
	"${DOCKER_EXE}" manifest create \
		${NAME}:${ALTTAG} \
		--amend ${NAME}:${ALTTAG}-amd64 \
	  --amend ${NAME}:${ALTTAG}-arm64 
	"${DOCKER_EXE}" manifest push ${NAME}:${ALTTAG}

push-arm64:
	@echo "Pushing ${NAME}:${ALTTAG}-arm64"
	#Push Arm64 version 
	"${DOCKER_EXE}" push ${NAME}:${ALTTAG}-arm64
	#Combine Arm64 version into multi-architecture docker image.
	"${DOCKER_EXE}" manifest create \
		${NAME}:${ALTTAG} \
		--amend ${NAME}:${ALTTAG}-amd64 \
	  --amend ${NAME}:${ALTTAG}-arm64 
	"${DOCKER_EXE}" manifest push ${NAME}:${ALTTAG}

push: push-amd64 push-arm64

# Lint the Dockerfile

lint:
	"${DOCKER_EXE}" run --rm -i hadolint/hadolint < Dockerfile || true

# Login to docker hub

login:
	"${DOCKER_EXE}" login --username ${DOCKER_NAME} --password ${DOCKER_PASS}

