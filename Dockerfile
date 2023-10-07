# Utiliza una imagen de PHP que sea adecuada para Laravel
FROM php:7.4-fpm

# Instala las extensiones de PHP necesarias para Laravel (puedes agregar más según tus necesidades)
RUN docker-php-ext-install pdo pdo_mysql

# Instala Nginx
RUN apt-get update && apt-get install -y nginx

# Copia tus archivos de la aplicación en el contenedor
COPY . /var/www/html

# Configura Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Configuración de Laravel
WORKDIR /var/www/html

# Establece el entorno de desarrollo
ENV APP_ENV development
ENV APP_DEBUG true

# Instala Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Ejecuta Composer para instalar las dependencias de Laravel
RUN composer install

# Iniciar Nginx y PHP-FPM
CMD service php7.4-fpm start && nginx -g "daemon off;"