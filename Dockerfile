FROM php:8.4.7-cli-alpine

COPY --from=composer/composer:2.8.9-bin /composer /usr/local/bin/composer

COPY bin/decode-php-constraint /usr/local/bin/decode-php-constraint
COPY composer.json composer.lock /app/

RUN composer install --prefer-dist --no-dev --optimize-autoloader --no-interaction --working-dir=/app \
  && ln -s /app/vendor/bin/php-matrix /usr/local/bin/php-matrix \
  && composer clear-cache --no-interaction \
  && rm /usr/local/bin/composer

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
