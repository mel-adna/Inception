FROM debian:bullseye

# Install NGINX and OpenSSL
RUN apt-get update && apt-get install -y nginx openssl

# Create the folder for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Generate the SSL Certificate
# req -x509: Create a self-signed certificate
# -nodes: No password required
# -out: Where to save the certificate
# -keyout: Where to save the key
# -subj: Fills in the info (Country, Organization, CommonName)
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=mel-adna.42.fr/UID=mel-adna"

# Copy our configuration file
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Ensure the /var/www/html folder exists and has permissions
RUN mkdir -p /var/www/html
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Run NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
