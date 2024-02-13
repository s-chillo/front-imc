ARG NODE_VERSION=20.10.0

FROM node:${NODE_VERSION}-alpine as base

WORKDIR /usr/src/app

FROM base as deps

RUN --mount=type=bind,source=package.json,target=package.json \
  --mount=type=bind,source=package-lock.json,target=package-lock.json \
  --mount=type=cache,target=/root/.npm \
  npm ci --omit=dev

FROM deps as build

RUN --mount=type=bind,source=package.json,target=package.json \
  --mount=type=bind,source=package-lock.json,target=package-lock.json \
  --mount=type=cache,target=/root/.npm \
  npm ci

COPY . .
RUN npm run build 

FROM nginx:1.23.3-alpine
COPY --from=build /usr/src/app/dist /usr/share/nginx/html/
COPY --from=build /usr/src/app/web-imc.conf /etc/nginx/conf.d/web-imc.conf
EXPOSE 80