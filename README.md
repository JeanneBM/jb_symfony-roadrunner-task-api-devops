## Application Containerization - docker-compose.yaml

### Container Structure:

**Service `app`**:
- Built from the local Dockerfile
- Exposes port `8080`
- Depends on `db` and `redis` (with healthcheck)

**Service `db`**:
- PostgreSQL 15.6
- Volume `pgdata`
- `healthcheck` ensures database readiness

**Service `redis`**:
- Redis 6.0.20
- Volume `redisdata`
- `healthcheck`

✅ **Compliance**: The file defines a complete infrastructure (PHP, PostgreSQL, Redis) that meets technical requirements.

---

## Dockerfile - Application Image Definition

### Key Elements:

- **Base Image**: `php:8.1-cli` (compliant with PHP 8.1+ requirements).
- **System Dependencies**:
  - Install necessary PHP extensions (`pdo_pgsql`, `redis`, etc.)
  - Tools (`git`, `curl`, `composer`).
- **RoadRunner**:
  - Install RoadRunner (v2023.3.8)
  - Set as the application server (instead of PHP-FPM).
- **Composer**: Install dependencies (`--no-dev --optimize-autoloader`).
- **Security Enhancements**:
  - Remove unnecessary packages (`apt-get clean`).
  - Use fallbacks when installing Composer.
- **Ports**: Expose port `8080` as per `docker-compose.yaml`.

✅ **Compliance**: The Dockerfile correctly containerizes the application with RoadRunner instead of PHP-FPM, using optimization and best practices.

---

## CI/CD - GitHub Actions (ci.yaml)

### CI System Choice

`ci.yaml` configures GitHub Actions to run static analysis (PHPStan), tests (PHPUnit), and build & tag Docker images.

### Triggers

The pipeline runs on:

- `push` to the `main` branch
- `pull_request` to the `main` branch

### Pipeline Tasks:

1. **Checkout repository**: Retrieve the code (`actions/checkout@v3`).
2. **Set up PHP**: Configure PHP 8.1 with Composer and PHPStan (`shivammathur/setup-php@v2`).
3. **Cache Composer dependencies**: Cache dependencies (`actions/cache@v3`).
4. **Install dependencies**: Install production dependencies (`--no-dev`) and development dependencies (`--dev`) for static analysis.
5. **Run static analysis**: Execute PHPStan (`composer stan`, level 5).
6. **Run tests**: Run PHPUnit tests (`composer test`).
7. **Build and tag Docker image**: Build a Docker image `task-manager-api:${{ github.sha }}` and tag it as `latest`.

✅ **Compliance**: The pipeline fully implements CI/CD by performing static analysis, testing, building, and tagging Docker images.

---

## **Security**:

1. Environment variables managed in docker-compose.yaml.
2. Cleaning unused packages in Dockerfile.
3. Caching dependencies in CI.

---
