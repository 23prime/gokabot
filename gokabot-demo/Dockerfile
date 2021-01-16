FROM node:15.3.0-alpine3.12

WORKDIR /app

COPY package.json ./
RUN yarn install

COPY . ./
