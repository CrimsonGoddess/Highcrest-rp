<#
  Installs server resources by executing a txAdmin-format recipe (engine v3) without txAdmin.

  Usage:  powershell -ExecutionPolicy Bypass -File tools\install-resources.ps1
          -Recipe     recipe file (default tools\recipe.yaml)
          -ServerData target folder (default server-data)

  Database tasks are not run here: their SQL paths are written, in order, to
  tools\sql-order.txt and applied by tools\setup-database.ps1.
#>
param(
    [string]$Recipe,
    [string]$ServerData
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $Recipe)     { $Recipe = Join-Path $PSScriptRoot 'recipe.yaml' }
if (-not $ServerData) { $ServerData = Join-Path $projectRoot 'server-data' }
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Resolve-RecipePath([string]$p) {
    return [IO.Path]::GetFullPath([IO.Path]::Combine($ServerData, $p.Replace('/', '\')))
}

function Get-RemoteFile([string]$url, [string]$out) {
    $parent = [IO.Path]::GetDirectoryName($out)
    [void][IO.Directory]::CreateDirectory($parent)
    & curl.exe -sSL --fail --retry 4 --retry-delay 3 -m 300 $url -o $out
    if ($LASTEXITCODE -ne 0) { throw "download failed ($LASTEXITCODE): $url" }
}

# Merge a directory into another. Uses robocopy because it treats [brackets] literally.
function Merge-Directory([string]$from, [string]$to) {
    [void][IO.Directory]::CreateDirectory($to)
    & robocopy.exe $from.TrimEnd('\') $to.TrimEnd('\') /E /NFL /NDL /NJH /NJS /NP /R:2 /W:1 | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $from -> $to" }
    $global:LASTEXITCODE = 0
}

function New-TempDir {
    $d = Join-Path $ServerData ('tmp\x' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    [void][IO.Directory]::CreateDirectory($d)
    return $d
}

function Install-GithubRepo([string]$src, [string]$ref, [string]$subpath, [string]$dest) {
    if (-not $ref) { $ref = 'HEAD' }
    $tmp = New-TempDir
    $zip = Join-Path $tmp 'repo.zip'
    Get-RemoteFile "$($src.TrimEnd('/'))/archive/$ref.zip" $zip
    $ex = Join-Path $tmp 'x'
    [IO.Compression.ZipFile]::ExtractToDirectory($zip, $ex)
    $top = [IO.Directory]::GetDirectories($ex)[0]
    $from = $top
    if ($subpath) { $from = [IO.Path]::Combine($top, $subpath.Replace('/', '\')) }
    Merge-Directory $from (Resolve-RecipePath $dest)
    [IO.Directory]::Delete($tmp, $true)
}

function Expand-Zip([string]$src, [string]$dest) {
    $tmp = New-TempDir
    [IO.Compression.ZipFile]::ExtractToDirectory((Resolve-RecipePath $src), $tmp)
    Merge-Directory $tmp (Resolve-RecipePath $dest)
    [IO.Directory]::Delete($tmp, $true)
}

function Move-RecipePath([string]$src, [string]$dest, [bool]$copyOnly) {
    $from = Resolve-RecipePath $src
    $to = Resolve-RecipePath $dest
    if ([IO.Directory]::Exists($from)) {
        # Directories are merged rather than replaced so nothing shipped by the resource is lost.
        Merge-Directory $from $to
        if (-not $copyOnly) { [IO.Directory]::Delete($from, $true) }
    } else {
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($to))
        [IO.File]::Copy($from, $to, $true)
        if (-not $copyOnly) { [IO.File]::Delete($from) }
    }
}

# Minimal parser for the flat "- action: x / key: value" shape recipes use.
$tasks = New-Object System.Collections.ArrayList
$current = $null
$inTasks = $false
foreach ($raw in [IO.File]::ReadAllLines($Recipe)) {
    $line = $raw.Trim()
    if ($line -eq 'tasks:') { $inTasks = $true; continue }
    if (-not $inTasks -or $line -eq '' -or $line.StartsWith('#')) { continue }
    if ($line -match '^-\s*action:\s*(\S+)') {
        $current = @{ action = $Matches[1] }
        [void]$tasks.Add($current)
    } elseif ($line -match '^([A-Za-z_]+):\s*(.*)$') {
        $current[$Matches[1]] = $Matches[2].Trim().Trim('"')
    }
}

[void][IO.Directory]::CreateDirectory($ServerData)
$sqlOrder = New-Object System.Collections.ArrayList
$failed = New-Object System.Collections.ArrayList
$i = 0
foreach ($t in $tasks) {
    $i++
    $label = "[$i/$($tasks.Count)] $($t.action) $($t.src)$($t.url)$($t.path)$($t.file)"
    Write-Host $label
    try {
        switch ($t.action) {
            'download_github' { Install-GithubRepo $t.src $t.ref $t.subpath $t.dest }
            'download_file'   { Get-RemoteFile $t.url (Resolve-RecipePath $t.path) }
            'unzip'           { Expand-Zip $t.src $t.dest }
            'move_path'       { Move-RecipePath $t.src $t.dest $false }
            'copy_path'       { Move-RecipePath $t.src $t.dest $true }
            'remove_path' {
                $p = Resolve-RecipePath $t.path
                if ([IO.Directory]::Exists($p)) { [IO.Directory]::Delete($p, $true) }
                elseif ([IO.File]::Exists($p)) { [IO.File]::Delete($p) }
            }
            'query_database' {
                # Recipe temp SQL would be deleted during cleanup, so keep a copy under sql\.
                $from = Resolve-RecipePath $t.file
                $sqlDir = Join-Path $projectRoot 'sql'
                [void][IO.Directory]::CreateDirectory($sqlDir)
                $name = ('{0:D2}-{1}' -f ($sqlOrder.Count + 1), [IO.Path]::GetFileName($from))
                [IO.File]::Copy($from, (Join-Path $sqlDir $name), $true)
                [void]$sqlOrder.Add($name)
            }
            'connect_database' { }
            'waste_time'       { }
            default { throw "unknown action: $($t.action)" }
        }
    } catch {
        Write-Host "  FAILED: $_" -ForegroundColor Red
        [void]$failed.Add("$label :: $_")
    }
}

[IO.File]::WriteAllLines((Join-Path $PSScriptRoot 'sql-order.txt'), [string[]]$sqlOrder)
Write-Host ''
Write-Host "Tasks: $($tasks.Count)  Failed: $($failed.Count)  SQL files: $($sqlOrder.Count)"
$failed | ForEach-Object { Write-Host $_ -ForegroundColor Red }
if ($failed.Count -gt 0) { exit 1 }
exit 0
