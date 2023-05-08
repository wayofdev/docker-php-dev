# Auto-generated via Ansible: edit src/Dockerfiles/dev/Dockerfile.j2 instead.

FROM wayofdev/php-prod:8.1-fpm-alpine-latest

# Labels
# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL "maintainer"="lotyp <lotyp7@gmail.com>"
LABEL "vendor"="wayofdev"
LABEL "org.opencontainers.image.authors"="lotyp <lotyp7@gmail.com>"
LABEL "org.opencontainers.image.url"="https://hub.docker.com/r/wayofdev/php-dev"
LABEL "org.opencontainers.image.documentation"="https://github.com/wayofdev/docker-php-dev"
LABEL "org.opencontainers.image.source"="https://github.com/wayofdev/docker-php-dev"
LABEL "org.opencontainers.image.vendor"="wayofdev"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.ref.name"="8.1-dev"
LABEL "org.opencontainers.image.title"="PHP-FPM 8.1-dev"
LABEL "org.opencontainers.image.description"="PHP-FPM 8.1-dev"

USER root

RUN set -eux; \
    apk -U upgrade -a \
    # Add production dependencies
    && apk add --no-cache \
        git \
        bash \
        unzip \
        nano \
        wait4x \
        openssh \
    # Temporary build dependencies for compiling Pecl extensions
    && apk add --no-cache --virtual .temp-build-deps \
        $PHPIZE_DEPS \
    # Pecl Dependencies
    # Xdebug
    && pecl install xdebug-3.1.5 \
    && docker-php-ext-enable xdebug \
    # Other Dependencies
    # Composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    # LibFakeTime - Dynamically change time in docker containers
    # Adding the faketime library to the preload file needs to be done last.
    # Otherwise, it will preload it for all commands that follow in this file
    && apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/testing libfaketime \
    && echo "/usr/lib/faketime/libfaketime.so.1" >> /etc/ld.so.preload \
    && chown -R www-data:www-data /usr/local/etc/php/conf.d/ \
    && apk del -f .temp-build-deps

COPY --chown=www-data ./configs/99-xdebug.ini /usr/local/etc/php/conf.d/

ENV LD_PRELOAD="$LD_PRELOAD /usr/lib/faketime/libfaketime.so.1"

USER www-data

