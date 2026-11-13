-- /atmplace (admins): place the ATM screen panel by clicking the screen's corners, then fine-tune.
--
-- 1. Pick corners: aim at the ATM's screen and left-click its TOP-LEFT, TOP-RIGHT, then either BOTTOM
--    corners (right-click undoes the last one). That gives the panel's position, size and tilt.
-- 2. Fine-tune, seen through the ATM camera players get:
--      Scroll          push the panel in / out          Arrows   nudge the panel
--      Shift + Scroll  resize (keeps the shape)         W / S    camera closer / further
--      Shift + Arrows  stretch width / height           A / D    camera lower / higher
--      Enter           save for every ATM of this model
--      R               pick the corners again            Backspace  cancel
-- No key bindings are registered; keys are read only while placing.

local PAGE = ('nui://%s/web/public/preview.html'):format(GetCurrentResourceName()) -- placeholder screen
local ATM_SET = {}
for _, model in ipairs(Config.atms) do ATM_SET[model] = true end

local NUDGE = 0.002   -- metres per frame while an arrow is held
local PUSH = 0.004    -- metres per scroll notch
local SCALE = 0.01    -- 1% per scroll notch
local CAM = 0.01      -- metres per frame for the camera
local CORNERS = { 'TOP-LEFT', 'TOP-RIGHT', 'BOTTOM (left or right)' }

-- Controls (read with IsDisabledControl*, everything else is disabled while placing).
local C = {
    lmb = 24, rmb = 25, wheelUp = 241, wheelDown = 242, shift = 21,
    up = 172, down = 173, left = 174, right = 175,
    w = 32, s = 33, a = 34, d = 35, enter = 191, back = 194, r = 45, -- 194 = Backspace only (177 also fires on right-click)
}
local function pressed(c) return IsDisabledControlPressed(0, c) end
local function tapped(c) return IsDisabledControlJustPressed(0, c) end

local active = false

---------------------------------------------------------------------------
-- Maths helpers (all in the ATM's local space)
---------------------------------------------------------------------------

local function len(v) return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) end
local function norm(v) local l = len(v) return l > 0 and v / l or v end
local function dot(a, b) return a.x * b.x + a.y * b.y + a.z * b.z end
local function cross(a, b)
    return vector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

-- The panel's right axis from its normal and up.
local function rightOf(d) return norm(cross(d.up, d.normal)) end

-- Three clicked points (local) -> placement. The top edge (first two clicks) sets the direction
-- and width; the third click (either bottom corner, or anywhere on the bottom edge) only sets
-- the height. The normal is made to face the camera and `up` points to the top of the screen.
local function fromCorners(tl, tr, bottom, camLocal)
    local across = tr - tl
    local width = len(across)
    local R = norm(across)
    local down = bottom - tl
    local normal = norm(cross(across, down))
    if dot(normal, camLocal - tl) < 0 then normal = normal * -1.0 end
    -- Up is square to the top edge, in the screen's plane, pointing away from the bottom click.
    local up = norm(cross(normal, R))
    if dot(up, down) > 0 then up = up * -1.0 end
    local height = math.abs(dot(down, up))
    local centre = tl + across / 2 - up * (height / 2)
    return { offset = centre, normal = normal, up = up, width = width, height = height }
end

---------------------------------------------------------------------------
-- Aiming
---------------------------------------------------------------------------

local function camDirection()
    local rot = GetGameplayCamRot(2)
    local x, z = math.rad(rot.x), math.rad(rot.z)
    local cx = math.abs(math.cos(x))
    return vector3(-math.sin(z) * cx, math.cos(z) * cx, math.sin(x))
end

-- What the crosshair hits: world point and entity (or nil).
local function aim(distance)
    local from = GetGameplayCamCoord()
    local to = from + camDirection() * (distance or 6.0)
    local handle = StartShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, -1, cache.ped, 0)
    local status, hit, point, _, entity = 1, false, nil, nil, 0
    while status == 1 do
        Wait(0)
        status, hit, point, _, entity = GetShapeTestResult(handle)
    end
    if hit then return point, entity end
