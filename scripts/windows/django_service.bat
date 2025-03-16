@echo off
rem *** Setting UTF-8 encoding
chcp 65001 > nul

rem *** Script to run Django via waitress as a Windows service

rem *** Set environment variables
set PROJECT_DIR=%~dp0..\..
rem Make sure the paths are absolute
cd %PROJECT_DIR%
set PROJECT_DIR=%CD%
set VENV_DIR=%PROJECT_DIR%\backend\venv
set DJANGO_DIR=%PROJECT_DIR%\backend

rem *** Check if directories exist
if not exist "%DJANGO_DIR%" (
    echo ERROR: Backend directory not found at %DJANGO_DIR%
    exit /b 1
)

rem *** Check if virtual environment exists
if not exist "%VENV_DIR%" (
    echo ERROR: Virtual environment not found at %VENV_DIR%
    exit /b 1
)

rem *** Activate virtual environment
echo Activating virtual environment...
call "%VENV_DIR%\Scripts\activate.bat"

rem *** Change to project directory
echo Changing to Django project directory: %DJANGO_DIR%
cd "%DJANGO_DIR%"

rem *** Create logs directory if it doesn't exist
if not exist "%DJANGO_DIR%\logs" (
    echo Creating logs directory...
    mkdir "%DJANGO_DIR%\logs"
)

rem *** Run Django via waitress with better error handling
echo Starting Django with waitress on 0.0.0.0:8000...
echo Logs will be written to: %DJANGO_DIR%\logs\waitress.log
waitress-serve --listen=0.0.0.0:8000 mysite.wsgi:application > "%DJANGO_DIR%\logs\waitress.log" 2>&1

rem *** In case waitress fails, log the error
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Waitress failed to start with exit code %ERRORLEVEL% >> "%DJANGO_DIR%\logs\service_error.log"
    date /t >> "%DJANGO_DIR%\logs\service_error.log"
    time /t >> "%DJANGO_DIR%\logs\service_error.log"
)

rem *** Deactivate virtual environment
call "%VENV_DIR%\Scripts\deactivate.bat" 