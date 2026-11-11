local playerCache = {}

local sqlFile = LoadResourceFile(GetCurrentResourceName(), "install/lation_detecting.sql")
if sqlFile then
    MySQL.query(sqlFile)
else
    CreateThread(function()
        while true do
            print("^1[ERROR]: install folder or .sql files missing, you will experience issues^0")
            Wait(10000)
        end
    end)
end

function InsertPlayer(source)
    if not source then
        EventLog("[experience.lua]: InsertPlayer: source missing or nil", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[experience.lua]: InsertPlayer: unable to retrieve player identifier", "error")
        return
    end
    local query = [[
        INSERT INTO `lation_detecting`
        (identifier, level, experience, items_found, money_earned)
        VALUES (?, ?, ?, ?, ?)
    ]]
    MySQL.insert(query, {
        identifier,
        1,
        0,
        0,
        0
    })
    playerCache[identifier] = {
        level = 1,
        experience = 0,
        items_found = 0,
        money_earned = 0
    }
    EventLog("[experience.lua]: InsertPlayer: successfully inserted new player & returning data")
    return playerCache[identifier]
end

function GetPlayerData(source, field)
    if not source then
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[experience.lua]: GetPlayerData: unable to obtain player identifier", "error")
        return
    end
    local playerData = playerCache[identifier]
    if not playerData then
        local result = MySQL.query.await("SELECT * FROM `lation_detecting` WHERE `identifier` = ?", {identifier})
        if result and #result > 0 then
            playerData = result[1]
            playerCache[identifier] = playerData
        else
            playerData = InsertPlayer(source)
            if not playerData then
                EventLog("[experience.lua]: GetPlayerData: tried to insert player, but has still failed", "error")
                return
            end
        end
    end
    if field then
        EventLog("[experience.lua]: GetPlayerData: successfully retrieved, returning data[" .. field .. "]")
        return playerData[field]
    end
    EventLog("[experience.lua]: GetPlayerData: successfully retrieved, returning complete data")
    return playerData
end

function GetLevelData()
    return Config.Detecting.levels
end

function AddPlayerData(source, field, amount)
    if source and field and amount then
        if type(amount) == "number" and type(field) == "string" then
            goto valid
        end
    end
    EventLog("[experience.lua]: AddPlayerData: invalid or missing parameters", "error")
    do return end
    ::valid::
    local identifier = GetIdentifier(source)
    local playerData = identifier and GetPlayerData(source)
    if not (identifier and playerData) or amount <= 0 then
        EventLog("[experience.lua]: AddPlayerData: unable to retrieve player data or invalid amount", "error")
        return
    end
    if field == "experience" then
        local newExperience = playerData.experience + amount
        local maxLevelXP = Config.Detecting.levels[#Config.Detecting.levels]
        if newExperience >= maxLevelXP then
            newExperience = maxLevelXP
        end
        local newLevel = 1
        for levelIndex, levelXP in ipairs(Config.Detecting.levels) do
            if levelXP <= newExperience then
                newLevel = levelIndex
            else
                break
            end
        end
        if newLevel > playerData.level then
            TriggerClientEvent("lation_detecting:Notify", source, Strings.Notify.levelUp, "success")
            if Logs.Events.level_up then
                local playerName = GetName(source)
                local logMessage = string.format(Strings.Logs.level_up.message, tostring(playerName), tostring(identifier), tostring(newLevel))
                PlayerLog(source, Strings.Logs.level_up.title, logMessage)
            end
        end
        playerCache[identifier].level = newLevel
        playerCache[identifier].experience = newExperience
        EventLog("[experience.lua]: AddPlayerData: updated level and exp for player: new level: " .. newLevel .. ", total exp: " .. newExperience)
    else
        if not playerCache[identifier][field] then
            playerCache[identifier][field] = 0
        end
        playerCache[identifier][field] = playerCache[identifier][field] + amount
        EventLog("[experience.lua]: AddPlayerData: updated " .. field .. " for player by +" .. amount)
    end
end

lib.callback.register("lation_detecting:GetPlayerData", function(source, field)
    return GetPlayerData(source, field)
end)

AddEventHandler("txAdmin:events:serverShuttingDown", function()
    local query = " UPDATE `lation_detecting` SET level = ?, experience = ?, items_found = ?, money_earned = ? WHERE `identifier` = ? "
    for identifier, data in pairs(playerCache) do
        MySQL.query.await(query, {
            data.level,
            data.experience,
            data.items_found,
            data.money_earned,
            identifier
        })
        if playerCache[identifier] then
            playerCache[identifier] = nil
        end
    end
end)

AddEventHandler("onResourceStop", function()
    local query = " UPDATE `lation_detecting` SET level = ?, experience = ?, items_found = ?, money_earned = ? WHERE `identifier` = ? "
    for identifier, data in pairs(playerCache) do
        MySQL.query.await(query, {
            data.level,
            data.experience,
            data.items_found,
            data.money_earned,
            identifier
        })
        if playerCache[identifier] then
            playerCache[identifier] = nil
        end
    end
end)

AddEventHandler("playerDropped", function()
    local source = source
    if not source then
        EventLog("[experience.lua]: playerDropped: unable to retrieve source", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[experience.lua]: playerDropped: unable to retrieve player identifier", "error")
        return
    end
    local playerData = playerCache[identifier]
    if not playerData then
        EventLog("[experience.lua]: playerDropped: player not found in cache, no need to update")
        return
    end
    local query = " UPDATE `lation_detecting` SET level = ?, experience = ?, items_found = ?, money_earned = ? WHERE `identifier` = ? "
    MySQL.query.await(query, {
        playerData.level,
        playerData.experience,
        playerData.items_found,
        playerData.money_earned,
        identifier
    })
    if playerCache[identifier] then
        playerCache[identifier] = nil
    end
end)

exports("GetPlayerData", GetPlayerData)
exports("AddPlayerData", AddPlayerData)
exports("GetLevelData", GetLevelData)
