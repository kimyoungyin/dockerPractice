FROM node:18.15.0-alpine

WORKDIR /app

COPY package.json /app

RUN npm install

COPY . /app

ENV PORT 80

EXPOSE $PORT

CMD [ "npm", "start" ]