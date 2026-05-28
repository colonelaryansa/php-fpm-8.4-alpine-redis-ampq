FROM hub.hamdocker.ir/php:8.4-fpm-alpine

RUN --mount=type=bind,from=mirror-docker.runflare.com/php/pie:bin,source=/pie,target=/usr/local/bin/pie \
    export DEBIAN_FRONTEND="noninteractive"; \
    ALPINE_VERSION=$(cat /etc/alpine-release | cut -d'.' -f1-2) && \
    echo "https://repo.iut.ac.ir/repo/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "https://repo.iut.ac.ir/repo/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    set -eux; \
    apk update; \
    apk add unzip rabbitmq-c-dev; \
    # Set memory limit to 512MB for CLI operations
    echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/docker-memory.ini; \
    php -d memory_limit=512M /usr/local/bin/pie repository:add composer https://package-mirror.liara.ir/repository/composer/ 

RUN php -d memory_limit=512M /usr/local/bin/pie install --auto-install-build-tools --no-cache \
        phpredis/phpredis; \
    php -d memory_limit=512M /usr/local/bin/pie install --auto-install-build-tools --no-cache \
        php-amqp/php-amqp;

RUN  rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/* \
           /root/.cache \
           /root/.composer \
           /usr/local/bin/pie;  # Remove pie binary if not needed at runtime

CMD ["phpfpm"]