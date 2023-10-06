#!/usr/bin/env bash
echo "Running composer"
composer global require hirak/prestissimo
composer install --no-dev --working-dir=/var/www/html
composer require fzaninotto/faker

echo "Running npm install"
npm install

echo "Running npm run dev"
npm run dev

echo "Caching config..."
php artisan config:cache

echo "Caching routes..."
php artisan route:cache

echo "Running migrations..."
php artisan migrate:refresh --seed --force