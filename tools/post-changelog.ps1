<#
  Posts a changelog to the Discord channel behind the webhook in deploy\discord-changelog.txt.
  Messages over Discord's 2000-character limit are split on line breaks.

    tools\post-changelog.ps1 -File docs\changelog-pending.md
#>
param(
    [Parameter(Mandatory = $true)][string]$File
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$webhook = ([IO.File]::ReadAllText((Join-Path $root 'deploy\discord-changelog.txt'))).Trim()
if ($webhook -notmatch '^https://(ptb\.|canary\.)?discord(app)?\.com/api/webhooks/\d+/[\w-]+$') {
    throw 'deploy\discord-changelog.txt does not hold a Discord webhook URL.'
}

$path = if ([IO.Path]::IsPathRooted($File)) { $File } else { Join-Path $root $File }
$text = ([IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)).Trim()
if (-not $text) { throw "$File is empty." }

$chunks = New-Object System.Collections.ArrayList
$current = ''
foreach ($line in $text -split "`r?`n") {
    if (($current.Length + $line.Length + 1) -gt 1900) {
        [void]$chunks.Add($current.TrimEnd())
        $current = ''
    }
    $current += "$line`n"
}
if ($current.Trim()) { [void]$chunks.Add($current.TrimEnd()) }

foreach ($chunk in $chunks) {
    # Mentions are switched off so a changelog can never ping @everyone or roles by accident.
    $body = @{ content = $chunk; allowed_mentions = @{ parse = @() } } | ConvertTo-Json -Depth 4
    Invoke-RestMethod -Uri $webhook -Method Post -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body)) | Out-Null
    Start-Sleep -Milliseconds 800
}
Write-Output ("Posted {0} message(s)." -f $chunks.Count)
