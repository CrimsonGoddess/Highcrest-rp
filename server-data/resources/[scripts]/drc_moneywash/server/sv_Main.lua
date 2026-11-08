lib.locale()

local DataForHouse = {}
local HouseRobberiesData = {}
local PedDead = {}
local onTimerRob = {}
local HouseHacked = {}
local PedSpawned = {}
local HousePowdered = {}
local PropRobbedCreated = {}
local Lasers = {}
local LaseredHouse = {}
local SafeRobbed = {}
local PropRobbedStatic = {}


CreateThread( function()
    local currentTime = os.time()
    for i, house in each(HouseRobberiesData) do
        local lockHouse, alarm, lights, changeHouse, resetTime, robbed = false, true, false, false, house.lastreset, house.robbed
        local difference = (house.lastreset + Config.ResetTime * 60) - currentTime
        if difference < 0 then
            lockHouse, alarm, lights, changeHouse, resetTime, robbed = true, true, currentTime, {}
        end
        DataForHouse[house.house] = {
            locked = lockHouse,
            alarm = alarm,
            lights = lights,
            robbed = {},
            players = json.decode(house.players),
            lastreset = resetTime,
            changed = changeHouse
        }
    end
    syncDataForHouse()
end)

RegisterNetEvent("drc_moneywash:sync")
AddEventHandler("drc_moneywash:sync", function()
    local src = source
    TriggerClientEvent("drc_moneywash:sync", src, DataForHouse, true)
    local char = GetIdent(src)
    local query = MySQL.Sync.fetchAll("SELECT name FROM owned_warehouse WHERE owner = @owner", {
        ['@owner'] = char
    })

    if #query > 0 then
        local ownedHouses = {}
        for _, result in ipairs(query) do
            local house = result.name
            table.insert(ownedHouses, house)
        end
        TriggerClientEvent('drc_moneywash:createblip', src, ownedHouses)
        TriggerClientEvent('drc_moneywash:setowner', src, ownedHouses)
    end


    local allHousesQuery = MySQL.Sync.fetchAll("SELECT name, access FROM owned_warehouse")

    local AccessHouses = {}
    for _, houseData in ipairs(allHousesQuery) do
        local house = houseData.name
        local accessData = houseData.access

        if accessData then
            local accessList = json.decode(accessData)
            -- Check if the character is in the access list
            for _, accessEntry in pairs(accessList) do
                if accessEntry.player and accessEntry.player == char then
                    table.insert(AccessHouses, house)
                    break
                end
            end
        end
    end

    if #AccessHouses > 0 then
        TriggerClientEvent('drc_moneywash:createblip', src, AccessHouses)
        TriggerClientEvent('drc_moneywash:setaccess', src, AccessHouses)
    end

end)

RegisterNetEvent("drc_moneywash:lockpick")
AddEventHandler("drc_moneywash:lockpick", function(data)
    local src = source
    local neededPoliceCount = Config.Warehouses[data].MoneyWash.NeedPoliceCount
    if CheckJob() < neededPoliceCount then
        TriggerClientEvent('drc_moneywash:notify', src, 'error', locale('moneywash'), locale('RequiredCops'))
        return
    end
    if GetItem(Config.Lockpick.item, 1, src) then
        if Config.Lockpick.remove then
            RemoveItem(Config.Lockpick.item, 1, src)
        end
        TriggerClientEvent("drc_moneywash:lockpick", src, data)
    else
        TriggerClientEvent('drc_moneywash:notify', src, 'error', locale('moneywash'), locale('RequiredItems'))
    end
end)

RegisterNetEvent("drc_moneywash:unlockHouse")
AddEventHandler( "drc_moneywash:unlockHouse", function(house)
    local src = source

    if DataForHouse[house] then
        DataForHouse[house].locked = false
    else
        DataForHouse[house] = {
            locked = false,
            alarm = true,
            lights = false,
            robbed = {},
            players = {},
            lastreset = os.time(),
            changed = true
        }
    end
    TriggerClientEvent("drc_moneywash:sync", -1, DataForHouse, false)
end)

