Core = nil
playerJobData = {}
coopData = {}
cooldowns = {}
avatarCache = {}

CreateThread(function()
    Core = GetCore()
end)

-- Initialize Database and Load Player Data
CreateThread(function()
    local results = ExecuteSql("SELECT * FROM `codem_garbage`")
    if results then
        for _, data in ipairs(results) do
            local playerInfo = {
                profiledata = json.decode(data.profiledata),
                historydata = json.decode(data.historydata),
                dailymission = json.decode(data.dailymission)
            }
            playerJobData[data.identifier] = playerInfo
        end
    end
end)

RegisterServerEvent("codem-garbage:loadData")
AddEventHandler("codem-garbage:loadData", function()
    LoadGarbageData(source)
end)

-- Function to Load or Create Player Data
function LoadGarbageData(src)
    local identifier = GetIdentifier(src)
    if not playerJobData[identifier] then
        InitializeNewPlayer(src, function()
            -- Callback after initialization if needed
        end)
    end
    
    local data = playerJobData[identifier]
    if data then
        local avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture
        data.profiledata.avatar = avatar
        data.profiledata.name = GetName(src)
        data.profiledata.identifier = identifier
        
        Wait(100)
        TriggerClientEvent("codem-garbage:client:loadnuidata", src, data, coopData)
        SavePlayerData(src)
    end
end

-- Daily Mission Utility
function CheckAndResetTimestamp(timestamp)
    local daySeconds = 86400
    local now = os.time()
    local nextReset = timestamp + daySeconds
    local remaining = (nextReset - now) / 3600
    local shouldReset = now > nextReset
    return shouldReset, remaining
end

function CheckDailyMission(src)
    local identifier = GetIdentifier(src)
    local data = playerJobData[identifier]
    if not data then return nil end
    
    local mission = data.dailymission
    local shouldReset, remaining = CheckAndResetTimestamp(mission.timestamp)
    
    if shouldReset then
        Wait(500)
        mission.timestamp = os.time()
        mission.remainingtime = 24
        
        mission.earninoneroute.count = 0
        mission.earninoneroute.complete = false
        
        mission.completeoneroute.count = 0
        mission.completeoneroute.complete = false
        
        mission.transportpassenger.count = 0
        mission.transportpassenger.complete = false
        
        SavePlayerData(src)
    else
        mission.remainingtime = remaining
    end
    return mission
end

-- Callbacks
CreateThread(function()
    while Core == nil do Wait(0) end
    
    RegisterCallback("codem-garbage:getPlayerData", function(src, cb)
        local identifier = GetIdentifier(src)
        if not playerJobData[identifier] then
            InitializeNewPlayer(src, function()
                local payload = {
                    name = GetName(src),
                    allData = playerJobData[identifier],
                    coopData = coopData
                }
                local updatedMission = CheckDailyMission(src)
                if updatedMission then payload.allData.dailymission = updatedMission end
                CalculateLeaderboard(src)
                cb(payload)
            end)
        else
            local updatedMission = CheckDailyMission(src)
            if updatedMission then playerJobData[identifier].dailymission = updatedMission end
            
            local payload = {
                name = GetName(src),
                allData = playerJobData[identifier],
                coopData = coopData
            }
            CalculateLeaderboard(src)
            cb(payload)
        end
    end)
end)

-- Lobby and Player Management
RegisterServerEvent("codem-garbage:kickPlayer")
AddEventHandler("codem-garbage:kickPlayer", function(targetData)
    local src = source
    local targetIdentifier = targetData.identifier
    -- Host info
    local hostIdentifier = nil
    for _, room in pairs(coopData) do
        for _, player in pairs(room.players) do
            if tonumber(player.src) == tonumber(targetData.src) then
                hostIdentifier = room.roomData.hostIdentifier
                break
            end
        end
    end
    
    if not hostIdentifier then return end
    
    local room = coopData[hostIdentifier]
    local players = room.players
    
    for i, player in pairs(players) do
        if tonumber(player.src) == tonumber(targetData.src) then
            if player.host then
                -- Host is leaving/kicking themselves, delete room
                for _, p in pairs(players) do
                    if p.src then
                        TriggerClientEvent("codem-garbage:deleteRoom", tonumber(p.src), hostIdentifier)
                    end
                end
                coopData[hostIdentifier] = nil
                Wait(150)
                TriggerClientEvent("codem-garbage:deleteroomeveryone", -1, hostIdentifier)
            else
                -- Remove single player
                table.remove(players, i)
                room.players = players
                for _, p in pairs(players) do
                    if tonumber(p.src) ~= tonumber(targetData.src) then
                        TriggerClientEvent("codem-garbage:updateClientRoomPlayersData", tonumber(p.src), hostIdentifier, players)
                    end
                end
                TriggerClientEvent("codem-garbage:deleteMyTeam", targetData.src)
            end
            break
        end
    end
end)

