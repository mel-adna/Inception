# User Documentation

## Overview
This infrastructure hosts a secure WordPress website along with tools to manage files, databases, and monitor system health. All services run in isolated Docker containers for security and portability.

---

## Services Provided

| Service | URL / Access | Description |
|:---|:---|:---|
| **WordPress** | `https://mel-adna.42.fr` | The main website and blog platform. |
| **Adminer** | `http://localhost:8080` | Web-based database management interface. |
| **Static Site** | `http://localhost:1337` | Personal resume/portfolio page. |
| **Glances** | `http://localhost:3000` | Real-time system monitoring dashboard. |
| **FTP** | `ftp://127.0.0.1` (Port 21) | Direct file access to WordPress files. |

---

## Starting and Stopping the Project

### Starting the Server
Open a terminal in the project root and run:
```bash
make all
```
This will create the required directories, build all images, and start the containers.

### Stopping the Server
To stop all running containers without removing data:
```bash
make down
```

### Viewing Logs
To monitor the logs of all services in real-time:
```bash
make logs
```

### Full Restart
To completely reset the project (removes all data and rebuilds):
```bash
make re
```

---

## Accessing the Website and Admin Panel

1. **WordPress Site:**
   - Open your browser and navigate to `https://mel-adna.42.fr`.
   - Ensure `127.0.0.1 mel-adna.42.fr` is added to your `/etc/hosts` file.

2. **WordPress Admin Panel:**
   - Go to `https://mel-adna.42.fr/wp-admin`.
   - Log in with the WordPress admin credentials (see Credentials section below).

3. **Database Admin (Adminer):**
   - Open `http://localhost:8080`.
   - Use the MariaDB credentials to log in.

---

## Credentials Location and Management

Sensitive credentials are stored in two locations:
1. **`secrets/` folder** — Contains password files (Docker secrets)
2. **`srcs/.env`** — Contains non-sensitive configuration variables

Both are **NOT committed to the repository** for security reasons.

### Setting Up Credentials

1. **Create your secrets files** (in the `secrets/` folder):
   ```bash
   # Database user password
   echo "your_secure_db_password" > secrets/db_password.txt

   # Database root password
   echo "your_secure_root_password" > secrets/db_root_password.txt

   # WordPress admin credentials
   cat > secrets/credentials.txt << EOF
   wp_admin_user=your_login
   wp_admin_password=your_secure_password
   wp_admin_email=your_email@example.com
   EOF

   # FTP password
   echo "your_ftp_password" > secrets/ftp_password.txt
   ```

2. **Create your .env file**:
   ```bash
   cp srcs/.env.example srcs/.env
   ```

3. **Edit `srcs/.env`** and set your domain and paths:
   - `DOMAIN_NAME` — Your domain (e.g., `mel-adna.42.fr`)
   - `VOL_WP_PATH` — WordPress data path (e.g., `/home/mel-adna/data/wordpress`)
   - `VOL_DB_PATH` — MariaDB data path (e.g., `/home/mel-adna/data/mariadb`)

> ⚠️ **Security Note:** Never share your `secrets/` folder or `.env` file, and never commit them to version control.

---

## Checking Service Health

### Verify All Containers Are Running
```bash
docker ps
```
You should see containers for: `nginx`, `wordpress`, `mariadb`, `redis`, `ftp`, `adminer`, `website`, and `glances`.

### Check Individual Service Logs
```bash
docker logs <container_name>
# Examples:
docker logs wordpress
docker logs mariadb
docker logs nginx
```

### Test Website Connectivity
```bash
curl -k https://mel-adna.42.fr
```
A successful response indicates the NGINX and WordPress services are working correctly.

### Test Database Connection
Access Adminer at `http://localhost:8080` and attempt to log in with your MariaDB credentials. If successful, the database service is healthy.

### Monitor System Resources
Open Glances at `http://localhost:3000` to view real-time CPU, memory, and container statistics.
