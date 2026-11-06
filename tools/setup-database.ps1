<#
  First-time database setup, safe to re-run:
    - initialises the portable MariaDB data directory
    - sets a generated root password and creates a limited "fivem" user
    - writes server-data\secrets.cfg (never overwrites an existing one)
    - applies each file in tools\sql-order.txt exactly once
#>
$ErrorActionPreference = 'Stop'
$root    = Split-Path -Parent $PSScriptRoot
$dbRoot  = Join-Path $root 'database'
$bin     = Join-Path $dbRoot 'mariadb\bin'
$dataDir = Join-Path $dbRoot 'data'
$myIni   = Join-Path $dbRoot 'my.ini'
$client  = Join-Path $dbRoot 'client.cnf'
$secrets = Join-Path $root 'server-data\secrets.cfg'
$sqlDir  = Join-Path $root 'sql'
$utf8    = New-Object Text.UTF8Encoding($false)

function New-Password {
    $chars = [char[]]'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    $bytes = New-Object byte[] 32
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    return -join ($bytes | ForEach-Object { $chars[$_ % $chars.Length] })
}

# Feeds a file to the client on stdin. Returns stderr text; empty means success.
function Invoke-SqlFile([string]$path, [string]$database) {
    $errFile = [IO.Path]::GetTempFileName()
    $outFile = [IO.Path]::GetTempFileName()
    $cliArgs = @("--defaults-extra-file=`"$client`"", '--default-character-set=utf8mb4', $database)
    $p = Start-Process -FilePath (Join-Path $bin 'mariadb.exe') -ArgumentList $cliArgs -RedirectStandardInput $path `
        -RedirectStandardError $errFile -RedirectStandardOutput $outFile -NoNewWindow -Wait -PassThru
    $err = (Get-Content -LiteralPath $errFile -Raw)
    Remove-Item -LiteralPath $errFile, $outFile -Force
    if ($p.ExitCode -ne 0) { return "exit $($p.ExitCode): $err" }
    return ''
}

function Invoke-SqlText([string]$sql, [string]$database) {
    $tmp = [IO.Path]::GetTempFileName()
    try {
        [IO.File]::WriteAllText($tmp, $sql, $utf8)
        return Invoke-SqlFile $tmp $database
    } finally {
        Remove-Item -LiteralPath $tmp -Force
    }
}

# 1. Config. Forward slashes are required inside my.ini.
$fwdData = $dataDir.Replace('\', '/')
$fwdBase = (Join-Path $dbRoot 'mariadb').Replace('\', '/')
$ini = @"
[mysqld]
basedir="$fwdBase"
datadir="$fwdData"
port=3306
bind-address=127.0.0.1
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
innodb_buffer_pool_size=1G
max_connections=200
"@
[IO.File]::WriteAllText($myIni, $ini, $utf8)

# 2. Initialise on first run.
$firstRun = -not (Test-Path -LiteralPath (Join-Path $dataDir 'mysql'))
if ($firstRun) {
    Write-Host 'Initialising data directory...'
    & (Join-Path $bin 'mariadb-install-db.exe') "--datadir=$dataDir" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "mariadb-install-db failed: $LASTEXITCODE" }
    # The installer writes its own my.ini into the data directory; ours is authoritative.
    Remove-Item -LiteralPath (Join-Path $dataDir 'my.ini') -Force -ErrorAction SilentlyContinue
}

# 3. Start.
& (Join-Path $PSScriptRoot 'start-database.ps1')

# 4. Accounts and secrets on first run.
if ($firstRun) {
    $rootPw = New-Password
    $appPw  = New-Password
    # Fresh install: root has no password yet, so connect without one to set it.
    [IO.File]::WriteAllText($client, "[client]`r`nuser=root`r`nhost=127.0.0.1`r`nport=3306`r`n", $utf8)
    $bootstrap = @"
ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootPw';
DROP USER IF EXISTS 'root'@'127.0.0.1';
DROP USER IF EXISTS 'root'@'::1';
CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY '$rootPw';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
DROP DATABASE IF EXISTS test;
CREATE DATABASE fivem CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'fivem'@'127.0.0.1' IDENTIFIED BY '$appPw';
GRANT ALL PRIVILEGES ON fivem.* TO 'fivem'@'127.0.0.1';
FLUSH PRIVILEGES;
"@
    $e = Invoke-SqlText $bootstrap 'mysql'
    if ($e) { throw "bootstrap failed: $e" }
    [IO.File]::WriteAllText($client, "[client]`r`nuser=root`r`npassword=$rootPw`r`nhost=127.0.0.1`r`nport=3306`r`n", $utf8)

    if (Test-Path -LiteralPath $secrets) {
        Write-Host 'secrets.cfg already exists; left unchanged. New database password NOT written to it.' -ForegroundColor Yellow
    } else {
        $s = @"
# Private settings. Never share this file or commit it.

# Create a key at https://portal.cfx.re/servers/registration-keys and paste it here.
sv_licenseKey "CHANGE_ME"

set mysql_connection_string "mysql://fivem:$appPw@127.0.0.1:3306/fivem?charset=utf8mb4"

# Make yourself admin: join once, copy your identifier from the server console, then uncomment.
# add_principal identifier.fivem:YOUR_ID group.admin
"@
        [IO.File]::WriteAllText($secrets, $s, $utf8)
        Write-Host 'Wrote server-data\secrets.cfg'
    }
}

# 5. Apply SQL once each.
$e = Invoke-SqlText 'CREATE TABLE IF NOT EXISTS _applied_sql (name VARCHAR(190) PRIMARY KEY, applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);' 'fivem'
if ($e) { throw $e }
$failures = 0
foreach ($name in [IO.File]::ReadAllLines((Join-Path $PSScriptRoot 'sql-order.txt'))) {
    if (-not $name.Trim()) { continue }
    $check = & (Join-Path $bin 'mariadb.exe') "--defaults-extra-file=$client" -N -e "SELECT COUNT(*) FROM fivem._applied_sql WHERE name='$name'"
    if ("$check".Trim() -eq '1') { Write-Host "  skip    $name"; continue }
    $e = Invoke-SqlFile (Join-Path $sqlDir $name) 'fivem'
    if ($e) {
        Write-Host "  FAILED  $name :: $e" -ForegroundColor Red
        $failures++
    } else {
        $e2 = Invoke-SqlText "INSERT INTO _applied_sql (name) VALUES ('$name');" 'fivem'
        if ($e2) { throw $e2 }
        Write-Host "  applied $name"
    }
}
Write-Host "SQL failures: $failures"
if ($failures -gt 0) { exit 1 }
exit 0
