# Use a build argument to select the final stage (development or production)
ARG ENVIRONMENT=development

# STAGE 1: Builder
# This stage installs all build-time dependencies and tools.
FROM dunglas/frankenphp:1.7-php8.4-alpine AS builder

# Install build-time OS dependencies and PECL for extensions
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    curl-dev \
    git \
    icu-dev \
    libxml2-dev \
    libzip-dev \
    libpng-dev \
    oniguruma-dev \
    linux-headers \
    postgresql-dev

# Install PHP extensions using PECL for simplicity and standard practice
RUN pecl install redis-6.2.0 \
    && docker-php-ext-enable redis

# Install Excimer extension using PECL
RUN pecl channel-update pecl.php.net \
    && pecl install excimer \
    && docker-php-ext-enable excimer

# Install other extensions
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    gd \
    intl \
    pcntl \
    pdo_pgsql \
    mbstring \
    zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Install Supercronic
RUN curl -fsSLo /usr/local/bin/supercronic https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    && chmod +x /usr/local/bin/supercronic


# STAGE 2: Base
# This is the clean base for your final images, containing no build tools.
FROM dunglas/frankenphp:1.7-php8.4-alpine AS base

# Accept user/group IDs as arguments to avoid permission errors
ARG USER_ID=1000
ARG GROUP_ID=1000

# Copy only the necessary tools from the builder stage
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer
COPY --from=builder /usr/local/bin/supercronic /usr/local/bin/supercronic

# Copy compiled PHP extensions from the builder stage
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

# Copy extension configurations
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Install only RUNTIME OS dependencies
RUN apk add --no-cache icu-libs libxml2 libzip libpng oniguruma libpq

# Create a non-root user with the provided IDs. This is the main fix.
RUN addgroup -g ${GROUP_ID} -S appgroup && \
    adduser -u ${USER_ID} -S appuser -G appgroup

# Create and set permissions for Caddy data directory
RUN mkdir -p /data/caddy && chown -R appuser:appgroup /data


# STAGE 3: Development
# The development-specific image
FROM base AS development
# Re-declare ARGs for this stage
ARG USER_ID
ARG GROUP_ID

# Use development php.ini
RUN cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

# Create coverage directory and set correct ownership using the dynamic user
RUN mkdir -p /opt/phpstorm-coverage && \
    chown -R ${USER_ID}:${GROUP_ID} /opt/phpstorm-coverage


# STAGE 4: Production
# The production-specific image
FROM base AS production
# Use production php.ini
RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini


# FINAL STAGE
# Select the final image based on the ENVIRONMENT build argument
FROM ${ENVIRONMENT}

COPY ./config/Caddyfile /etc/frankenphp/Caddyfile

# Set the working directory
WORKDIR /srv

# Switch to the non-root user
USER appuser
