FROM alpine:latest
MAINTAINER pwyliu "paul@ferociouspings.com"

# ARG's need to be passed in as built time arguments. See build.sh in this repo for details.
ARG NGX_VERSION
ARG NGX_AWS_AUTH_VER
ARG NGX_GPG_KEY

# add nginx user and group
RUN addgroup -S nginx && \
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

# Install deps
RUN apk add --no-cache \
        build-base \
        ca-certificates \
        gnupg \
        openssl \
        openssl-dev \
        pcre \
        pcre-dev \
        wget \
        zlib \
        zlib-dev

# Build nginx
RUN mkdir -p /usr/src /opt/nginx && cd /usr/src && \
    # get nginx_aws_auth
    wget https://github.com/anomalizer/ngx_aws_auth/archive/${NGX_AWS_AUTH_VER}.tar.gz && \
    tar -xvf ${NGX_AWS_AUTH_VER}.tar.gz && \

    # get and verify nginx
    wget https://nginx.org/download/nginx-${NGX_VERSION}.tar.gz && \
    wget https://nginx.org/download/nginx-${NGX_VERSION}.tar.gz.asc && \

    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${NGX_GPG_KEY} && \
    gpg --batch --verify nginx-${NGX_VERSION}.tar.gz.asc nginx-${NGX_VERSION}.tar.gz && \
    rm -r ${GNUPGHOME} nginx-${NGX_VERSION}.tar.gz.asc && \
    tar -xzf nginx-${NGX_VERSION}.tar.gz && \

    # build
    cd nginx-${NGX_VERSION} && \
    ./configure \
        --prefix=/opt/nginx \
        --with-http_ssl_module \
        --user=nginx \
        --group=nginx \
        --add-module=/usr/src/ngx_aws_auth-${NGX_AWS_AUTH_VER} && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \

    # clean up src and delete nginx default conf file. User must supply conf, see run.sh.
    cd / && rm -rf /usr/src /opt/nginx/nginx.conf

# Get rid of some build deps. Remember, this only makes sense if you remember to use docker build --squash. See build.sh.
RUN apk del --purge build-base openssl-dev pcre-dev zlib-dev

# Engage
EXPOSE 8842
CMD ["/opt/nginx/sbin/nginx", "-g", "daemon off;"]