RegisterNetEvent("drc_moneywash:lockHouse")
AddEventHandler( "drc_moneywash:lockHouse", function(house)
    local src = source

    if DataForHouse[house] then
        DataForHouse[house].locked = true
    else
        DataForHouse[house] = {
            locked = true,
            alarm = true,
            lights = false,
            robbed = {},
            players = {},
            lastreset = os.time(),
            changed = true
        }
    end
    TriggerClientEvent("drc_moneywash:sync", -1, DataForHouse, false)
end)

RegisterNetEvent("drc_moneywash:lights")
AddEventHandler( "drc_moneywash:lights", function(house, value)
    local src = source

    if DataForHouse[house] then
        DataForHouse[house].lights = value
    else
        DataForHouse[house] = {
            locked = true,
            alarm = true,
            lights = false,
            robbed = {},
            players = {},
            lastreset = os.time(),
            changed = true
        }
    end
    TriggerClientEvent("drc_moneywash:sync", -1, DataForHouse, false)
end)


RegisterNetEvent("drc_moneywash:alarm")
AddEventHandler( "drc_moneywash:alarm", function(house, value)
    local src = source

    if DataForHouse[house] then
        DataForHouse[house].alarm = value
    else
        DataForHouse[house] = {
            locked = true,
            alarm = true,
            lights = false,
            robbed = {},
            players = {},
            lastreset = os.time(),
            changed = true
        }
    end
    TriggerClientEvent("drc_moneywash:sync", -1, DataForHouse, false)
end)

RegisterNetEvent("drc_moneywash:joinHouse")
AddEventHandler("drc_moneywash:joinHouse", function(house)
    local src = source

    local alreadyIn = false

    if DataForHouse[house] then
        local char = GetIdent(src)
        for i, player in each(DataForHouse[house].players) do
            if player == char then
                alreadyIn = true
                break
            end
        end
    else
        DataForHouse[house] = {
            locked = false,
            alarm = true,
            lights = false,
            robbed = {},
            players = {},
            lastreset = os.time(),
            changed = true
        }
    end

    if not alreadyIn then
        table.insert(DataForHouse[house].players, GetIdent(src))
    end
end)

function AlarmEnabled(house)
    if DataForHouse[house] then
        return DataForHouse[house].alarm
    else
        return true
    end
end

RegisterNetEvent("drc_moneywash:CheckHackedHouse")
AddEventHandler("drc_moneywash:CheckHackedHouse", function(house)
    --table.insert(HouseHacked, {house = house})
    for k, v in pairs(HouseHacked) do
        if v.house == house then 
            TriggerClientEvent('drc_moneywash:HackedSync', -1, v.house)
        end
    end
end)

RegisterNetEvent("drc_moneywash:AddHackedHouse")
AddEventHandler("drc_moneywash:AddHackedHouse", function(house)
    table.insert(HouseHacked, {house = house})
    TriggerClientEvent('drc_moneywash:HackedSync', -1, house)
end)

RegisterNetEvent("drc_moneywash:leaveHouse")
AddEventHandler( "drc_moneywash:leaveHouse", function(house)
    local src = source
    for i, player in each(DataForHouse[house].players) do
        if player == GetIdent(src) then
            table.remove(DataForHouse[house].players, i)
            DataForHouse[house].changed = true
            break
        end
    end
end)

function syncDataForHouse()
    local currentTime = os.time()
    for house, data in pairs(DataForHouse) do
        if data.changed then
            data.changed = false
            local lockHouse = data.locked
            local difference = currentTime - (data.lastreset + Config.ResetTime * 60)
            if difference > 0 then
                lockHouse = true
            end

            if not Config.ResetHousesAfterTime then
                lockHouse = false
            end
            if lockHouse then
                data.locked = true
                data.alarm = true
                data.lights = false
                data.robbed = {}
                data.lastreset = os.time()

                HouseHacked[house] = nil
                PedSpawned[house] = nil
                HousePowdered[house] = nil
                PropRobbedCreated[house] = nil
                Lasers[house] = nil
                LaseredHouse[house] = nil
                SafeRobbed[house] = nil
                PropRobbedStatic[house] = nil
                TriggerClientEvent("drc_moneywash:reset", -1, house)
            end
            table.insert(HouseRobberiesData, {house = house, robbed = json.encode(data.robbed), 
            players = json.encode(data.players), locked = lockHouse, alarm = data.alarm, lights = data.lights, lastreset = data.lastreset})
        end
    end
    TriggerClientEvent("drc_moneywash:sync", -1, DataForHouse)
    SetTimeout(Config.ResetTime * 60, syncDataForHouse)