end

local function aimedAtm()
    local _, entity = aim()
    if entity and entity ~= 0 and ATM_SET[GetEntityModel(entity)] then return entity end
end

---------------------------------------------------------------------------
-- Drawing
---------------------------------------------------------------------------

local function marker(p, r, g, b, size)
    size = size or 0.02
    DrawMarker(28, p.x, p.y, p.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size, size, size, r, g, b, 230, false, false, 2, false, nil, nil, false)
end

local function line(a, b, r, g, bl)
    DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, r, g, bl, 255)
end

local function worldOf(entity, v) return GetOffsetFromEntityInWorldCoords(entity, v.x, v.y, v.z) end

local function drawPanelOutline(entity, d)
    local R, U = rightOf(d), d.up
    local hw, hh = d.width / 2, d.height / 2
    local o = d.offset
    local tl = worldOf(entity, o - R * hw + U * hh)
    local tr = worldOf(entity, o + R * hw + U * hh)
    local br = worldOf(entity, o + R * hw - U * hh)
    local bl = worldOf(entity, o - R * hw - U * hh)
    line(tl, tr, 255, 220, 0) line(tr, br, 255, 220, 0) line(br, bl, 255, 220, 0) line(bl, tl, 255, 220, 0)
end

local function help(text)
    lib.showTextUI(text, { position = 'left-center' })
end

---------------------------------------------------------------------------
-- Step 1: click the corners
---------------------------------------------------------------------------

