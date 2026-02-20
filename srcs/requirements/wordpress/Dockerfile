FROM debian:bullseye

# Install PHP, MariaDB client (to talk to DB), Curl, and Less (needed by wp-cli)
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    mariadb-client \
    curl \
    php-redis \
    less \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI (Added here so it persists)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy config and script
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
RUN mkdir -p /run/php
COPY tools/script.sh /usr/local/bin/script.sh

# Set permission and work directory
RUN chmod +x /usr/local/bin/script.sh
WORKDIR /var/www/html

# Run the setup script
ENTRYPOINT ["/usr/local/bin/script.sh"]

# Expose port 9000
EXPOSE 9000
