FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    libpq-dev \
    unzip \
    && pecl install xdebug

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure PHP extensions
RUN docker-php-ext-configure zip

# Xdebug
RUN docker-php-ext-enable xdebug

# Install PHP extensions
RUN docker-php-ext-install zip pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# php.ini
COPY docker-compose/php/custom.ini /usr/local/etc/php/conf.d/

# nginx.conf
COPY docker-compose/nginx/upload.conf /etc/nginx/conf.d/

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user
