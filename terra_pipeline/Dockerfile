FROM node:18-alpine

WORKDIR /app

COPY portfolio/package*.json ./
RUN npm install

COPY portfolio/ .

EXPOSE 3000

CMD ["npm", "start"]
