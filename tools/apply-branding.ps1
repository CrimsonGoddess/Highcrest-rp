<#
  Applies Highcrest colors to the compiled ox_lib and ox_inventory interfaces.
  Safe to re-run. Run it again after re-downloading either resource.
  If an update changes the compiled code, this stops with an error instead of guessing.
#>
$ErrorActionPreference = 'Stop'
$res  = Join-Path (Split-Path -Parent $PSScriptRoot) 'server-data\resources'
$utf8 = New-Object Text.UTF8Encoding($false)

function Update-Text([string]$path, [string[][]]$pairs, [string]$appendCss) {
    $text = [IO.File]::ReadAllText($path)
    foreach ($pair in $pairs) {
        if ($text.Contains($pair[0])) {
            $text = $text.Replace($pair[0], $pair[1])
        } elseif (-not $text.Contains($pair[1])) {
            throw "Expected text not found in ${path}: $($pair[0])"
        }
    }
    if ($appendCss -and -not $text.Contains('/*highcrest*/')) {
        $text += "/*highcrest*/$appendCss"
    }
    [IO.File]::WriteAllText($path, $text, $utf8)
    Write-Host "Branded $([IO.Path]::GetFileName($path))"
}

# ox_lib: menus, dialogs, notifications and progress bars share one palette.
$libJs = [IO.Directory]::GetFiles([IO.Path]::Combine($res, '[ox]', 'ox_lib', 'web', 'build', 'assets'), '*.js')[0]
Update-Text $libJs @(
    , @('dark:["#C1C2C5","#A6A7AB","#909296","#5c5f66","#373A40","#2C2E33","#25262b","#1A1B1E","#141517","#101113"]',
        'dark:["#F5F5F5","#B9B9C2","#94949E","#62626C","#4A2A31","#35202A","#1C1C22","#141418","#0F0F12","#0B0B0D"]')
) ''
Update-Text $libJs @(
    , @('"#e03131","#c92a2a"]', '"#DC1E3C","#C8102E"]')
) ''

# ox_inventory: stylesheet.
$invAssets = [IO.Path]::Combine($res, '[ox]', 'ox_inventory', 'web', 'build', 'assets')
$accents = @'
.inventory-slot,.hotbar-item-slot,.item-notification-item-box{border:1px solid rgba(212,175,55,.2)}
.inventory-slot-label-box{border-top:1px solid #c8102e}
.inventory-slot-number{background-color:#d4af37;color:#0b0b0d}
.inventory-control .inventory-control-button:hover{background-color:#c8102e}
.useful-controls-button:hover{background-color:#c8102e!important}
.weight-bar{border:1px solid rgba(212,175,55,.4)}
.tooltip-wrapper,.context-menu-list{border:1px solid rgba(200,16,46,.55)}
'@
Update-Text ([IO.Path]::Combine($invAssets, 'index.css')) @(
    @('#22232c', '#1c1c22'),
    @('#33343f', '#3a1a22'),
    @('#0c0c0c66', '#0b0b0dd1'),
    @('#0c0c0ccc', '#0b0b0df2')
) ($accents -replace "`r?`n", '')

# ox_inventory: weight and durability bars run from gold to crimson.
Update-Text ([IO.Path]::Combine($invAssets, 'index.js')) @(
    , @('primaryColor:[231,76,60],secondColor:[39,174,96],accentColor:[211,84,0]',
        'primaryColor:[200,16,46],secondColor:[212,175,55],accentColor:[190,110,40]')
) ''
