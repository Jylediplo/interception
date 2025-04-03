# # Use Debian 11 as the base image
# FROM debian:11

# # Install PHP 7.4, PHP-FPM, and required extensions
# RUN apt-get update && apt-get install -y \
#     php7.4-fpm \
#     php7.4-mysql \
#     php7.4-curl \
#     curl \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# # Create directory for PHP-FPM socket
# RUN mkdir -p /var/run/php && chown -R www-data:www-data /var/run/php

# # Download and extract WordPress
# RUN mkdir -p /var/www/html \
#     && curl -O https://wordpress.org/latest.tar.gz \
#     && tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 \
#     && rm latest.tar.gz

# # Copy the PHP-FPM configuration
# COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf

# # Expose port 9000 for PHP-FPM
# EXPOSE 9000

# # Start PHP-FPM
# CMD ["php-fpm7.4", "--nodaemonize"]

# Use Debian 11 as the base image
FROM debian:11

# Install PHP, PHP-FPM, and required extensions
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    default-mysql-client \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create directory for PHP-FPM socket
RUN mkdir -p /var/run/php && chown -R www-data:www-data /var/run/php

# Download and extract WordPress
RUN mkdir -p /var/www/html \
    && curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 \
    && rm latest.tar.gz

# Copy startup script into the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy PHP-FPM configuration
COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Run the entrypoint script, then start PHP-FPM
CMD ["/entrypoint.sh"]
