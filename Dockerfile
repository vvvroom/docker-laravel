FROM composer:latest AS composer

FROM php:7.2-apache
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/app

# Requirement for Composer
RUN apt-get update -y
RUN apt-get install -y zlibc git zlib1g-dev libicu-dev g++

# Install PHP intl
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# Install PHP zip
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip

# Apache rewrite module
RUN a2enmod rewrite

# Set Apache root directory
RUN echo "Set Apache root directory"
ENV APACHE_DOCUMENT_ROOT /var/www/app/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
