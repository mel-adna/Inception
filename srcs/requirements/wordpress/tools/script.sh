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

# wait for mariadb to be ready
sleep 10

cd /var/www/html
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Installing WordPress..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    wp core download --allow-root
    wp config create --dbname=$MYSQL_DB --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=mariadb:3306 --path='/var/www/html' --allow-root
    # Enable Redis Cache
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp config set WP_CACHE true --allow-root
    wp core install --url=$DOMAIN_NAME --title="$WP_TITLE" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root
    wp user create bob bob@example.com --role=author --user_pass=user_password123 --allow-root
fi
exec /usr/sbin/php-fpm7.4 -F
