#!/bin/bash

# Read passwords from Docker secrets
if [ -f /run/secrets/db_password ]; then
    export MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

if [ -f /run/secrets/db_root_password ]; then
    export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi

# 1. Start the service temporarily
service mariadb start 

# 2. Wait for it to wake up
sleep 5

# 3. Check if the database is missing (First Run)
if [ ! -d "/var/lib/mysql/$MYSQL_DB" ]; then
    echo "Database not found. Creating..."

    # Create Database and User
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO \`${MYSQL_USER}\`@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    # Set Root Password (This locks the door)
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    
    echo "Database setup finished."
else
    echo "Database already exists. Skipping setup."
fi

# 4. Stop the temporary service 
# (We use the password variable because root is now locked!)
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# 5. Start the permanent service
exec mysqld_safe
