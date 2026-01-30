FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    wget \
    php \
    php-mysql \
    && rm -rf /var/lib/apt/lists/*

# Copy the script
COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 8080

CMD ["/usr/local/bin/script.sh"]
