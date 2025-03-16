# Используем официальный образ Node.js
FROM node:18

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы frontend
COPY frontend /app

# Создаем .env файл с необходимыми переменными окружения
RUN echo "API_BASE_URL=http://backend:8000" > .env \
    && echo "NODE_ENV=development" >> .env

# Устанавливаем зависимости
RUN npm install

# Собираем проект
RUN npm run build

# Запускаем сервер
CMD ["npm", "run", "dev"]