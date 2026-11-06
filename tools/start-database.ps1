# Starts the portable MariaDB in the background if it isn't running, then waits until it accepts connections.
$ErrorActionPreference = 'Stop'
$root   = Split-Path -Parent $PSScriptRoot
$dbRoot = Join-Path $root 'database'
$bin    = Join-Path $dbRoot 'mariadb\bin'

function Test-DbPort {
    $c = New-Object Net.Sockets.TcpClient
    try {
        $c.Connect('127.0.0.1', 3306)
        return $true
    } catch {
        return $false
    } finally {
        $c.Close()
    }
}

if (Test-DbPort) {
    Write-Host 'Database already running.'
    exit 0
}

Write-Host 'Starting database...'
Start-Process -FilePath (Join-Path $bin 'mariadbd.exe') `
    -ArgumentList "--defaults-file=`"$(Join-Path $dbRoot 'my.ini')`"" -WindowStyle Hidden

for ($i = 0; $i -lt 60; $i++) {
    if (Test-DbPort) {
        Write-Host 'Database ready.'
        exit 0
    }
    Start-Sleep -Milliseconds 500
}
throw 'Database did not start within 30 seconds. Check the .err log in database\data.'
