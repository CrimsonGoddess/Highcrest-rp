-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

--[[
    Version Check System for zloma_apartments
    Checks for updates on resource start
]]

local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '0.0.0'

-- Must be the RAW gist URL.
local versionUrl = 'https://gist.githubusercontent.com/ZlomaScripts/0a9e17c00f877cf8d7805742d08f58e7/raw/version.json'

local function CheckVersion()
    PerformHttpRequest(versionUrl, function(statusCode, response)
        if statusCode ~= 200 then
            print('^3[zloma_apartments] ^1Could not check for updates (HTTP ' .. tostring(statusCode) .. ')^7')
            return
        end

        local ok, data = pcall(json.decode, response)
        if not ok or type(data) ~= 'table' or not data.version then
            print('^3[zloma_apartments] ^1Could not parse version data^7')
            return
        end

        local latestVersion = data.version
        local comparison=ApartmentVersion.compare(currentVersion,latestVersion)
        if comparison==nil then
            print('^3[zloma_apartments] Invalid semantic version in update check^7')
            return
        end
        print('')
        print('^5╭─^3 ZLOMA APARTMENTS ^5──────────────────────────────────────╮^7')
        print('^5│^7')

        if comparison >= 0 then
            print('^5│^7  Version    ^8→^7  v' .. currentVersion .. (comparison==0 and ' ^2(latest)^7' or ' ^3(local beta/development build ahead of published version)^7'))
            print('^5│^7')
            print('^5╰──────────────────────────────────────────────────────────╯^7')
            print('')
        else
            print('^5│^7  Version    ^8→^7  v' .. currentVersion .. ' ^1(outdated)^7')
            print('^5│^7')
            print('^5╰──────────────────────────────────────────────────────────╯^7')
            print('')
            print('^3╭─ UPDATE AVAILABLE ───────────────────────────────────────╮^7')
            print('^3│^7  Current: ^1v' .. currentVersion .. '^7')
            print('^3│^7  Latest:  ^2v' .. latestVersion .. '^7')

            if type(data.changelog) == 'table' and #data.changelog > 0 then
                print('^3│^7')
                print('^3│^7  ^5What\'s New:^7')
                for _, change in ipairs(data.changelog) do
                    print('^3│^7    • ' .. change)
                end
            end

            print('^3│^7')
            print('^3│^7  ^6Download:^7')
            if data.github then print('^3│^7    GitHub:  ^4' .. data.github .. '^7') end
            if data.download then print('^3│^7    Release: ^4' .. data.download .. '^7') end
            if data.discord then print('^3│^7    Discord: ^4' .. data.discord .. '^7') end
            if data.cfx then print('^3│^7    CFX:     ^4' .. data.cfx .. '^7') end
            if data.tebex then print('^3│^7    Tebex:   ^4' .. data.tebex .. '^7') end

            print('^3╰──────────────────────────────────────────────────────────╯^7')
            print('')
        end
    end, 'GET', '', { ['Content-Type'] = 'application/json' })
end

CreateThread(function()
    Wait(3000)
    CheckVersion()
end)
