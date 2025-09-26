# Node 16 base as required by assignment
FROM node:16-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package files and install (use ci for deterministic install)
COPY package*.json ./
RUN npm ci --only=production

# Copy app source
COPY . .

# Expose port
EXPOSE 8080

# Start app
CMD ["node", "app.js"]
