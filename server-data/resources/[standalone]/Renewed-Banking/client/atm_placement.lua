-- /atmplace: aim at an ATM, then nudge the screen panel and camera until they line up.
-- The panel's corners and the camera are drawn so you can see them. Enter saves for every ATM of that model.
-- Backspace cancels. Nudge keys are held (hold to move):
--   Arrows: panel left/right/up/down    Q/E: panel in/out    Z/X: width    C/V: height
--   R/F: camera higher/lower           T/G: camera further/closer
--   A/D: turn the panel left/right

local PAGE = ('nui://%s/web/public/preview.html'):format(GetCurrentResourceName()) -- placeholder screen, visible while placing
local ATM_SET = {}
for _, model in ipairs(Config.atms) do ATM_SET[model] = true end

local STEP = 0.003
local TURN = 0.02 -- radians per frame for yaw (about 1 degree)

-- Turns the panel's facing around the vertical axis.
local function yaw(d, ang)
    local n = d.normal
    local c, s = math.cos(ang), math.sin(ang)
    d.normal = vector3(n.x * c - n.y * s, n.x * s + n.y * c, n.z)
end
local ADJUST = {
    { name = 'panel_left',  key = 'LEFT',  dir = -1, fn = function(d, s) d.offset = d.offset + vector3(s, 0.0, 0.0) end },
    { name = 'panel_right', key = 'RIGHT', dir =  1, fn = function(d, s) d.offset = d.offset + vector3(s, 0.0, 0.0) end },
    { name = 'panel_up',    key = 'UP',    dir =  1, fn = function(d, s) d.offset = d.offset + vector3(0.0, 0.0, s) end },
    { name = 'panel_down',  key = 'DOWN',  dir = -1, fn = function(d, s) d.offset = d.offset + vector3(0.0, 0.0, s) end },
    { name = 'panel_in',    key = 'Q',     dir = -1, fn = function(d, s) d.offset = d.offset + vector3(0.0, s, 0.0) end },
    { name = 'panel_out',   key = 'E',     dir =  1, fn = function(d, s) d.offset = d.offset + vector3(0.0, s, 0.0) end },
    { name = 'width_dn',    key = 'Z',     dir = -1, fn = function(d, s) d.width = math.max(0.05, d.width + s) end },
    { name = 'width_up',    key = 'X',     dir =  1, fn = function(d, s) d.width = math.max(0.05, d.width + s) end },
    { name = 'height_dn',   key = 'C',     dir = -1, fn = function(d, s) d.height = math.max(0.05, d.height + s) end },
    { name = 'height_up',   key = 'V',     dir =  1, fn = function(d, s) d.height = math.max(0.05, d.height + s) end },
    { name = 'cam_down',    key = 'F',     dir = -1, fn = function(d, s) d.camHeight = d.camHeight + s end },
    { name = 'cam_up',      key = 'R',     dir =  1, fn = function(d, s) d.camHeight = d.camHeight + s end },
    { name = 'cam_closer',  key = 'G',     dir = -1, fn = function(d, s) d.camDistance = math.max(0.2, d.camDistance + s) end },
    { name = 'cam_further', key = 'T',     dir =  1, fn = function(d, s) d.camDistance = math.max(0.2, d.camDistance + s) end },
    { name = 'turn_left',   key = 'A',     dir =  1, step = TURN, fn = function(d, s) yaw(d, s) end },
    { name = 'turn_right',  key = 'D',     dir = -1, step = TURN, fn = function(d, s) yaw(d, s) end },
}

local active, panelId = false, nil
local held = {}
local saveNow, cancelNow = false, false

for _, a in ipairs(ADJUST) do
    local cmd = 'atmp_' .. a.name
    RegisterCommand('+' .. cmd, function() if active then held[a.name] = true end end, false)
    RegisterCommand('-' .. cmd, function() held[a.name] = nil end, false)
    RegisterKeyMapping('+' .. cmd, 'ATM placement: ' .. a.name, 'keyboard', a.key)
end
RegisterCommand('+atmp_save', function() if active then saveNow = true end end, false)
RegisterKeyMapping('+atmp_save', 'ATM placement: save', 'keyboard', 'RETURN')
RegisterCommand('+atmp_cancel', function() if active then cancelNow = true end end, false)
RegisterKeyMapping('+atmp_cancel', 'ATM placement: cancel', 'keyboard', 'BACK')

local function copyPlacement(p)
    return {
        offset = p.offset, normal = p.normal,
        width = p.width, height = p.height, zOffset = p.zOffset,
        camDistance = p.camDistance, camHeight = p.camHeight,
    }
end

local function camDirection()
    local rot = GetGameplayCamRot(2)
    local x, z = math.rad(rot.x), math.rad(rot.z)
    local cx = math.abs(math.cos(x))
    return vector3(-math.sin(z) * cx, math.cos(z) * cx, math.sin(x))
end

