local detectingPlayers = {}

function IsPlayerBanned(source)
    if not source then
        EventLog("[detecting.lua]: IsPlayerBanned: source missing or nil", "error")
        return false
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[detecting.lua]: IsPlayerBanned: unable to retrieve player identifier", "error")
        return false
    end
    return Config.Detecting.bans[identifier] or false
end

function IsInRestrictedArea(coords)
    for _, area in pairs(Config.Detecting.restricted_areas) do
        local distance = #(coords - area.coords)
        if distance < area.radius then
            return true
        end
    end
    return false
end

function IsInDesignatedArea(coords)
    for _, area in pairs(Config.Detecting.designated_areas.areas) do
        local distance = #(coords - area.coords)
        if distance < area.radius then
            return true
        end
    end
    return false
end

function GetRewardItem(loot)
    local weightedList = {}
    if not loot then
        EventLog("[detecting.lua]: GetRewardItem: loot table missing or nil", "error")
        return
    end
    if type(loot) ~= "table" then
        EventLog("[detecting.lua]: GetRewardItem: loot table param invalid type", "error")
        return
    end
    for itemName, itemData in pairs(loot) do
        for i = 1, itemData.chance do
            table.insert(weightedList, itemName)
        end
    end
    local randomIndex = math.random(#weightedList)
    return weightedList[randomIndex]
end

lib.callback.register("lation_detecting:IsPlayerBanned", function(source)
    return IsPlayerBanned(source)
end)

RegisterNetEvent("lation_detecting:ItemAssigned", function(item)
    local source = source
    if not source or not item then
        EventLog("[detecting.lua]: lation_detecting:ItemAssigned: params missing or nil", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[detecting.lua]: lation_detecting:ItemAssigned: unable to retrieve player identifier", "error")
        return
    end
    local playerData = detectingPlayers[identifier]
    if not playerData or not playerData.started then
        EventLog("[detecting.lua]: lation_detecting:ItemAssigned: unable to verify player detecting status", "error")
        return
    end
    if playerData.started ~= item then
        EventLog("[detecting.lua]: lation_detecting:ItemAssigned: players started model doesnt match passed model", "error")
        return
    end
    playerData.ended = item
end)

RegisterNetEvent("lation_detecting:ItemFound", function()
    local source = source
    if not source then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: source missing or nil", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: unable to retrieve player identifier", "error")
        return
    end
    local playerName = GetName(source)
    if not playerName then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: unable to retrieve player name", "error")
        return
    end
    local playerData = detectingPlayers[identifier]
    if not playerData then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: player not found in detecting table", "error")
        return
    end
    if playerData.started ~= playerData.ended then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: player started & ended model do not match", "error")
        return
    end
    local level = nil
    local detectorData = nil
    for detectorLevel, detector in pairs(Config.Detectors) do
        if detector.item == playerData.started and detector.item == playerData.ended then
            level = detectorLevel
            detectorData = detector
            break
        end
    end
    if not level or not detectorData then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: unable to retrieve required level and/or model data", "error")
        return
    end
    local playerLevel = exports.lation_detecting:GetPlayerData(source, "level")
    if not playerLevel then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: unable to retrieve player level", "error")
        return
    end
    if Config.Detecting.verify_level and level > playerLevel then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: player level does not meet required level for this model", "error")
        return
    end
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if IsInRestrictedArea(playerCoords) then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: player is inside a restricted area", "error")
        return
    end
    if Config.Detecting.designated_areas.enabled then
        if not IsInDesignatedArea(playerCoords) then
            EventLog("[detecting.lua]: lation_detecting:ItemFound: player is not inside a designated area", "error")
            return
        end
    end
    local rewardItem = GetRewardItem(detectorData.loot)
    if not rewardItem then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: unable to retrieve the selected reward item", "error")
        return
    end
    local itemData = detectorData.loot[rewardItem]
    if not itemData then
        EventLog("[detecting.lua]: lation_detecting:ItemFound: unable to retrieve the selected item data", "error")
        return
    end
    local quantity = math.random(itemData.quantity.min, itemData.quantity.max)
    AddItem(source, rewardItem, quantity)
    ItemFound(source, detectorData.item, rewardItem, quantity)
    exports.lation_detecting:AddPlayerData(source, "experience", itemData.addXP)
    exports.lation_detecting:AddPlayerData(source, "items_found", quantity)
    detectingPlayers[identifier] = nil
    if Logs.Events.found_item then
        local logMessage = string.format(Strings.Logs.found_item.message, tostring(playerName), tostring(identifier), tostring(quantity), tostring(rewardItem))
        PlayerLog(source, Strings.Logs.found_item.title, logMessage)
    end
end)

for level, detector in pairs(Config.Detectors) do
    RegisterUsableItem(detector.item, function(source)
        if not source then
            EventLog("[detecting.lua]: RegisterUsableItem: source missing or nil", "error")
            return
        end
        local identifier = GetIdentifier(source)
        if not identifier then
            EventLog("[detecting.lua]: RegisterUsableItem: unable to retrieve player identifier", "error")
            return
        end
        if Config.Detecting.job.require then
            local playerJob = GetPlayerJob(source)
            if playerJob and playerJob ~= Config.Detecting.job.job then
                TriggerClientEvent("lation_detecting:Notify", source, Strings.Notify.notAuthorized, "error")
                return
            end
        end
        if Config.Detecting.verify_level then
            local playerLevel = exports.lation_detecting:GetPlayerData(source, "level")
            if playerLevel < level then
                TriggerClientEvent("lation_detecting:Notify", source, Strings.Notify.noLevel, "error")
                return
            end
        end
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        if IsInRestrictedArea(playerCoords) then
            TriggerClientEvent("lation_detecting:Notify", source, Strings.Notify.cantDetect, "error")
            return
        end
        if IsPlayerBanned(source) then
            TriggerClientEvent("lation_detecting:Notify", source, Strings.Notify.notAuthorized, "error")
            return
        end
        if not CanUseDetector(source, detector.item) then
            EventLog("[detecting.lua]: RegisterUsableItem: CanUseDetector returned false", "error")
            return
        end
        if not detectingPlayers[identifier] then
            detectingPlayers[identifier] = {}
        end
        detectingPlayers[identifier].started = detector.item
        TriggerClientEvent("lation_detecting:UseDetector", source, level)
    end)
end

RegisterUsableItem(Config.Shovel.item, function(source)
    if not source then
        EventLog("[detecting.lua]: RegisterUsableItem: source missing or nil", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[detecting.lua]: RegisterUsableItem: unable to retrieve player identifier", "error")
        return
    end
    local playerData = detectingPlayers[identifier]
    if not playerData then
        EventLog("[detecting.lua]: RegisterUsableItem: player not found in detecting table", "error")
        return
    end
    TriggerClientEvent("lation_detecting:UseShovel", source)
end)

AddEventHandler("playerDropped", function()
    local source = source
    if not source then
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        return
    end
    if detectingPlayers[identifier] then
        detectingPlayers[identifier] = nil
    end
end)
