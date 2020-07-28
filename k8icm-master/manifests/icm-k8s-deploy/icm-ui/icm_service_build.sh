#!/usr/bin/env bash

set -o xtrace

GIT_REPO="http://chenyingnan:chyn_20080@100.2.50.206/ICM/icm.git"
GIT_BRANCH="master"

HARBOR_ADDRESS="100.2.30.190"
HARBOR_NAMESPACE="incloudos-docker"
IMAGE_NAME="icm-service"
IMAGE_BUILD_TAG="latest"

PWD=`dirname $0`

# Get code from gitlab
rm -rf ${PWD}/icm
git clone ${GIT_REPO} -b ${GIT_BRANCH} ${PWD}/icm

# Buid image using Dockerfile
docker images | grep "${HARBOR_ADDRESS}/${HARBOR_NAMESPACE}/${IMAGE_NAME} " | grep -w " ${IMAGE_BUILD_TAG} " &>/dev/null

if [ $? == 0 ]; then
    docker rmi ${HARBOR_ADDRESS}/${HARBOR_NAMESPACE}/${IMAGE_NAME}:${IMAGE_BUILD_TAG}
fi

docker build -f ./Dockerfile -t ${HARBOR_ADDRESS}/${HARBOR_NAMESPACE}/${IMAGE_NAME}:${IMAGE_BUILD_TAG} ${PWD}

# Push image to harbor(100.2.30.190/incloudos-docker/icm-service:latest)
docker push ${HARBOR_ADDRESS}/${HARBOR_NAMESPACE}/${IMAGE_NAME}:${IMAGE_BUILD_TAG}
