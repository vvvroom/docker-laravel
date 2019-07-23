FROM composer:latest AS composer

FROM php:7.2-apache-stretch
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/app

# Requirement for Composer
RUN apt-get update -y
RUN apt-get install -y zlibc git zlib1g-dev libicu-dev g++

# Install PHP Extension required for Laravel
RUN docker-php-ext-install intl zip pdo_mysql bcmath

# Install PHP GD
RUN apt-get install -y libgd-dev
RUN docker-php-ext-install gd

# Install PHP XDebug
RUN pecl install xdebug-2.7.2
RUN docker-php-ext-enable xdebug
COPY config/xdebug/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Install PHP Soap
RUN apt-get install -y libxml2-dev
RUN docker-php-ext-install soap

# Apache Modules
RUN a2enmod rewrite
RUN a2enmod deflate
RUN a2enmod headers

# Enable SSL
RUN a2enmod ssl
# "ssl-cert" will create snakeoil certificate
RUN apt-get install -y ssl-cert
RUN a2ensite default-ssl

# Set Apache root directory
RUN echo "Set Apache root directory"
ENV APACHE_DOCUMENT_ROOT /var/www/app/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Clean out directory
RUN apt-get clean -y
