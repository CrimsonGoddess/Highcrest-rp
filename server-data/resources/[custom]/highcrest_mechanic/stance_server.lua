-- Stance, server side. GTA doesn't keep or sync wheel poke, camber or ride height, so:
--   * the stance lives in player_vehicles.mods (keys in Config.stance.keys), saved by mechanic orders
--   * this file keeps plate -> stance in memory and puts it on the car's state bag (hcStance)
--     whenever that car spawns, so stance_client.lua applies it for everyone nearby.

local byPlate = {} -- trimmed plate -> { stanceHeight = n, ... } (only cars with some stance)

local function trim(plate)
    return type(plate) == 'string' and plate:gsub('^%s+', ''):gsub('%s+$', ''):upper() or nil
end

-- Just the stance keys from a mods table; nil if everything is stock.
local function stanceOf(mods)
    local s, any = {}, false
    for key in pairs(Config.stance.keys) do
        local v = tonumber(mods and mods[key]) or 0
        s[key] = v
        if v ~= 0 then any = true end
    end
    return any and s or nil
end

CreateThread(function()
    local rows = MySQL.query.await("SELECT plate, mods FROM player_vehicles WHERE mods LIKE '%\"stance%'") or {}
    for _, row in ipairs(rows) do
        local s = stanceOf(json.decode(row.mods or '') or {})
        if s then byPlate[trim(row.plate)] = s end
    end
    print(('[highcrest_mechanic] %d stanced cars loaded'):format(#rows))
end)

local function tag(entity, s)
    if entity ~= 0 and DoesEntityExist(entity) then Entity(entity).state:set('hcStance', s, true) end
end

-- Called by server.lua when a mechanic order is paid.
function StanceSaved(plate, mods, netId)
    local key = trim(plate)
    if not key then return end
    byPlate[key] = stanceOf(mods)
    tag(NetworkGetEntityFromNetworkId(tonumber(netId) or 0), byPlate[key] or false)
end

-- A car appeared: if its plate has a stance, tag it. The plate can be set a moment after the car
-- is created (garages), so check a few times.
AddEventHandler('entityCreated', function(entity)
    if not next(byPlate) or GetEntityType(entity) ~= 2 then return end
    CreateThread(function()
        for _ = 1, 6 do
            Wait(750)
            if not DoesEntityExist(entity) then return end
            local s = byPlate[trim(GetVehicleNumberPlateText(entity))]
            if s then return tag(entity, s) end
        end
    end)
end)
