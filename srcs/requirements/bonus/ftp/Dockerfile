FROM debian:bullseye

RUN apt-get update && apt-get install -y vsftpd && rm -rf /var/lib/apt/lists/*

# Create the folder for the PID file
RUN mkdir -p /var/run/vsftpd/empty

# Copy the start script
COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 21

CMD ["/usr/local/bin/script.sh"]
