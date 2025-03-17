# Документация по проекту

## Краткое описание проекта

Это веб-приложение с клиент-серверной архитектурой на Nuxt 3 и Django REST Framework. Оно поддерживает авторизацию, работу с контентом, аналитику и мультиязычность.

## Архитектура проекта

Проект представляет собой современное веб-приложение, построенное на стеке:

- Frontend: Nuxt 3 (Vue.js) с Vuetify 
- Backend: Django REST Framework
- Аутентификация: JWT (JSON Web Tokens)
- Документация API: OpenAPI (Swagger)

## Требования

- Python 3.10+
- Node.js 18+
- Django 4.2+
- NPM 10+

## Назначение

Проект является полноценным веб-приложением демонстрирующим клиент-серверную архитектуру
с возможностями:

- Авторизацию и аутентификацию
- Отображение данных моделей в виде таблиц и форм
- Блог
- Возможность загрузки файлов и мультимедиа
- Аналитику
- Многоязычность (i18n)

## Руководство для пользователей

### Начало работы

1. Регистрация и вход
   - Перейдите на страницу входа/регистрации
   - Создайте аккаунт или войдите в существующий
   - После успешной аутентификации вы получите JWT токен
   - В профиле вы можете изменить свои данные (имя, email, аватар и тд)

2. Основные функции
   - Просмотр, создание, редактирование и удаление записей в моделях Django
   - Управление личным кабинетом пользователя
   - Графики и диаграммы
   - Возможность загрузки файлов и мультимедиа

### Интерфейс

- Современный адаптивный дизайн на основе Vuetify
- Поддержка мобильных устройств
- Поддержка светлой и темной темы
- Многоязычный интерфейс
- Интуитивно понятная навигация

## Руководство для администраторов

### Административные функции

Управление административными функциями осуществляется через админку Django.
Документацию по Django ищи по ссылке: https://docs.djangoproject.com/en/4.2/
Админка доступна по адресу: http://localhost:8000/admin/

1. Управление пользователями
   - Создание/удаление пользователей
   - Управление правами доступа
   - Модерация контента

2. Управление контентом
   - Управление записями в таблицах моделей
   - Управление записями в блоге
   - Управление медиафайлами

3. Системные настройки
   - Настройка JWT токенов
   - Настройка CORS

### Безопасность

- JWT аутентификация
- CORS защита
- Безопасное хранение паролей
- Защита от CSRF атак

## Техническая документация

### API

API схема доступна по адресу: http://localhost:8000/api/schema/
SWAGGER UI доступен по адресу: http://localhost:8000/api/schema/swagger/

Также управлять API можно через встроенный набор представлений restframework
Документация по Django REST Framework: https://www.django-rest-framework.org/

### База данных

- Использование Django ORM
- Настройки базы задаются через .env
- Миграции через python manage.py migrate
- Резервное копирование через python manage.py dumpdata

### Развертывание

Для компьютеров без интернета можно воспользоваться архивом 

#### Backend

1. Создание и активация виртуального окружения
   ```bash
   python -m venv venv
   source venv/bin/activate  # Unix/macOS
   .\venv\Scripts\activate   # Windows
   ```

2. Установка зависимостей
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   pip install django-debug-toolbar  # опционально
   pip install black  # опционально
   pip install flake8  # опционально
   ```

3. Настройка переменных окружения
   ```bash
   touch .env
   DEBUG=True
   SECRET_KEY=django-insecure-_secret-key_here
   DATABASE_URL=sqlite:///db.sqlite3
   ALLOWED_HOSTS=localhost,127.0.0.1
   CORS_ALLOWED_ORIGINS=http://localhost:3000
   STATIC_URL=/static/
   MEDIA_URL=/media/
   EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
   TIME_ZONE=Asia/Yekaterinburg
   LANGUAGE_CODE=ru
   ```

4. Настройка базы данных
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   python manage.py createsuperuser
   ```

5. Сборка статических файлов
   ```bash
   python manage.py collectstatic
   ```

6. Запуск сервера разработки
   ```bash
   python manage.py runserver
   ```

#### Frontend (Nuxt)

