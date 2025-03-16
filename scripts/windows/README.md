# Установка Django и Nuxt.js как службы Windows

В этой директории содержатся скрипты для запуска Django и Nuxt.js в качестве служб Windows.

## Предварительные требования

1. Установите утилиту [NSSM (Non-Sucking Service Manager)](https://nssm.cc/download)
   - Скачайте последнюю версию NSSM
   - Распакуйте архив
   - Скопируйте `nssm.exe` в директорию, которая добавлена в системную переменную PATH, или укажите полный путь к nssm.exe в скриптах установки
   
   ### Добавление NSSM 
      
   1. Отредактируйте файлы `install_django_service.bat` и `install_nuxt_service.bat`
   2. Замените строку:
      ```
      set NSSM_PATH=nssm.exe
      ```
      на:
      ```
      set NSSM_PATH=C:\путь\к\директории\nssm.exe
      ```
      (укажите фактический путь к файлу nssm.exe)

2. Убедитесь, что на сервере установлены все необходимые зависимости:
   - Python и Pip
   - Node.js и npm
   - Виртуальное окружение для Django (в директории `backend/venv`)
   - Все зависимости проекта (из директорий `offline_packages/windows`)

## Установка Django как службы

1. Создайте директорию для логов:
   ```
   mkdir backend\logs
   ```

2. Запустите скрипт установки службы:
   Для оффлайн установки зависимости находятся в папке site/offline_packages/windows
   ```
   pip install --no-index --find-links=%OFFLINE_DIR% -r "%REQUIREMENTS_FILE%"
   ```
   ```
   scripts\windows\install_django_service.bat
   ```

3. Проверьте, что служба успешно установлена и запущена:
   ```
   sc query DjangoBackend
   ```

## Установка Nuxt.js как службы

1. Создайте директорию для логов:
   ```
   mkdir frontend\logs
   ```

2. Запустите скрипт установки службы:
   Для оффлайн установки распакуйте node_modules.zip в папку frontend 
   ```
   call npm install-offline
   ```
   ```
   scripts\windows\install_nuxt_service.bat
   ```

3. Проверьте, что служба успешно установлена и запущена:
   ```
   sc query NuxtFrontend
   ```

## Управление службами

Для управления установленными службами вы можете использовать стандартные инструменты Windows:

- Через командную строку:
  ```
  sc start DjangoBackend
  sc stop DjangoBackend
  sc start NuxtFrontend
  sc stop NuxtFrontend
  ```

- Через графический интерфейс:
  - Откройте "Службы" (services.msc)
  - Найдите службы "Django Backend" и "Nuxt.js Frontend"
  - Используйте контекстное меню для запуска, остановки или настройки служб

## Удаление служб

Если вам нужно удалить установленные службы:
Запустите скрипт удаления 

```
scripts/windows/uninstall_services.bat
```