FROM nginx:alpine

# Install openssl for certificate generation
RUN apk add --no-cache openssl

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create directory for certificates and add dummy certs if not provided
RUN mkdir -p /etc/nginx/certs && \
    if [ ! -f /etc/nginx/certs/nginx-selfsigned.crt ]; then \
        echo "Creating dummy SSL certificate" && \
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/certs/nginx-selfsigned.key \
        -out /etc/nginx/certs/nginx-selfsigned.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"; \
    fi

# Expose both HTTP and HTTPS ports
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"] 