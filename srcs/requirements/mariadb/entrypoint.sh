#!/bin/bash
set -e

# Start MariaDB in the background
service mariadb start

# Wait for MariaDB to be fully ready
until mysqladmin ping --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done

echo "MariaDB is up and running!"

# Run initialization only if the database does not exist
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Initializing database..."
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    echo "Database and user created!"
else
    echo "Database already exists, skipping initialization."
fi

# Stop the background MariaDB process
service mariadb stop

# Start MariaDB in the foreground as the main process
exec mariadbd
