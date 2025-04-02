### This Dockerfile is safer, smaller and more efficient.
### Uses multi-stage build – reduces image size
### Runs as a non-root user – improves security
### Installs only necessary dependencies – avoids unnecessary bloat
### Proper RoadRunner setup


# =========================
# STAGE 1: Base (system dependencies + PHP)
# =========================
FROM php:8.1-cli AS base

# Set working directory
WORKDIR /app

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpq-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        curl \
        zip \
        mbstring \
        xml \
        bcmath \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# =========================
# STAGE 2: Builder (install dependencies + RoadRunner)
# =========================
FROM base AS builder

# Install PHP dependencies
COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress --ignore-platform-reqs --no-scripts

# Download and install RoadRunner
RUN curl -sSL https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/roadrunner-2023.3.8-linux-amd64 -o /usr/local/bin/rr \
    && chmod +x /usr/local/bin/rr

# Copy application source code
COPY . .

# =========================
# STAGE 3: Final (production)
# =========================
FROM base AS final

# Set working directory
WORKDIR /app

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser:appuser /app

# Copy application files from builder stage
COPY --from=builder /app /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Start RoadRunner
CMD ["/usr/local/bin/rr", "serve"]
