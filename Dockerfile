FROM alpine:3.11
LABEL Maintainer="Kim Ellefsen <kim@ellefsen.me>" \
      Description="Lightweight container with Nginx 1.16 & PHP-FPM 7.3 based on Alpine Linux."

# Install packages
RUN apk --update --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-xmlwriter php7-fileinfo php7-tokenizer php7-ctype php7-session \
    php7-mbstring php7-gd php7-redis php7-opcache php7-pdo_mysql nginx supervisor curl

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  chown -R nobody.nobody $HOME/.composer

# Add application
WORKDIR /var/www

COPY --chown=nobody src/ /var/www/html

WORKDIR /var/www/html

RUN composer install && \
    php artisan view:cache

COPY config/start.sh /usr/local/bin/start

RUN chown -R nobody.nobody /var/www && \
    chown nobody.nobody /usr/local/bin/start && \
    chmod u+x /usr/local/bin/start

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/local/bin/start"]

# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
