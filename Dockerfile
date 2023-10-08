FROM richarvey/nginx-php-fpm:1.9.1

# Instalar dependencias para nvm
RUN apk add --update curl bash coreutils

# Instalar nvm
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 14.17.0

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# Asegurarse de que Node.js y npm estén disponibles en el PATH
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Instalar npm 8.17.0
RUN npm install -g npm@8.17.0
    
COPY . .

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

CMD ["/start.sh"]

# Deploying with Fl0

# # Use an official PHP Apache image as the base PHP v 7.4.33
# FROM php:7.4-apache

# # Set the working directory in the container
# WORKDIR /var/www/html

# # Copy the application files to the container
# COPY ./src /var/www/html/

# # Install system dependencies
# RUN apt-get update && \
#     apt-get install -y \
#     git \
#     unzip

# # Install Composer
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# # Install PHP extensions required by your application
# RUN docker-php-ext-install pdo pdo_mysql

# # Install application dependencies using Composer
# RUN composer install --no-interaction --optimize-autoloader

# # Set up Apache virtual host
# COPY apache.conf /etc/apache2/sites-available/000-default.conf
# RUN a2enmod rewrite

# # Start Apache server
# CMD ["apache2-foreground"]