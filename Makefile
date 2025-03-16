# Makefile для сборки проекта

# Переменные
PARENT_DIR = /Users/glinnik-it/Projects
PROJECT_DIR = $(PARENT_DIR)/site
PYTHON = $(PROJECT_DIR)/backend/venv/bin/python
PIP = $(PROJECT_DIR)/backend/venv/bin/pip
NPM = npm
OFFLINE_DIR = $(PROJECT_DIR)/offline_packages
LINUX_OFFLINE_DIR = $(OFFLINE_DIR)/linux
WIN_OFFLINE_DIR = $(OFFLINE_DIR)/windows
FRONTEND_DIR = $(PROJECT_DIR)/frontend
SCRIPTS_DIR = $(PROJECT_DIR)/scripts

# Задачи
all: prepare_backend prepare_frontend package_project

prepare_backend:
	@echo "Создание директорий для зависимостей..."
	mkdir -p $(LINUX_OFFLINE_DIR)
	mkdir -p $(WIN_OFFLINE_DIR)
	@echo "Скачивание Python-зависимостей для Linux..."
	$(PIP) download -r $(PROJECT_DIR)/backend/requirements.txt -d $(LINUX_OFFLINE_DIR)
	@echo "Скачивание платформо-зависимых пакетов для Linux..."
	$(PIP) download psycopg2-binary -d $(LINUX_OFFLINE_DIR) --platform manylinux2014_x86_64 --only-binary=:all: --no-deps
	@echo "Скачивание Python-зависимостей для Windows..."
	$(PIP) download -r $(PROJECT_DIR)/backend/requirements.txt -d $(WIN_OFFLINE_DIR)
	@echo "Скачивание платформо-зависимых пакетов для Windows..."
	$(PIP) download psycopg2-binary -d $(WIN_OFFLINE_DIR) --platform win_amd64 --only-binary=:all: --no-deps

prepare_frontend:
	@echo "Создание архива Node.js-зависимостей..."
	cd $(FRONTEND_DIR) && $(NPM) pack

package_project:
	@echo "Упаковка проекта в архив..."
	cd $(PARENT_DIR) && zip -r $(PROJECT_DIR)/project.zip site -x "*/venv/*" "*/node_modules/*" "*.git*" "*.DS_Store"

clean:
	@echo "Очистка временных файлов..."
	rm -rf $(OFFLINE_DIR)
	rm -f $(FRONTEND_DIR)/*.tgz
	rm -f project.zip

.PHONY: all prepare_backend prepare_frontend package_project clean 