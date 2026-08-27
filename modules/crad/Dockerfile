FROM php:8.2-apache

# Install PHP MySQL extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache rewrite
RUN a2enmod rewrite

# Copy project
COPY . /var/www/html/

WORKDIR /var/www/html/

# Configure Apache to listen on the port provided by HostForge
CMD ["sh", "-c", "sed -i \"s/Listen 80/Listen ${PORT:-8080}/\" /etc/apache2/ports.conf && sed -i \"s/<VirtualHost \\*:80>/<VirtualHost *:${PORT:-8080}>/\" /etc/apache2/sites-available/000-default.conf && apache2-foreground"]