end


RegisterNetEvent("drc_moneywash:lasercheck")
AddEventHandler("drc_moneywash:lasercheck", function(laser, house)
    local AlreadyFound = false
    for k, v in pairs(Lasers) do
        if v.house == house then
            AlreadyFound = true
        end
    end
    if not AlreadyFound then
        SetTimeout(1000, function()
            table.insert(Lasers, {house = house, lasers = laser})
        end)
    end
    Wait(2000)
    for k, v in pairs(Lasers) do
        TriggerClientEvent('drc_moneywash:lasercheck', -1, v.lasers, house) 
    end
end)

RegisterNetEvent("drc_moneywash:CheckLaser")
AddEventHandler("drc_moneywash:CheckLaser", function(house)
    for k, v in pairs(LaseredHouse) do
        if v.house == house then 
            TriggerClientEvent('drc_moneywash:LaserSync', -1, v.house)
        end
    end
end)

RegisterNetEvent("drc_moneywash:AddLaser")
AddEventHandler("drc_moneywash:AddLaser", function(house)
    table.insert(LaseredHouse, {house = house})
    TriggerClientEvent('drc_moneywash:LaserSync', -1, house)
end)

RegisterNetEvent("drc_moneywash:robbedpropcreated")
AddEventHandler("drc_moneywash:robbedpropcreated", function(model, house, place, netId, TrunkNeeded)
    local src = source
    local Residence = Config.Warehouses[house].MoneyWash
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    local dist = #(srcCoords - vec3(Config.Warehouses[house].MoneyWash.InsidePositions.Exit.coords.x, Config.Warehouses[house].MoneyWash.InsidePositions.Exit.coords.y, Config.Warehouses[house].MoneyWash.InsidePositions.Exit.coords.z))
    if not TrunkNeeded and dist > 45 then
        if Config.DropPlayer then
            Logs(src, locale('ban/kick_reason_startrobbery_far'))
            DropPlayer(source, locale('ban/kick_reason_startrobbery_far'))
            return
        end
        BanPlayer(source, locale('ban/kick_reason_startrobbery_far'))
        return
    else
        if onTimerRob[src] and onTimerRob[src] > GetGameTimer() then
            if Config.DropPlayer then
                Logs(src, locale('ban/kick_reason_startrobbery_time'))
                DropPlayer(source, locale('ban/kick_reason_startrobbery_time'))
                return
            end
            BanPlayer(source, locale('ban/kick_reason_startrobbery_time'))
            return
        end
        onTimerRob[src] = GetGameTimer() + (1.5 * 1000)
        local AlreadyRobbed = false
        for k, v in pairs(PropRobbedCreated) do
            if PropRobbedCreated[house] == nil then
                if v.house == house then 
                    if place == v.prop then
                        AlreadyRobbed = true
                    end
                end
            end
        end
        if not AlreadyRobbed then
            if model == Residence.CreateProps[place].model then
                table.insert(PropRobbedCreated, {house = house, prop = place})
                local count = Residence.CreateProps[place].Count or 1
                Logs(src, 'Found **'..MoneyWash.CreateProps[place].Item..'** **'..count..'x**')
                AddItem(Residence.CreateProps[place].Item, Residence.CreateProps[place].Count or 1, src)
                TriggerClientEvent('drc_moneywash:notify', src, 'success', locale('moneywash'), locale('FindItem', Residence.CreateProps[place].Item, count))
                table.insert(DataForHouse[house].robbed, place)
                DataForHouse[house].changed = true
                TriggerClientEvent("drc_moneywash:sync", -1, DataForHouse, false)
            end
        end
    end
end)

