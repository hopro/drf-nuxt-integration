@echo off
rem *** Setting UTF-8 encoding
chcp 65001 > nul

rem *** Nuxt.js Service Installation Script


rem *** Service names
set SERVICE_NAME=NuxtFrontend
set DEPENDENCY_SERVICE=DjangoBackend

rem *** Directory paths
set PROJECT_DIR=%~dp0..\..
set FRONTEND_DIR=%PROJECT_DIR%\frontend
set OFFLINE_DIR=%PROJECT_DIR%\offline_packages\npm_cache

rem *** Path to NSSM executable
set NSSM_PATH=%PROJECT_DIR%\scripts\windows\nssm.exe

rem *** Create logs directory
if not exist "%FRONTEND_DIR%\logs" (
    echo Creating Nuxt.js logs directory...
    mkdir "%FRONTEND_DIR%\logs"
)

rem *** Check npm dependencies
if not exist "%FRONTEND_DIR%\node_modules" (
    echo node_modules directory not found. Installing dependencies...

    rem *** Check if npm is installed
    where npm >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: npm not found. Please install Node.js.
        goto :end
    )

    rem *** Install dependencies
    cd "%FRONTEND_DIR%"
    echo Running npm install...
    call npm install
    
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to install npm dependencies.
        goto :end
    )

    echo npm dependencies successfully installed.
)

rem *** Ensure we are in the correct directory
cd "%FRONTEND_DIR%"

rem *** Check for built project
if not exist "%FRONTEND_DIR%\.output" (
    echo .output directory not found. Building the project...
    echo Running nuxi build...
    call npx nuxi build
    
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to build Nuxt.js project.
        goto :end
    )

    echo Nuxt.js project successfully built.
)

rem *** Path to Nuxt.js service script
set BAT_PATH=%~dp0nuxt_service.bat

rem *** Check for existing service and remove it
echo Checking for existing Nuxt.js service...
sc query %SERVICE_NAME% > nul
if %ERRORLEVEL% EQU 0 (
    echo Service %SERVICE_NAME% exists. Stopping and removing...
    sc stop %SERVICE_NAME%
    timeout /t 10 /nobreak > nul
    taskkill /f /im nssm.exe 2>nul
    sc delete %SERVICE_NAME%
    timeout /t 10 /nobreak > nul
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

rem *** Check if dependency service exists and is running
echo Checking for dependency service...
sc query %DEPENDENCY_SERVICE% > nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Dependency service %DEPENDENCY_SERVICE% not found.
    echo Please install the %DEPENDENCY_SERVICE% service first using install_django_service.bat
    goto :end
)

rem *** Check actual Django server availability
echo Checking if Django server is accessible...
set "DJANGO_PORT=8000"
set "DJANGO_SERVER=localhost"

rem *** Try to connect to Django server
powershell -Command "try { $client = New-Object System.Net.Sockets.TcpClient('%DJANGO_SERVER%', %DJANGO_PORT%); $client.Close(); Write-Output 'Connection successful' } catch { Write-Output 'Connection failed' }" > "%TEMP%\django_connection.txt"
findstr /C:"Connection successful" "%TEMP%\django_connection.txt" > nul
if %ERRORLEVEL% EQU 0 (
    echo Django server is accessible at %DJANGO_SERVER%:%DJANGO_PORT%
    echo Proceeding with installation regardless of service state.
    goto :create_service
)

rem *** If server not accessible, check Django service status
echo Django server not accessible. Checking service status...
set "SERVICE_RUNNING=0"
for /f "tokens=3 delims=: " %%a in ('sc query %DEPENDENCY_SERVICE% ^| findstr "STATE"') do (
    if "%%a"=="4" set "SERVICE_RUNNING=1"
)

rem *** Check if service is paused
sc query %DEPENDENCY_SERVICE% | findstr /C:"STATE" | findstr /C:"7" > nul
if %ERRORLEVEL% EQU 0 (
    echo Service %DEPENDENCY_SERVICE% is PAUSED. Attempting to continue it...
    sc continue %DEPENDENCY_SERVICE%
    timeout /t 10 /nobreak > nul
)

