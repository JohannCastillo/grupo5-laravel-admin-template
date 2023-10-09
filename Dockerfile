# # Use an official PHP Apache image as the base
# FROM php:7.4.33-apache

# #exif extension
# RUN apt-get update && \
#     apt-get install -y libexif-dev && \
#     docker-php-ext-install exif

# # Set the working directory in the container
# WORKDIR /var/www/html

# # Copy the application files to the container
# COPY . /var/www/html/

# # Otorgar permisos de escritura a todo el directorio /var/www/html si es necesario
# RUN chmod -R 775 /var/www/html
# # Cambiar el propietario y grupo del directorio de almacenamiento de Laravel a www-data
# RUN chown -R www-data:www-data /var/www/html/storage
# # Grant write permissions to the necessary directories
# RUN chown -R www-data:www-data /var/www/html/storage \
#     && chmod -R 775 /var/www/html/storage \
#     && chown -R www-data:www-data /var/www/html/bootstrap/cache \
#     && chmod -R 775 /var/www/html/bootstrap/cache

# # Install system dependencies
# RUN apt-get update && \
#     apt-get install -y \
#     git \
#     unzip

# # Instalar las dependencias de desarrollo de PostgreSQL
# RUN apt-get install -y libpq-dev

# # Install Composer
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# # Install PHP extensions required by your application
# RUN docker-php-ext-install pdo pdo_pgsql
# # 
# ENV COMPOSER_ALLOW_SUPERUSER=1

# # Configurar variables de entorno de la aplicación Laravel para producción
# ENV APP_ENV=production
# ENV APP_DEBUG=false
# ENV LOG_CHANNEL=stderr

# # Install application dependencies using Composer
# RUN composer install --no-interaction --optimize-autoloader
# # Node modules
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
#     apt-get install -y nodejs
# RUN npm install

# # Set up Apache virtual host
# COPY apache.conf /etc/apache2/sites-available/000-default.conf
# RUN a2enmod rewrite

# EXPOSE 443

# # Start Apache server
# CMD ["apache2-foreground"]

# ---------- Caddy
# Utilizamos la imagen base de PHP con el manejador de paquetes Composer
FROM php:7.4-fpm

# Instalamos las extensiones PHP necesarias para Laravel y PostgreSQL
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    libpq-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo pdo_mysql pdo_pgsql

# Instalamos Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Establecemos el directorio de trabajo en /var/www
WORKDIR /var/www

# Copiamos los archivos de la aplicación Laravel al contenedor
COPY . /var/www

# Instalamos Node.js y npm
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && apt-get install -y nodejs

# Agregamos el repositorio de Caddy y lo instalamos
RUN apt-get update && apt-get install -y software-properties-common && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | apt-key add - && \
    add-apt-repository 'deb [arch=amd64] https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt stable main' && \
    apt-get update && apt-get install -y caddy

# Instalamos las dependencias de Composer
RUN composer install

# Instalamos las dependencias de Node.js
RUN npm install

# Copiamos el Caddyfile al contenedor
COPY Caddyfile /etc/caddy/Caddyfile

# Exponemos el puerto 9000 para la comunicación con PHP-FPM
EXPOSE 9000

# Comando para iniciar PHP-FPM
CMD ["php-fpm"]