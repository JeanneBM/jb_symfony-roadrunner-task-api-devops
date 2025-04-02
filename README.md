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
  - Launched with the rr serve command on port 8080.
- **Composer**: 
  - Dependency installation from composer.json and composer.lock.
  - Uses flags: --no-dev (skips development dependencies) and --optimize-autoloader (optimizes the autoloader for better production performance).
- **Security Enhancements**:
  - Removal of unnecessary packages: apt-get clean and deletion of /var/lib/apt/lists/* to reduce image size.
  - Running as a non-root user (appuser), minimizing risks in case of a security breach.
  - No explicit Composer fallback mechanism in this case, but the installation is stable due to copying from the official image.
- **Ports**: Expose port `8080` as per `docker-compose.yaml`.

✅ **Compliance**: The Dockerfile correctly containerizes the application using RoadRunner instead of PHP-FPM, adhering to optimization and best practices, such as:

    - Multi-stage build for a smaller image size.
    - Minimization of dependencies and cleanup after installation.
    - Enhanced security through the use of a non-root user.


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
