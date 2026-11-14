<#
  Pulls GitHub's main branch and uploads exactly the files that changed since the last upload.

    tools\pull-and-upload.ps1 -Preview        show what would be uploaded, change nothing
    tools\pull-and-upload.ps1                 pull, upload, then record the new position on the server

  The server remembers the last uploaded commit in /servers/highcrest/.deployed-commit, so it
  doesn't matter who uploaded last (the owner, the lead dev, or either one's Claude).

  Safety rules built in:
  - Only commits that are on GitHub get uploaded (no unpushed or uncommitted work).
  - Nothing on the server is ever deleted. A resource that git moved (for example into [disabled])
    is moved on the server too; any other removed files are listed so a person can decide.
  - Files the SERVER writes itself are never uploaded over (see $serverOwned below).
  - secrets.cfg is never uploaded.
  Login: deploy\sftp.txt (host=, port=, user=, password=), never committed.
#>
param(
    [switch]$Preview,
    # Only needed the very first time, before the server has a .deployed-commit marker.
    [string]$Since
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root
$remoteRoot = '/servers/highcrest'
$markerRemote = "$remoteRoot/.deployed-commit"

# Files the running server creates or edits. Uploading a local copy would wipe live data.
$serverOwned = @(
    '/highcrest_handling/handling\.meta$',
    '/highcrest_handling/entries\.json$',
    '/Renewed-Banking/atm_placements\.json$',
    '/rtx_shellcreator/data/',
    '/rtx_custom_(shells|mlos|walk)/',
    '/uz_AutoShot/shots/',
    '(^|/)secrets\.cfg$'
)

function Invoke-Git { $out = & git.exe @args; if ($LASTEXITCODE -ne 0) { throw "git $($args -join ' ') failed" }; $out }

# 1. Make sure we upload exactly what's on GitHub.
$dirty = Invoke-Git status --porcelain --untracked-files=no -- server-data
if ($dirty) { throw "You have uncommitted changes in server-data. Commit and push them first:`n$($dirty -join "`n")" }
Invoke-Git fetch origin --quiet
$branch = (Invoke-Git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne 'main') { throw "You're on branch '$branch'. Switch to main first (git checkout main)." }
Invoke-Git merge --ff-only origin/main --quiet | Out-Null
$head = (Invoke-Git rev-parse HEAD).Trim()
$remoteHead = (Invoke-Git rev-parse origin/main).Trim()
if ($head -ne $remoteHead) { throw 'Your main has commits GitHub does not have. Push them first (git push), then run this again.' }

# 2. WinSCP and the login.
$winscp = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\WinSCP\WinSCP.com'),
    'C:\Program Files (x86)\WinSCP\WinSCP.com',
    'C:\Program Files\WinSCP\WinSCP.com'
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $winscp) { throw 'WinSCP is not installed (winget install WinSCP.WinSCP).' }
$loginFile = Join-Path $root 'deploy\sftp.txt'
$keyFile = Join-Path $root 'deploy\sftp-hostkey.txt'
if (-not (Test-Path -LiteralPath $loginFile)) { throw 'deploy\sftp.txt is missing (lines: host=, port=, user=, password=).' }
$login = @{}
foreach ($line in [IO.File]::ReadAllLines($loginFile)) {
    if ($line -match '^\s*(host|port|user|password)=(.*)$') { $login[$Matches[1]] = $Matches[2].Trim() }
}
foreach ($key in 'host', 'port', 'user', 'password') { if (-not $login[$key]) { throw "deploy\sftp.txt is missing: $key" } }
if (-not (Test-Path -LiteralPath $keyFile)) {
    # Learn the server's identity once (same as deploy-nodecraft.ps1).
    & (Join-Path $PSScriptRoot 'deploy-nodecraft.ps1') -Preview -Resources @() | Out-Null
}
$hostKey = [IO.File]::ReadAllText($keyFile).Trim()

function Invoke-WinScp([string[]]$commands, [switch]$AllowFail) {
    $all = @('option batch abort', 'option confirm off',
        ('open sftp://{0}:{1}/ -username="{2}" -password="{3}" -hostkey="{4}"' -f $login.host, $login.port, $login.user, $login.password.Replace('"', '""'), $hostKey)) + $commands + @('exit')
    $file = [IO.Path]::GetTempFileName()
    try {
        [IO.File]::WriteAllLines($file, [string[]]$all)
        & $winscp /ini=nul "/script=$file"
        if ($LASTEXITCODE -ne 0 -and -not $AllowFail) { throw "WinSCP failed with exit code $LASTEXITCODE" }
    } finally { Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue }
}

# 3. Where did the last upload stop?
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('hc-marker-' + [guid]::NewGuid())
[void][IO.Directory]::CreateDirectory($tmp)
try {
    Invoke-WinScp @(('get "{0}" "{1}\"' -f $markerRemote, $tmp)) -AllowFail | Out-Null
    $markerFile = Join-Path $tmp '.deployed-commit'
    $marker = if (Test-Path -LiteralPath $markerFile) { ([IO.File]::ReadAllText($markerFile)).Trim() } else { '' }
} finally { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
$from = if ($Since) { $Since } else { $marker }
if (-not $from) { throw 'The server has no .deployed-commit yet. Run once with -Since <commit that the server already matches>.' }
$from = (Invoke-Git rev-parse $from).Trim()
& git merge-base --is-ancestor $from $head
if ($LASTEXITCODE -ne 0) { throw "The server's recorded commit $from is not part of main. Ask the owner before uploading." }

Write-Host "Server is at  $($from.Substring(0,7))"
Write-Host "GitHub is at  $($head.Substring(0,7))"
if ($from -eq $head) { Write-Host 'The server is already up to date. Nothing to upload.'; return }
Write-Host "`nNew commits:"
Invoke-Git log --oneline "$from..$head" | ForEach-Object { Write-Host "  $_" }

# 4. What changed under server-data?
$changes = Invoke-Git -c core.quotepath=false diff --name-status --no-renames $from $head -- server-data
$uploads = New-Object System.Collections.ArrayList
$deleted = New-Object System.Collections.ArrayList
$skipped = New-Object System.Collections.ArrayList
foreach ($row in $changes) {
    $status, $path = $row -split "`t", 2
    $rel = $path.Substring('server-data/'.Length)
    if ($serverOwned | Where-Object { $rel -match $_ }) { [void]$skipped.Add($rel); continue }
    if ($status -eq 'D') { [void]$deleted.Add($rel) } else { [void]$uploads.Add($rel) }
}

# A resource is the folder under resources\ (inside any [category] folders).
function Get-ResourceDir([string]$rel) {
    $m = [regex]::Match($rel, '^(resources/(?:\[[^\]/]+\]/)*[^/\[][^/]*)/')
    if ($m.Success) { $m.Groups[1].Value } else { $null }
}
# Whole resources that git moved (old folder gone locally, same name added somewhere else).
$moves = @{}
foreach ($rel in $deleted) {
    $dir = Get-ResourceDir $rel
    if (-not $dir -or $moves.ContainsKey($dir) -or (Test-Path -LiteralPath (Join-Path 'server-data' $dir))) { continue }
    $name = $dir.Split('/')[-1]
    $targets = @($uploads | ForEach-Object { Get-ResourceDir $_ } | Where-Object { $_ -and $_ -ne $dir -and $_.Split('/')[-1] -eq $name } | Select-Object -Unique)
    if ($targets.Count -eq 1) { $moves[$dir] = $targets[0] }
}
$leftOver = @($deleted | Where-Object { $d = Get-ResourceDir $_; -not ($d -and $moves.ContainsKey($d)) })

Write-Host "`nFiles to upload: $($uploads.Count)"
$uploads | ForEach-Object { Write-Host "  $_" }
if ($moves.Count) { Write-Host "`nResources to move on the server:"; $moves.GetEnumerator() | ForEach-Object { Write-Host "  $($_.Key)  ->  $($_.Value)" } }
if ($skipped.Count) { Write-Host "`nNot uploaded (the server owns these files):"; $skipped | ForEach-Object { Write-Host "  $_" } }
if ($leftOver.Count) { Write-Host "`nRemoved in git but LEFT on the server (delete by hand only if it matters):"; $leftOver | ForEach-Object { Write-Host "  $_" } }

$restart = @($uploads + @($moves.Values) | ForEach-Object { Get-ResourceDir $_ } | Where-Object { $_ } | ForEach-Object { $_.Split('/')[-1] } | Select-Object -Unique)
$cfgChanged = @($uploads | Where-Object { $_ -match '^[^/]+\.cfg$' -or $_ -match '\.cfg$' })

if ($Preview) { Write-Host "`nPreview only. Nothing was changed."; return }

# 5. Upload.
$cmds = New-Object System.Collections.ArrayList
foreach ($pair in $moves.GetEnumerator()) {
    $parent = $remoteRoot + '/' + ($pair.Value.Substring(0, $pair.Value.LastIndexOf('/')))
    [void]$cmds.Add('option batch continue')
    [void]$cmds.Add(('mkdir "{0}"' -f $parent))
    [void]$cmds.Add('option batch abort')
    [void]$cmds.Add(('mv "{0}/{1}" "{0}/{2}"' -f $remoteRoot, $pair.Key, $pair.Value))
}
# Create any new folders, parents first. Existing ones just fail quietly.
$dirs = @($uploads | ForEach-Object { $p = $_; $parts = $p.Split('/'); for ($i = 1; $i -lt $parts.Count; $i++) { ($parts[0..($i - 1)] -join '/') } } | Select-Object -Unique | Sort-Object { $_.Split('/').Count })
if ($dirs.Count) {
    [void]$cmds.Add('option batch continue')
    foreach ($d in $dirs) { if (-not (Test-Path -LiteralPath (Join-Path 'server-data' $d) -PathType Container)) { continue }; [void]$cmds.Add(('mkdir "{0}/{1}"' -f $remoteRoot, $d)) }
    [void]$cmds.Add('option batch abort')
}
foreach ($rel in $uploads) {
    $local = Join-Path (Join-Path $root 'server-data') ($rel.Replace('/', '\'))
    [void]$cmds.Add(('put "{0}" "{1}/{2}"' -f $local, $remoteRoot, $rel))
}
$markerLocal = [IO.Path]::GetTempFileName()
try {
    [IO.File]::WriteAllText($markerLocal, $head)
    [void]$cmds.Add(('put "{0}" "{1}"' -f $markerLocal, $markerRemote))
    Invoke-WinScp $cmds | Out-Null
} finally { Remove-Item -LiteralPath $markerLocal -Force -ErrorAction SilentlyContinue }

Write-Host "`nUploaded. The server is now at $($head.Substring(0,7))."
if ($cfgChanged.Count) { Write-Host 'A .cfg file changed: do a FULL restart in txAdmin.' }
elseif ($restart.Count) { Write-Host 'Restart these in the txAdmin live console:'; $restart | ForEach-Object { Write-Host "  ensure $_" } }