lib.callback.register('drc_moneywash:getitem', function(source, item)
    local src = source
    if GetItem(item, 1, src) then
        return true
    else
        return false
    end
end)

local function DoesPlaceExist(wash_process, place)
    local wash_process_table = wash_process and json.decode(wash_process) or {}
    local place_data = wash_process_table[place]
    return place_data ~= nil and place_data.endtime ~= nil and place_data.money ~= nil
end

local WashOccupied = {}

lib.callback.register('drc_moneywash:checkwash', function(source, house, place, type, amount)
    local src = source
    local wash_process
    local dryer_data = nil
    fetchResult = MySQL.Sync.fetchAll('SELECT wash_process FROM owned_warehouse WHERE name = @name', {
        ['@name'] = house
    })
    if fetchResult[1] then
        wash_process = fetchResult[1].wash_process
    else
        return 
    end
    if not DoesPlaceExist(wash_process, place) then
        if type == "check" or type == "collect" then
            TriggerClientEvent('drc_moneywash:notify', src, 'info', locale('info'), locale('notstarted'))
            return false
        end
    end
    if wash_process then 
        wash_process_table = json.decode(wash_process)
        dryer_data = wash_process_table[place]
    end
    if type == "start" then
        if not WashOccupied[place .. house] then
            if GetItemCount(Config.MoneyWash.WashItems.RequiredItems.item, src) >= amount then
                if (dryer_data == nil) or (dryer_data ~= nil and dryer_data.endtime == nil) then
                    WashOccupied[place .. house] = true
                    SetTimeout(Config.MoneyWash.WashItems.AnimationDuration, function()
                        WashOccupied[place .. house] = false 
                    end)
                    return true
                else
                    return "started"
                end
            else
                return false
            end
        else
            return "occupied"
        end
    end
    if type ~= "start" then
        result = fetchResult
        local wash_process = result[1].wash_process
        local wash_process_table = json.decode(wash_process)
        if result and #result > 0 and result[1].wash_process then
            
            local currentTime = os.time()
            local cooldownEndTime = wash_process_table[place].endtime

            if cooldownEndTime == nil then
                cooldownEndTime = 0
            end

            if type == "check" then
                if currentTime < cooldownEndTime then
                    local cooldownRemaining = cooldownEndTime - currentTime
                    TriggerClientEvent('drc_moneywash:notify', src, 'info', locale('info'), locale('timeleft', math.floor(cooldownRemaining / 60), cooldownRemaining % 60))
                else
                    TriggerClientEvent('drc_moneywash:notify', src, 'info', locale('info'), locale('alreadywashed'))
                end
            end

            if type == "collect" then
                if currentTime > cooldownEndTime then
                    washprocess = json.decode(result[1].wash_process)
                    local washItems = Config.MoneyWash.WashItems
                    local percentageLost = HighcrestWashRate(src)
                    local dirtyMoneyAmount =  washprocess[place].money
                    local cutAmount = math.max(math.floor(dirtyMoneyAmount * percentageLost / 100), 1)
                    if result[1] and result[1].wash_process then
                        wash_process = json.decode(result[1].wash_process)
                    else
                        wash_process = {}
                    end
                    wash_process[place] = {endtime = nil, money = nil}
                    local wash_process_json = json.encode(wash_process)

                    MySQL.Async.execute('UPDATE owned_warehouse SET wash_process = @wash_process WHERE name = @name', {
                        ['@wash_process'] = wash_process_json,
                        ['@name'] = house,
                    }, function(affectedRows)
                    end)
                    local players = GetPlayersInHouse(house)
                    TriggerClientEvent("drc_moneywash:syncDryerDeActivation", -1, place, players, src)
                    AddItem(washItems.AddItems.item, cutAmount, src)
                else
                    local cooldownRemaining = cooldownEndTime - currentTime
                    TriggerClientEvent('drc_moneywash:notify', src, 'info', locale('info'), locale('timeleft', math.floor(cooldownRemaining / 60), cooldownRemaining % 60))
                end
            end
        else
            TriggerClientEvent('drc_moneywash:notify', src, 'error', locale('error'), locale('notstartedwash'))
        end
    end
end)

