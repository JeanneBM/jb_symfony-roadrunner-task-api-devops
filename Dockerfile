# Base image with PHP 8.1 CLI
FROM php:8.1-cli AS base

# Set working directory
WORKDIR /app

# Install system dependencies and PHP extensions in a single layer
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpq-dev \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install RoadRunner
RUN curl -L https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/roadrunner-2023.3.8-linux-amd64 -o /usr/local/bin/rr \
    && chmod +x /usr/local/bin/rr

# Copy application files
COPY . .

# Install PHP dependencies and optimize
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress

# Expose port for RoadRunner
EXPOSE 8080

# Start RoadRunner server
CMD ["/usr/local/bin/rr", "serve"]
