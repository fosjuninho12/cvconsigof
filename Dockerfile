FROM php:7.4-apache

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && apt-get install -y \
    git unzip \
    libzip-dev zlib1g-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install \
      pdo pdo_mysql zip gd \
      mbstring intl xml bcmath opcache \
      exif fileinfo \
  && a2enmod rewrite headers \
  && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
  && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# Se existir htaccess.txt, cria .htaccess
RUN if [ -f "htaccess.txt" ] && [ ! -f ".htaccess" ]; then cp htaccess.txt .htaccess; fi

# Instala deps (usa composer.lock se existir)
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