lib.callback.register('drc_moneywash:checkwashrunning', function(source, house)
    local src = source
    local wash_process
    fetchResult = MySQL.Sync.fetchAll('SELECT wash_process FROM owned_warehouse WHERE name = @name', {
        ['@name'] = house
    })
    if fetchResult[1] then
        wash_process = fetchResult[1].wash_process
    else
        return 
    end
    result = fetchResult
    local wash_process_table = json.decode(wash_process)

    if result and #result > 0 and result[1].wash_process then
        local currentTime = os.time()
        local housesWithExpiredEndTime = {}
        local housesWithActiveWashing = {}
        local players = GetPlayersInHouse(house)

        for houseIndex, houseData in pairs(wash_process_table) do
            if houseData.endtime and houseData.endtime < currentTime then
                table.insert(housesWithExpiredEndTime, houseIndex)
                TriggerClientEvent("drc_moneywash:syncDryerActivation", -1, houseIndex, players, src)
            elseif houseData.endtime and houseData.endtime >= currentTime then
                table.insert(housesWithActiveWashing, houseIndex)
                TriggerClientEvent("drc_moneywash:syncDryerActivation", -1, houseIndex, players, src)
            end
        end
    end
end)

RegisterNetEvent("drc_moneywash:startmoneywash")
AddEventHandler("drc_moneywash:startmoneywash", function(place, house, amount)
    local src = source
    local currentTime = os.time()
    local upgraded = false

    local src = source

    local query = MySQL.Sync.fetchAll("SELECT * FROM owned_warehouse WHERE name = @name", {
        ['@name'] = house
    })

    if #query > 0 then
        upgraded = tonumber(query[1].washing) == 1
    end


    local cooldownDuration = Config.MoneyWash.WashItems.Cooldown * amount
    if upgraded then
        cooldownDuration = math.max(math.floor(cooldownDuration * Config.MoneyWash.WashItems.UpgradeReduction / 100), 1)
    end

    local washItems = Config.MoneyWash.WashItems
    local cooldownEndTime = currentTime + cooldownDuration 
    local count = GetItemCount(Config.MoneyWash.WashItems.RequiredItems.item, src)
    if count >= amount then
        RemoveItem(washItems.RequiredItems.item, amount, src)
        MySQL.Async.fetchAll('SELECT wash_process FROM owned_warehouse WHERE name = @name', {
            ['@name'] = house
        }, function(result)
            local wash_process

            if result[1] and result[1].wash_process then
                wash_process = json.decode(result[1].wash_process)
            else
                wash_process = {}
            end
            wash_process[place] = {endtime = cooldownEndTime, money = amount}
            local wash_process_json = json.encode(wash_process)
            MySQL.Async.execute('UPDATE owned_warehouse SET wash_process = @wash_process WHERE name = @name', {
                ['@wash_process'] = wash_process_json,
                ['@name'] = house,
            }, function(affectedRows)
                local players = GetPlayersInHouse(house)
                TriggerClientEvent("drc_moneywash:syncDryerActivation", -1, place, players, src)
                if WashOccupied[place .. house] then
                    WashOccupied[place .. house] = false
                end
            end)
        end)
    end
end)


local CutOccupied = {}

lib.callback.register('drc_moneywash:checkcut', function(source, house, amount)
    local src = source
    local cutItems = Config.MoneyWash.CutItems
    local house = house
    if not CutOccupied[house] then
        if CheckDirtyMoney(source, amount, false) then
            CutOccupied[house] = true
            SetTimeout(cutItems.AnimationDuration, function()
                CutOccupied[house] = false 
            end)
            return true
        else
            return false
        end
    else
        return "occupied"
    end
end)

RegisterNetEvent("drc_moneywash:cutmoney")
AddEventHandler("drc_moneywash:cutmoney", function(place, house, amount)
    local src = source
    if CheckDirtyMoney(src, amount, true) then
        if CutOccupied[house] then
            CutOccupied[house] = false
        end
    end
end)

