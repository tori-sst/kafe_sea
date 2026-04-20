FROM node:20-alpine AS builder

RUN apk add --no-cache python3 make g++

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml ./

# Отключаем PostCSS и Tailwind для сборки
RUN pnpm install --no-frozen-lockfile

COPY . .

# Удаляем postcss.config.mjs временно
RUN mv postcss.config.mjs postcss.config.mjs.bak || true

# Собираем без PostCSS
RUN pnpm run build

# Возвращаем конфиг (на всякий случай)
RUN mv postcss.config.mjs.bak postcss.config.mjs || true

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]