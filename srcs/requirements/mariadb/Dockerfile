# Use the second-to-last Debian version
FROM debian:bullseye

# Install MariaDB server
RUN apt-get update && apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Create required directories and set correct permissions
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld && chmod 775 /run/mysqld

# Copy initialization script
# COPY ./init.sql /docker-entrypoint-initdb.d/
# RUN docker-entrypoint-initdb.d/init.sql

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh .
# RUN service mariadb start

# RUN service mariadb stop

# Set user and expose port
EXPOSE 3306
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

# Start MariaDB
CMD ["mariadbd"]
