# Этап сборки
FROM node:18-alpine AS build

# Устанавливаем необходимые системные зависимости
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Устанавливаем pnpm
RUN npm install -g pnpm

# Копируем файлы с зависимостями
COPY package.json pnpm-lock.yaml ./

# Устанавливаем зависимости (разрешаем сборку native модулей)
RUN pnpm install --no-frozen-lockfile

# Копируем остальные файлы
COPY . .

# Собираем проект
RUN pnpm run build

# Этап раздачи статики
FROM nginx:alpine

# Копируем собранные файлы из этапа сборки
COPY --from=build /app/dist /usr/share/nginx/html

# Копируем конфиг nginx (если есть)
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]