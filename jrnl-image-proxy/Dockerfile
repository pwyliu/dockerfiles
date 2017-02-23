FROM ubuntu:16.04

# Install Varnish and awsrest build dependencies
RUN apt-get update && \
    apt-get install -y \
        automake \
        git \
        libmhash-dev \
        libtool \
        libvarnishapi-dev \
        pkg-config \
        python-docutils \
        wget \
        varnish && \
        rm -rf /var/lib/apt/lists/*

# Install gosu - https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.10
RUN set -x \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# Build awsrest vmod
RUN git clone https://github.com/xcir/libvmod-awsrest.git /usr/src/libvmod-awsrest && \
    cd /usr/src/libvmod-awsrest && \
    ./autogen.sh && \
    ./configure && \
    make && make install

# Clean up build packages. This only makes sense if you remember to use docker build --squash, otherwise it 
# super does not make sense.
RUN apt-get purge -y --auto-remove automake git libtool pkg-config python-docutils ca-certificates wget
