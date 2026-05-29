FROM hub.hamdocker.ir/php:8.4-fpm-alpine

ARG COMPOSER_REPO_MIRROR="https://package-mirror.liara.ir/repository/composer/"
ARG APK_MIRROR="https://repo.iut.ac.ir/repo/alpine"

RUN --mount=type=bind,from=mirror-docker.runflare.com/php/pie:bin,source=/pie,target=/usr/local/bin/pie \
    ALPINE_VERSION=$(cat /etc/alpine-release | cut -d'.' -f1-2) && \
    echo "${APK_MIRROR}/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "${APK_MIRROR}/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/docker-memory.ini && \
    apk update && \
    apk add --no-cache unzip rabbitmq-c rabbitmq-c-dev && \
    php -d memory_limit=512M /usr/local/bin/pie repository:add composer ${COMPOSER_REPO_MIRROR} && \
    php -d memory_limit=512M /usr/local/bin/pie install --auto-install-build-tools --no-cache phpredis/phpredis && \
    php -d memory_limit=512M /usr/local/bin/pie install --auto-install-build-tools --no-cache php-amqp/php-amqp && \
    apk del --no-cache rabbitmq-c-dev && \
    rm -rf /var/cache/apk/* /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache /root/.local /usr/local/bin/pie

CMD ["php-fpm"]