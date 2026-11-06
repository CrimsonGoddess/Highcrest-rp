@echo off
title FiveM Server
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "tools\start-database.ps1"
if errorlevel 1 (
    echo Database failed to start.
    pause
    exit /b 1
)

findstr /c:"CHANGE_ME" "server-data\secrets.cfg" >nul
if not errorlevel 1 (
    echo.
    echo No license key set yet. Add it to server-data\secrets.cfg
    echo Create one at https://portal.cfx.re/servers/registration-keys
    echo.
    pause
    exit /b 1
)

cd /d "%~dp0server-data"
"..\artifacts\FXServer.exe" +exec server.cfg
pause
