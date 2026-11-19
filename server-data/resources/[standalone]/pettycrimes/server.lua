local QBCore = exports['qb-core']:GetCoreObject()

local cooldowns = {
    ParkingMeter = {},
    Vending = {}
}

local function isOnCooldown(bucket, key)
    local t = cooldowns[bucket][key]
    return t and (os.time() - t) < Config.Cooldowns[bucket]
end

local function setCooldown(bucket, key)
    cooldowns[bucket][key] = os.time()
end

local function getPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

local function hasItem(src, item, amount)
    amount = amount or 1
    local Player = getPlayer(src)
    if not Player then return false end
    local it = Player.Functions.GetItemByName(item)
    return it and it.amount and it.amount >= amount
end

local function removeItem(src, item, amount)
    local Player = getPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(item, amount or 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount or 1)
end

local function addMoney(src, amount)
    local Player = getPlayer(src)
    if not Player then return end
    Player.Functions.AddMoney('cash', amount, 'robbery-et_robs')
end

local function addItem(src, item, amount)
    local Player = getPlayer(src)
    if not Player then return end
    Player.Functions.AddItem(item, amount, false)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
end

local function weightedPick(tbl)
    local total = 0
    for _, v in ipairs(tbl) do total = total + (v.weight or 1) end
    local roll = math.random(1, total)
    local upto = 0
    for _, v in ipairs(tbl) do
        upto = upto + (v.weight or 1)
        if roll <= upto then return v end
    end
    return tbl[#tbl]
end

-- Optional cops check (qb-policejob style)
local function getCopCount()
    local count = 0
    for _, id in ipairs(QBCore.Functions.GetPlayers()) do
        local P = QBCore.Functions.GetPlayer(id)
        if P and P.PlayerData and P.PlayerData.job
            and P.PlayerData.job.name == 'police'
            and P.PlayerData.job.onduty then
            count = count + 1
        end
    end
    return count
end

RegisterNetEvent('et_robs:server:parkingMeterSuccess', function(coords)
    local src = source
    if type(coords) ~= 'vector3' then return end

    local ped = GetPlayerPed(src)
    local pcoords = GetEntityCoords(ped)

    -- Anti-spoof: must be close to the meter they claim
    if #(pcoords - coords) > 4.0 then return end

    -- Stable key based on position (rounded)
    local key = ('pm:%.1f:%.1f:%.1f'):format(coords.x, coords.y, coords.z)

    if isOnCooldown('ParkingMeter', key) then
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='This meter looks empty.' })
        return
    end

    if Config.Police.enabled and getCopCount() < (Config.Police.minCops or 0) then
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='Not enough police around.' })
        return
    end

    if not hasItem(src, Config.Items.Lockpick, 1) then
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='You need a lockpick.' })
        return
    end

    setCooldown('ParkingMeter', key)

    local cash = math.random(Config.ParkingMeter.cashMin, Config.ParkingMeter.cashMax)
    addMoney(src, cash)

    TriggerClientEvent('ox_lib:notify', src, { type='success', description=('You pulled $%s from the meter.'):format(cash) })
end)


RegisterNetEvent('et_robs:server:vendingSuccess', function(coords)
    local src = source
    if type(coords) ~= 'vector3' then return end

    local ped = GetPlayerPed(src)
    local pcoords = GetEntityCoords(ped)

    -- Anti-spoof
    if #(pcoords - coords) > 4.0 then return end

    local key = ('vm:%.1f:%.1f:%.1f'):format(coords.x, coords.y, coords.z)

    if isOnCooldown('Vending', key) then
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='It’s already been hit.' })
        return
    end

    if Config.Police.enabled and getCopCount() < (Config.Police.minCops or 0) then
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='Not enough police around.' })
        return
    end

    if not hasItem(src, Config.Items.Crowbar, 1) then
        TriggerClientEvent('ox_lib:notify', src, { type='error', description='You need a crowbar.' })
        return
    end

    setCooldown('Vending', key)

    local rolls = math.random(Config.Vending.rewardCount.min, Config.Vending.rewardCount.max)
    for _=1, rolls do
        local pick = weightedPick(Config.Vending.lootTable)
        local amt = math.random(pick.min, pick.max)
        addItem(src, pick.item, amt)
    end

    TriggerClientEvent('ox_lib:notify', src, { type='success', description='You pried it open and grabbed some stuff.' })
end)


RegisterNetEvent('et_robs:server:breakItem', function(item)
    local src = source
    if item ~= Config.Items.Lockpick and item ~= Config.Items.Crowbar then return end
    if not hasItem(src, item, 1) then return end
    removeItem(src, item, 1)
end)
