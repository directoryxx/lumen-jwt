FROM php:7.1-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
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
    curl \
    bash \
    libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql


RUN docker-php-ext-install opcache

COPY docker/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# install nodejs
RUN apt-get -y install software-properties-common

RUN curl -sL https://deb.nodesource.com/setup_10.x -o node.sh

RUN chmod +x node.sh

RUN bash node.sh

RUN apt-get -y install nodejs

RUN node -v

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
 

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl 
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

RUN composer install

#RUN cp .env.example .env

#RUN php artisan key:generate

#RUN php artisan migrate:refresh --seed

#RUN npm run dev

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www


# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
