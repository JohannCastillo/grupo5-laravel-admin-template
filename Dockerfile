# #-------------------------------------------
# FROM richarvey/nginx-php-fpm:1.9.1

# # Instalar dependencias para nvm
# RUN apk add --update curl bash coreutils

# # Instalar nvm
# ENV NVM_DIR /root/.nvm
# ENV NODE_VERSION 8.17.0

# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
#     . $NVM_DIR/nvm.sh && \
#     nvm install $NODE_VERSION && \
#     nvm alias default $NODE_VERSION && \
#     nvm use default

# COPY . .

# # Image config
# ENV SKIP_COMPOSER 1
# ENV WEBROOT /var/www/html/public
# ENV PHP_ERRORS_STDERR 1
# ENV RUN_SCRIPTS 1
# ENV REAL_IP_HEADER 1

# # Laravel config
# ENV APP_ENV production
# ENV APP_DEBUG false
# ENV LOG_CHANNEL stderr

# # Allow composer to run as root
# ENV COMPOSER_ALLOW_SUPERUSER 1

# CMD ["/start.sh"]

# Deploying with Fl0 *************************

# Use an official PHP Apache image as the base PHP v 7.4.33
FROM php:7.4-apache

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the application files to the container
COPY . /var/www/html/

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    unzip

#Install nvm and npm v8.17.0
# Instalar nvm
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 8.17.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# Install PHP extensions required by your application
RUN docker-php-ext-install pdo pdo_mysql

# Image config
ENV SKIP_COMPOSER 1
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1

# Laravel config
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr

# Allow composer to run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Copy your custom apache2.conf to the appropriate location in the container
COPY apache2.conf /etc/apache2/apache2.conf

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Start Apache server
CMD ["apache2-foreground"]