if "%SERVICE_RUNNING%"=="0" (
    echo Service %DEPENDENCY_SERVICE% found but may not be fully running.
    
    rem *** Check if service is starting or already running
    sc query %DEPENDENCY_SERVICE% | findstr /C:"RUNNING" /C:"STARTING" /C:"START_PENDING" > nul
    if %ERRORLEVEL% EQU 0 (
        echo Service appears to be in transition state. Waiting for it to stabilize...
        timeout /t 20 /nobreak > nul
    ) else (
        echo Attempting to start the service...
        sc start %DEPENDENCY_SERVICE%
        timeout /t 20 /nobreak > nul
    )
    
    rem *** Check server availability again
    powershell -Command "try { $client = New-Object System.Net.Sockets.TcpClient('%DJANGO_SERVER%', %DJANGO_PORT%); $client.Close(); Write-Output 'Connection successful' } catch { Write-Output 'Connection failed' }" > "%TEMP%\django_connection.txt"
    findstr /C:"Connection successful" "%TEMP%\django_connection.txt" > nul
    if %ERRORLEVEL% NEQ 0 (
        echo WARNING: The Django server is still not accessible.
        echo Do you want to continue with installation anyway? (Y/N)
        set /p CONTINUE_INSTALL=
        if /i "%CONTINUE_INSTALL%" NEQ "Y" goto :end
    ) else (
        echo Django server is now accessible.
    )
)

:create_service
echo Creating new service %SERVICE_NAME%...
%NSSM_PATH% install %SERVICE_NAME% %BAT_PATH%

echo Configuring service...
%NSSM_PATH% set %SERVICE_NAME% Description "Nuxt.js Frontend Service"
%NSSM_PATH% set %SERVICE_NAME% DisplayName "Nuxt.js Frontend"
%NSSM_PATH% set %SERVICE_NAME% Start SERVICE_AUTO_START

echo Setting service dependencies...
%NSSM_PATH% set %SERVICE_NAME% DependOnService %DEPENDENCY_SERVICE%

echo Configuring restart on failure...
%NSSM_PATH% set %SERVICE_NAME% AppExit Default Restart
%NSSM_PATH% set %SERVICE_NAME% AppRestartDelay 10000

echo Starting service...
%NSSM_PATH% start %SERVICE_NAME%
timeout /t 15 /nobreak > nul

echo Checking service status...
set "NUXT_RUNNING=0"
for /f "tokens=3 delims=: " %%a in ('sc query %SERVICE_NAME% ^| findstr "STATE"') do (
    if "%%a"=="4" set "NUXT_RUNNING=1"
    if "%%a"=="7" (
        echo Service %SERVICE_NAME% is in PAUSED state. Attempting to continue...
        sc continue %SERVICE_NAME%
        timeout /t 5 /nobreak > nul
        
        rem Check again after continue
        for /f "tokens=3 delims=: " %%b in ('sc query %SERVICE_NAME% ^| findstr "STATE"') do (
            if "%%b"=="4" set "NUXT_RUNNING=1"
        )
    )
)

if "%NUXT_RUNNING%"=="0" (
    echo Service %SERVICE_NAME% is not in RUNNING state. Checking status...
    
    sc query %SERVICE_NAME% | findstr /C:"PAUSED" > nul
    if %ERRORLEVEL% EQU 0 (
        echo Service %SERVICE_NAME% is PAUSED. Forcing restart...
        sc continue %SERVICE_NAME%
        timeout /t 5 /nobreak > nul
        sc stop %SERVICE_NAME%
        timeout /t 5 /nobreak > nul
        sc start %SERVICE_NAME%
    ) else (
        echo Service %SERVICE_NAME% may be in transition state. Waiting for it to stabilize...
        timeout /t 15 /nobreak > nul
    )
    
    echo Checking final service status...
    sc query %SERVICE_NAME% | findstr /C:"RUNNING" > nul
    if %ERRORLEVEL% NEQ 0 (
        echo WARNING: Service %SERVICE_NAME% may not be in RUNNING state.
        echo Please check the service status and logs manually.
    ) else (
        echo Service %SERVICE_NAME% is now running.
    )
) else (
    echo Service %SERVICE_NAME% is running successfully.
)

echo Nuxt.js Frontend service installation completed

:end 