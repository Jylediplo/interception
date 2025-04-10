#!/bin/bash
set -e

# Start MariaDB in the background
mysqld_safe --skip-networking &
pid="$!"

# Wait for MariaDB to be ready
until mysqladmin ping --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done

echo "MariaDB is up and running!"

# Run initialization if necessary
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
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Start MariaDB in the foreground
exec mysqld