-- Joining Lobby
RegisterServerEvent("codem-gabage:joinLobbyPassword")
AddEventHandler("codem-gabage:joinLobbyPassword", function(data)
    local src = source
    if IsOnCooldown(src) then return end
    
    local identifier = GetIdentifier(src)
    if not playerJobData[identifier] then return end
    
    local hostIdentifier = data.roomdata.hostIdentifier
    local room = coopData[hostIdentifier]
    
    if not room then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.undefinedroom)
        return
    end
    
    for _, player in pairs(room.players) do
        if tonumber(player.src) == tonumber(src) then
            TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.ingame)
            return
        end
    end
    
    if data.password == room.roomData.password then
        local newPlayer = {
            name = GetName(src),
            avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
            src = src,
            identifier = identifier,
            host = false,
            level = playerJobData[identifier].profiledata.level
        }
        table.insert(room.players, newPlayer)
        TriggerClientEvent("codem-garbage:updateClientRoomPlayersData", -1, hostIdentifier, room.players)
    else
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.wrongpassword)
    end
    SetCooldown(src)
end)

-- Badge System
RegisterServerEvent("codem-garbage:takeBadge")
AddEventHandler("codem-garbage:takeBadge", function(data)
    local src = source
    if IsOnCooldown(src) then return end
    
    local identifier = GetIdentifier(src)
    local player = playerJobData[identifier]
    if not player then return end
    
    if player.profiledata.badge == data.name then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.alreadybadge)
        return
    end
    
    if tonumber(player.profiledata.level) < tonumber(data.level) then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.levelbadge)
        return
    end
    
    player.profiledata.badge = data.name
    TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.badgeget)
    SavePlayerData(src)
    SetCooldown(src)
end)

-- Synchronization
RegisterServerEvent("codem-garbage:updateLobbys")
AddEventHandler("codem-garbage:updateLobbys", function(data)
    TriggerClientEvent("codem-garbage:updateLobbys", -1, data)
end)

RegisterServerEvent("codem-gabage:updateArea")
AddEventHandler("codem-gabage:updateArea", function(area)
    local src = source
    local identifier = GetIdentifier(src)
    local room = coopData[identifier]
    if not room then return end
    
    for _, player in pairs(room.players) do
        if player.src and player.src ~= src then
            TriggerClientEvent("codem-garbage:client:UpdateArea", tonumber(player.src), area)
        end
    end
end)

RegisterServerEvent("codem-gabage:joinLobby")
AddEventHandler("codem-gabage:joinLobby", function(data)
    local src = source
    if IsOnCooldown(src) then return end
    
    local identifier = GetIdentifier(src)
    if not playerJobData[identifier] then return end
    
    local hostIdentifier = data.roomData.hostIdentifier
    local room = coopData[hostIdentifier]
    
    if not room then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.undefinedroom)
        return
    end
    
    if #room.players >= 4 then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.lobbyfull)
        return
    end
    
    if room.roomData.startMission then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.cantjointhis)
        return
    end
    
    for _, player in pairs(room.players) do
        if tonumber(player.src) == tonumber(src) then
            TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.ingame)
            return
        end
    end
    
    local newPlayer = {
        name = GetName(src),
        avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
        src = src,
        identifier = identifier,
        host = false,
        level = playerJobData[identifier].profiledata.level
    }
    table.insert(room.players, newPlayer)
    TriggerClientEvent("codem-garbage:updateClientRoomPlayersData", -1, hostIdentifier, room.players)
    SetCooldown(src)
end)

