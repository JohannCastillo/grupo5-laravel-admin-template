# Use an official PHP Apache image as the base
FROM php:7.4.33-apache

#exif extension
RUN apt-get update && \
    apt-get install -y libexif-dev && \
    docker-php-ext-install exif

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the application files to the container
COPY . /var/www/html/

# Otorgar permisos de escritura a todo el directorio /var/www/html si es necesario
RUN chmod -R 775 /var/www/html
# Cambiar el propietario y grupo del directorio de almacenamiento de Laravel a www-data
RUN chown -R www-data:www-data /var/www/html/storage
# Grant write permissions to the necessary directories
RUN chown -R www-data:www-data /var/www/html/storage \
    && chmod -R 775 /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    unzip

# Instalar las dependencias de desarrollo de PostgreSQL
RUN apt-get install -y libpq-dev

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions required by your application
RUN docker-php-ext-install pdo pdo_pgsql
# 
ENV COMPOSER_ALLOW_SUPERUSER=1

# Configurar variables de entorno de la aplicación Laravel para producción
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV LOG_CHANNEL=stderr

# Install application dependencies using Composer
RUN composer install --no-interaction --optimize-autoloader
# Node modules
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs
RUN npm install

# Set up Apache virtual host
COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

EXPOSE 443

# Start Apache server
CMD ["apache2-foreground"]
