@echo off
rem *** Setting UTF-8 encoding
chcp 65001 > nul

rem *** Script to uninstall Nuxt.js and Django Windows services

rem *** Service names
set NUXT_SERVICE=NuxtFrontend
set DJANGO_SERVICE=DjangoBackend

rem *** Additional tools path
set NSSM_PATH=C:\site\scripts\windows\nssm.exe

echo ===================================================
echo Удаление служб веб-приложения
echo ===================================================

rem *** Check and remove Nuxt.js service
echo Проверка службы Nuxt...
%NSSM_PATH% status %NUXT_SERVICE% > nul
if %ERRORLEVEL% EQU 0 (
    echo Служба %NUXT_SERVICE% найдена. Остановка и удаление...
    %NSSM_PATH% stop %NUXT_SERVICE%
    timeout /t 5 /nobreak > nul
    %NSSM_PATH% remove %NUXT_SERVICE% confirm
    timeout /t 5 /nobreak > nul
    %NSSM_PATH% status %NUXT_SERVICE% > nul
    if %ERRORLEVEL% EQU 1 (
        echo Служба %NUXT_SERVICE% успешно удалена.
    ) else (
        echo Служба %NUXT_SERVICE% не найдена.
    )
) else (
    echo Служба %NUXT_SERVICE% не найдена.
)

rem *** Check and remove Django service
echo Проверка службы Django...
%nssm_path% status %DJANGO_SERVICE% > nul
if %ERRORLEVEL% EQU 0 (
    echo Служба %DJANGO_SERVICE% найдена. Остановка и удаление...
    
    rem *** Stop service
    %nssm_path% stop %DJANGO_SERVICE%
    timeout /t 5 /nobreak > nul
    
    rem *** Kill waitress process
    taskkill /f /im waitress-serve.exe 2>nul
    
    rem *** Delete service
    %nssm_path% remove %DJANGO_SERVICE% confirm
    timeout /t 5 /nobreak > nul
    
    rem *** Check if service was successfully removed
    %nssm_path% status %DJANGO_SERVICE% > nul
    if %ERRORLEVEL% EQU 1 (
        echo Служба %DJANGO_SERVICE% успешно удалена.
    ) else (
        echo Служба %DJANGO_SERVICE% не найдена.
    )
) else (
    echo Служба %DJANGO_SERVICE% не найдена.
)

echo.
echo ===================================================
echo Процесс удаления служб завершён
echo ===================================================
pause 
