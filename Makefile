# Define the path to your compose file
COMPOSE_FILE = ./srcs/docker-compose.yml

# Define the command that includes the path and the .env file
CMD = docker compose -f $(COMPOSE_FILE) --env-file srcs/.env

# Default rule: Create dirs first, then build
all: dirs
	$(CMD) up -d --build

# [REQUIRED] Create the data directories on the host
dirs:
	mkdir -p /home/mel-adna/data/wordpress
	mkdir -p /home/mel-adna/data/mariadb

# Stop everything
down:
	$(CMD) down

# View logs
logs:
	$(CMD) logs -f

# Clean up: Stop containers and remove volumes
clean: down
	$(CMD) down -v

# [REQUIRED] Full clean: Remove images, volumes, network, AND host data
fclean: clean
	$(CMD) down --rmi all -v
	sudo rm -rf /home/mel-adna/data/wordpress/*
	sudo rm -rf /home/mel-adna/data/mariadb/*

# Reset: Clean everything and start fresh
re: fclean all

.PHONY: all dirs down logs clean fclean re
