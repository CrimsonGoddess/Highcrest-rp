-- Highcrest /coords: an admin panel for finding, previewing, adjusting and copying coordinates.
--
-- The working point is "feet height" (the ground under a ped), the same as qbx's /vec3 and /vec4,
-- so copied values can be pasted straight into configs that already use those commands.
-- Previews: a marker with axis lines, a ghost of your own ped, a vehicle or a prop.

local isOpen = false
local mode = 'panel' -- 'panel' | 'raycast' | 'look'
local point = { x = 0.0, y = 0.0, z = 0.0, h = 0.0 }
local settings = { preview = 'marker', model = '', radius = 0.0 }
local ghost = { entity = nil, kind = nil, model = nil, offset = 0.0 }
local outlined = nil

local function send(action, data)
    SendNUIMessage({ action = action, data = data })
end

local function round(n, places)
    local m = 10 ^ (places or 4)
    return math.floor(n * m + 0.5) / m
end

local function feet()
    local c = GetEntityCoords(cache.ped)
    return { x = round(c.x), y = round(c.y), z = round(c.z - 1.0), h = round(GetEntityHeading(cache.ped)) }
end

local function groundZ(x, y, z)
    for _, start in ipairs({ z + 2.0, z + 50.0, 1000.0 }) do
        local found, ground = GetGroundZFor_3dCoord(x, y, start, false)
        if found then return ground end
    end
end

---------------------------------------------------------------------------
-- Preview ghost
---------------------------------------------------------------------------

local function clearOutline()
    if outlined and DoesEntityExist(outlined) then SetEntityDrawOutline(outlined, false) end
    outlined = nil
end

local function deleteGhost()
    if ghost.entity and DoesEntityExist(ghost.entity) then DeleteEntity(ghost.entity) end
    ghost.entity, ghost.kind, ghost.model, ghost.offset = nil, nil, nil, 0.0
end

