*This explains "How it Works" to a developer.*

```markdown
# Developer Documentation

## Architecture
The project uses **Docker Compose** to orchestrate 8 services. All images are built from `debian:bullseye` or `alpine`.

### Directory Structure
* `Makefile`: Entry point for build commands.
* `srcs/docker-compose.yml`: Defines services, networks, and volumes.
* `srcs/requirements/`: Contains Dockerfiles and scripts for each service.
    * `mariadb/`: Database initialization script.
    * `nginx/`: SSL certificate generation and config.
    * `wordpress/`: WP-CLI setup and Redis configuration.
    * `bonus/`: Contains definitions for Redis, FTP, Adminer, Website, and Glances.

## Data Persistence
Data is persisted using **Docker Volumes** stored on the host machine at `/home/mel-adna/data/`:
1.  `wordpress_vol`: Stores `/var/www/html` (Website files).
2.  `mariadb_vol`: Stores `/var/lib/mysql` (Database files).

The `Makefile` automatically creates these directories (`make dirs`) before building containers to avoid permission errors.

## Network
All containers are connected to a custom bridge network named `inception`.
* **Internal Communication:** Containers talk via hostnames (e.g., WordPress connects to `mariadb:3306`).
* **External Access:** Only NGINX (443), Adminer (8080), Glances (3000), FTP (21), and Website (1337) are exposed to the host.

## Debugging
If a service fails to start, check the logs:
```bash
docker logs <service_name>
# Example: docker logs wordpress
