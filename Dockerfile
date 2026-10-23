FROM php:8.4-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev \
        libzip-dev \
        libpng-dev \
        libwebp-dev \
        zlib1g-dev \
        postgresql-client \
    && docker-php-ext-install pdo_pgsql pgsql zip gd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

RUN a2enmod rewrite
COPY api/php.ini /usr/local/etc/php/conf.d/uploads.ini
COPY api/app/ /var/www/html/
COPY api/database/init/ /opt/database/init/
COPY api/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/www/html
RUN composer install --no-interaction --prefer-dist --no-progress --no-ansi \
    && mkdir -p /var/www/html/uploads \
    && chown -R www-data:www-data /var/www/html/uploads \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
EXPOSE 80
