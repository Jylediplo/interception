-- Create the WordPress database
CREATE DATABASE wordpress;

-- Create the admin user
CREATE USER 'admin_user'@'%' IDENTIFIED BY 'admin_password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'admin_user'@'%' WITH GRANT OPTION;

-- Create a regular user
CREATE USER 'wp_user'@'%' IDENTIFIED BY 'wp_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON wordpress.* TO 'wp_user'@'%';

-- Apply privileges
FLUSH PRIVILEGES;
