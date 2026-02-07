*This project has been created as part of the 42 curriculum by mel-adna.*

# Inception

## Description

Inception is a **System Administration** project focused on Docker and containerization. The goal is to build a complete web infrastructure using microservices architecture, where each service runs in its own isolated container.

The project sets up a functional **WordPress website** with:
- **NGINX** as a reverse proxy with TLS encryption
- **WordPress** with php-fpm for the web application
- **MariaDB** for the database
- **Docker volumes** for persistent data storage
- **Docker network** for secure inter-container communication

This infrastructure demonstrates real-world DevOps practices including container orchestration, secure credential management with Docker secrets, and service isolation.

---

## Project Architecture & Design Choices

### Sources Included

The project is built entirely from scratch using official base images:

| Service | Base Image | Purpose |
|:---|:---|:---|
| **NGINX** | `debian:bullseye` | Web server, SSL termination, reverse proxy |
| **WordPress** | `debian:bullseye` | PHP application with php-fpm |
| **MariaDB** | `debian:bullseye` | MySQL-compatible database |
| **Redis** | `debian:bullseye` | Object caching for WordPress |
| **FTP** | `debian:bullseye` | File transfer access to WordPress files |
| **Adminer** | `debian:bullseye` | Web-based database management |
| **Static Site** | `debian:bullseye` | Personal resume/portfolio page |
| **Glances** | `debian:bullseye` | Real-time system monitoring |

### Main Design Choices

1. **Microservices Architecture:** Each service runs in its own container, allowing independent scaling, updates, and failure isolation.

2. **Security First:**
   - NGINX is the only entry point (port 443 with TLS 1.2/1.3)
   - Docker secrets for sensitive credentials (not environment variables)
   - Custom bridge network for container isolation
   - No direct database exposure to the internet

3. **Data Persistence:** Named Docker volumes ensure data survives container restarts and rebuilds.

4. **Automation:** Makefile provides simple commands (`make all`, `make down`, `make re`) for the entire lifecycle.

---

## Technical Comparisons

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|:---|:---|:---|
| **Virtualization Level** | Hardware (Hypervisor) | OS-level (Kernel sharing) |
| **Boot Time** | Minutes | Seconds |
| **Resource Usage** | High (full OS per VM) | Low (shared kernel) |
| **Isolation** | Complete (separate kernel) | Process-level (shared kernel) |
| **Image Size** | Gigabytes | Megabytes |
| **Performance** | Overhead from hypervisor | Near-native |

**Why Docker for this project:** Containers are lightweight, start instantly, and are perfect for microservices. Each service (NGINX, WordPress, MariaDB) runs in isolation but shares the host kernel for efficiency.

### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|:---|:---|:---|
| **Storage** | Plaintext in memory | Encrypted at rest |
| **Visibility** | Visible via `docker inspect` | Only inside container |
| **Access Method** | `$VAR_NAME` | Read from `/run/secrets/file` |
| **Security Level** | Low | High |
| **Use Case** | Non-sensitive config | Passwords, API keys |

**Why Secrets for this project:** Database passwords and admin credentials are sensitive. Docker secrets are encrypted and only mounted in containers that explicitly need them, following the principle of least privilege.

### Docker Network vs Host Network

| Aspect | Docker Bridge Network | Host Network |
|:---|:---|:---|
| **Isolation** | Yes (private subnet) | No (shares host IP) |
| **Container DNS** | Yes (`ping mariadb`) | No |
| **Port Mapping** | Required (`-p 443:443`) | Not needed |
| **Security** | Containers are isolated | Containers share host ports |
| **Use Case** | Production | Debugging only |

**Why Bridge Network for this project:** The `inception` bridge network provides:
- Internal DNS (WordPress connects to `mariadb:3306` by name)
- Only NGINX port 443 is exposed externally
- MariaDB is never directly accessible from outside

### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|:---|:---|:---|
| **Managed By** | Docker | Host filesystem |
| **Location** | Docker's storage area | Any host path |
| **Portability** | Easy backup/migration | Tied to host structure |
| **Performance** | Optimized by Docker | Depends on host FS |
| **Use Case** | Production data | Development/debugging |

**Why Volumes for this project:** Named volumes (`mariadb_vol`, `wordpress_vol`) are managed by Docker, making backups and migrations easier. Data persists independently of container lifecycle.

---

## Instructions

### Prerequisites

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Make**
- **A Virtual Machine** running Debian/Ubuntu (required by the subject)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repo_url> inception
   cd inception
   ```

2. **Create Docker secrets:**
   ```bash
   mkdir -p secrets
   echo "your_db_password" > secrets/db_password.txt
   echo "your_root_password" > secrets/db_root_password.txt
   echo "your_ftp_password" > secrets/ftp_password.txt
   cat > secrets/credentials.txt << EOF
   wp_admin_user=mel-adna
   wp_admin_password=your_password
   wp_admin_email=mel-adna@student.1337.ma
   EOF
   ```

3. **Configure environment:**
   ```bash
   cp srcs/.env.example srcs/.env
   # Edit srcs/.env with your domain and paths
   ```

4. **Add domain to hosts file:**
   ```bash
   echo "127.0.0.1 mel-adna.42.fr" | sudo tee -a /etc/hosts
   ```

5. **Build and run:**
   ```bash
   make all
   ```

6. **Access the site:**
   - WordPress: `https://mel-adna.42.fr`
   - Admin Panel: `https://mel-adna.42.fr/wp-admin`

### Makefile Commands

| Command | Description |
|:---|:---|
| `make all` | Build images and start all containers |
| `make down` | Stop all containers |
| `make logs` | View container logs |
| `make clean` | Stop containers and remove volumes |
| `make fclean` | Remove everything (images, volumes, data) |
| `make re` | Full rebuild |

---

## Bonus Features

| Bonus | Description | Access |
|:---|:---|:---|
| **Redis** | Object caching for WordPress performance | Internal (port 6379) |
| **FTP Server** | File access to WordPress volume | `ftp://127.0.0.1:21` |
| **Adminer** | Database management GUI | `http://localhost:8080` |
| **Static Website** | Personal resume page (HTML/CSS/JS) | `http://localhost:1337` |
| **Glances** | Real-time system monitoring | `http://localhost:3000` |

---

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

### Tutorials & Articles
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Understanding PID 1 in Containers](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)
- [TLS/SSL Configuration Guide](https://ssl-config.mozilla.org/)

### AI Usage

AI tools were used during this project for the following tasks:

1. **Configuration Debugging:**
   - Resolving FTP passive mode port configuration issues
   - Fixing NGINX FastCGI setup for php-fpm communication

2. **Script Generation:**
   - Creating skeleton entrypoint scripts for services
   - Generating database initialization scripts

3. **Concept Clarification:**
   - Understanding the difference between `ENTRYPOINT` and `CMD`
   - Learning about Docker secrets implementation
   - Explaining PID 1 best practices in containers

4. **Documentation Assistance:**
   - Structuring README and documentation files
   - Writing technical comparisons

> **Note:** All AI-generated code and content was thoroughly reviewed, tested, and understood before being incorporated into the project. The learner takes full responsibility for all code in this repository.

---

## Author

- **mel-adna** — 42 Network Student
