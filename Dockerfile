# Use the official PHP image
FROM php:8.2-fpm

# Install system dependencies and Node.js
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    git \
    libonig-dev \
    libxml2-dev \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_21.x | bash - \
    && apt-get install -y nodejs \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip mysqli pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . /var/www

# Copy Composer configuration and install PHP dependencies
COPY composer.json composer.lock ./
RUN composer install

# Set environment variable for node modules binaries
ENV PATH /var/www/node_modules/.bin:$PATH

# Install Node.js packages and Vite
RUN npm install -g npm@latest \
    && npm install \
    && npm install -g vite

# Build the Vue.js application
RUN npm run build

# Expose port 9000 and start PHP-FPM server
EXPOSE 9000
CMD ["php-fpm"]
