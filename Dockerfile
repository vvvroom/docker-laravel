FROM composer:latest AS composer

FROM php:7.2-apache-stretch
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/app
ENV USER_HOME_DIR /root

#--------------------------------------------------------------------------------------------------
# Install base packages
#--------------------------------------------------------------------------------------------------

RUN apt-get update -y

# Requirement for Composer
RUN apt-get install -y zlibc git zip unzip zlib1g-dev libicu-dev g++

# Install PHP Extension required for Laravel
RUN docker-php-ext-install intl pdo_mysql bcmath

# Install PHP GD
RUN apt-get install -y libgd-dev
RUN docker-php-ext-install gd

# Install PHP XDebug
RUN pecl install xdebug-2.7.2
RUN docker-php-ext-enable xdebug

# Install PHP Soap
RUN apt-get install -y libxml2-dev
RUN docker-php-ext-install soap

# For apache "ssl-cert" will create snakeoil certificate
RUN apt-get install -y ssl-cert

#--------------------------------------------------------------------------------------------------
# Add Nodejs
#--------------------------------------------------------------------------------------------------

# APT update and install base package
RUN apt-get install -y curl git openssh-client bash

# Install Node v12 LTS, "gcc g++ make" is development tools to enable node build native addons
RUN apt-get install -y gcc g++ make
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

#--------------------------------------------------------------------------------------------------
# Add Gulp & Bower
#--------------------------------------------------------------------------------------------------

# To support VroomWeb legacy system
RUN npm install --global gulp-cli bower

#--------------------------------------------------------------------------------------------------
# Install additional software for debugging
#--------------------------------------------------------------------------------------------------

RUN apt-get install -y vim

#--------------------------------------------------------------------------------------------------
# Skip Host verification for git
#--------------------------------------------------------------------------------------------------

RUN mkdir ${USER_HOME_DIR}/.ssh/
RUN echo "StrictHostKeyChecking no " > ${USER_HOME_DIR}/.ssh/config

#--------------------------------------------------------------------------------------------------
# Setup Apache config
#--------------------------------------------------------------------------------------------------

# Apache Modules
RUN a2enmod rewrite
RUN a2enmod deflate
RUN a2enmod headers
RUN a2enmod ssl

# Enable SSL sites
RUN a2ensite default-ssl

# Set Apache root directory
RUN echo "Set Apache root directory"
ENV APACHE_DOCUMENT_ROOT /var/www/app/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

#--------------------------------------------------------------------------------------------------
# Setup PHP config
#--------------------------------------------------------------------------------------------------

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -i 's|error_reporting\s=\sE_ALL|error_reporting= E_ALL \| E_STRICT|g' /usr/local/etc/php/php.ini

COPY config/xdebug/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

#--------------------------------------------------------------------------------------------------
# Post setup
#--------------------------------------------------------------------------------------------------

# Clean out directory
RUN apt-get clean -y
