-- Highcrest /carry. The server decides who carries whom: it checks distance, that neither
-- player is already carrying or carried, and that the target agreed (or is downed).

local MAX_DISTANCE = 3.0
local REQUEST_TIME = 15000

local carrying = {} -- [carrier] = target
local carriedBy = {} -- [target] = carrier
local pending = {}  -- [target] = { from = carrier, expires = ms }

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
    pending[target] = nil
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

    if isDowned(target) then
        return start(src, target)
    end

    local open = pending[target]
    if open and open.expires > GetGameTimer() then
        return lib.notify(src, { description = 'They already have a carry request open.', type = 'error' })
    end
    pending[target] = { from = src, expires = GetGameTimer() + REQUEST_TIME }
    TriggerClientEvent('highcrest_carry:client:ask', target, src)
    lib.notify(src, { description = 'Asked them if you can carry them.', type = 'inform' })
end)

RegisterNetEvent('highcrest_carry:server:answer', function(accept)
    local src = source
    local request = pending[src]
    pending[src] = nil
    if not request or request.expires < GetGameTimer() then return end
    local carrier = request.from
    if not GetPlayerName(carrier) then return end
    if accept ~= true then
        return lib.notify(carrier, { description = 'They said no.', type = 'error' })
    end
    if busy(carrier) or busy(src) or not closeEnough(carrier, src) or isDowned(carrier) then
        return lib.notify(carrier, { description = 'Carry cancelled: you moved apart.', type = 'error' })
    end
    start(carrier, src)
end)

RegisterNetEvent('highcrest_carry:server:stop', function()
    stop(source)
end)

AddEventHandler('playerDropped', function()
    local src = source
    stop(src)
    pending[src] = nil
end)
