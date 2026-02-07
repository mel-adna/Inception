# 🎯 Inception — Evaluation Preparation Guide

This document will help you prepare for the defense. It contains all the commands to test services, explanations of key concepts, and answers to common questions.

---

## 📋 Table of Contents

1. [Pre-Evaluation Setup](#pre-evaluation-setup)
2. [Testing All Services](#testing-all-services)
3. [Key Concepts to Explain](#key-concepts-to-explain)
4. [Common Evaluation Questions](#common-evaluation-questions)
5. [Quick Command Reference](#quick-command-reference)
6. [Troubleshooting](#troubleshooting)

---

## 🔧 Pre-Evaluation Setup

### 1. Start Your Virtual Machine
Make sure you're running on a VM (Debian/Ubuntu recommended).

### 2. Verify Prerequisites
```bash
# Check Docker is installed
docker --version

# Check Docker Compose
docker compose version

# Check Make
make --version
```

### 3. Set Up Hosts File
```bash
# Add your domain to hosts
echo "127.0.0.1 mel-adna.42.fr" | sudo tee -a /etc/hosts

# Verify it's added
cat /etc/hosts | grep mel-adna
```

### 4. Create Your Secrets (if not done)
```bash
cd ~/inception  # or wherever your project is

# Create secrets with real passwords
echo "your_db_password" > secrets/db_password.txt
echo "your_root_password" > secrets/db_root_password.txt
echo "your_ftp_password" > secrets/ftp_password.txt

cat > secrets/credentials.txt << EOF
wp_admin_user=mel-adna
wp_admin_password=your_wp_password
wp_admin_email=mel-adna@student.1337.ma
EOF
```

### 5. Create .env File
```bash
cp srcs/.env.example srcs/.env
# Edit with your values
nano srcs/.env
```

### 6. Build and Start Everything
```bash
make all
```

---

## 🧪 Testing All Services

### Test 1: Verify All Containers Are Running
```bash
docker ps
```
**Expected:** 8 containers running:
- `nginx`
- `wordpress`
- `mariadb`
- `redis`
- `ftp`
- `adminer`
- `website`
- `glances`

### Test 2: NGINX + SSL (Port 443)
```bash
# Test HTTPS connection
curl -k https://mel-adna.42.fr

# Check SSL certificate
openssl s_client -connect mel-adna.42.fr:443 -tls1_2

# Verify TLS version (should show TLSv1.2 or TLSv1.3)
openssl s_client -connect mel-adna.42.fr:443 2>/dev/null | grep "Protocol"
```
**Browser Test:** Open `https://mel-adna.42.fr` — You should see WordPress.

### Test 3: WordPress
```bash
# Check WordPress is responding
curl -k https://mel-adna.42.fr/wp-admin/

# Enter the container and check WP-CLI
docker exec -it wordpress wp --info --allow-root

# List WordPress users (should show 2 users)
docker exec -it wordpress wp user list --allow-root
```
**Browser Test:** 
- Go to `https://mel-adna.42.fr/wp-admin`
- Login with your admin credentials
- Verify you can create posts

### Test 4: MariaDB
```bash
# Connect to database
docker exec -it mariadb mysql -u wp_user -p

# Once connected, run:
SHOW DATABASES;
USE wordpress_db;
SHOW TABLES;
SELECT user_login FROM wp_users;
```
**Expected:** You should see the WordPress database and 2 users.

### Test 5: Redis Cache (Bonus)
```bash
# Check Redis is running
docker exec -it redis redis-cli ping
# Expected: PONG

# Check Redis has WordPress keys
docker exec -it redis redis-cli keys "*"

# Monitor Redis activity (while browsing WordPress)
docker exec -it redis redis-cli monitor
```

### Test 6: FTP Server (Bonus)
```bash
# Install FTP client if needed
sudo apt install ftp

# Connect to FTP
ftp 127.0.0.1
# Username: ftp_user
# Password: (your FTP password from secrets)

# Once connected:
ls
cd wp-content
ls
```
**Alternative Test:** Use FileZilla with `127.0.0.1`, port `21`.

### Test 7: Adminer (Bonus)
**Browser Test:** 
- Open `http://localhost:8080`
- Server: `mariadb`
- Username: `wp_user`
- Password: (your db password)
- Database: `wordpress_db`

### Test 8: Static Website (Bonus)
```bash
curl http://localhost:1337
```
**Browser Test:** Open `http://localhost:1337` — Should show your resume/static site.

### Test 9: Glances (Bonus)
**Browser Test:** Open `http://localhost:3000` — Should show system monitoring dashboard.

### Test 10: Docker Network
```bash
# Check the network exists
docker network ls | grep inception

# Verify containers are on the same network
docker network inspect inception

# Test container-to-container communication
docker exec -it wordpress ping -c 3 mariadb
docker exec -it wordpress ping -c 3 redis
docker exec -it nginx ping -c 3 wordpress
```

### Test 11: Volumes and Persistence
```bash
# Check volumes exist
docker volume ls | grep vol

# Check data on host
ls -la /home/mel-adna/data/wordpress/
ls -la /home/mel-adna/data/mariadb/

# Test persistence: Stop and restart
make down
make all
# Data should still be there!
```

### Test 12: Container Restart on Crash
```bash
# Kill a container process and watch it restart
docker exec -it wordpress kill 1

# Wait a few seconds, then check
docker ps | grep wordpress
# Should show wordpress running with a new "STATUS" (recently started)
```

### Test 13: Docker Secrets
```bash
# Verify secrets are mounted in containers
docker exec -it mariadb cat /run/secrets/db_password
docker exec -it mariadb cat /run/secrets/db_root_password
docker exec -it wordpress cat /run/secrets/db_password
docker exec -it wordpress cat /run/secrets/credentials
docker exec -it ftp cat /run/secrets/ftp_password
```

---

## 📚 Key Concepts to Explain

### 1. What is Docker?
> Docker is a platform for containerization. It packages applications and their dependencies into isolated containers that share the host's kernel but run in isolation. Unlike VMs, containers don't need a full OS, making them lightweight and fast.

### 2. What is Docker Compose?
> Docker Compose is a tool for defining and running multi-container applications. You define all services in a `docker-compose.yml` file and manage them with simple commands like `docker compose up`.

### 3. What is a Dockerfile?
> A Dockerfile is a script containing instructions to build a Docker image. Each instruction creates a layer. Common instructions:
> - `FROM` — Base image
> - `RUN` — Execute commands during build
> - `COPY` — Copy files into the image
> - `EXPOSE` — Document which ports the container listens on
> - `CMD` / `ENTRYPOINT` — Command to run when container starts

### 4. Difference: ENTRYPOINT vs CMD
> - **CMD:** Default command, can be overridden when running the container
> - **ENTRYPOINT:** Always executed, CMD becomes arguments to it
> 
> Example: If `ENTRYPOINT ["nginx"]` and `CMD ["-g", "daemon off;"]`, running the container executes `nginx -g daemon off;`

### 5. Difference: Virtual Machines vs Docker
| Aspect | Virtual Machine | Docker |
|:---|:---|:---|
| Virtualization | Hardware-level (hypervisor) | OS-level (kernel sharing) |
| Boot time | Minutes | Seconds |
| Size | GBs (full OS) | MBs (just app + deps) |
| Isolation | Complete (separate kernel) | Process-level (shared kernel) |
| Performance | Overhead due to hypervisor | Near-native |

### 6. Difference: Docker Secrets vs Environment Variables
| Aspect | Environment Variables | Docker Secrets |
|:---|:---|:---|
| Storage | In memory, plaintext | Encrypted at rest |
| Visibility | `docker inspect` shows them | Only mounted in containers that need them |
| Access | Any process in container | Read from `/run/secrets/` |
| Security | Low | High |

### 7. Difference: Docker Network vs Host Network
| Aspect | Docker Bridge Network | Host Network |
|:---|:---|:---|
| Isolation | Yes, internal DNS names | No, shares host IP |
| Port mapping | Required (`-p 443:443`) | Not needed |
| Security | Better (isolated) | Less secure |
| Use case | Production | Debugging only |

### 8. Difference: Docker Volumes vs Bind Mounts
| Aspect | Docker Volumes | Bind Mounts |
|:---|:---|:---|
| Managed by | Docker | Host filesystem |
| Location | Docker's storage area | Anywhere on host |
| Portability | Easy to backup/migrate | Depends on host path |
| Use case | Production data | Development |

### 9. What is PID 1?
> PID 1 is the first process in a container. It's special because:
> - It receives all signals (SIGTERM, SIGINT)
> - It must handle zombie processes
> - If PID 1 exits, the container stops
> 
> Best practice: Use `exec` in entrypoint scripts so your app becomes PID 1.

### 10. Why TLS 1.2/1.3?
> TLS (Transport Layer Security) encrypts traffic between client and server.
> - TLS 1.0/1.1 have known vulnerabilities (POODLE, BEAST)
> - TLS 1.2 is secure and widely supported
> - TLS 1.3 is faster and more secure (fewer round trips)

### 11. What is php-fpm?
> PHP-FPM (FastCGI Process Manager) is a way to run PHP. Instead of Apache loading PHP as a module, NGINX sends PHP requests to php-fpm via FastCGI protocol. This is more efficient and allows NGINX and PHP to scale separately.

### 12. How does the architecture work?
```
                    ┌─────────────────────────────────────────┐
                    │           Docker Network: inception      │
                    │                                          │
   User Request     │  ┌─────────┐      ┌───────────┐         │
   (HTTPS:443) ────────▶│  NGINX  │─────▶│ WordPress │◀───────┐│
                    │  │  :443   │ PHP  │  (php-fpm)│        ││
                    │  └─────────┘      └─────┬─────┘        ││
                    │                         │              ││
                    │                         │ MySQL:3306   ││
                    │                         ▼              ││
                    │                   ┌───────────┐   ┌────┴┐│
                    │                   │  MariaDB  │   │Redis││
                    │                   │   :3306   │   │:6379││
                    │                   └───────────┘   └─────┘│
                    └─────────────────────────────────────────┘
```

---

## ❓ Common Evaluation Questions

### Q1: Why can't you use `network: host`?
> Host network removes isolation. The container shares the host's network directly, which is insecure. With bridge network, containers communicate via internal DNS and you control which ports are exposed.

### Q2: Why no `links:` or `--link`?
> `links:` is deprecated. Docker networks provide the same functionality (container name as DNS) plus better isolation and multi-host support.

### Q3: Why no `latest` tag?
> `latest` is ambiguous — it changes over time. Using a specific tag (like `debian:bullseye`) ensures reproducible builds. Your container should work the same way today and in 6 months.

### Q4: Why `restart: always`?
> It ensures containers come back up if they crash or if the Docker daemon restarts. In production, you want services to be resilient.

### Q5: Why can't the admin username contain 'admin'?
> Security best practice. Attackers often try brute-forcing `admin` usernames first. Using a unique username adds a layer of security.

### Q6: Why use Docker secrets instead of .env for passwords?
> Environment variables can be seen with `docker inspect`. Secrets are encrypted at rest and only mounted inside containers that explicitly need them, reducing exposure.

### Q7: Why is NGINX the only entry point?
> Defense in depth. NGINX acts as a reverse proxy:
> - Handles SSL termination
> - Filters requests
> - Only forwards valid PHP requests to WordPress
> - MariaDB is never directly exposed to the internet

### Q8: Why use debian:bullseye and not latest Debian?
> The subject requires "penultimate stable version." Bullseye is Debian 11, the previous stable release before Bookworm (Debian 12).

### Q9: How do containers communicate?
> Via the Docker bridge network named `inception`. Each container gets a hostname matching its service name. WordPress connects to `mariadb:3306`, NGINX sends PHP to `wordpress:9000`.

### Q10: What happens if MariaDB crashes?
> The container restarts automatically (`restart: always`). WordPress might show errors briefly but will reconnect once MariaDB is back.

---

## 📝 Quick Command Reference

### Start/Stop
```bash
make all          # Build and start everything
make down         # Stop all containers
make re           # Full rebuild (clean + build)
make logs         # View all logs
make clean        # Stop + remove volumes
make fclean       # Remove everything including images
```

### Docker Commands
```bash
docker ps                          # List running containers
docker ps -a                       # List all containers (including stopped)
docker logs <container>            # View container logs
docker logs -f <container>         # Follow logs in real-time
docker exec -it <container> bash   # Enter a container
docker exec -it <container> sh     # For Alpine-based containers
docker inspect <container>         # Detailed container info
docker network ls                  # List networks
docker volume ls                   # List volumes
docker images                      # List images
```

### Database Commands (inside MariaDB container)
```bash
docker exec -it mariadb mysql -u root -p
# Then:
SHOW DATABASES;
USE wordpress_db;
SHOW TABLES;
SELECT * FROM wp_users;
```

### WordPress Commands (inside WordPress container)
```bash
docker exec -it wordpress wp --info --allow-root
docker exec -it wordpress wp user list --allow-root
docker exec -it wordpress wp plugin list --allow-root
docker exec -it wordpress wp theme list --allow-root
```

---

## 🔥 Troubleshooting

### Container won't start
```bash
# Check logs
docker logs <container_name>

# Check if port is in use
sudo lsof -i :443
sudo lsof -i :3306
```

### Database connection refused
```bash
# Check MariaDB is running
docker ps | grep mariadb

# Check MariaDB logs
docker logs mariadb

# Verify network connectivity
docker exec -it wordpress ping mariadb
```

### WordPress shows "Error establishing database connection"
```bash
# Check credentials match
docker exec -it wordpress cat /run/secrets/db_password
docker exec -it mariadb mysql -u wp_user -p
# Enter the same password - should work

# Check wp-config.php
docker exec -it wordpress cat /var/www/html/wp-config.php | grep DB_
```

### SSL Certificate errors in browser
```bash
# This is normal for self-signed certificates!
# Click "Advanced" → "Proceed anyway"

# Or add exception in Firefox/Chrome
```

### FTP connection issues
```bash
# Make sure passive mode ports are open
docker ps | grep ftp
# Should show 21:21 and 21100:21100

# Check FTP logs
docker logs ftp
```

---

## ✅ Final Checklist Before Defense

- [ ] All 8 containers running (`docker ps`)
- [ ] Can access `https://mel-adna.42.fr` in browser
- [ ] Can login to WordPress admin panel
- [ ] Can see 2 users in WordPress (admin + author)
- [ ] Can access Adminer and see database
- [ ] Redis is caching (`docker exec redis redis-cli ping`)
- [ ] FTP works (connect with client)
- [ ] Static website loads on port 1337
- [ ] Glances shows monitoring on port 3000
- [ ] Data persists after `make down && make all`
- [ ] Containers restart after crash
- [ ] Secrets are NOT in git (`git status` shows nothing sensitive)

---

**Good luck with your evaluation! 🚀**
