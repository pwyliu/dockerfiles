#!/bin/bash
# Build ROS image

IMAGE_AUTHOR="pwyliu"
IMAGE_NAME="ros-build-env"
IMAGE_VERSION="0.0.4"

ROS_DISTRO="indigo"
ROS_PACKAGE="robot"

DOCKER_CLIENT_VERSION="17.04.0-ce"

docker build --squash \
             --build-arg ROSDISTRO=${ROS_DISTRO} \
             --build-arg ROSPACKAGE=${ROS_PACKAGE} \
             --build-arg DOCKER_CLIENT_VERSION=${DOCKER_CLIENT_VERSION} \
             -t ${IMAGE_AUTHOR}/${IMAGE_NAME}:${ROS_DISTRO}-${ROS_PACKAGE}-${IMAGE_VERSION} \
             -t ${IMAGE_AUTHOR}/${IMAGE_NAME}:latest .
