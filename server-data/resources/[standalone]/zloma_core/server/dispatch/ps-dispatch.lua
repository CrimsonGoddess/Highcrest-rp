-- ps-dispatch has two incompatible generations:
--   v2 (current)  server event 'ps-dispatch:server:notify', codeName must match an
--                 entry in its Config.Dispatch
--   v1 (legacy)   server event 'dispatch:server:notify', the alert carries its own
--                 blip ('alert') and the UI fields dispatchCode / dispatchMessage
-- v1 ships server/sv_dispatchcodes.lua, v2 does not.
local legacyCache = {}

local function isLegacy(resource)
    if legacyCache[resource] == nil then
        legacyCache[resource] = LoadResourceFile(resource, 'server/sv_dispatchcodes.lua') ~= nil
    end
    return legacyCache[resource]
end

AddEventHandler('onResourceStart', function(resource) legacyCache[resource] = nil end)

local function sendLegacy(coords, jobs, data)
    local high = data.priority == 'high'
    local minutes = tonumber(data.time) or 10
    TriggerEvent('dispatch:server:notify', {
        dispatchcodename = data.psCodeName,
        dispatchCode = data.code,
        dispatchMessage = data.title,
        information = data.description ~= data.title and data.description or nil,
        firstStreet = data.street,
        priority = high and 1 or 2,
        origin = { x = coords.x, y = coords.y, z = coords.z },
        job = jobs,
        alert = {
            displayCode = data.code,
            description = data.title,
            radius = 0,
            recipientList = jobs,
            blipSprite = data.blip.sprite,
            blipColour = data.blip.color,
            blipScale = data.blip.scale,
            -- v1 fades the blip over 128 steps of blipLength seconds
            blipLength = math.max(.5, minutes * 60 / 128),
            sound = 'Lose_1st',
            sound2 = 'GTAO_FM_Events_Soundset',
            offset = 'false',
            blipflash = high and 'true' or 'false',
        },
    })
end

ZlomaCore.DispatchAdapters['ps-dispatch'] = function(_, coords, jobs, data)
    if isLegacy('ps-dispatch') then return sendLegacy(coords, jobs, data) end
    TriggerEvent('ps-dispatch:server:notify', {
        message = data.description or data.title,
        -- Must match an entry in ps-dispatch Config.Dispatch.
        codeName = data.psCodeName,
        code = data.code,
        icon = data.icon or 'fa-solid fa-bell',
        priority = data.priority == 'high' and 1 or 2,
        coords = vector3(coords.x, coords.y, coords.z),
        alertTime = data.time,
        alert = {
            radius = 0,
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            color = data.blip.color,
            flash = data.priority == 'high',
        },
        jobs = jobs
    })
end