-- The ATM the crosshair is on, or nil.
local function aimedAtm()
    local from = GetGameplayCamCoord()
    local to = from + camDirection() * 6.0
    local handle = StartShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, -1, cache.ped, 0)
    local status, hit, _, _, entity = 1, false, nil, nil, 0
    while status == 1 do
        Wait(0)
        status, hit, _, _, entity = GetShapeTestResult(handle)
    end
    if hit and entity ~= 0 and ATM_SET[GetEntityModel(entity)] then return entity end
end

-- The panel's four corners, in world space. Assumes the panel stands upright (normal is horizontal).
local function panelCorners(entity, d)
    local n = d.normal
    local len = math.sqrt(n.x * n.x + n.y * n.y)
    local X = len > 0 and vector3(-n.y / len, n.x / len, 0.0) or vector3(1.0, 0.0, 0.0)
    local Z = vector3(0.0, 0.0, 1.0)
    local hw, hh = d.width / 2, d.height / 2
    local o = d.offset
    local function world(v) return GetOffsetFromEntityInWorldCoords(entity, v.x, v.y, v.z) end
    -- order: bottom-left, top-left, bottom-right, top-right
    return {
        world(o + X * -hw + Z * -hh), world(o + X * -hw + Z * hh),
        world(o + X * hw + Z * -hh), world(o + X * hw + Z * hh),
    }
end

local function marker(p, r, g, b)
    DrawMarker(28, p.x, p.y, p.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.12, 0.12, 0.12, r, g, b, 230, false, false, 2, false, nil, nil, false)
end

local EDGES = { { 1, 2 }, { 2, 4 }, { 4, 3 }, { 3, 1 } }
local function drawPlot(entity, d)
    local c = panelCorners(entity, d)
    for _, e in ipairs(EDGES) do
        local a, b = c[e[1]], c[e[2]]
        DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, 255, 220, 0, 255)
    end
    for _, p in ipairs(c) do marker(p, 255, 220, 0) end
    local camPos, target = AtmCamPoints(entity, d)
    marker(camPos, 0, 200, 255)
    marker(target, 255, 255, 255)
    DrawLine(camPos.x, camPos.y, camPos.z, target.x, target.y, target.z, 0, 200, 255, 200)
end

local function serialize(d)
    return {
        offset = { x = d.offset.x, y = d.offset.y, z = d.offset.z },
        normal = { x = d.normal.x, y = d.normal.y, z = d.normal.z },
        width = d.width, height = d.height, zOffset = d.zOffset,
        camDistance = d.camDistance, camHeight = d.camHeight,
    }
end

local function runPlacement(entity)
    active, saveNow, cancelNow, held = true, false, false, {}
    local model = GetEntityModel(entity)
    local d = copyPlacement(PlacementFor(entity))
    panelId = exports['cr-3dnui']:AttachPanelToEntity({
        entity = entity, url = PAGE, resW = 1024, resH = 1024,
        offset = d.offset, localNormal = d.normal, localUp = vector3(0.0, 0.0, 1.0),
        width = d.width, height = d.height, zOffset = d.zOffset,
        depthCompensation = 'screen', frontOnly = true,
    })
    if not panelId then
        active = false
        return lib.notify({ title = 'ATM placement', description = 'Could not place the panel.', type = 'error' })
    end
    AtmCamStart(entity, d)

    while active do
        Wait(0)
        DisableAllControlActions(0)
        if cancelNow or not DoesEntityExist(entity) then break end

        local changed = false
        for _, a in ipairs(ADJUST) do
            if held[a.name] then
                a.fn(d, a.dir * (a.step or STEP))
                changed = true
            end
        end
        if changed then
            exports['cr-3dnui']:AttachPanelToEntity({
                panelId = panelId, entity = entity,
                offset = d.offset, localNormal = d.normal, localUp = vector3(0.0, 0.0, 1.0), zOffset = d.zOffset,
                depthCompensation = 'screen', frontOnly = true,
            })
            exports['cr-3dnui']:SetPanelSize(panelId, d.width, d.height)
            AtmCamUpdate(entity, d)
        end

        drawPlot(entity, d)

        if saveNow then
            TriggerServerEvent('renewed-banking:server:savePlacement', model, serialize(d))
            lib.notify({ title = 'ATM placement', description = 'Saved for every ATM of this model.', type = 'success' })
            break
        end
    end

    exports['cr-3dnui']:DestroyPanel(panelId)
    panelId = nil
    AtmCamStop()
    active = false
end

RegisterCommand('atmplace', function()
    if active then return end
    if AtmSessionActive() then
        return lib.notify({ title = 'ATM placement', description = 'Finish using the ATM first.', type = 'error' })
    end
    local entity = aimedAtm()
    if not entity then
        return lib.notify({ title = 'ATM placement', description = 'Aim at an ATM first.', type = 'error' })
    end
    CreateThread(function() runPlacement(entity) end)
end, false)
