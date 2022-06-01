FROM node:14
# Create app directory
WORKDIR /app
COPY package*.json ./
RUN yarn install
# If you are building your code for production
# RUN npm ci --only=production
# copy all files into the image
COPY . .
# to expose application on 5000 port
EXPOSE 3000
CMD ["yarn", "run", "start"]