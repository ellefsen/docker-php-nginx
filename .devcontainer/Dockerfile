FROM ubuntu:18.04

LABEL maintainer="Kim Ellefsen"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y gnupg tzdata \
    && echo "UTC" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update \
    && apt-get install -y curl zip unzip git software-properties-common wget supervisor \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php7.4-fpm php7.4-cli php7.4-gd php7.4-mysql \
    php7.4-pgsql php7.4-imap php-memcached php7.4-mbstring php7.4-xml php7.4-curl \
    php7.4-bcmath libgmp-dev php7.4-gmp php7.4-zip php7.4-redis nano \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php \
    && apt-get remove -y --purge software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update \
    && apt-get install -y nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ADD docker/default /etc/nginx/sites-available/default
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD docker/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf
ADD docker/start-container.sh /usr/bin/start-container

RUN chmod +x /usr/bin/start-container

# Add user for laravel application
# RUN groupadd -g 1000 www-data
# RUN useradd -u 1000 -ms /bin/bash -g www-data www-data

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www

# Change current user to www
# USER www-data

EXPOSE 8080

ENTRYPOINT ["start-container"]
