--[[
    Version Check System for zloma_core
    Checks for updates on resource start
]]

local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '0.0.0'

-- Remote version URL (host this JSON file on GitHub or your server)
-- IMPORTANT: Must be RAW URL, not blob URL. Click "Raw" button on GitHub to get correct URL
local versionUrl = 'https://gist.githubusercontent.com/ZlomaScripts/721203c66e700a23b1a820fe7d957246/raw/version.json'

local function CheckVersion()
    PerformHttpRequest(versionUrl, function(statusCode, response, headers)
        if statusCode ~= 200 then
            print('^3[zloma_core] ^1Could not check for updates (HTTP ' .. tostring(statusCode) .. ')^7')
            return
        end

        local data = json.decode(response)
        if not data then
            print('^3[zloma_core] ^1Could not parse version data^7')
            return
        end

        local latestVersion = data.version

        if currentVersion == latestVersion then
            print('^5│^7  Version    ^8→^7  v' .. currentVersion .. ' ^2(latest)^7')
            print('^5│^7')
            print('^5╰──────────────────────────────────────────────────────────╯^7')
            print('')
        else
            -- Close the main startup box first
            print('^5│^7  Version    ^8→^7  v' .. currentVersion .. ' ^1(outdated)^7')
            print('^5│^7')
            print('^5╰──────────────────────────────────────────────────────────╯^7')
            print('')
            -- Update notification
            print('^3╭─ UPDATE AVAILABLE ───────────────────────────────────────╮^7')
            print('^3│^7  Current: ^1v' .. currentVersion .. '^7')
            print('^3│^7  Latest:  ^2v' .. latestVersion .. '^7')

            -- Show changelog
            if data.changelog and #data.changelog > 0 then
                print('^3│^7')
                print('^3│^7  ^5What\'s New:^7')
                for _, change in ipairs(data.changelog) do
                    print('^3│^7    • ' .. change)
                end
            end

            -- Show download links
            print('^3│^7')
            print('^3│^7  ^6Download:^7')
            if data.discord then
                print('^3│^7    Discord: ^4' .. data.discord .. '^7')
            end
            if data.cfx then
                print('^3│^7    CFX:     ^4' .. data.cfx .. '^7')
            end
            if data.tebex then
                print('^3│^7    Tebex:   ^4' .. data.tebex .. '^7')
            end

            print('^3╰──────────────────────────────────────────────────────────╯^7')
            print('')
        end
    end, 'GET', '', {['Content-Type'] = 'application/json'})
end

-- Startup Banner
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    print('')
    print('^5╭─^3 ZLOMA CORE ^5────────────────────────────────────────────╮^7')
    print('^5│^7')

    -- Check version after a short delay
    CreateThread(function()
        Wait(3000)
        CheckVersion()
    end)
end)
