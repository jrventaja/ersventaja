FROM node:14-slim AS build
WORKDIR /app
COPY / ./
COPY package*.json ./
RUN npm install -g @angular/cli && \
npm install && \
ng build --prod=true

FROM httpd:latest
COPY --from=build ./app/dist/rsventajaweb /usr/local/apache2/htdocs/