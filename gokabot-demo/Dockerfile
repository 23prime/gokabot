FROM node:16.17.0-slim

WORKDIR /app

COPY package.json ./
RUN yarn install

COPY . ./
