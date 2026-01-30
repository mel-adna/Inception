FROM debian:bullseye

RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

# Create the website folder
WORKDIR /var/www/html

# Copy the HTML file (we will create this next)
COPY tools/index.html /var/www/html/index.html

# Expose the 42 port
EXPOSE 1337

# Start Python's built-in HTTP server
CMD ["python3", "-m", "http.server", "1337"]
