FROM node:20-alpine AS builder

# Устанавливаем зависимости для сборки нативных модулей (если нужны)
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Устанавливаем pnpm
RUN npm install -g pnpm

# Копируем файлы зависимостей
COPY package.json pnpm-lock.yaml ./

# Устанавливаем всё честно
RUN pnpm install --no-frozen-lockfile

# Копируем весь проект (включая tailwind.config.mjs и postcss.config.mjs)
COPY . .

# Собираем проект (Tailwind отработает сам внутри этой команды)
RUN pnpm run build

# Финальный этап: отдаем статику через Nginx
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]