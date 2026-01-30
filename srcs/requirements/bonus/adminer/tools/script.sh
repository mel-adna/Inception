#!/bin/bash

# 1. Create directory
mkdir -p /var/www/html

# 2. Download Adminer
wget "http://www.adminer.org/latest.php" -O /var/www/html/index.php

# 3. Start PHP Server on port 8080
echo "Starting Adminer on port 8080..."
cd /var/www/html
php -S 0.0.0.0:8080