-- Mission Start (Multiplayer)
RegisterServerEvent("codem-garbage:startJobMultiplayer")
AddEventHandler("codem-garbage:startJobMultiplayer", function(data)
    local src = source
    if IsOnCooldown(src) then return end
    
    local identifier = GetIdentifier(src)
    local room = coopData[identifier]
    if not room then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.undefinedroom)
        return
    end
    
    if #room.players > 4 then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.lobbyfull)
        return
    end
    if #room.players <= 1 then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.minplayer)
        return
    end
    
    local route = Config.GarbagejobSettings.garbageStop[data.routename]
    if route then
        room.roomData.startMission = true
        local vehicleHash = GetHashKey(Config.GarbagejobSettings.trashvehicle)
        local spawn = Config.GarbagejobSettings.garbageTruckSpawnCoords[1]
        
        local vehicle = CreateVehicle(vehicleHash, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
        while not DoesEntityExist(vehicle) do Wait(0) end
        
        TriggerClientEvent("codem-garbage:setDriverData", src)
        SetCooldown(src)
        Wait(1000)
        
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        for _, player in pairs(room.players) do
            if player.src then
                TriggerClientEvent("codem-garbage:startMultiplayerJob", tonumber(player.src), route, netId, data.routename)
            end
        end
    else
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.notroute)
    end
end)

-- Lobby Creation
RegisterServerEvent("codem-garbage:onlineJobsInsertData")
AddEventHandler("codem-garbage:onlineJobsInsertData", function(data)
    local src = source
    local identifier = GetIdentifier(src)
    if not playerJobData[identifier] then return end
    
    if not coopData[identifier] then
        coopData[identifier] = {
            roomData = {
                roomName = data[1].name,
                password = data[1].password,
                areaName = data[1].areaName,
                hostIdentifier = identifier,
                startMission = false
            },
            players = {
                {
                    name = GetName(src),
                    avatar = data[1].avatar,
                    src = src,
                    identifier = identifier,
                    host = true,
                    level = data[1].level
                }
            }
        }
        TriggerClientEvent("codem-garbage:insertOnlineData", -1, data, src, identifier, GetName(src))
    else
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.lobbyopened)
    end
end)

