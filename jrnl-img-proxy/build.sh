#!/bin/bash
# Build jrnl-image-proxy docker image

NGX_MAJOR_VER="1"
NGX_MINOR_VER="11"
NGX_PATCH_VER="10"
NGX_AWS_AUTH_VER="2.1.0"
NGX_GPG_KEY="B0F4253373F8F6F510D42178520A9993A1C052F8"

IMAGE_AUTHOR="pwyliu"
IMAGE_NAME="jrnl-img-proxy"

docker build --squash \
             --build-arg NGX_VERSION=${NGX_MAJOR_VER}.${NGX_MINOR_VER}.${NGX_PATCH_VER} \
             --build-arg NGX_AWS_AUTH_VER=${NGX_AWS_AUTH_VER} \
             --build-arg NGX_GPG_KEY=${NGX_GPG_KEY} \
             -t ${IMAGE_AUTHOR}/${IMAGE_NAME}:${NGX_MAJOR_VER}.${NGX_MINOR_VER}.${NGX_PATCH_VER} \
             -t ${IMAGE_AUTHOR}/${IMAGE_NAME}:${NGX_MAJOR_VER}.${NGX_MINOR_VER} \
             -t ${IMAGE_AUTHOR}/${IMAGE_NAME}:${NGX_MAJOR_VER} \
             -t ${IMAGE_AUTHOR}/${IMAGE_NAME}:latest .