1. Установка Node.js
   ```bash
   node -v  # проверка версии
   nvm install 16  # установка через nvm
   nvm use 16
   ```

2. Установка зависимостей
   ```bash
   cd frontend
   npm install
   # или
   yarn install
   npm install -D @nuxtjs/eslint-config-typescript  # опционально
   npm install -D prettier  # опционально
   ```

3. Настройка переменных окружения
   ```bash
   touch .env
   API_BASE_URL=http://localhost:8000
   NODE_ENV=development
   ```

4. Генерация типов API
   ```bash
   cd frontend
   npm run openapi
   ```

5. Запуск сервера разработки
   ```bash
   cd frontend
   npm run dev
   # или
   yarn dev
   ```

6. Сборка для продакшена
   ```bash
   cd frontend
   npm run build
   npm run preview
   ```

### Настройка Gunicorn

Gunicorn используется для запуска Django-приложения в продакшене. Настройка включает в себя создание файла службы и конфигурацию.

1. Установка Gunicorn
   ```bash
   pip install gunicorn
   ```

2. Создание файла службы
   ```bash
   sudo nano /etc/systemd/system/gunicorn.service
   ```

3. Добавление конфигурации
   ```bash
   [Unit]
   Description=gunicorn daemon
   After=network.target

   [Service]
   User=www-data
   Group=www-data
   WorkingDirectory=/path/to/your/project
   ExecStart=/path/to/your/venv/bin/gunicorn --workers 3 --bind unix:/path/to/your/project.sock myproject.wsgi:application

   [Install]
   WantedBy=multi-user.target
   ```

