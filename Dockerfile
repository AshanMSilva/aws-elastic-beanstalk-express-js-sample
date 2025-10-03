FROM node:16

# Create app directory
WORKDIR /app

# Copy package files and install
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy app source
COPY . .

# Start app
CMD ["npm", "start"]