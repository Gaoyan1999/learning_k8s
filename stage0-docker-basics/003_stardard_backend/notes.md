# Stage 0 – 003_standard_backend CRUD API Notes

## Overview
This task implements a full CRUD API using Java 21, Spring Boot, Gradle, and MySQL in Docker.  
Project structure follows standard layered architecture: **Controller → Service → Repository**.

---

## Project Setup

- Java 21
- Gradle (wrapper `gradlew`)
- Spring Boot 3.3.5
- MySQL 8 running in Docker
- Docker port mapping: `3307:3306` (to avoid host port conflicts)

---

## Setup
1. mysql
```bash
docker run --name mysql-demo \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=demo_db \
  -p 3307:3306 \
  -d mysql:8
```
2. setup server
```shell
./gradlew bootRun
```