4. Перезапуск службы
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start gunicorn
   sudo systemctl enable gunicorn
   ```

### Структура проекта после установки
   ```bash
   project/
   ├── backend/
   │ ├── venv/
   │ ├── manage.py
   │ ├── requirements.txt
   │ ├── .env
   │ └── ...
   └── frontend/
   ├── node_modules/
   ├── .env
   ├── package.json
   └── ...
   ```

### Проверка работоспособности

1. Backend

   ```bash
   curl http://localhost:8000/api/schema/
   http://localhost:8000/api/admin/
   ```

2. Frontend
   ```bash
   curl http://localhost:3000
   http://localhost:3000
   ```

### Продакшен

1. Сборка для продакшена

   ```bash
   cd frontend
   npm run build
   npm run preview
   ```

2. Настройка Nginx
   Установка Nginx

   ```bash
   sudo apt update
   sudo apt install nginx
   ```

   Настройка Nginx
   Создание файла конфигурации

   ```bash
   sudo nano /etc/nginx/sites-available/mysite
   ```

   Добавление конфигурации

   ```bash
   server {
       listen 80;
       server_name localhost;

    location / {
        return 301 https://$host$request_uri;
    }
   }

   server {
      listen 443 ssl;
      server_name localhost;

      include snippets/self-signed.conf;
      include snippets/ssl-params.conf;

      location / {
         proxy_pass http://127.0.0.1:3000;
         proxy_set_header Host $host;
         proxy_set_header X-Real-IP $remote_addr;
         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header X-Forwarded-Proto $scheme;
      }

      location /api {
         proxy_pass http://unix:/root/site/backend/mysite/django.sock;
         proxy_set_header Host $host;
         proxy_set_header X-Real-IP $remote_addr;
         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header X-Forwarded-Proto $scheme;
      }

      location /static/ {
         alias /src/site/backend/static/;
      }

      location /media/ {
         alias /src/site/backend/media/;
      }
   }
   ```

   Проверка конфигурации

   ```bash
   sudo nginx -t
   ```

   Перезапуск Nginx

   ```bash
   sudo systemctl restart nginx
   ```

   Django service
   Создание файла службы

   ```bash
   sudo nano /etc/systemd/system/django.service
   ```

   Добавление конфигурации

   ```bash
   [Unit]
   Description=Django Application
   After=network.target

   [Service]
   User=root
   Group=www-data
   WorkingDirectory=/root/site/backend
   ExecStart=/root/site/backend/myenv/bin/gunicorn --workers 3 --bind unix:/root/site/backend/mysite/django.sock mysite.wsgi:application

   [Install]
   WantedBy=multi-user.target
   ```

   Перезапуск службы

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start django
   sudo systemctl enable django
   ```

   Nuxt service
   Создание файла службы

   ```bash
   sudo nano /etc/systemd/system/nuxt.service
   ```

   Добавление конфигурации

   ```bash
   [Unit]
   Description=Nuxt.js Application
   After=network.target

   [Service]
   User=root
   Group=www-data
   WorkingDirectory=/root/site/frontend
   ExecStart=/root/.nvm/versions/node/v22.14.0/bin/npm run start
   Environment=PATH=/root/.nvm/versions/node/v22.14.0/bin:/usr/bin:/bin
   Environment=NODE_ENV=production

   [Install]
   WantedBy=multi-user.target
   ```

   Перезапуск службы

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start nuxt
   sudo systemctl enable nuxt
   ```

### Дополнительные рекомендации

1. Для разработки

   - Используйте django-debug-toolbar для отладки
   - Настройте линтеры и форматтеры
   - Используйте pre-commit хуки

2. Для продакшена

   - Настройте HTTPS
   - Используйте WSGI сервер (например, Gunicorn)
   - Настройте Nginx как reverse proxy
   - Используйте переменные окружения для конфиденциальных данных
   - Настройте мониторинг и логирование

3. Безопасность
   - Регулярно обновляйте зависимости
   - Проверяйте уязвимости через npm audit и pip-audit
   - Используйте безопасные настройки CORS
   - Настройте rate limiting для API

## Обновление системы

1. Обновление frontend
   cd frontend
   git pull
   npm install
   npm run build

2. Обновление backend
   cd backend
   git pull
   pip install -r requirements.txt
   python manage.py migrate
   python manage.py collectstatic

## Устранение неполадок

1. Проблемы с аутентификацией

   - Проверьте срок действия JWT токена
   - Очистите кэш браузера
   - Проверьте настройки CORS

2. Проблемы с базой данных

   - Проверьте миграции: python manage.py showmigrations
   - Создайте резервную копию: python manage.py dumpdata
   - Проверьте логи Django

3. Проблемы с frontend
   - Очистите кэш npm: npm cache clean --force
   - Удалите node_modules и переустановите зависимости
   - Проверьте консоль браузера на наличие ошибок

## Лицензия

Проект распространяется под лицензией MIT.

## Контакты

Для связи с командой разработчиков, пожалуйста, используйте email: support@example.com

## Вклад в проект

Мы приветствуем вклад в проект! Пожалуйста, следуйте стандартам кодирования и отправляйте pull requests через GitHub. Убедитесь, что ваш код проходит все тесты и соответствует стилю проекта.

## Развертывание из архива без доступа к интернету

### Подготовка окружения

1. Убедитесь, что на целевом компьютере установлены Python и Node.js. Если они не установлены, скачайте установочные файлы на компьютер с доступом к интернету и перенесите их на целевой компьютер.

### Перенос архива проекта

1. Перенесите архив `project.zip`, созданный с помощью `make`, на целевой компьютер. Вы можете использовать USB-накопитель или другой способ передачи данных.

### Распаковка архива

1. Распакуйте архив `project.zip` в нужную директорию на целевом компьютере.

### Установка Python-зависимостей

1. Откройте командную строку и перейдите в директорию, где находится проект.
2. Активируйте виртуальное окружение:
   ```bash
   .\backend\venv\Scripts\activate
   ```
3. Установите Python-зависимости из локальной директории:
   ```bash
   pip install --no-index --find-links=offline_packages -r backend/requirements.txt
   ```

### Установка Node.js-зависимостей

1. Перейдите в директорию `frontend`:
   ```bash
   cd frontend
   ```
2. Установите Node.js-зависимости из локального архива:
   ```bash
   npm install --offline
   ```

### Настройка переменных окружения

1. Убедитесь, что все необходимые переменные окружения настроены. Вы можете использовать файл `.env` для этого.

### Запуск сервера

1. Для запуска backend-сервера выполните:
   ```bash
   python manage.py runserver
   ```
2. Для запуска frontend-сервера выполните:
   ```bash
   npm run dev
   ```
