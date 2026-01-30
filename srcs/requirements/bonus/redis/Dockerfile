FROM debian:bullseye

RUN apt-get update && apt-get install -y redis-server && rm -rf /var/lib/apt/lists/*

# Configure Redis to listen on all interfaces (so WordPress can find it)
# By default, it only listens on localhost (127.0.0.1)
RUN sed -i "s|bind 127.0.0.1|#bind 127.0.0.1|g" /etc/redis/redis.conf
RUN sed -i "s|# maxmemory <bytes>|maxmemory 2mb|g" /etc/redis/redis.conf
RUN sed -i "s|# maxmemory-policy noeviction|maxmemory-policy allkeys-lru|g" /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server",  "--protected-mode", "no"]
