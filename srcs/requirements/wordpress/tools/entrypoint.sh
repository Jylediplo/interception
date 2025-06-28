#!/bin/bash

# Exit immediately if a command exits with a non-zero status
# set -e

# Path to wp-config.php
CONFIG_FILE="/var/www/html/wp-config.php"

# Check if wp-config.php already exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating wp-config.php..."

    cat <<EOL > $CONFIG_FILE
<?php
define( 'DB_NAME', '${WORDPRESS_DB_NAME}' );
define( 'DB_USER', '${WORDPRESS_DB_USER}' );
define( 'DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}' );
define( 'DB_HOST', '${WORDPRESS_DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

/** Authentication Unique Keys and Salts */
define( 'AUTH_KEY',         '$(openssl rand -base64 32)' );
define( 'SECURE_AUTH_KEY',  '$(openssl rand -base64 32)' );
define( 'LOGGED_IN_KEY',    '$(openssl rand -base64 32)' );
define( 'NONCE_KEY',        '$(openssl rand -base64 32)' );
define( 'AUTH_SALT',        '$(openssl rand -base64 32)' );
define( 'SECURE_AUTH_SALT', '$(openssl rand -base64 32)' );
define( 'LOGGED_IN_SALT',   '$(openssl rand -base64 32)' );
define( 'NONCE_SALT',       '$(openssl rand -base64 32)' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOL

    echo "wp-config.php created!"
else
    echo "wp-config.php already exists. Skipping creation."
fi

# Wait for database to be ready
echo "Waiting for database connection..."
RETRIES=10
until mysql -h $WORDPRESS_DB_HOST -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -e "SELECT 1" >/dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
    echo "Waiting for database connection, $((RETRIES--)) remaining attempts..."
    sleep 5
done

if [ $RETRIES -eq 0 ]; then
    echo "Failed to connect to database. Continuing anyway..."
fi

# Install WordPress if not already installed
if ! $(wp core is-installed --allow-root --path=/var/www/html 2>/dev/null); then
    # Install wp-cli if not already installed
    if [ ! -f "/usr/local/bin/wp" ]; then
        echo "Installing wp-cli..."
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
    fi
    
    echo "Installing WordPress..."
    # Install WordPress core
    wp core install \
        --path=/var/www/html \
        --url="${WORDPRESS_URL}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "Creating standard user..."
    wp user create "${WORDPRESS_BASIC_USER}" "${WORDPRESS_BASIC_EMAIL}" \
        --user_pass="${WORDPRESS_BASIC_PASSWORD}" \
        --role="${WORDPRESS_BASIC_ROLE}" \
        --path=/var/www/html \
        --allow-root
    
    echo "WordPress installed with admin user: ${WORDPRESS_ADMIN_USER}"
else
    echo "WordPress is already installed."
fi

# Fix permissions
chown -R www-data:www-data /var/www/html


# Start PHP-FPM
exec php-fpm7.4 --nodaemonize