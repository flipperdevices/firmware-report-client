FROM node:lts-alpine as build-stage

COPY app /app

WORKDIR /app

RUN npm install 

RUN npm run build

RUN npx pkg ./node_modules/@import-meta-env/cli/bin/import-meta-env.js -t node16-alpine -o import-meta-env

FROM nginx:stable-alpine as production

RUN rm -rf /etc/nginx/conf.d/*

COPY --from=build-stage /app/nginx-site.conf /etc/nginx/conf.d/nginx-site.conf

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build-stage /app/dist /usr/share/nginx/html/dist

COPY --from=build-stage /app/import-meta-env /usr/share/nginx/html/import-meta-env

COPY app/.env.example /usr/share/nginx/html/.env.example

COPY app/import-meta-env.sh /docker-entrypoint.d/import-meta-env.sh

RUN chmod +x /docker-entrypoint.d/import-meta-env.sh

RUN chmod +x /usr/share/nginx/html/import-meta-env