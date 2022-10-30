FROM node:10

RUN mkdir -p /home/node/app && chown -R node:node /home/node/app

WORKDIR /home/node/app

USER node

COPY --chown=node:node . .

RUN npm install

CMD ["node", "src/000.js"]

EXPOSE 3000
