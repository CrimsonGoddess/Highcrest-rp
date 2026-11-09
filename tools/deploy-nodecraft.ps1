<#
  Uploads resources to the Nodecraft server over SFTP, using the login in deploy\sftp.txt.
  Only changed files are sent, and nothing on the server is deleted.

    tools\deploy-nodecraft.ps1 -Preview                  show what would change
    tools\deploy-nodecraft.ps1                           upload
    tools\deploy-nodecraft.ps1 -Resources a,b            choose resources in [custom]
    tools\deploy-nodecraft.ps1 -Folders "resources\[x]"   sync whole folders, relative to server-data
    tools\deploy-nodecraft.ps1 -Files x,y                upload single files, relative to server-data
                                                         (with -Preview, downloads them to deploy\remote-check to compare)
#>
param(
    [switch]$Preview,
    [string[]]$Resources = @('highcrest_phone', 'highcrest_ui', 'highcrest_empire'),
    [string[]]$Files = @(),
    [string[]]$Folders = @()
)
$ErrorActionPreference = 'Stop'
# A list arrives as one comma-separated value when this script is run with -File.
$Files = @($Files | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
# Asking for single files means only those files, unless resources are named too.
$Folders = @($Folders | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
if (($Files.Count -gt 0 -or $Folders.Count -gt 0) -and -not $PSBoundParameters.ContainsKey('Resources')) { $Resources = @() }
$root = Split-Path -Parent $PSScriptRoot
$loginFile = Join-Path $root 'deploy\sftp.txt'
$keyFile = Join-Path $root 'deploy\sftp-hostkey.txt'
$remoteBase = '/servers/highcrest/resources/[custom]'
$localBase = Join-Path $root 'server-data\resources\[custom]'

$winscp = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\WinSCP\WinSCP.com'),
    'C:\Program Files (x86)\WinSCP\WinSCP.com',
    'C:\Program Files\WinSCP\WinSCP.com'
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $winscp) { throw 'WinSCP is not installed.' }

$login = @{}
foreach ($line in [IO.File]::ReadAllLines($loginFile)) {
    if ($line -match '^\s*(host|port|user|password)=(.*)$') { $login[$Matches[1]] = $Matches[2].Trim() }
}
foreach ($key in 'host', 'port', 'user', 'password') {
    if (-not $login[$key] -or $login[$key] -like 'PASTE_*') { throw "deploy\sftp.txt is missing: $key" }
}

# Remember the server's identity on first use, so later uploads can't go to an impostor.
if (-not (Test-Path -LiteralPath $keyFile)) {
    # With no login and no known key, WinSCP refuses to connect and prints the key it saw.
    $probe = [IO.Path]::GetTempFileName()
    [IO.File]::WriteAllLines($probe, [string[]]@('option batch abort', "open sftp://$($login.host):$($login.port)/", 'exit'))
    $output = (& $winscp /ini=nul "/script=$probe" 2>&1 | Out-String)
    Remove-Item -LiteralPath $probe -Force
    $match = [regex]::Match($output, '(ssh-[a-z0-9-]+|ecdsa-[a-z0-9-]+) \d+ [A-Za-z0-9+/]{20,}=*')
    if (-not $match.Success) { throw "Could not read the server host key:`n$output" }
    [IO.File]::WriteAllText($keyFile, $match.Value)
}
$hostKey = [IO.File]::ReadAllText($keyFile).Trim()

$lines = New-Object System.Collections.ArrayList
[void]$lines.Add('option batch abort')
[void]$lines.Add('option confirm off')
[void]$lines.Add(('open sftp://{0}:{1}/ -username="{2}" -password="{3}" -hostkey="{4}"' -f $login.host, $login.port, $login.user, $login.password.Replace('"', '""'), $hostKey))
foreach ($resource in $Resources) {
    $local = Join-Path $localBase $resource
    if (-not (Test-Path -LiteralPath $local)) { throw "No such resource: $resource" }
    $mode = if ($Preview) { '-preview' } else { '' }
    if (-not $Preview) {
        # The folder may already exist, so a failure here is fine.
        [void]$lines.Add('option batch continue')
        [void]$lines.Add(('mkdir "{0}/{1}"' -f $remoteBase, $resource))
        [void]$lines.Add('option batch abort')
    }
    [void]$lines.Add(('synchronize remote {0} -criteria=either "{1}" "{2}/{3}"' -f $mode, $local, $remoteBase, $resource))
}
foreach ($folder in $Folders) {
    $local = Join-Path (Join-Path $root 'server-data') $folder
    if (-not (Test-Path -LiteralPath $local)) { throw "No such folder: $folder" }
    $remote = '/servers/highcrest/' + $folder.Replace('\', '/').TrimEnd('/')
    $mode = if ($Preview) { '-preview' } else { '' }
    if (-not $Preview) {
        [void]$lines.Add('option batch continue')
        [void]$lines.Add(('mkdir "{0}"' -f $remote))
        [void]$lines.Add('option batch abort')
    }
    [void]$lines.Add(('synchronize remote {0} -criteria=either "{1}" "{2}"' -f $mode, $local, $remote))
}
foreach ($file in $Files) {
    if ($file -match '(^|[\\/])secrets\.cfg$') { throw 'secrets.cfg is never deployed by this script.' }
    $local = Join-Path (Join-Path $root 'server-data') $file
    $remote = '/servers/highcrest/' + $file.Replace('\', '/')
    if ($Preview) {
        $checkDir = Join-Path $root ('deploy\remote-check\' + [IO.Path]::GetDirectoryName($file))
        [void][IO.Directory]::CreateDirectory($checkDir)
        [void]$lines.Add(('get "{0}" "{1}\"' -f $remote, $checkDir))
    } else {
        [void]$lines.Add(('put "{0}" "{1}"' -f $local, $remote))
    }
}
[void]$lines.Add('exit')

$script =[IO.Path]::GetTempFileName()
try {
    [IO.File]::WriteAllLines($script, [string[]]$lines)
    # The script file holds the password, so it's deleted straight after this runs.
    & $winscp /ini=nul "/script=$script"
    if ($LASTEXITCODE -ne 0) { throw "WinSCP failed with exit code $LASTEXITCODE" }
} finally {
    Remove-Item -LiteralPath $script -Force -ErrorAction SilentlyContinue
}
