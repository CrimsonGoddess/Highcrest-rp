local resourceName = "lation_detecting"
local currentResource = cache.resource
local version = GetResourceMetadata(resourceName, "version", 0)

if currentResource ~= resourceName then
    local errorInterval = 900000
    print("^1[ERROR]: An error has occured with the resource '" .. currentResource .. "'^0")
    print("^1[ERROR]: Please rename the folder to '" .. resourceName .. "' to avoid further issues^0")
    CreateThread(function()
        while true do
            Wait(errorInterval)
            print("^1[ERROR]: An error has occured with the resource '" .. currentResource .. "'^0")
            print("^1[ERROR]: Please rename the folder to '" .. resourceName .. "' to avoid further issues^0")
        end
    end)
end

function CheckVersion()
    if not version then
        print("^1[ERROR]: Unable to determine current resource version for '" .. resourceName .. "'^0")
        return
    end
    SetTimeout(1000, function()
        PerformHttpRequest("https://api.lationscripts.com/" .. resourceName .. "/version", function(statusCode, response)
            if statusCode ~= 200 then
                print("^1[ERROR]: Unable to fetch version information from API.^0")
                return
            end
            local data = json.decode(response)
            if data.version then
                if data.version ~= version then
                    print("^3An update is available for " .. resourceName .. "^0")
                    print("^3Your Version: ^1" .. version .. "^0 | ^3Latest Version: ^2" .. data.version .. "^0")
                    print("^3Download the latest release from https://portal.cfx.re/assets/granted-assets^0")
                    print("^3For more information about this update visit our Discord: https://discord.gg/9EbY4nM5uu^0")
                end
            end
        end, "GET")
    end)
end

if Config.Setup.version then
    CheckVersion()
end
