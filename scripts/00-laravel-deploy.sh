#!/usr/bin/env bash
echo "Running composer"
composer global require hirak/prestissimo
composer install --working-dir=/var/www/html

echo "*******************************************"

echo "Running npm install"
npm install

echo "*******************************************"

echo "Caching config..."
php artisan route:clear
php artisan config:clear
php artisan config:cache

echo "*******************************************"

echo "Caching routes..."
php artisan route:cache

echo "Running migrations..."
php artisan migrate:fresh --seed --force

echo "*******************************************"
# echo "Route listing..."
# php artisan route:list

echo "Views ..."
ls /var/www/html/resources/views

echo "*******************************************"

echo "Login ..."
ls /var/www/html/resources/views/auth

echo "*******************************************"
echo "Bootstrap app ..."
ls /var/www/html/bootstrap/cache

echo "*******************************************"
echo "Laravel Logs ......."
cat /var/www/html/storage/logs/laravel-2023-10-07.log

echo   "************************************************"
echo "Env content ....."
cat /var/www/html/.env