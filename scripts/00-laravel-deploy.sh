#!/usr/bin/env bash
echo "Running composer"
composer global require hirak/prestissimo
composer install --working-dir=/var/www/html

echo "Running npm install"
npm install

echo "Running npm run dev"
npm run dev

echo "Caching config..."
php artisan route:clear
php artisan config:clear
php artisan config:cache

echo "Caching routes..."
php artisan route:cache

echo "Running migrations..."
php artisan migrate:fresh --seed --force

echo "Route listing..."
php artisan route:list
pwd
ls /var/www/html/
ls /var/www/html/public/