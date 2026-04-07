# Use the official, lightweight Nginx image
FROM nginx:alpine

# Copy your custom index.html into the Nginx server directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 (Matches the containerPort in app-deployment.yaml)
EXPOSE 80