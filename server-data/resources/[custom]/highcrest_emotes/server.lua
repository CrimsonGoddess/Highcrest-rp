-- Highcrest emotes: two-person emote requests from the F4 menu. The server relays the request,
-- tells the sender what happened, and on "yes" starts scully_emotemenu's synchronized emote
-- for both players (the same events scully's own server sends after an accept).

local MAX_DISTANCE = 5.0
local ASK_MS = 16000 -- the prompt runs 15 s; a little slack for the round trip

local pending = {} -- [target] = { from, mine, theirs, expires }

local function nameOf(id)
    local player = exports.qbx_core:GetPlayer(id)
    local info = player and player.PlayerData.charinfo
    if info and info.firstname then return ('%s %s'):format(info.firstname, info.lastname or '') end
    return GetPlayerName(id) or 'Someone'
end

local function closeEnough(a, b)
    local pa, pb = GetPlayerPed(a), GetPlayerPed(b)
    if pa == 0 or pb == 0 then return false end
    return #(GetEntityCoords(pa) - GetEntityCoords(pb)) <= MAX_DISTANCE
end

local function notify(id, text, kind)
    TriggerClientEvent('ox_lib:notify', id, { title = 'Emotes', description = text, type = kind or 'inform' })
end

-- Emote data is animation names and offsets from scully's own lists; just check the shape.
local function validData(d)
    return type(d) == 'table' and type(d.Dictionary) == 'string' and type(d.Animation) == 'string'
        and type(d.Label) == 'string' and type(d.Options) == 'table' and type(d.Options.Shared) == 'table'
end

RegisterNetEvent('highcrest_emotes:server:ask', function(target, mine, theirs)
    local src = source
    target = tonumber(target)
    if not target or target == src or not GetPlayerName(target) then return end
    if not validData(mine) or not validData(theirs) then return end
    if not closeEnough(src, target) then return notify(src, 'Get closer to them first.', 'error') end

    local open = pending[target]
    if open and open.expires > GetGameTimer() then
        return notify(src, 'They already have a request open.', 'error')
    end
    mine.Synchronized, theirs.Synchronized = true, true
    pending[target] = { from = src, mine = mine, theirs = theirs, expires = GetGameTimer() + ASK_MS }
    TriggerClientEvent('highcrest_emotes:client:asked', target, nameOf(src), mine.Label)
    notify(src, ('Asked %s to do %s…'):format(nameOf(target), mine.Label))

    SetTimeout(ASK_MS + 500, function()
        local still = pending[target]
        if still and still.from == src and still.expires <= GetGameTimer() then
            pending[target] = nil
            notify(src, ('%s didn\'t answer.'):format(nameOf(target)), 'error')
        end
    end)
end)

RegisterNetEvent('highcrest_emotes:server:answer', function(accept)
    local src = source
    local request = pending[src]
    pending[src] = nil
    if not request or request.expires < GetGameTimer() then return end
    local sender = request.from
    if not GetPlayerName(sender) then return end
    if accept ~= true then
        return notify(sender, ('%s declined.'):format(nameOf(src)), 'error')
    end
    if not closeEnough(sender, src) then
        notify(src, 'You moved too far apart.', 'error')
        return notify(sender, 'You moved too far apart.', 'error')
    end
    notify(sender, ('%s accepted.'):format(nameOf(src)), 'success')
    -- scully: the sender moves into place next to the target, then both play their side.
    TriggerClientEvent('scully_emotemenu:targetStartSynchronizedEmote', src, sender, request.mine, request.theirs)
    TriggerClientEvent('scully_emotemenu:senderStartSynchronizedEmote', sender, src, request.mine)
end)

AddEventHandler('playerDropped', function()
    local src = source
    pending[src] = nil
    for target, request in pairs(pending) do
        if request.from == src then pending[target] = nil end
    end
end)
