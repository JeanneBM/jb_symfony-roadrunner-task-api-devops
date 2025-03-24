# Use PHP 8.1 CLI as the base image
FROM php:8.1-cli AS base

# Set the working directory inside the container
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

# Install Composer properly with PATH setup
ENV PATH="/usr/bin:${PATH}"
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer --version

# Install RoadRunner
RUN curl -sSL https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/roadrunner-2023.3.8-linux-amd64 -o /usr/local/bin/rr \
    && chmod +x /usr/local/bin/rr

# Verify basic commands work
RUN which php && which composer && php -v && composer --version

# First copy only composer files to leverage Docker cache
COPY composer.json composer.lock ./

# Install dependencies with multiple fallbacks
RUN { \
    composer clear-cache && \
    COMPOSER_MEMORY_LIMIT=-1 composer install \
        --no-dev \
        --optimize-autoloader \
        --no-interaction \
        --no-progress \
        --ignore-platform-reqs \
        --prefer-dist \
        -vvv || \
    { \
        echo "First attempt failed, trying without lock file..." && \
        rm -f composer.lock && \
        COMPOSER_MEMORY_LIMIT=-1 composer install \
            --no-dev \
            --optimize-autoloader \
            --no-interaction \
            --no-progress \
            --ignore-platform-reqs \
            --prefer-dist \
            -vvv; \
    }; \
}

# Copy the rest of application files
COPY . .

EXPOSE 8080

CMD ["/usr/local/bin/rr", "serve"]