local function makeGhostEntity(entity, offset)
    SetEntityAlpha(entity, 160, false)
    SetEntityCollision(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    ghost.entity, ghost.offset = entity, offset or 0.0
end

-- Create or swap the ghost to match settings.preview / settings.model. Returns an error message or nil.
local function syncGhost()
    local kind, model = settings.preview, settings.model
    if kind == 'marker' or kind == 'none' then return deleteGhost() end
    if kind == 'ped' then model = 'self' end
    if ghost.entity and ghost.kind == kind and ghost.model == model and DoesEntityExist(ghost.entity) then return end
    deleteGhost()

    if kind == 'ped' then
        local ped = ClonePed(cache.ped, false, false, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        makeGhostEntity(ped, 1.0) -- a ped's origin is about 1 m above its feet
    else
        if not model or model == '' then return 'Type a model name first.' end
        local hash = tonumber(model) or joaat(model)
        if not IsModelInCdimage(hash) then return ('"%s" is not a valid model.'):format(model) end
        local ok = pcall(lib.requestModel, hash, 5000)
        if not ok then return ('Could not load "%s".'):format(model) end
        local entity
        if kind == 'vehicle' then
            if not IsModelAVehicle(hash) then SetModelAsNoLongerNeeded(hash) return ('"%s" is not a vehicle.'):format(model) end
            entity = CreateVehicle(hash, point.x, point.y, point.z, point.h, false, false)
            SetVehicleDoorsLocked(entity, 2)
        else
            entity = CreateObjectNoOffset(hash, point.x, point.y, point.z, false, false, false)
        end
        SetModelAsNoLongerNeeded(hash)
        local min = GetModelDimensions(hash)
        -- Vehicles sit with their wheels on the point; props are placed by their origin.
        makeGhostEntity(entity, kind == 'vehicle' and -min.z or 0.0)
    end
    ghost.kind, ghost.model = kind, model
end

local function placeGhost(p)
    if not ghost.entity or not DoesEntityExist(ghost.entity) then return end
    SetEntityCoordsNoOffset(ghost.entity, p.x, p.y, p.z + ghost.offset, false, false, false)
    SetEntityHeading(ghost.entity, p.h)
end

---------------------------------------------------------------------------
-- Drawing
---------------------------------------------------------------------------

local function drawPoint(p, colour)
    local origin = vec3(p.x, p.y, p.z)
    local rad = math.rad(p.h)
    local forward = vec3(-math.sin(rad), math.cos(rad), 0.0)
    local r, g, b = colour[1], colour[2], colour[3]

    -- Axis lines: X red, Y green, Z blue.
    DrawLine(origin.x, origin.y, origin.z, origin.x + 0.8, origin.y, origin.z, 230, 60, 60, 255)
    DrawLine(origin.x, origin.y, origin.z, origin.x, origin.y + 0.8, origin.z, 60, 220, 90, 255)
    DrawLine(origin.x, origin.y, origin.z, origin.x, origin.y, origin.z + 0.8, 70, 130, 255, 255)
    -- Heading arrow.
    local tip = origin + forward * 1.2
    DrawLine(origin.x, origin.y, origin.z + 0.02, tip.x, tip.y, tip.z + 0.02, r, g, b, 255)
    DrawMarker(2, tip.x, tip.y, tip.z + 0.05, 0.0, 0.0, 0.0, 90.0, 0.0, -p.h, 0.25, 0.25, 0.25, r, g, b, 220,
        false, false, 2, false, nil, nil, false)
    -- The point itself.
    DrawMarker(28, origin.x, origin.y, origin.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.07, 0.07, 0.07, r, g, b, 255,
        false, false, 2, false, nil, nil, false)
    DrawMarker(25, origin.x, origin.y, origin.z + 0.02, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, r, g, b, 120,
        false, false, 2, false, nil, nil, false)
    -- Zone radius (for sphere zones), if set.
    if settings.radius and settings.radius > 0 then
        local d = settings.radius * 2.0
        DrawMarker(28, origin.x, origin.y, origin.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, d, d, d, r, g, b, 45,
            false, false, 2, false, nil, nil, false)
    end
end

local function disableGameplay()
    for _, control in ipairs({ 24, 25, 37, 44, 45, 140, 141, 142, 143, 199, 200, 257, 263, 264 }) do
        DisableControlAction(0, control, true)
    end
end

local CRIMSON = { 200, 16, 46 }
local GOLD = { 212, 175, 55 }

CreateThread(function()
    while true do
        if isOpen and mode ~= 'raycast' then
            drawPoint(point, CRIMSON)
            placeGhost(point)
            if mode == 'look' then
                disableGameplay()
                for _, control in ipairs({ 21, 22, 30, 31, 32, 33, 34, 35 }) do DisableControlAction(0, control, true) end
            end
            Wait(0)
        else
            Wait(250)
        end
    end
end)

---------------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------------

local function savedPoints()
    local raw = GetResourceKvpString('points')
    local ok, list = pcall(json.decode, raw or '[]')
    return ok and type(list) == 'table' and list or {}
end

local function focusPanel()
    mode = 'panel'
    SetNuiFocusKeepInput(false)
    SetNuiFocus(true, true)
end

local function close()
    if not isOpen then return end
    isOpen, mode = false, 'panel'
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    send('close')
    deleteGhost()
    clearOutline()
    if lib.isTextUIOpen() then lib.hideTextUI() end
end

local function open()
    if isOpen then return close() end
    if IsPauseMenuActive() then return end
    isOpen = true
    point = feet()
    focusPanel()
    send('open', { point = point, settings = settings, points = savedPoints() })
    syncGhost()
end

RegisterNetEvent('highcrest_coords:client:open', open)

local function num(v, fallback)
    v = tonumber(v)
    if not v or v ~= v or v == math.huge or v == -math.huge then return fallback end
    return v
end

RegisterNUICallback('update', function(data, cb)
    if type(data) ~= 'table' then return cb({}) end
    local p, s = data.point, data.settings
    if type(p) == 'table' then
        point = { x = num(p.x, point.x), y = num(p.y, point.y), z = num(p.z, point.z), h = num(p.h, point.h) % 360.0 }
    end
    local err
    if type(s) == 'table' then
        settings.radius = math.max(0.0, num(s.radius, 0.0))
        local changed = s.preview ~= settings.preview or s.model ~= settings.model
        settings.preview = ({ marker = true, ped = true, vehicle = true, object = true })[s.preview] and s.preview or 'marker'
        settings.model = type(s.model) == 'string' and s.model:sub(1, 64) or ''
        if changed then err = syncGhost() end
    end
    cb({ error = err })
end)

RegisterNUICallback('me', function(_, cb) cb(feet()) end)

RegisterNUICallback('ground', function(data, cb)
    local z = groundZ(num(data.x, point.x), num(data.y, point.y), num(data.z, point.z))
    cb({ z = z and round(z) or nil })
end)

RegisterNUICallback('faceMe', function(_, cb)
    local me = GetEntityCoords(cache.ped)
    cb({ h = round(GetHeadingFromVector_2d(me.x - point.x, me.y - point.y)) })
end)

RegisterNUICallback('waypoint', function(_, cb)
    local blip = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blip) then return cb({ error = 'Set a waypoint on the map first.' }) end
    local c = GetBlipInfoIdCoord(blip)
    -- Ground height is only known once the area is loaded; fall back to the waypoint's own height.
    local z = groundZ(c.x, c.y, c.z) or c.z
    cb({ x = round(c.x), y = round(c.y), z = round(z) })
end)

RegisterNUICallback('teleport', function(_, cb)
    cb(1)
    local ped = cache.vehicle or cache.ped
    SetEntityCoords(ped, point.x, point.y, point.z + (cache.vehicle and 0.5 or 0.0), false, false, false, false)
    if not cache.vehicle then SetEntityHeading(ped, point.h) end
end)

RegisterNUICallback('copy', function(data, cb)
    cb(1)
    if type(data) ~= 'table' or type(data.text) ~= 'string' or data.text == '' then return end
    lib.setClipboard(data.text)
    lib.notify({ description = ('Copied: %s'):format(#data.text > 70 and data.text:sub(1, 67) .. '...' or data.text), type = 'success' })
end)

RegisterNUICallback('savePoints', function(list, cb)
    cb(1)
    if type(list) == 'table' then SetResourceKvp('points', json.encode(list)) end
end)

RegisterNUICallback('look', function(data, cb)
    cb(1)
    if not isOpen or mode == 'raycast' then return end
    if data and data.on then
        mode = 'look'
        SetNuiFocus(true, false)  -- keep the keyboard on the panel (to see Space released), hide the cursor
        SetNuiFocusKeepInput(true) -- and let the mouse turn the camera
    else
        focusPanel()
    end
end)

RegisterNUICallback('close', function(_, cb)
    cb(1)
    close()
end)

---------------------------------------------------------------------------
-- Raycast picking
---------------------------------------------------------------------------

local ENTITY_TYPES = { [1] = 'ped', [2] = 'vehicle', [3] = 'object' }

local function entityInfo(entity)
    local c = GetEntityCoords(entity)
    local hash = GetEntityModel(entity)
    local name = GetEntityArchetypeName(entity)
    if GetEntityType(entity) == 1 then c = c - vec3(0.0, 0.0, 1.0) end -- peds: feet height, like /vec4
    return {
        type = ENTITY_TYPES[GetEntityType(entity)] or 'entity',
        model = (name and name ~= '') and name or tostring(hash),
        hash = hash,
        netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or nil,
        x = round(c.x), y = round(c.y), z = round(c.z), h = round(GetEntityHeading(entity)),
    }
end

RegisterNUICallback('raycast', function(_, cb)
    cb(1)
    if not isOpen or mode == 'raycast' then return end
    mode = 'raycast'
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    send('raycast', true)
    lib.showTextUI('[LMB] Pick point  \n[E] Pick entity  \n[Scroll] Turn  \n[Shift+Scroll] Fine turn  \n[RMB / Backspace] Back', { position = 'left-center', icon = 'crosshairs' })

    CreateThread(function()
        local heading = point.h
        local result, picked
        while isOpen and mode == 'raycast' do
            disableGameplay()
            for _, control in ipairs({ 14, 15, 16, 17, 38, 177, 81, 82, 99, 100 }) do DisableControlAction(0, control, true) end

            local hit, entity, coords = lib.raycast.fromCamera(511, 4, 150.0)
            local step = IsControlPressed(0, 21) and 1.0 or 15.0
            if IsDisabledControlJustPressed(0, 15) then heading = (heading + step) % 360.0 end
            if IsDisabledControlJustPressed(0, 14) then heading = (heading - step) % 360.0 end

            local target = entity ~= 0 and GetEntityType(entity) ~= 0 and entity ~= cache.ped and entity ~= ghost.entity and entity or nil
            if target ~= outlined then
                clearOutline()
                if target then SetEntityDrawOutline(target, true) SetEntityDrawOutlineColor(212, 175, 55, 255) outlined = target end
            end

            if hit then
                local p = { x = round(coords.x), y = round(coords.y), z = round(coords.z), h = round(heading) }
                local me = GetEntityCoords(cache.ped)
                DrawLine(me.x, me.y, me.z, p.x, p.y, p.z, 212, 175, 55, 160)
                drawPoint(p, GOLD)
                placeGhost(p)
                if IsDisabledControlJustPressed(0, 24) then
                    result, picked = p, nil
                    break
                end
                if target and IsDisabledControlJustPressed(0, 38) then
                    picked = entityInfo(target)
                    result = { x = picked.x, y = picked.y, z = picked.z, h = picked.h }
                    break
                end
            end

            if IsDisabledControlJustPressed(0, 25) or IsDisabledControlJustPressed(0, 177) then break end
            Wait(0)
        end

        clearOutline()
        if lib.isTextUIOpen() then lib.hideTextUI() end
        if not isOpen then return end
        if result then point = result end
        focusPanel()
        send('raycast', false)
        send('picked', { point = point, entity = picked })
    end)
end)

---------------------------------------------------------------------------

CreateThread(function()
    while true do
        if isOpen and IsPedDeadOrDying(cache.ped, true) then close() end
        Wait(500)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if isOpen then
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
    end
    deleteGhost()
    clearOutline()
    if lib.isTextUIOpen() then lib.hideTextUI() end
end)