local CountOccupied = {}

lib.callback.register('drc_moneywash:checkcount', function(source, house, amount)
    local src = source
    local cutItems = Config.MoneyWash.CountItems
    if not CountOccupied[house] then
        if GetItemCount(cutItems.RequiredItems.item, src) >= amount then
            CountOccupied[house] = true
            SetTimeout(cutItems.AnimationDuration, function()
                CountOccupied[house] = false 
            end)
            return true
        else
            return false
        end
    else
        return "occupied"
    end
end)

RegisterNetEvent("drc_moneywash:countmoney")
AddEventHandler("drc_moneywash:countmoney", function(place, house, amount)
    local src = source
    local countItems = Config.MoneyWash.CountItems

    if GetItemCount(countItems.RequiredItems.item, src) >= amount then

        local percentageLost = HighcrestWashRate(src)
        local cutAmount = math.max(math.floor(amount * percentageLost / 100), 1)

        RemoveItem(countItems.RequiredItems.item, amount, src)
        AddItem(countItems.AddItems.item, cutAmount, src)
        HighcrestAddWashXp(src, amount) -- Highcrest: washing XP for a finished wash
        if CountOccupied[house] then
            CountOccupied[house] = false
        end
    end
end)


RegisterServerEvent("drc_moneywash:knockOnDoors")
AddEventHandler("drc_moneywash:knockOnDoors", function(house)
    local players = GetPlayersInHouse(house)

    for _, player in ipairs(players) do
        print(player)
        TriggerClientEvent('drc_moneywash:notify', player, 'info', locale('info'), locale('someoneknocked'))
    end
end)

RegisterNetEvent("drc_moneywash:activateDryer")
AddEventHandler("drc_moneywash:activateDryer", function(place, house)
    local src = source
    local players = GetPlayersInHouse(house)
    TriggerClientEvent("drc_moneywash:syncDryerActivation", -1, place, players, src)
end)

function GetPlayersInHouse(house)
    local src = source
    local players = {}

    if DataForHouse[house] then
        for _, player in ipairs(DataForHouse[house].players) do
            source = GetSourceFromIdentifier(player)
            if source then
                table.insert(players, source)
            end
        end
    end
    return players
end

function GetSourceFromIdentifier(identifier)
    local players = GetPlayers()
    for _, player in ipairs(players) do
        local char = GetIdent(player)
        if char == identifier then
            return player
        end
    end
    return nil
end

local playersInCamera = {}

lib.callback.register('drc_moneywash:checkcamera', function(source, house)
    if Config.CCTV == "solo" then
       local players = GetPlayersInHouse(house)
       print( #players)
       print(json.encode(players))
        if #players == 1 then 
            return true
        else
            return false
        end
    elseif Config.CCTV == "multi" then
        local players = GetPlayersInHouse(house)
        for _, player in ipairs(players) do
            if IsPlayerInCamera(house) then
                return false
            end
        end
        if #players > 0 then
            table.insert(playersInCamera, {player = players[1], house = house})
            return true
        else
            return false
        end
    end
end)

function IsPlayerInCamera(house)
    for _, entry in ipairs(playersInCamera) do
        if entry.house == house then
            return true
        end
    end
    return false
end


lib.callback.register('drc_moneywash:checkownedhouses', function(source)
    local src = source
    local char = GetIdent(src)
    -- Retrieve the list of houses owned by the player
    local query = MySQL.Sync.fetchAll("SELECT * FROM owned_warehouse WHERE owner = @owner", {
        ['@owner'] = char
    })

    local ownedHouses = {}

    -- Iterate through the houses in the Config.Warehouses table
    for house, _ in pairs(Config.Warehouses) do
        -- Check if the house is already present in the owned_warehouse table
        for _, result in ipairs(query) do
            if result.name == house then
                -- House is owned by the player, add it to the ownedHouses table
                table.insert(ownedHouses, house)
                break
            end
        end
    end

    -- Check if the player owns any houses
    if #ownedHouses > 0 then
        return ownedHouses
    else
        return nil
    end
end)

-- DRYING

local LoadingOccupied = {}
local StartingOccupied = {}
local CollectingOccupied = {}

lib.callback.register('drc_moneywash:checkloaded', function(source, house, amount)
    local src = source
    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_warehouse WHERE name = @name', {
    ['@name'] = house
    })
    local drying_process_json = ""
    if (result[1] and result[1].drying_process and json.decode(result[1].drying_process).money) or (result[1] and result[1].drying_process and json.decode(result[1].drying_process).money == 0) then
        return false
    else

        local count = GetItemCount(Config.MoneyWash.DryItems.RequiredItems.item, src)
        if tonumber(count) == 0 or tonumber(count) < tonumber(amount) then
            return "nomoney"
        end

        if not LoadingOccupied[house] then
            LoadingOccupied[house] = true 
            SetTimeout(Config.MoneyWash.DryItems.AnimationDuration, function()
                LoadingOccupied[house] = false 
            end)
            return true
        else
            return "occupied"
        end
    end
