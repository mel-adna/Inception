# User Documentation

## Overview
This infrastructure hosts a secure WordPress website along with tools to manage files, databases, and monitor system health.

## Service Access URLs

|     Service     |       URL / Access          |    Description          |
|      :---       |           :---              |        :---             |
|  **WordPress**  | `https://mel-adna.42.fr`    | The main website.       |
|   **Adminer**   |   `http://localhost:8080`   | Manage the database.    |
| **Static Site** |   `http://localhost:1337`   | Personal Resume Page.   |
|   **Glances**   |   `http://localhost:3000`   | Sys Monitor Dashboard.  |
|     **FTP**     | `ftp://127.0.0.1` (Port 21) | Access files via FTP.   |

## How to Manage the Project

### Starting the Server
Open a terminal in the project root and run:
```bash
make all
