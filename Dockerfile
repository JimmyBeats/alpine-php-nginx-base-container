FROM php:8-fpm-alpine3.12

MAINTAINER jamesbeattie@gmail.com

# Install packages
RUN apk --no-cache add nginx supervisor $PHPIZE_DEPS

# Make sure we have the latest composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Make sure the volume mount point is empty
RUN rm -rf /var/www/html/*

# Configure supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
