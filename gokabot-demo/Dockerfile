FROM node:14.17.5-alpine3.12

WORKDIR /app

COPY package.json ./
RUN yarn install

COPY . ./
