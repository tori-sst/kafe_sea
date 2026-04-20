# Этап сборки
FROM node:18-alpine AS build
WORKDIR /app
RUN npm install -g pnpm
COPY package.json pnpm-lock.yaml ./
RUN pnpm install
COPY . .
# Передаем переменную окружения прямо в сборку
ARG STRAPI_URL
ENV STRAPI_URL=$STRAPI_URL
RUN pnpm run build

# Этап раздачи статики
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]