end)

RegisterNetEvent("drc_moneywash:loadmoney")
AddEventHandler("drc_moneywash:loadmoney", function(house, amount)
    local src = source
    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_warehouse WHERE name = @name', {
    ['@name'] = house
    })
    local count = GetItemCount(Config.MoneyWash.DryItems.RequiredItems.item, src)
    if tonumber(count) > 0 and tonumber(count) >= tonumber(amount) then
        if (result[1] and result[1].drying_process and result[1].drying_process["money"]) or (result[1] and result[1].drying_process and result[1].drying_process["money"] == 0) then
        else
            RemoveItem(Config.MoneyWash.DryItems.RequiredItems.item, amount, src)
            drying_process = {}
            drying_process["money"] = amount
            drying_process_json = json.encode(drying_process)
            MySQL.Async.execute('UPDATE owned_warehouse SET drying_process = @drying_process WHERE name = @name', {
                ['@drying_process'] = drying_process_json,
                ['@name'] = house,
            }, function(affectedRows)
                if LoadingOccupied[house] then
                    LoadingOccupied[house] = false
                end
            end)
        end
    end
end)

lib.callback.register('drc_moneywash:checkstarted', function(source, house)
    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_warehouse WHERE name = @name', {
        ['@name'] = house
    })

    if (result[1] and result[1].drying_process) then
        local dryingProcess = json.decode(result[1].drying_process)
        if (dryingProcess and dryingProcess.money) then
            if (dryingProcess and dryingProcess.endtime) then
                return false
            else

                if not StartingOccupied[house] then
                    StartingOccupied[house] = true 
                    SetTimeout(Config.MoneyWash.DryItems.AnimationDuration, function()
                        StartingOccupied[house] = false 
                    end)
                    return true
                else
                    return "occupied"
                end
            end
        end
    end

    return false
end)

RegisterNetEvent("drc_moneywash:startdrying")
AddEventHandler("drc_moneywash:startdrying", function(house)
    local src = source
    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_warehouse WHERE name = @name', {
        ['@name'] = house
    })  
    if (result[1] and result[1].drying_process and (json.decode(result[1].drying_process).endtime)) == nil then
        if (result[1] and result[1].drying_process and (json.decode(result[1].drying_process).money)) then
            local duration = 5 -- 5 minutes (300 seconds)
            local currentTime = os.time()

            local upgraded = false

            local src = source
        
            local query = MySQL.Sync.fetchAll("SELECT * FROM owned_warehouse WHERE name = @name", {
                ['@name'] = house
            })
        
            if #query > 0 then
                upgraded = tonumber(query[1].printer) == 1
            end

            local cooldownDuration = Config.MoneyWash.DryItems.Cooldown * json.decode(result[1].drying_process).money-- Cooldown duration in seconds (e.g., 5 minutes)
            if upgraded then
                cooldownDuration = math.max(math.floor(cooldownDuration * Config.MoneyWash.DryItems.UpgradeReduction / 100), 1)
            end
            local cooldownEndTime = currentTime + cooldownDuration -- Calculate the end time of the cooldown
            local drying_process = {}

            if result[1] and result[1].drying_process then
                drying_process["money"] = json.decode(result[1].drying_process).money
            end

            drying_process["endtime"] = cooldownEndTime
            local drying_process_json = json.encode(drying_process)
            MySQL.Async.execute('UPDATE owned_warehouse SET drying_process = @drying_process WHERE name = @name', {
                ['@drying_process'] = drying_process_json,
                ['@name'] = house,
            }, function(affectedRows)
                if StartingOccupied[house] then
                    StartingOccupied[house] = false
                end
            end)
        end
    end
