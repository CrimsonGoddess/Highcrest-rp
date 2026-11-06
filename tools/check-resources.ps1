<#
  Static audit of server-data\resources. Reports:
    - dependencies that no installed resource provides
    - ui_page and loadscreen files that don't exist (usually an unbuilt web UI)
  Exits 1 if any problem is found.
#>
$root = Split-Path -Parent $PSScriptRoot
$resRoot = Join-Path $root 'server-data\resources'
# Enumerate with .NET: Get-ChildItem -Include with -LiteralPath matches every file on PowerShell 5.1.
$manifests = @([IO.Directory]::EnumerateFiles($resRoot, '*.lua', [IO.SearchOption]::AllDirectories) |
    Where-Object { ([IO.Path]::GetFileName($_) -in 'fxmanifest.lua', '__resource.lua') -and $_ -notmatch '\\node_modules\\' } |
    ForEach-Object { [IO.FileInfo]$_ })

$resources = @{}
foreach ($m in $manifests) {
    if ($resources.ContainsKey($m.Directory.Name)) { Write-Host "Duplicate resource name: $($m.Directory.Name)" }
    $resources[$m.Directory.Name] = $m
}

# A resource can satisfy a dependency under another name with: provide 'name'
$provided = @{}
foreach ($m in $manifests) {
    foreach ($x in [regex]::Matches([IO.File]::ReadAllText($m.FullName), "(?m)^\s*provides?\s+['""]([^'""]+)['""]")) {
        $provided[$x.Groups[1].Value] = $m.Directory.Name
    }
}
Write-Host "Resources found: $($resources.Count)"

$problems = New-Object System.Collections.ArrayList
foreach ($name in ($resources.Keys | Sort-Object)) {
    $m = $resources[$name]
    $text = [IO.File]::ReadAllText($m.FullName)
    $clean = [regex]::Replace($text, '--\[\[[\s\S]*?\]\]', '')
    $clean = [regex]::Replace($clean, '(?m)--.*$', '')

    $deps = New-Object System.Collections.ArrayList
    foreach ($x in [regex]::Matches($clean, "(?s)dependencies\s*\{(.*?)\}")) {
        foreach ($y in [regex]::Matches($x.Groups[1].Value, "['""]([^'""]+)['""]")) { [void]$deps.Add($y.Groups[1].Value) }
    }
    foreach ($x in [regex]::Matches($clean, "(?m)^\s*dependency\s+['""]([^'""]+)['""]")) { [void]$deps.Add($x.Groups[1].Value) }

    foreach ($d in $deps) {
        if ($d -match '^/') { continue }                   # /server:1234, /onesync, /gameBuild:...
        $bare = ($d -split ':')[0]
        if (-not $resources.ContainsKey($bare) -and -not $provided.ContainsKey($bare)) { [void]$problems.Add("$name : missing dependency '$d'") }
    }

    foreach ($x in [regex]::Matches($clean, "(?m)^\s*(ui_page|loadscreen)\s+['""]([^'""]+)['""]")) {
        $page = $x.Groups[2].Value
        if ($page -match '^(https?|nui)://') { continue }
        $full = [IO.Path]::Combine($m.Directory.FullName, $page.Replace('/', '\'))
        if (-not [IO.File]::Exists($full)) { [void]$problems.Add("$name : $($x.Groups[1].Value) file not found '$page'") }
    }
}

Write-Host "Problems: $($problems.Count)"
$problems | ForEach-Object { Write-Host "  $_" }
if ($problems.Count -gt 0) { exit 1 }
exit 0
