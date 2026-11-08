Core = nil
CoreName = nil
CoreReady = false
Citizen.CreateThread(function()
    for k, v in pairs(Cores) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            CoreName = v.ResourceName
            Core = v.GetFramework()
            CoreReady = true
        end
    end
end)

Config.ServerCallbacks = {}
function TriggerCallback(name, cb, ...)
    Config.ServerCallbacks[name] = cb
    TriggerServerEvent('0r-radio:server:triggerCallback', name, ...)
end

RegisterNetEvent('0r-radio:client:triggerCallback', function(name, ...)
    if Config.ServerCallbacks[name] then
        Config.ServerCallbacks[name](...)
        Config.ServerCallbacks[name] = nil
    end
end)

function GetPlayerData()
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayerData()
        return player
    elseif CoreName == "qbx_core" then
        local player = Core:GetPlayerData()
        return player
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerData()
        return player
    end
end

function hasRadioItem()
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        -- OX
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            if exports.ox_inventory:GetItemCount(Config.RadioItem, nil, false) >= 1 then
                return true
            end
        end
        -- QS
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            local item = exports['qs-inventory']:HasItem(Config.RadioItem, 1)
            return item
        end
        -- CodeM
        local hasCodem = GetResourceState('codem-inventory') == 'started' or GetResourceState('mInventory') == 'started'
        if hasCodem then
            local inv = exports['codem-inventory']:getUserInventory()
            for k, v in pairs(inv) do
                if v.name == Config.RadioItem then
                    if v.amount >= 1 then
                        return true
                    end
                end
            end
        end
       
        if CoreName == 'qb-core' then
             -- QB Inventory
            local qbPlayer = Core.Functions.GetPlayerData()
            if qbPlayer and qbPlayer.items and next(qbPlayer.items) then
                for _, item in pairs(qbPlayer.items) do
                    if item.name == Config.RadioItem then
                        if item.amount >= 1 then
                            return true
                        end
                    end
                end
            end
        end
        return false
    elseif CoreName == "es_extended" then
        -- OX
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            if exports.ox_inventory:GetItemCount(Config.RadioItem, nil, false) >= 1 then
                return true
            end
        end
        -- QS
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            local item = exports['qs-inventory']:HasItem(Config.RadioItem, 1)
            return item
        end
        -- CodeM
        local hasCodem = GetResourceState('codem-inventory') == 'started' or GetResourceState('mInventory') == 'started'
        if hasCodem then
            local inv = exports['codem-inventory']:getUserInventory()
            for k, v in pairs(inv) do
                if v.name == Config.RadioItem then
                    if v.amount >= 1 then
                        return true
                    end
                end
            end
        end
        -- ESX Inventory
        local player = Core.GetPlayerData()
        for k, v in pairs(player.inventory) do
            if v.name == Config.RadioItem then
                if v.count >= 1 then
                    return true
                end
            end
        end
        return false
    end
end