#!/bin/bash


# Start MariaDB service
echo "Starting MariaDB service..."
service mariadb start
until mariadb -u root -e "SELECT 1" &> /dev/null; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
done

echo "Initializing database..."

mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_ROOT_USER}'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL ON *.* TO '${MYSQL_ROOT_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Stopping MariaDB service..."

service mariadb stop

exec "$@"
