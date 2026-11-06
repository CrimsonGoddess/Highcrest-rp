@echo off
cd /d "%~dp0"
"database\mariadb\bin\mariadb-admin.exe" --defaults-extra-file="database\client.cnf" shutdown
if errorlevel 1 (
    echo Could not stop the database. It may not be running.
) else (
    echo Database stopped.
)
pause
