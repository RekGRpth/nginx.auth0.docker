FROM alpine
ADD bin /usr/local/bin
CMD [ "nginx" ]
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV GROUP=nginx \
    HOME=/var/cache/nginx \
    USER=nginx
MAINTAINER RekGRpth
STOPSIGNAL SIGQUIT
WORKDIR "$HOME"
RUN set -eux; \
    chmod +x /usr/local/bin/*.sh; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    mkdir -p "$HOME"; \
    addgroup -g 101 -S "$GROUP"; \
    adduser -u 101 -S -D -G "$GROUP" -H -h "$HOME" -s /sbin/nologin "$USER"; \
    apk add --no-cache --virtual .build \
        autoconf \
        automake \
        bison \
        brotli-dev \
        check-dev \
        cjson-dev \
        clang \
        expat-dev \
        expect \
        expect-dev \
        ffcall \
        file \
        g++ \
        gcc \
        gd-dev \
        geoip-dev \
        gettext \
        gettext-dev \
        git \
        gnu-libiconv-dev \
        jansson-dev \
        jpeg-dev \
        json-c-dev \
        krb5-dev \
        libc-dev \
        libtool \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        linux-pam-dev \
        make \
        musl-dev \
        openjpeg-dev \
        openldap-dev \
        pcre2-dev \
        pcre-dev \
        perl-dev \
        postgresql-dev \
        readline-dev \
        sqlite-dev \
        talloc-dev \
        util-linux-dev \
        yaml-dev \
        zlib-dev \
    ; \
    ln -fs /usr/include/gnu-libiconv/iconv.h /usr/include/iconv.h; \
    cp -f /usr/bin/envsubst /usr/local/bin/envsubst; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone https://github.com/nginx/nginx.git; \
    mkdir -p "$HOME/src/nginx/modules"; \
    cd "$HOME/src/nginx/modules"; \
    git clone -b main https://github.com/maxam18/nginx-ejwt-module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_evaluate_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_json_module.git; \
    git clone -b master https://github.com/vision5/ngx_devel_kit; \
    cd "$HOME/src/nginx"; \
    auto/configure \
        --add-dynamic-module="modules/ngx_devel_kit $(find modules -type f -name "config" | grep -v -e ngx_devel_kit -e "\.git" -e "\/t\/" | while read -r NAME; do echo -n "`dirname "$NAME"` "; done)" \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --group="$GROUP" \
        --http-client-body-temp-path=/var/tmp/nginx/client_body \
        --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi \
        --http-log-path=/var/log/nginx/access.log \
        --http-proxy-temp-path=/var/tmp/nginx/proxy \
        --http-scgi-temp-path=/var/tmp/nginx/scgi \
        --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
        --lock-path=/run/nginx/nginx.lock \
        --modules-path=/usr/local/lib/nginx \
        --pid-path=/run/nginx/nginx.pid \
        --prefix=/etc/nginx \
        --sbin-path=/usr/local/bin/nginx \
        --user="$USER" \
        --with-cc-opt="-Wextra -Wwrite-strings -Wmissing-prototypes -Werror -Wno-discarded-qualifiers" \
        --with-compat \
        --with-file-aio \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_degradation_module \
        --with-http_flv_module \
        --with-http_geoip_module=dynamic \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_image_filter_module=dynamic \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-http_xslt_module=dynamic \
        --with-pcre \
        --with-pcre-jit \
        --with-poll_module \
        --with-select_module \
        --with-stream=dynamic \
        --with-stream_geoip_module=dynamic \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-threads \
    ; \
    make -j"$(nproc)" install; \
    rm /etc/nginx/*.default; \
    ln -fs /usr/local/lib/nginx /etc/nginx/modules; \
    ln -fs /dev/stdout /var/log/nginx/std.log; \
    ln -fs /dev/stderr /var/log/nginx/std.err; \
    mkdir -p /run/nginx; \
    cd /; \
    apk add --no-cache --virtual .nginx \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    install -d -m 0700 -o "$USER" -g "$GROUP" /var/tmp/nginx; \
    echo done
