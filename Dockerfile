# Use PHP 8.1 CLI as the base image
FROM php:8.1-cli AS base

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies and PHP extensions in a single layer
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpq-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libzip-dev \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        curl \
        zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install RoadRunner
RUN curl -sSL https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/roadrunner-2023.3.8-linux-amd64 -o /usr/local/bin/rr \
    && chmod +x /usr/local/bin/rr

# Copy only composer files first to leverage Docker cache
COPY composer.json composer.lock ./

# Debugging steps
RUN echo "Checking PHP extensions:" && php -m \
    && echo "Composer version:" && composer --version \
    && echo "PHP configuration:" && php --ini

# Install dependencies with retry mechanism
RUN composer clear-cache \
    && (composer install \
        --no-dev \
        --optimize-autoloader \
        --no-interaction \
        --no-progress \
        --timeout=300 \
        -vvv || (echo "Composer install failed, retrying..." && composer install \
        --no-dev \
        --optimize-autoloader \
        --no-interaction \
        --no-progress \
        --timeout=600 \
        -vvv))

# Copy the rest of the application files
COPY . .

# Expose port for RoadRunner
EXPOSE 8080

# Start RoadRunner server
CMD ["/usr/local/bin/rr", "serve"]
