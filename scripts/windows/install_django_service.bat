@echo off
rem *** Setting UTF-8 encoding
chcp 65001 > nul

rem *** Django Service Installation Script

rem *** Path to NSSM executable
set NSSM_PATH=C:\site\scripts\windows\nssm.exe

rem *** Service names
set SERVICE_NAME=DjangoBackend
set DEPENDENT_SERVICE=NuxtFrontend

rem *** Directory paths
set PROJECT_DIR=%~dp0..\..
rem Make sure the paths are absolute
cd %PROJECT_DIR%
set PROJECT_DIR=%CD%
set VENV_DIR=%PROJECT_DIR%\backend\venv
set DJANGO_DIR=%PROJECT_DIR%\backend
set REQUIREMENTS_FILE=%PROJECT_DIR%\backend\requirements.txt
set OFFLINE_DIR=%PROJECT_DIR%\offline_packages\windows
rem *** Create logs directory
if not exist "%DJANGO_DIR%\logs" (
    echo Creating Django logs directory...
    mkdir "%DJANGO_DIR%\logs"
)

rem *** Check if Python is installed
echo Checking for Python...
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python not found. Please install Python 3.6 or higher.
    echo Make sure Python is added to your PATH environment variable.
    goto :end
)

rem *** Check if backend directory exists
if not exist "%DJANGO_DIR%" (
    echo ERROR: Backend directory not found at %DJANGO_DIR%
    echo Creating backend directory...
    mkdir "%DJANGO_DIR%"
)

rem *** Create virtual environment if it doesn't exist
if not exist "%VENV_DIR%" (
    echo Creating new virtual environment in %VENV_DIR%...
    
    python -m venv "%VENV_DIR%"
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to create virtual environment.
        goto :end
    )
    
    echo Installing dependencies...
    if exist "%REQUIREMENTS_FILE%" (
        echo Installing from requirements.txt...
        call "%VENV_DIR%\Scripts\activate.bat"
        echo Upgrading pip...
        python -m pip install --upgrade pip
        
        echo Installing requirements from local packages...
        python -m pip install -r "%REQUIREMENTS_FILE%"
        pip install --no-index --find-links=%OFFLINE_DIR% -r "%REQUIREMENTS_FILE%"
        
        if %ERRORLEVEL% NEQ 0 (
            echo ERROR: Failed to install dependencies.
            call "%VENV_DIR%\Scripts\deactivate.bat"
            goto :end
        )
        
        echo Installing waitress from local packages...
        python -m pip install waitress
        echo Migrating and creating superuser...
        python backend\manage.py migrate
        python backend\manage.py createsuperuser
        
        call "%VENV_DIR%\Scripts\deactivate.bat"
    ) else (
        echo WARNING: requirements.txt not found at "%REQUIREMENTS_FILE%".
    )
    
    echo Virtual environment successfully created and configured.
)

rem *** Path to Django service script
set BAT_PATH=%~dp0django_service.bat

rem *** Check for dependent Nuxt service and remove it
echo Checking for dependent services...
sc query %DEPENDENT_SERVICE% > nul
if %ERRORLEVEL% EQU 0 (
    echo Found dependent service %DEPENDENT_SERVICE%. Removing it first...
    sc stop %DEPENDENT_SERVICE%
    timeout /t 10 /nobreak > nul
    sc delete %DEPENDENT_SERVICE%
    timeout /t 10 /nobreak > nul
)

rem *** Check for existing Django service and remove it
echo Checking for existing Django service...
sc query %SERVICE_NAME% > nul
if %ERRORLEVEL% EQU 0 (
    echo Service %SERVICE_NAME% exists. Stopping and removing...
    sc stop %SERVICE_NAME%
    timeout /t 20 /nobreak > nul
    taskkill /f /im nssm.exe 2>nul
    sc delete %SERVICE_NAME%
    timeout /t 20 /nobreak > nul
)

rem *** Additional check to ensure service is fully removed
echo Verifying service removal...
sc query %SERVICE_NAME% > nul
if %ERRORLEVEL% EQU 0 (
    echo WARNING: Service %SERVICE_NAME% was not fully removed. Force removing...
    taskkill /f /im nssm.exe 2>nul
    sc delete %SERVICE_NAME% /force
    timeout /t 10 /nobreak > nul
)

echo Creating new service %SERVICE_NAME%...
%NSSM_PATH% install %SERVICE_NAME% %BAT_PATH%

echo Configuring service...
%NSSM_PATH% set %SERVICE_NAME% Description "Django Backend Service"
%NSSM_PATH% set %SERVICE_NAME% DisplayName "Django Backend"
%NSSM_PATH% set %SERVICE_NAME% Start SERVICE_AUTO_START

echo Configuring restart on failure...
%NSSM_PATH% set %SERVICE_NAME% AppExit Default Restart
%NSSM_PATH% set %SERVICE_NAME% AppRestartDelay 10000

echo Starting service...
%NSSM_PATH% start %SERVICE_NAME%
timeout /t 5 /nobreak > nul

echo Checking service status...
sc query %SERVICE_NAME% | find "PAUSED" > nul
if %ERRORLEVEL% EQU 0 (
    echo Service %SERVICE_NAME% is PAUSED. Forcing restart...
    sc continue %SERVICE_NAME%
    timeout /t 5 /nobreak > nul
    sc stop %SERVICE_NAME%
    timeout /t 5 /nobreak > nul
    sc start %SERVICE_NAME%
)

:end 
pause 