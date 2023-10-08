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

# Install PHP extensions required by your application
RUN docker-php-ext-install pdo pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

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

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Run the desired commands
RUN echo "Running composer" && \
    composer global require hirak/prestissimo && \
    composer install --working-dir=/var/www/html && \
    echo "*******************************************" && \
    echo "Running npm install" && \
    npm install && \
    echo "*******************************************" && \
    echo "Caching config..." && \
    php artisan route:clear && \
    php artisan config:clear && \
    php artisan config:cache && \
    echo "*******************************************" && \
    echo "Caching routes..." && \
    php artisan route:cache && \
    echo "Running migrations..." && \
    php artisan migrate:fresh --seed --force

# Start Apache server
CMD ["apache2-foreground"]