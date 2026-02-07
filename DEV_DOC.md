# Developer Documentation

This document explains how the project works and how to set it up from scratch.

---

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+ or integrated with Docker)
- **Make** (GNU Make)
- **A Unix-based OS** (Debian/Ubuntu recommended, or a VM running Linux)

### Install Docker on Debian/Ubuntu
```bash
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

---

## Project Architecture

The project uses **Docker Compose** to orchestrate 8 services. All images are built from `debian:bullseye` or `alpine`.

### Directory Structure
```
inception/
├── Makefile                    # Entry point for build commands
├── README.md                   # Project overview
├── USER_DOC.md                 # End-user documentation
├── DEV_DOC.md                  # This file
├── secrets/                    # Docker secrets (not in repo)
│   ├── credentials.txt         # WordPress admin credentials
│   ├── db_password.txt         # MariaDB user password
│   ├── db_root_password.txt    # MariaDB root password
│   └── ftp_password.txt        # FTP user password
└── srcs/
    ├── .env                    # Environment variables (not in repo)
    ├── .env.example            # Template for .env
    ├── docker-compose.yml      # Defines services, networks, volumes, secrets
    └── requirements/           # Dockerfiles and configs for each service
        ├── mariadb/            # Database initialization script
        ├── nginx/              # SSL certificate generation and config
        ├── wordpress/          # WP-CLI setup and Redis configuration
        └── bonus/              # Redis, FTP, Adminer, Website, Glances
```

---

## Setting Up the Environment from Scratch

### Step 1: Clone the Repository
```bash
git clone <repo_url> inception
cd inception
```

### Step 2: Create Docker Secrets
Create the secrets folder and add your sensitive passwords:
```bash
mkdir -p secrets

# Database user password
echo "your_secure_db_password" > secrets/db_password.txt

# Database root password  
echo "your_secure_root_password" > secrets/db_root_password.txt

# WordPress admin credentials
cat > secrets/credentials.txt << EOF
wp_admin_user=mel-adna
wp_admin_password=your_secure_password
wp_admin_email=mel-adna@student.1337.ma
EOF

# FTP password
echo "your_ftp_password" > secrets/ftp_password.txt
```

### Step 3: Configure Environment Variables
```bash
cp srcs/.env.example srcs/.env
```

Edit `srcs/.env` and set the configuration variables:
```bash
# Domain
DOMAIN_NAME=mel-adna.42.fr

# Database name and user (passwords are in secrets/)
MYSQL_DB=wordpress_db
MYSQL_USER=wp_user

# WordPress title
WP_TITLE=Inception

# Data Paths
VOL_WP_PATH=/home/mel-adna/data/wordpress
VOL_DB_PATH=/home/mel-adna/data/mariadb
```

### Step 4: Configure Host DNS
Add the domain to your local hosts file:
```bash
echo "127.0.0.1 mel-adna.42.fr" | sudo tee -a /etc/hosts
```

### Step 5: Build and Launch
```bash
make all
```

---

## Makefile Commands

| Command | Description |
|:---|:---|
| `make all` | Create data directories, build images, and start all containers. |
| `make dirs` | Create the host directories for volume mounts. |
| `make down` | Stop all running containers (data is preserved). |
| `make logs` | Follow the logs of all containers in real-time. |
| `make clean` | Stop containers and remove Docker volumes. |
| `make fclean` | Full clean: remove images, volumes, network, and host data. |
| `make re` | Full reset: run `fclean` then `all` (complete rebuild). |

---

## Managing Containers and Volumes

### List Running Containers
```bash
docker ps
```

### Stop All Containers
```bash
make down
# or
docker compose -f srcs/docker-compose.yml down
```

### Restart a Single Service
```bash
docker compose -f srcs/docker-compose.yml restart <service_name>
# Example:
docker compose -f srcs/docker-compose.yml restart wordpress
```

### Rebuild a Single Service
```bash
docker compose -f srcs/docker-compose.yml up -d --build <service_name>
```

### List Volumes
```bash
docker volume ls
```

### Remove All Volumes (⚠️ Destroys Data)
```bash
docker volume prune -f
```

### Access a Container Shell
```bash
docker exec -it <container_name> /bin/bash
# For Alpine-based containers:
docker exec -it <container_name> /bin/sh
```

---

## Data Persistence

Data is persisted using **Docker Volumes** stored on the host machine at `/home/mel-adna/data/`:

| Volume | Container Path | Purpose |
|:---|:---|:---|
| `wordpress_vol` | `/var/www/html` | WordPress files (themes, plugins, uploads) |
| `mariadb_vol` | `/var/lib/mysql` | MariaDB database files |

### Host Paths
```
/home/mel-adna/data/
├── wordpress/    # Bind-mounted to WordPress container
└── mariadb/      # Bind-mounted to MariaDB container
```

The `Makefile` automatically creates these directories (`make dirs`) before building containers to avoid permission errors.

### Backing Up Data
```bash
# Backup WordPress files
sudo tar -czvf wordpress_backup.tar.gz /home/mel-adna/data/wordpress

# Backup MariaDB database
docker exec mariadb mysqldump -u root -p<password> wordpress > db_backup.sql
```

---

## Network Configuration

All containers are connected to a custom bridge network named `inception`.

- **Internal Communication:** Containers communicate via hostnames (e.g., WordPress connects to `mariadb:3306`).
- **External Access:** Only specific ports are exposed to the host:

| Service | Port | Protocol |
|:---|:---|:---|
| NGINX | 443 | HTTPS |
| Adminer | 8080 | HTTP |
| Glances | 3000 | HTTP |
| FTP | 21 | FTP |
| Static Site | 1337 | HTTP |

---

## Debugging

### Check Container Logs
```bash
docker logs <container_name>
# Examples:
docker logs wordpress
docker logs mariadb
docker logs nginx
```

### Follow Logs in Real-Time
```bash
docker logs -f <container_name>
# Or for all containers:
make logs
```

### Check Container Status
```bash
docker ps -a
```
Containers with `Exited` status have crashed. Check their logs for errors.

### Common Issues

| Issue | Solution |
|:---|:---|
| Port already in use | Stop conflicting services or change port in `docker-compose.yml` |
| Permission denied on volumes | Ensure `/home/mel-adna/data/` directories exist and have correct permissions |
| Database connection refused | Check that MariaDB is fully started before WordPress attempts to connect |
| SSL certificate errors | Ensure NGINX has generated certificates correctly in its Dockerfile |

### Inspect a Container
```bash
docker inspect <container_name>
```

### Check Network Connectivity Between Containers
```bash
docker exec wordpress ping mariadb
```
