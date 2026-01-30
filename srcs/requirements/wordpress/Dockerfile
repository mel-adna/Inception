FROM debian:bullseye

# Install PHP, MariaDB client (to talk to DB), and Curl (to download WP)
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    mariadb-client \
    curl \
    php-redis \
    && rm -rf /var/lib/apt/lists/*

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
