<#
  Builds the files needed to move the server to a host, in deploy\:
    server-data.zip   scripts and configs, without secrets or caches
    database.sql      a full backup of the game database (contains player data, keep it private)
    database-clean.sql  the same tables with no player data, for a fresh start
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
    --exclude='^./secrets.cfg' --exclude='^./cache' --exclude='^./tmp' --exclude='^./_*.cfg' --exclude=sv_npwd.log .
if ($LASTEXITCODE -ne 0) { throw "tar failed: $LASTEXITCODE" }

# Resources have their own folders named cache and tmp, so confirm only the intended files were left out.
$serverData = Join-Path $root 'server-data'
$packed = @{}
& tar.exe -tf $zip | ForEach-Object { $packed[($_ -replace '^\./', '')] = $true }
if ($packed.ContainsKey('secrets.cfg')) { throw 'secrets.cfg was packaged' }
$missing = @([IO.Directory]::EnumerateFiles($serverData, '*', [IO.SearchOption]::AllDirectories) |
    ForEach-Object { $_.Substring($serverData.Length + 1).Replace('\', '/') } |
    Where-Object { -not $packed.ContainsKey($_) -and $_ -notmatch '^(cache|tmp)/|^secrets\.cfg$|^_.*\.cfg$|/sv_npwd\.log$' })
if ($missing.Count -gt 0) { throw "Files missing from the package: $($missing -join ', ')" }

function Invoke-Dump([string]$outFile, [string[]]$dumpArgs) {
    $err = [IO.Path]::GetTempFileName()
    $p = Start-Process -FilePath (Join-Path $bin 'mariadb-dump.exe') -ArgumentList (@(
        "--defaults-extra-file=`"$client`"", '--single-transaction', '--default-character-set=utf8mb4', '--skip-dump-date'
    ) + $dumpArgs) -RedirectStandardOutput $outFile -RedirectStandardError $err -NoNewWindow -Wait -PassThru
    $errText = Get-Content -LiteralPath $err -Raw
    Remove-Item -LiteralPath $err -Force
    if ($p.ExitCode -ne 0) { throw "mariadb-dump failed: $errText" }
}

$sql = Join-Path $deploy 'database.sql'
Invoke-Dump $sql @('fivem')

# Clean start: every table, but only the starting data the server needs. Bank accounts are created on startup.
$clean = Join-Path $deploy 'database-clean.sql'
$seed = [IO.Path]::GetTempFileName()
Invoke-Dump $clean @('--no-data', 'fivem')
Invoke-Dump $seed @('--no-create-info', 'fivem', 'ox_doorlock')
[IO.File]::AppendAllText($clean, [IO.File]::ReadAllText($seed), (New-Object Text.UTF8Encoding($false)))
Remove-Item -LiteralPath $seed -Force

Write-Host ('server-data.zip:    {0:N0} MB' -f ((Get-Item -LiteralPath $zip).Length / 1MB))
Write-Host ('database.sql:       {0:N1} MB' -f ((Get-Item -LiteralPath $sql).Length / 1MB))
Write-Host ('database-clean.sql: {0:N0} KB' -f ((Get-Item -LiteralPath $clean).Length / 1KB))