end)

lib.callback.register('drc_moneywash:checkdry', function(source, house, type)
    local src = source
    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_warehouse WHERE name = @name', {
        ['@name'] = house
    })
  
    if type == "check" then
        if result[1] and result[1].drying_process then
            local dryingProcess = json.decode(result[1].drying_process)

            if dryingProcess and dryingProcess.money and dryingProcess.endtime then
                local currentTime = os.time()
                local cooldownEndTime = tonumber(dryingProcess.endtime)
                if currentTime < cooldownEndTime then
                    local cooldownRemaining = cooldownEndTime - currentTime
                    TriggerClientEvent('drc_moneywash:notify', src, 'info', locale('info'), locale('timeleft', math.floor(cooldownRemaining / 60), cooldownRemaining % 60))
                else
                    TriggerClientEvent('drc_moneywash:notify', src, 'info', locale('info'), locale('alreadydried'))
                end
            end
        else
            TriggerClientEvent('drc_moneywash:notify', src, 'error', locale('error'), locale('notstarted'))
        end
    else

        if result[1] and result[1].drying_process then
            local dryingProcess = json.decode(result[1].drying_process)

            if dryingProcess and dryingProcess.money and dryingProcess.endtime then
                local currentTime = os.time()
                local cooldownEndTime = tonumber(dryingProcess.endtime)

                if currentTime >= cooldownEndTime then
                    if not CollectingOccupied[house] then
                        CollectingOccupied[house] = true 
                        SetTimeout(Config.MoneyWash.DryItems.AnimationDuration, function()
                            CollectingOccupied[house] = false 
                        end)
                        return true
                    else
                        return "occupied"
                    end
                else
                    return false
                end
            end
        else
            return "notstarted"
        end
    end
end)

RegisterNetEvent("drc_moneywash:collectdrymoney")
AddEventHandler("drc_moneywash:collectdrymoney", function(house)
    local src = source
    local result = MySQL.Sync.fetchAll('SELECT * FROM owned_warehouse WHERE name = @name', {
        ['@name'] = house
    })

    if result[1] and result[1].drying_process then
        local dryingProcess = json.decode(result[1].drying_process)

        if dryingProcess and dryingProcess.money and dryingProcess.endtime then
            local currentTime = os.time()
            local cooldownEndTime = tonumber(dryingProcess.endtime)

            if currentTime >= cooldownEndTime then     
                local requiredItem = Config.MoneyWash.DryItems.RequiredItems
                local percentageLost = HighcrestWashRate(src)
                local collectedAmount = math.max(math.floor(dryingProcess.money * percentageLost / 100), 1)
                MySQL.Async.execute('UPDATE owned_warehouse SET drying_process = @drying_process WHERE name = @name', {
                    ['@drying_process'] = nil,
                    ['@name'] = house,
                }, function(affectedRows)
                end)
                if CollectingOccupied[house] then
                    CollectingOccupied[house] = false
                end
                AddItem(Config.MoneyWash.DryItems.AddItems.item, collectedAmount, src)
            else
                local cooldownRemaining = cooldownEndTime - currentTime
                local cooldownText = string.format("%d minutes and %d seconds", math.floor(cooldownRemaining / 60), cooldownRemaining % 60)
                TriggerClientEvent('drc_moneywash:notify', src, 'info', locale('info'), locale('timeleft', math.floor(cooldownRemaining / 60), cooldownRemaining % 60))
            end
        end
    end
end)