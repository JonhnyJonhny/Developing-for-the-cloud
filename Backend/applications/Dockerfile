# application/Dockerfile

# 1. Use an official base image (e.g., Node.js, Python, or .NET)
FROM node:18-alpine 

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Copy your dependency files and install them
COPY package*.json ./
RUN npm install

# 4. Copy the rest of your application code
COPY . .

# 5. Expose the port your app runs on
EXPOSE 8080

# 6. Command to start your app
CMD ["npm", "start"]