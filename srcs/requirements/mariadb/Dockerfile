# Use Debian Bullseye (Penultimate Stable)
FROM debian:bullseye

# Install MariaDB
RUN apt-get update && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Setup directories and permissions
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 777 /var/run/mysqld

# Copy config and script
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/script.sh /usr/local/bin/script.sh
RUN chomd 777 /usr/local/bin/script.sh

# Run the script
ENTRYPOINT ["/usr/local/bin/script.sh"]

# Expose the port
EXPOSE 3306
