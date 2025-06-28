FROM debian:bullseye


RUN apt-get update && apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld && chmod 775 /run/mysqld


COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh .

EXPOSE 3306
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

# Start MariaDB
CMD ["mariadbd"]