-- Leaderboard Calculation
function CalculateLeaderboard(src)
    local xpGroups = {}
    
    for _, player in pairs(playerJobData) do
        local profile = player.profiledata
        if profile.level then
            if not xpGroups[profile.level] then xpGroups[profile.level] = {} end
            table.insert(xpGroups[profile.level], {
                name = profile.name,
                avatar = profile.avatar,
                xp = profile.xp,
                level = profile.level,
                badge = profile.badge
            })
        end
    end
    
    local levels = {}
    for level in pairs(xpGroups) do table.insert(levels, level) end
    table.sort(levels, function(a, b) return a > b end)
    
    local sortedList = {}
    for _, level in ipairs(levels) do
        local group = xpGroups[level]
        table.sort(group, function(a, b) return a.xp > b.xp end)
        for _, entry in ipairs(group) do
            table.insert(sortedList, entry)
        end
    end
    
    local top50 = {}
    for i = 1, math.min(50, #sortedList) do
        top50[i] = sortedList[i]
    end
    
    TriggerClientEvent("codem-garbage:top50", src, top50)
end

-- New Player Initialization
function InitializeNewPlayer(src, callback)
    local identifier = GetIdentifier(src)
    if playerJobData[identifier] then return end
    
    local profile = {
        identifier = identifier,
        xp = 0,
        level = 1,
        avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
        name = GetName(src),
        completejobs = 0,
        totalearnings = 0,
        gathered = 0,
        sincedate = os.date("%d.%m.%Y"),
        badge = false
    }
    
    local daily = {
        timestamp = os.time(),
        remainingtime = 24,
        transportpassenger = { complete = false, count = 0 },
        completeoneroute = { complete = false, count = 0 },
        earninoneroute = { complete = false, count = 0 }
    }
    
    local data = {
        identifier = identifier,
        profiledata = profile,
        historydata = {},
        dailymission = daily
    }
    
    Wait(100)
    playerJobData[identifier] = data
    ExecuteSql("INSERT INTO codem_garbage (identifier, profiledata, historydata, dailymission) VALUES (:identifier, :profiledata, :historydata, :dailymission)", {
        identifier = identifier,
        profiledata = json.encode(data.profiledata),
        historydata = json.encode(data.historydata),
        dailymission = json.encode(data.dailymission)
    })
    
    playerJobData[identifier].dailymission.timestamp = os.time()
    callback()
end

-- Persistence
function SavePlayerData(src)
    local identifier = GetIdentifier(src)
    local data = playerJobData[identifier]
    if not data then return end
    
    ExecuteSql("UPDATE codem_garbage SET profiledata = :profiledata, historydata = :historydata, dailymission = :dailymission WHERE identifier = :identifier", {
        identifier = identifier,
        profiledata = json.encode(data.profiledata),
        historydata = json.encode(data.historydata),
        dailymission = json.encode(data.dailymission)
    })
end

-- XP and Leveling
function AddXPGarbabgeJob(src, amount)
    if not amount or amount <= 0 then return end
    local identifier = GetIdentifier(src)
    local data = playerJobData[identifier]
    if not data then return end
    
    local profile = data.profiledata
    profile.xp = tonumber(profile.xp) + tonumber(amount)
    
    local maxLevel = #Config.RequiredXP
    if profile.level > maxLevel then
        Config.Notification(Config.NotificationText.maxlevel.text, Config.NotificationText.maxlevel.type, true, src)
        return
    end
    
    if tonumber(profile.xp) >= tonumber(Config.RequiredXP[profile.level]) then
        profile.level = tonumber(profile.level) + 1
        profile.xp = 0
    end
    
    Config.Notification(string.format(Config.NotificationText.newxp.text, amount), Config.NotificationText.newxp.type, true, src)
end

function SetXPBusJob(src, amount)
    if not amount or amount <= 0 then return end
    local identifier = GetIdentifier(src)
    local data = playerJobData[identifier]
    if not data then return end
    
    local profile = data.profiledata
    profile.xp = tonumber(amount)
    
    if tonumber(profile.xp) >= tonumber(Config.RequiredXP[profile.level]) then
        profile.level = tonumber(profile.level) + 1
        profile.xp = 0
    end
end

function AddLevelGarbageJob(src, level)
    local identifier = GetIdentifier(src)
    local data = playerJobData[identifier]
    if not data then return end
    
    local profile = data.profiledata
    if profile.level > #Config.RequiredXP then
        Config.Notification(Config.NotificationText.maxlevel.text, Config.NotificationText.maxlevel.type, true, src)
        return
    end
    
    profile.level = level
    if not Config.RequiredXP[profile.level] then
        profile.level = #Config.RequiredXP
        profile.xp = Config.RequiredXP[profile.level]
    else
        profile.xp = 0
    end
end

function RemoveLevelGarbageJob(src, amount)
    local identifier = GetIdentifier(src)
    local data = playerJobData[identifier]
    if not data then return end
    
    local profile = data.profiledata
    local levelToSet = tonumber(profile.level) - (amount <= 0 and 1 or amount)
    profile.level = math.max(1, levelToSet)
    profile.xp = 0
end

-- Discord API Utils
function DiscordRequest(method, endpoint, data)
    local result = nil
    local auth = "Bot " .. bot_Token
    PerformHttpRequest("https://discordapp.com/api/" .. endpoint, function(code, res, headers)
        result = { data = res, code = code, headers = headers }
    end, method, #data > 0 and json.encode(data) or "", { ["Content-Type"] = "application/json", ["Authorization"] = auth })
    
    while result == nil do Wait(0) end
    return result
end

function GetDiscordAvatar(src)
    local discordId = nil
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if string.match(identifier, "discord:") then
            discordId = string.gsub(identifier, "discord:", "")
            break
        end
    end

    if discordId then
        if avatarCache[discordId] then return avatarCache[discordId] end
        
        local res = DiscordRequest("GET", "users/" .. discordId, {})
        if res.code == 200 then
            local data = json.decode(res.data)
            if data and data.avatar then
                local isGif = data.avatar:sub(1, 1) == "a" or data.avatar:sub(2, 2) == "_"
                local ext = isGif and ".gif" or ".png"
                local url = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. data.avatar .. ext
                avatarCache[discordId] = url
                return url
            end
        end
    end
    return nil
end

-- Cooldown Utils
function IsOnCooldown(src)
    if cooldowns[src] and (os.time() - cooldowns[src] < 5) then
        TriggerClientEvent("codem-garbage:notificaton", src, Config.Locales.waitcooldown)
        return true
    end
    return false
end

function SetCooldown(src)
    cooldowns[src] = os.time()
end
