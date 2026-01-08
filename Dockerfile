FROM php:7.4-apache

# Extensões comuns (ajuste se precisar de mais)
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install pdo pdo_mysql zip gd \
  && a2enmod rewrite headers \
  && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copia tudo
COPY . .

# (Opcional) Se seu arquivo é htaccess.txt, renomeia para .htaccess
# Se já existir .htaccess, remova esta linha.
RUN if [ -f "htaccess.txt" ] && [ ! -f ".htaccess" ]; then cp htaccess.txt .htaccess; fi

# Permissões (ajuste conforme o projeto usa /storage)
RUN chown -R www-data:www-data /var/www/html \
 && find /var/www/html -type d -exec chmod 755 {} \; \
 && find /var/www/html -type f -exec chmod 644 {} \;

# Instala dependências PHP
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

EXPOSE 80
