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

# Start PHP-FPM
exec php-fpm7.4 --nodaemonize
