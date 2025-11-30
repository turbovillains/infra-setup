# syntax = docker/dockerfile:1

ARG IMAGE_REGISTRY=cr.noroutine.me
ARG NODE_VERSION=lts

FROM ${IMAGE_REGISTRY}/library/node:${NODE_VERSION} AS base

WORKDIR /app

FROM base AS build

COPY . .

RUN npm install
RUN npm run build

#Production stage
FROM base AS production

COPY --from=build /app/dist /app/dist
COPY --from=build /app/node_modules /app/node_modules

EXPOSE 8000

CMD ["node", "dist/index.js"]