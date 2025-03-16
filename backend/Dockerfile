# Используем официальный образ Python
FROM python:3.8-slim

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libpq-dev \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы backend
COPY backend /app

# Устанавливаем зависимости из PyPI
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install python-decouple django-rest-swagger

# Создаем .env файл с необходимыми переменными окружения
RUN echo "DEBUG=True" > .env \
    && echo "SECRET_KEY=django-insecure-_secret-key_here" >> .env \
    && echo "DATABASE_URL=sqlite:///db.sqlite3" >> .env \
    && echo "ALLOWED_HOSTS=localhost,127.0.0.1" >> .env \
    && echo "CORS_ALLOWED_ORIGINS=http://localhost:3000" >> .env \
    && echo "STATIC_URL=/static/" >> .env \
    && echo "MEDIA_URL=/media/" >> .env \
    && echo "EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend" >> .env \
    && echo "TIME_ZONE=Asia/Yekaterinburg" >> .env \
    && echo "LANGUAGE_CODE=ru" >> .env

# Устанавливаем переменные окружения
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Выполняем миграции и собираем статические файлы
RUN python manage.py collectstatic --noinput || true
RUN python manage.py migrate || true

# Запускаем сервер
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "mysite.wsgi:application"]