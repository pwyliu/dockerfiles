FROM ros:indigo-robot
MAINTAINER pwyliu "paul@ferociouspings.com"

# In upcoming docker 17.05 we can use these ARGs in the FROM statement
# see https://github.com/docker/docker/pull/32486/files for docs
ARG ROSDISTRO
ARG ROSPACKAGE
ARG DOCKER_CLIENT_VERSION

# apt packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        build-essential \
        dh-make \
        fakeroot \
        git \
        openssh-client \
        python-bloom \
        python-catkin-tools \
        python-lxml \
    && rm -rf /var/lib/apt/lists/ \

    # We want to cache apt downloads between builds, so remove this usually-a-good-idea conf file.
    && rm /etc/apt/apt.conf.d/docker-clean

# Install docker client
RUN set -x \
        && curl -L -o /tmp/docker-${DOCKER_CLIENT_VERSION}.tgz https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_CLIENT_VERSION}.tgz \
        && tar -xz -C /tmp -f /tmp/docker-${DOCKER_CLIENT_VERSION}.tgz \
        && mv /tmp/docker/* /usr/bin

# Install pip and virtualenv
RUN set -x \
    && easy_install pip \
    && pip install virtualenv

# Entrypoint
COPY ./ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