local function pickCorners(entity)
    local picked = {}
    local shown
    while active do
        Wait(0)
        DisableAllControlActions(0)
        EnableControlAction(0, 1, true) -- look around
        EnableControlAction(0, 2, true)
        if tapped(C.back) or not DoesEntityExist(entity) then return nil end

        local i = #picked + 1
        if shown ~= i then
            shown = i
            help(('**ATM placement 1/2**  \nClick the screen\'s **%s** corner  \nRight-click: undo · Backspace: cancel'):format(CORNERS[i]))
        end

        -- Crosshair and what it points at.
        DrawRect(0.5, 0.5, 0.003, 0.005, 255, 255, 255, 230)
        local point, hitEntity = aim(4.0)
        local onAtm = point and hitEntity == entity
        if point then marker(point, onAtm and 0 or 255, onAtm and 255 or 60, 60, 0.015) end

        for n, p in ipairs(picked) do
            local w = worldOf(entity, p)
            marker(w, 255, 220, 0)
            if picked[n + 1] then line(w, worldOf(entity, picked[n + 1]), 255, 220, 0) end
        end

        if tapped(C.rmb) and #picked > 0 then picked[#picked] = nil end
        if tapped(C.lmb) then
            if onAtm then
                picked[#picked + 1] = GetOffsetFromEntityGivenWorldCoords(entity, point.x, point.y, point.z)
                if #picked == 3 then
                    local cam = GetGameplayCamCoord()
                    return picked, GetOffsetFromEntityGivenWorldCoords(entity, cam.x, cam.y, cam.z)
                end
            else
                lib.notify({ title = 'ATM placement', description = 'Click on the ATM itself.', type = 'error' })
            end
        end
    end
end

---------------------------------------------------------------------------
-- Step 2: fine-tune through the ATM camera
---------------------------------------------------------------------------

local function attach(panelId, entity, d)
    local opts = AtmPanelOpts(entity, d) -- converts directions to world space (see atm_dui.lua)
    opts.panelId = panelId
    if not panelId then opts.url, opts.resW, opts.resH = PAGE, 1024, 1024 end
    return exports['cr-3dnui']:AttachPanelToEntity(opts)
end

-- Returns 'save', 'redo' or nil (cancel).
local function fineTune(entity, d)
    local panelId = attach(nil, entity, d)
    if not panelId then
        lib.notify({ title = 'ATM placement', description = 'Could not create the panel.', type = 'error' })
        return nil
    end
    AtmCamStart(entity, d)
    help('**ATM placement 2/2**  \nScroll: in/out · Shift+Scroll: size  \nArrows: move · Shift+Arrows: stretch  \n'
        .. 'W/S: camera closer/further · A/D: camera down/up  \nEnter: save · R: redo corners · Backspace: cancel')

    local result
    while active do
        Wait(0)
        DisableAllControlActions(0)
        if not DoesEntityExist(entity) then break end
        if tapped(C.back) then break end
        if tapped(C.enter) then result = 'save' break end
        if tapped(C.r) then result = 'redo' break end

        local shift = pressed(C.shift)
        local R = rightOf(d)
        local changed, camChanged = false, false
        local wheel = (tapped(C.wheelUp) and 1 or 0) - (tapped(C.wheelDown) and 1 or 0)

        if wheel ~= 0 then
            if shift then
                local k = 1 + SCALE * wheel
                d.width, d.height = math.max(0.05, d.width * k), math.max(0.05, d.height * k)
            else
                d.offset = d.offset + d.normal * (PUSH * wheel)
            end
            changed = true
        end

        local h = (pressed(C.right) and 1 or 0) - (pressed(C.left) and 1 or 0)
        local v = (pressed(C.up) and 1 or 0) - (pressed(C.down) and 1 or 0)
        if h ~= 0 or v ~= 0 then
            if shift then
                d.width = math.max(0.05, d.width + h * NUDGE)
                d.height = math.max(0.05, d.height + v * NUDGE)
            else
                d.offset = d.offset + R * (h * NUDGE) + d.up * (v * NUDGE)
            end
            changed = true
        end

        local zoom = (pressed(C.s) and 1 or 0) - (pressed(C.w) and 1 or 0)
        local lift = (pressed(C.d) and 1 or 0) - (pressed(C.a) and 1 or 0)
        if zoom ~= 0 then d.camDistance = math.max(0.2, d.camDistance + zoom * CAM) camChanged = true end
        if lift ~= 0 then d.camHeight = d.camHeight + lift * CAM camChanged = true end

        if changed then
            attach(panelId, entity, d)
            exports['cr-3dnui']:SetPanelSize(panelId, d.width, d.height)
        end
        if changed or camChanged then AtmCamUpdate(entity, d) end
        drawPanelOutline(entity, d)
    end

    exports['cr-3dnui']:DestroyPanel(panelId)
    AtmCamStop()
    return result
end

---------------------------------------------------------------------------
-- The command
---------------------------------------------------------------------------

local function serialize(d)
    return {
        offset = { x = d.offset.x, y = d.offset.y, z = d.offset.z },
        normal = { x = d.normal.x, y = d.normal.y, z = d.normal.z },
        up = { x = d.up.x, y = d.up.y, z = d.up.z },
        width = d.width, height = d.height, zOffset = d.zOffset,
        camDistance = d.camDistance, camHeight = d.camHeight,
    }
end

local function runPlacement(entity)
    active = true
    local model = GetEntityModel(entity)
    local current = PlacementFor(entity)

    while active do
        local corners, camLocal = pickCorners(entity)
        if not corners then break end
        local d = fromCorners(corners[1], corners[2], corners[3], camLocal)
        d.zOffset = current.zOffset or 0.004
        d.camDistance = current.camDistance or 0.8
        d.camHeight = current.camHeight or 0.0

        local result = fineTune(entity, d)
        if result == 'save' then
            TriggerServerEvent('renewed-banking:server:savePlacement', model, serialize(d))
            lib.notify({ title = 'ATM placement', description = 'Saved for every ATM of this model.', type = 'success' })
            break
        elseif result ~= 'redo' then
            break
        end
    end

    lib.hideTextUI()
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
