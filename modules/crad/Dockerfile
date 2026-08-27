FROM php:8.2-apache

# Install MySQL support
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache rewrite
RUN a2enmod rewrite

# Copy the SMS2 project into Apache's web directory
COPY . /var/www/html/

# Set the working directory
WORKDIR /var/www/html/

# Allow Apache to use port 3000
RUN sed -i 's/Listen 80/Listen 3000/' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:3000>/' /etc/apache2/sites-available/000-default.conf

EXPOSE 3000

CMD ["apache2-foreground"]