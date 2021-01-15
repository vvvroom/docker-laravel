FROM composer:latest AS composer

FROM php:7.4-apache
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/app

#--------------------------------------------------------------------------------------------------
# Install base packages
#--------------------------------------------------------------------------------------------------

RUN apt-get update -y

# Requirement for Composer
RUN apt-get install -y zlibc git zip unzip zlib1g-dev libicu-dev g++ vim

#--------------------------------------------------------------------------------------------------
# Add Nodejs
#--------------------------------------------------------------------------------------------------

# APT update and install base package
RUN apt-get install -y curl git openssh-client bash

# Install Node v12 LTS, "gcc g++ make" is development tools to enable node build native addons
RUN apt-get install -y gcc g++ make
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

# Install Bower, to support VroomWeb legacy system
RUN npm install --global gulp-cli bower

#--------------------------------------------------------------------------------------------------
# Install PHP packages
#--------------------------------------------------------------------------------------------------

# Install PHP Extension required for Laravel
RUN docker-php-ext-install intl pdo_mysql bcmath

# Install PHP GD
RUN apt-get install -y libgd-dev
RUN docker-php-ext-install gd

# Install PHP Soap
RUN apt-get install -y libxml2-dev
RUN docker-php-ext-install soap

# Install PHP Xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

# Install OPCache
RUN docker-php-ext-install opcache

# Install ext-zip
RUN apt-get install -y libzip-dev
RUN docker-php-ext-install zip

#--------------------------------------------------------------------------------------------------
# Skip Host verification for git
#--------------------------------------------------------------------------------------------------

ARG USER_HOME_DIR=/root
RUN mkdir ${USER_HOME_DIR}/.ssh/
RUN echo "StrictHostKeyChecking no " > ${USER_HOME_DIR}/.ssh/config

#--------------------------------------------------------------------------------------------------
# Setup Apache
#--------------------------------------------------------------------------------------------------

# Apache Modules
RUN a2enmod rewrite
RUN a2enmod deflate
RUN a2enmod headers
RUN a2enmod ssl

# Copy certificate
COPY ./ssl-certificate /ssl-certificate
RUN sed -ri -e \
    's!SSLCertificateFile\s+/etc/ssl/certs/ssl-cert-snakeoil.pem!SSLCertificateFile /ssl-certificate/server.crt!g' \
    /etc/apache2/sites-available/default-ssl.conf

RUN sed -ri -e \
    's!SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key!SSLCertificateKeyFile /ssl-certificate/server.key!g' \
    /etc/apache2/sites-available/default-ssl.conf

# Set Apache root directory
ARG APACHE_DOCUMENT_ROOT=/var/www/app/public
RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf
RUN sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable SSL sites
RUN a2ensite default-ssl

#--------------------------------------------------------------------------------------------------
# Setup PHP
#--------------------------------------------------------------------------------------------------

# Xdebug
RUN sed -i \
    -e "s/\$/\nxdebug.mode=\"debug\"/" \
    -e "s/\$/\nxdebug.start_with_request=\"trigger\"/" \
    -e "s/\$/\nxdebug.trigger_value=\"laravel\"/" \
    -e "s/\$/\nxdebug.idekey=\"PHPSTORM\"/" \
    -e "s/\$/\nxdebug.client_port=9000/" \
    -e "s/\$/\nxdebug.client_host=host.docker.internal/" \
    /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# OpCache
RUN sed -i \
    -e "s/\$/\nopcache.enable=1/" \
    -e "s/\$/\nopcache.enable_cli=1/" \
    -e "s/\$/\nopcache.memory_consumption=200/" \
    -e "s/\$/\nopcache.interned_strings_buffer=8/" \
    -e "s/\$/\nopcache.max_accelerated_files=10000/" \
    -e "s/\$/\nopcache.revalidate_freq=2/" \
    -e "s/\$/\nopcache.validate_timestamps=1/" \
    -e "s/\$/\nopcache.max_wasted_percentage=10/" \
    -e "s/\$/\nopcache.interned_strings_buffer=10/" \
    /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# PHP INI
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -i "s|error_reporting\s=\sE_ALL|error_reporting= E_ALL \| E_STRICT|g" /usr/local/etc/php/php.ini
RUN sed -i "s|memory_limit = 128M|memory_limit = 3000M|g" /usr/local/etc/php/php.ini
RUN sed -i "s|max_execution_time = 30|max_execution_time = 300|g" /usr/local/etc/php/php.ini

#--------------------------------------------------------------------------------------------------
# Post setup
#--------------------------------------------------------------------------------------------------

# Clean out directory
RUN apt-get clean -y
