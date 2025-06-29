FROM debian:bullseye

# Install PHP, PHP-FPM, and required extensions
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    default-mysql-client \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create directory for PHP-FPM socket
RUN mkdir -p /var/run/php && chown -R www-data:www-data /var/run/php

# Download and extract WordPress
RUN mkdir -p /var/www/html \
    && curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 \
    && rm latest.tar.gz

# Copy startup script into the container
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Run the entrypoint script, then start PHP-FPM
CMD ["/entrypoint.sh"]
