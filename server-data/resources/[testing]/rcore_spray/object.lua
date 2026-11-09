--[[
    Safe shared object getter for frameworks.
    Handles ESX and QBCore framework detection and loading with fallback methods.
]]
function GetSharedObjectSafe()
    local object = promise:new()
    local resolved = false

    if Framework then
        -- ESX Framework
        if Framework == FW_ESX then
            xpcall(function()
                object:resolve(exports[FrameworkTriggers['resourceName']]['getSharedObject']())
                resolved = true
            end, function()
                xpcall(function()
                    TriggerEvent(FrameworkTriggers['object'], function(obj)
                        object:resolve(obj)
                        resolved = true
                    end)
                end, function(err)
                    -- Error handler - framework object not available
                end)
            end)
        end

        -- QBCore Framework
        if Framework == FW_QBCORE then
            xpcall(function()
                object:resolve(exports[FrameworkTriggers['resourceName']]['GetCoreObject']())
                resolved = true
            end, function()
                xpcall(function()
                    object:resolve(exports[FrameworkTriggers['resourceName']]['GetSharedObject']())
                    resolved = true
                end, function()
                    xpcall(function()
                        TriggerEvent(FrameworkTriggers['object'], function(obj)
                            object:resolve(obj)
                            resolved = true
                        end)
                    end, debug.traceback)
                end)
            end)
        end

        SetTimeout(1000, function()
            if resolved == false then
                print('^1================ WARNING ================^7')
                print('^7Could not ^2load^7 shared object!^7')
                print('^1================ WARNING ================^7')
            end
        end)
    else
        print('^1================ WARNING ================^7')
        print('^7Framework not detected, could not ^2load^7 shared object!^7')
        print('^1================ WARNING ================^7')
    end

    return object
end

