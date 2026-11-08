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

function GetPlayer(source)
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayer(source)
        return player
    elseif CoreName == "qbx_core" then
        local player = Core:GetPlayer(source)
        return player
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        return player
    end
end

function GetPlayerByCid(cid)
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayerByCitizenId(cid)
        return player
    elseif CoreName == "qbx_core" then
        local player = Core:GetPlayerByCitizenId(cid)
        return player
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromIdentifier(cid)
        return player
    end
end

function GetPlayerJob(source)
    local src = tonumber(source)
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayer(src)
        if player then
            return player.PlayerData.job
        else
            return false
        end
    elseif CoreName == "qbx_core" then
        local player = Core:GetPlayer(src)
        if player then
            return player.PlayerData.job
        else
            return false
        end
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        if player then
            return player.job
        else
            return false
        end
    end
end

function GetPlayerLicense(source)
    local src = tonumber(source)
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayer(src)
        return player.PlayerData.citizenid
    elseif CoreName == "qbx_core" then
        local player = Core:GetPlayer(src)
        return player.PlayerData.citizenid
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        return player.getIdentifier()
    end
end

function GetCharName(source)
    local src = tonumber(source)
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayer(src)
        if player then
            return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        else
            return ""
        end
    elseif CoreName == "qbx_core" then
        local player = Core:GetPlayer(src)
        if player then
            return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        else
            return ""
        end
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(src)
        if player then
            return player.getName()
        else
            return ""
        end
    end
end

Config.ServerCallbacks = {}
function CreateCallback(name, cb)
    Config.ServerCallbacks[name] = cb
end

function TriggerCallback(name, source, cb, ...)
    if not Config.ServerCallbacks[name] then return end
    Config.ServerCallbacks[name](source, cb, ...)
end

RegisterNetEvent('0r-radio:server:triggerCallback', function(name, ...)
    local src = source
    TriggerCallback(name, src, function(...)
        TriggerClientEvent('0r-radio:client:triggerCallback', src, name, ...)
    end, ...)
end)

function RegisterUseableItem(name)
    while CoreReady == false do Citizen.Wait(0) end
    if CoreName == "qb-core" then
        Core.Functions.CreateUseableItem(name, function(source, item)
            TriggerClientEvent('0R-radio:use-jammer', source, item)
        end)
    elseif CoreName == "qbx_core" then
        Core:CreateUseableItem(name, function(source, item)
            TriggerClientEvent('0R-radio:use-jammer', source, item)
        end)
    elseif CoreName == "es_extended" then
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            Core.RegisterUsableItem(name, function(source, item)
                TriggerClientEvent('0R-radio:use-jammer', source, item)
            end)
        end
        Core.RegisterUsableItem(name, function(source, _, item)
            TriggerClientEvent('0R-radio:use-jammer', source, item)
        end)
    end
end

function RegisterUseableItem2(name)
    while CoreReady == false do Citizen.Wait(0) end
    if CoreName == "qb-core" then
        Core.Functions.CreateUseableItem(name, function(source, item)
            TriggerClientEvent('0R-radio:use-radio', source)
        end)
    elseif CoreName == "qbx_core" then
        Core:CreateUseableItem(name, function(source, item)
            TriggerClientEvent('0R-radio:use-radio', source)
        end)
    elseif CoreName == "es_extended" then
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            Core.RegisterUsableItem(name, function(source, item)
                TriggerClientEvent('0R-radio:use-radio', source)
            end)
        end
        Core.RegisterUsableItem(name, function(source, _, item)
            TriggerClientEvent('0R-radio:use-radio', source)
        end)
    end
end

function AddItem(source, name, amount, metadata, itemType)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = nil
        if CoreName == "qb-core" then
            player = Core.Functions.GetPlayer(source)
        elseif CoreName == "qbx_core" then
            player = Core:GetPlayer(source)
        end
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            return exports['qs-inventory']:AddItem(source, name, amount, false, metadata)
        end
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            return exports.ox_inventory:AddItem(source, name, amount, metadata)
        end
        local hasCodem = GetResourceState('codem-inventory') == 'started' or GetResourceState('mInventory') == 'started'
        if hasCodem then
            return exports["codem-inventory"]:AddItem(source, name, amount, nil, metadata)
        end
        player.Functions.AddItem(name, amount, false, metadata)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            return exports['qs-inventory']:AddItem(source, name, amount, false, metadata)
        end
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            return exports.ox_inventory:AddItem(source, name, amount, metadata)
        end
        local hasCodem = GetResourceState('codem-inventory') == 'started' or GetResourceState('mInventory') == 'started'
        if hasCodem then
            return exports["codem-inventory"]:AddItem(source, name, amount, nil, metadata)
        end
        if itemType == "weapon" then
            player.addWeapon(name, 0)
            return
        end
        player.addInventoryItem(name, amount)
    end
end

function RemoveItem(source, name, amount, metadata)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = nil
        if CoreName == "qb-core" then
            player = Core.Functions.GetPlayer(source)
        elseif CoreName == "qbx_core" then
            player = Core:GetPlayer(source)
        end
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            return exports['qs-inventory']:RemoveItem(source, name, amount, false, metadata)
        end
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            return exports.ox_inventory:RemoveItem(source, name, amount, metadata, nil)
        end
        local hasCodem = GetResourceState('codem-inventory') == 'started' or GetResourceState('mInventory') == 'started'
        if hasCodem then
            return exports["codem-inventory"]:RemoveItem(source, name, amount, nil)
        end
        player.Functions.RemoveItem(name, amount, false, metadata)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            return exports['qs-inventory']:RemoveItem(source, name, amount, false, metadata)
        end
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            return exports.ox_inventory:RemoveItem(source, name, amount, metadata, nil)
        end
        local hasCodem = GetResourceState('codem-inventory') == 'started' or GetResourceState('mInventory') == 'started'
        if hasCodem then
            return exports["codem-inventory"]:RemoveItem(source, name, amount, nil)
        end
        player.removeInventoryItem(name, amount)
    end
end