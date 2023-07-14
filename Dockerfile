# Base image
FROM php:8.2-fpm

# Install dependencies for PHP extensions and PECL
RUN apt-get update && apt-get install -y \
    libgmp-dev \
    libicu-dev \
    libzip-dev \
    unzip \
    libonig-dev \
    libpng-dev \
    zlib1g-dev \
    libxml2-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libreadline-dev \
    libxslt1-dev \
    autoconf \
    gcc \
    make \
    g++ \
    libc-dev \
    pkg-config \
    libssl-dev

# Configure and install bcmath, gmp, intl, mysqli, soap and opcache
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure gmp \
    && docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mbstring exif pcntl bcmath gmp intl mysqli soap opcache \
    && docker-php-ext-enable mysqli soap opcache

# Install dom, xml and xmlwriter PHP extensions
RUN docker-php-ext-install dom xml xmlwriter

# Install redis using PECL
RUN pecl install redis \
    && docker-php-ext-enable redis

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# Set node version
ARG NODE_VERSION=18

# Install node
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs

# Confirm installation
RUN node --version && npm --version

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install yarn

RUN echo 'max_input_vars = 5000' >> /usr/local/etc/php/conf.d/docker-php-max_input_vars.ini

# Add user for application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

RUN mkdir /var/moodledata && chown -R www-data:www-data /var/moodledata
RUN chmod 0777 /var/moodledata

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

EXPOSE 9000
CMD ["php-fpm"]
