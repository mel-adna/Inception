*This project has been created as part of the 42 curriculum by mel-adna.*

# Inception

## Description
Inception is a System Administration project that aims to broaden knowledge of **Docker** and **virtualization**. The goal is to build a complete infrastructure using microservices, separating each service (NGINX, WordPress, MariaDB) into its own container. This project also involves setting up volumes for data persistence and a custom Docker Network for security.

## Instructions

### Prerequisites
* Docker & Docker Compose
* Make
* A Unix-based OS (Debian/Ubuntu recommended)

### Installation
1.  Clone the repository:
    ```bash
    git clone <repo_url> inception
    cd inception
    ```
2.  Setup environment variables:
    * Copy the `.env.example` to `srcs/.env` (or create one manually).
    * Ensure `DOMAIN_NAME` is set to `mel-adna.42.fr`.
3.  Build and Run:
    ```bash
    make all
    ```
4.  Access the site:
    * Open `https://mel-adna.42.fr` in your browser.
    * (Ensure `127.0.0.1 mel-adna.42.fr` is in your `/etc/hosts`).

## Project Architecture & Bonuses
This project includes the mandatory stack plus 5 bonuses:
* **Redis:** Object caching for WordPress.
* **FTP Server:** Direct file access to the WordPress volume (Port 21).
* **Adminer:** Database management GUI (Port 8080).
* **Static Website:** A personal resume page (Port 1337).
* **Glances:** Real-time system monitoring (Port 3000).

## Technical Comparisons

### Virtual Machines vs Docker
* **Virtual Machines (VMs):** Emulate entire hardware and run a full OS kernel. They are heavy, slow to boot, and resource-intensive.
* **Docker:** Uses OS-level virtualization. Containers share the host's kernel but isolate the application processes. They are lightweight, start instantly, and use fewer resources.

### Secrets vs Environment Variables
* **Environment Variables:** Stored in plaintext in the system's memory. Easy to use but visible to anyone who can run `docker inspect`.
* **Docker Secrets:** Encrypted at rest and only mounted into the container that needs them. They are more secure but require Docker Swarm (not used in this project config, though recommended for production).

### Docker Network vs Host Network
* **Host Network:** The container shares the host's IP and port space directly. No isolation.
* **Docker Network (Bridge):** Creates an isolated internal network. Containers communicate via DNS names (e.g., `ping mariadb`) and only expose specific ports to the outside world. This is the secure approach used here.

### Docker Volumes vs Bind Mounts
* **Bind Mounts:** Link a specific file/folder on the *host* to the container. Dependent on the host's directory structure.
* **Docker Volumes:** Managed entirely by Docker. Storage is independent of the container's lifecycle and the host's filesystem structure. Easier to back up and migrate.

## Resources & AI Usage
* **Docker Documentation:** Official guides for Dockerfiles and Compose.
* **AI Assistance:** AI tools were used to:
    * Debug configuration errors (e.g., FTP Passive mode port mismatches).
    * Generate skeleton scripts for service configuration.
    * Explain the difference between `ENTRYPOINT` and `CMD`.
    * *Note: All code generated was reviewed, tested, and understood by the learner.*
