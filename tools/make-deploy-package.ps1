<#
  Builds the files needed to move the server to a host, in deploy\:
    server-data.zip   scripts and configs, without secrets or caches
    database.sql      a full backup of the game database (contains player data, keep it private)
  The database must be running.
#>
$ErrorActionPreference = 'Stop'
$root   = Split-Path -Parent $PSScriptRoot
$deploy = Join-Path $root 'deploy'
$bin    = Join-Path $root 'database\mariadb\bin'
$client = Join-Path $root 'database\client.cnf'
[void][IO.Directory]::CreateDirectory($deploy)

$zip = Join-Path $deploy 'server-data.zip'
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
& tar.exe -a -c -f $zip -C (Join-Path $root 'server-data') `
    --exclude=secrets.cfg --exclude=cache --exclude=tmp --exclude=sv_npwd.log --exclude='_*.cfg' .
if ($LASTEXITCODE -ne 0) { throw "tar failed: $LASTEXITCODE" }

$sql = Join-Path $deploy 'database.sql'
$err = [IO.Path]::GetTempFileName()
$p = Start-Process -FilePath (Join-Path $bin 'mariadb-dump.exe') -ArgumentList @(
    "--defaults-extra-file=`"$client`"", '--single-transaction', '--default-character-set=utf8mb4',
    '--skip-dump-date', 'fivem'
) -RedirectStandardOutput $sql -RedirectStandardError $err -NoNewWindow -Wait -PassThru
$errText = Get-Content -LiteralPath $err -Raw
Remove-Item -LiteralPath $err -Force
if ($p.ExitCode -ne 0) { throw "mariadb-dump failed: $errText" }

Write-Host ('server-data.zip: {0:N0} MB' -f ((Get-Item -LiteralPath $zip).Length / 1MB))
Write-Host ('database.sql:    {0:N1} MB' -f ((Get-Item -LiteralPath $sql).Length / 1MB))
