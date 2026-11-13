-- Highcrest /carry. The server decides who carries whom: it checks distance and that neither
-- player is already carrying or carried. There is no consent prompt.

local MAX_DISTANCE = 3.0

local carrying = {} -- [carrier] = target
local carriedBy = {} -- [target] = carrier

local function busy(id)
    return carrying[id] ~= nil or carriedBy[id] ~= nil
end

local function closeEnough(a, b)
    local pa, pb = GetPlayerPed(a), GetPlayerPed(b)
    if pa == 0 or pb == 0 then return false end
    return #(GetEntityCoords(pa) - GetEntityCoords(pb)) <= MAX_DISTANCE
end

local function isDowned(id)
    local player = exports.qbx_core:GetPlayer(id)
    local meta = player and player.PlayerData.metadata
    return meta and (meta.isdead or meta.inlaststand) or false
end

local function start(carrier, target)
    carrying[carrier] = target
    carriedBy[target] = carrier
    TriggerClientEvent('highcrest_carry:client:carry', carrier, target)
    TriggerClientEvent('highcrest_carry:client:carried', target, carrier)
end

local function stop(id)
    local target = carrying[id]
    local carrier = carriedBy[id]
    if target then
        carrying[id], carriedBy[target] = nil, nil
        TriggerClientEvent('highcrest_carry:client:stop', id)
        TriggerClientEvent('highcrest_carry:client:stop', target)
    elseif carrier then
        carrying[carrier], carriedBy[id] = nil, nil
        TriggerClientEvent('highcrest_carry:client:stop', id)
        TriggerClientEvent('highcrest_carry:client:stop', carrier)
    end
end

RegisterNetEvent('highcrest_carry:server:request', function(target)
    local src = source
    target = tonumber(target)
    if not target or target == src or not GetPlayerName(target) then return end
    if busy(src) or busy(target) then
        return lib.notify(src, { description = 'One of you is already carrying or being carried.', type = 'error' })
    end
    if not closeEnough(src, target) then
        return lib.notify(src, { description = 'Get closer to them first.', type = 'error' })
    end
    if isDowned(src) then return end

    -- No consent step (user's choice, 2026-11-13): pick them up straight away. A carried player
    -- who isn't downed can get down with X (client).
    start(src, target)
end)

RegisterNetEvent('highcrest_carry:server:stop', function()
    local src = source
    -- A downed player being carried can't end it themselves.
    if carriedBy[src] and isDowned(src) then return end
    stop(src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    stop(src)
end)
