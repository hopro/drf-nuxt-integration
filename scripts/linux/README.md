# Установка Django и Nuxt.js как службы на Linux (systemd)

В этой директории содержатся файлы настройки служб systemd для запуска Django и Nuxt.js.

## Предварительные требования

1. Убедитесь, что на сервере установлены все необходимые зависимости:
   - Python и Pip
   - Node.js и npm
   - Виртуальное окружение для Django (в директории `backend/venv`)
   - Все зависимости проекта (из директорий `offline_packages/linux`)

## Установка Django как службы

1. Отредактируйте файл `django.service`, указав правильные пути к директориям проекта и пользователя/группу, от имени которых будет запускаться служба.

2. Скопируйте файл службы в системную директорию:
   ```
   sudo cp scripts/linux/django.service /etc/systemd/system/
   ```

3. Перезагрузите диспетчер служб systemd:
   ```
   sudo systemctl daemon-reload
   ```

4. Включите службу для автозапуска при старте системы:
   ```
   sudo systemctl enable django.service
   ```

5. Запустите службу:
   ```
   sudo systemctl start django.service
   ```

6. Проверьте статус службы:
   ```
   sudo systemctl status django.service
   ```

## Установка Nuxt.js как службы

1. Отредактируйте файл `nuxt.service`, указав правильные пути к директориям проекта и пользователя/группу, от имени которых будет запускаться служба.

2. Скопируйте файл службы в системную директорию:
   ```
   sudo cp scripts/linux/nuxt.service /etc/systemd/system/
   ```

3. Перезагрузите диспетчер служб systemd:
   ```
   sudo systemctl daemon-reload
   ```

4. Включите службу для автозапуска при старте системы:
   ```
   sudo systemctl enable nuxt.service
   ```

5. Запустите службу:
   ```
   sudo systemctl start nuxt.service
   ```

6. Проверьте статус службы:
   ```
   sudo systemctl status nuxt.service
   ```

## Управление службами

Для управления установленными службами вы можете использовать стандартные команды systemd:

```
sudo systemctl start django.service
sudo systemctl stop django.service
sudo systemctl restart django.service
sudo systemctl status django.service

sudo systemctl start nuxt.service
sudo systemctl stop nuxt.service
sudo systemctl restart nuxt.service
sudo systemctl status nuxt.service
```

## Просмотр логов

Для просмотра логов служб используйте journalctl:

```
sudo journalctl -u django.service
sudo journalctl -u nuxt.service
```

Для просмотра логов в реальном времени:

```
sudo journalctl -u django.service -f
sudo journalctl -u nuxt.service -f
``` 