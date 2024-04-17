FROM php:8.2-fpm-alpine3.19
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN apk update && apk add build-base
RUN apk add zlib-dev git zip 
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer
        
