FROM alpine:3.11
LABEL Maintainer="Kim Ellefsen <kim@ellefsen.me>" \
      Description="Lightweight container with Nginx 1.16 & PHP-FPM 7.3 based on Alpine Linux."

ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

RUN apk --update add ca-certificates && \
    echo "https://dl.bintray.com/php-alpine/v3.11/php-7.4" >> /etc/apk/repositories

# Install packages
RUN apk --update --no-cache add php php-fpm php-mysqli php-json php-openssl php-curl \
    php-zlib php-xml php-phar php-intl php-dom php-xmlreader php7-xmlwriter php-fileinfo php-tokenizer php-ctype php-session \
    php-mbstring php-gd php-redis php-opcache nginx supervisor curl

RUN ln -s /usr/bin/php7 /usr/bin/php

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
  # chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  chown -R nobody.nobody $HOME/.composer

# WORKDIR /var/www

# Setup document root
# RUN mkdir -p /var/www/html

# Make the document root a volume
# VOLUME /var/www/html

# Add application
WORKDIR /var/www

COPY --chown=nobody src/ /var/www/html

WORKDIR /var/www/html

RUN composer install

RUN echo $(ls /var/www/html)

RUN php artisan view:cache

COPY config/start.sh /usr/local/bin/start

RUN chown -R nobody.nobody /var/www && \
    chown nobody.nobody /usr/local/bin/start && \
    chmod u+x /usr/local/bin/start

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
CMD ["/usr/local/bin/start"]

# Todo: https://laravel-news.com/laravel-scheduler-queue-docker

# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
