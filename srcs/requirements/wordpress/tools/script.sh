#!/bin/bash

# Read secrets from Docker secrets files
if [ -f /run/secrets/db_password ]; then
    export MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

if [ -f /run/secrets/credentials ]; then
    export WP_ADMIN_USER=$(grep 'wp_admin_user=' /run/secrets/credentials | cut -d'=' -f2)
    export WP_ADMIN_PASSWORD=$(grep 'wp_admin_password=' /run/secrets/credentials | cut -d'=' -f2)
    export WP_ADMIN_EMAIL=$(grep 'wp_admin_email=' /run/secrets/credentials | cut -d'=' -f2)
fi

# Wait for mariadb to be ready
sleep 10

cd /var/www/html

# 1. Install WordPress (Only if config is missing)
if [ ! -f "wp-config.php" ]; then
    echo "Installing WordPress..."
    
    # Note: wp-cli download removed from here (it's in Dockerfile now)
    
    wp core download --allow-root
    wp config create --dbname=$MYSQL_DB --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=mariadb:3306 --path='/var/www/html' --allow-root
    
    # Install Core
    wp core install --url=$DOMAIN_NAME --title="$WP_TITLE" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root
    
    # Create Bonus User
    wp user create bob bob@example.com --role=author --user_pass=user_password123 --allow-root
    
    # Configure Redis Settings in wp-config.php
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp config set WP_CACHE true --allow-root
fi

# 2. Manage Redis Plugin (Runs on every startup to be safe)
# This ensures the plugin is installed and the connection is active
if ! wp plugin is-installed redis-cache --allow-root; then
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root
else
    # If already installed, just make sure object cache is enabled
    wp redis enable --allow-root
fi

exec /usr/sbin/php-fpm7.4 -F
