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

# Copy application files into the container
COPY . .

# Debugging step: Verify Composer is installed correctly
RUN composer --version

# Debugging step: Check if required PHP extensions are enabled
RUN php -m

# Clear Composer cache and install dependencies
RUN composer clear-cache && \
    composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress \
    --timeout=300 \
    -v

# Expose port for RoadRunner
EXPOSE 8080

# Start RoadRunner server
CMD ["/usr/local/bin/rr", "serve"]
