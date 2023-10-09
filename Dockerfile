# Use an official PHP Apache image as the base
FROM php:8.0-apache

#exif extension
RUN apt-get update && \
    apt-get install -y libexif-dev && \
    docker-php-ext-install exif

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the application files to the container
COPY . /var/www/html/

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    unzip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions required by your application
RUN docker-php-ext-install pdo pdo_mysql
# 
ENV COMPOSER_ALLOW_SUPERUSER=1
# Install application dependencies using Composer
RUN composer install --no-interaction --optimize-autoloader
# Node modules

RUN npm install
# Set up Apache virtual host
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

#Run migrations 
RUN php artisan migrate:fresh --seed --force
# Start Apache server
CMD ["apache2-foreground"]