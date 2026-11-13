-- Saved ATM panel placements, one per model. Stored in atm_placements.json in the resource folder.
-- Only players allowed to run commands (ace "command", i.e. admins) can save.

local FILE = 'atm_placements.json'
local placements = {}

local raw = LoadResourceFile(GetCurrentResourceName(), FILE)
if raw then placements = json.decode(raw) or {} end

local function num(v, fallback)
    return tonumber(v) or fallback
end

local function vec(v)
    if type(v) ~= 'table' then return nil end
    return { x = num(v.x, 0.0), y = num(v.y, 0.0), z = num(v.z, 0.0) }
end

local function clean(d)
    if type(d) ~= 'table' then return nil end
    local offset, normal = vec(d.offset), vec(d.normal)
    if not offset or not normal then return nil end
    return {
        offset = offset, normal = normal,
        width = num(d.width, 0.36), height = num(d.height, 0.28), zOffset = num(d.zOffset, 0.004),
        camDistance = num(d.camDistance, 0.8), camHeight = num(d.camHeight, 0.0),
    }
end

lib.callback.register('renewed-banking:server:getPlacements', function()
    return placements
end)

RegisterNetEvent('renewed-banking:server:savePlacement', function(model, data)
    local src = source
    if not IsPlayerAceAllowed(src, 'command') then return end
    local placement = clean(data)
    if not placement or type(model) ~= 'number' then return end

    placements[tostring(model)] = placement
    SaveResourceFile(GetCurrentResourceName(), FILE, json.encode(placements, { indent = true }), -1)
    TriggerClientEvent('renewed-banking:client:placementUpdated', -1, model, placement)
end)
