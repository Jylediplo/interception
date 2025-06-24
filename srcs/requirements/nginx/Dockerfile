# Use Debian 11 (Bullseye) as the base image
FROM debian:bullseye

# Install Nginx and OpenSSL
RUN apt update && apt install -y nginx openssl && rm -rf /var/lib/apt/lists/*

# Create necessary directories for SSL
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate a self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Copy the custom Nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
