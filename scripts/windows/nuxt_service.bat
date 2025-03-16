@echo off
rem *** Setting UTF-8 encoding
chcp 65001 > nul

rem *** Script to run Nuxt.js as a Windows service

rem *** Set environment variables
set PROJECT_DIR=%~dp0..\..
set FRONTEND_DIR=%PROJECT_DIR%\frontend

rem *** Check if frontend directory exists
if not exist "%FRONTEND_DIR%" (
    echo ERROR: Frontend directory not found at %FRONTEND_DIR%
    exit /b 1
)

rem *** Check for node_modules
if not exist "%FRONTEND_DIR%\node_modules" (
    echo ERROR: node_modules not found. Please run install_nuxt_service.bat first
    exit /b 1
)

rem *** Check for built project
if not exist "%FRONTEND_DIR%\.output" (
    echo ERROR: Built project not found. Please run install_nuxt_service.bat first
    exit /b 1
)

rem *** Change to frontend directory
cd %FRONTEND_DIR%

rem *** Run Nuxt.js in production mode
echo Starting Nuxt.js in production mode...
npx nuxi start > %FRONTEND_DIR%\logs\nuxt.log 2>&1 