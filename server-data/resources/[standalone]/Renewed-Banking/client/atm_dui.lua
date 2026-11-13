-- ATM screen as a 3D panel on the machine (cr-3dnui). The bank branch keeps the NUI popup.
-- Placement comes from the saved per-model table (set with /atmplace), else Config.atmPanel.
-- Flow: camera zooms to the ATM -> panel attached -> page gets locale + accounts -> crosshair drives the mouse -> ESC or walking away closes it.

local PAGE = ('nui://%s/web/public/index.html'):format(GetCurrentResourceName())
local panelId, atmEntity, lastEntity, cam
local Placements = {} -- [tostring(model)] = placement with vector3 fields

local function toPlacement(raw)
    return {
        offset = vector3(raw.offset.x, raw.offset.y, raw.offset.z),
        normal = vector3(raw.normal.x, raw.normal.y, raw.normal.z),
        up = raw.up and vector3(raw.up.x, raw.up.y, raw.up.z) or nil, -- tilted screens (/atmplace corners)
        width = raw.width, height = raw.height, zOffset = raw.zOffset,
        camDistance = raw.camDistance, camHeight = raw.camHeight,
    }
end

CreateThread(function()
    local all = lib.callback.await('renewed-banking:server:getPlacements', false) or {}
    for model, raw in pairs(all) do Placements[model] = toPlacement(raw) end
end)

RegisterNetEvent('renewed-banking:client:placementUpdated', function(model, raw)
    Placements[tostring(model)] = toPlacement(raw)
end)

-- Shared with atm_placement.lua.
function PlacementFor(entity)
    return Placements[tostring(GetEntityModel(entity))] or Config.atmPanel
end

function AtmSessionActive()
    return panelId ~= nil
end

-- Camera stands in front of the panel (along its normal) and points at the panel's centre.
function AtmCamPoints(entity, p)
    local n, o, d = p.normal, p.offset, p.camDistance
    local camPos = GetOffsetFromEntityInWorldCoords(entity, o.x + n.x * d, o.y + n.y * d, o.z + n.z * d + p.camHeight)
    local target = GetOffsetFromEntityInWorldCoords(entity, o.x, o.y, o.z)
    return camPos, target
end

function AtmCamStart(entity, p)
    local camPos, target = AtmCamPoints(entity, p)
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', camPos.x, camPos.y, camPos.z, 0.0, 0.0, 0.0, 45.0, false, 0)
    PointCamAtCoord(cam, target.x, target.y, target.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 700, true, false, 0)
end

function AtmCamUpdate(entity, p)
    if not cam then return end
    local camPos, target = AtmCamPoints(entity, p)
    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(cam, target.x, target.y, target.z)
end

function AtmCamStop()
    if not cam then return end
    RenderScriptCams(false, true, 700, true, false, 0)
    DestroyCam(cam, false)
    cam = nil
end

local function sendToPage(message)
    if panelId then exports['cr-3dnui']:SendMessage(panelId, message) end
end

local function endAtmSession()
    AtmCamStop()
    -- highcrest_pause ignores Esc while this is set; keep it a moment so the Esc release that
    -- closed the ATM does not open the pause menu.
    SetTimeout(500, function() if not panelId then LocalPlayer.state:set('hcBlockPause', false, false) end end)
    if not panelId then return end
    exports['cr-3dnui']:EndFocus()
    exports['cr-3dnui']:DestroyPanel(panelId)
    panelId, atmEntity = nil, nil
end

local function failed()
    endAtmSession()
    lib.notify({ title = locale('bank_name'), description = locale('loading_failed'), type = 'error' })
end

-- ATM-relative direction -> world direction. cr-3dnui's own conversion reads GetEntityMatrix in
-- the wrong order (it takes the forward axis as right), which turns panels sideways. So we convert
-- here and pass rotateNormal = false (ATMs never move, so a world direction stays correct).
function AtmWorldDir(entity, v)
    local origin = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, 0.0)
    local d = GetOffsetFromEntityInWorldCoords(entity, v.x, v.y, v.z) - origin
    local l = #d
    return l > 0 and d / l or d
end

-- The cr-3dnui attach options for a placement (shared with atm_placement.lua).
function AtmPanelOpts(entity, p)
    return {
        entity = entity,
        offset = p.offset,
        localNormal = AtmWorldDir(entity, p.normal),
        -- Reversed on purpose: cr-3dnui maps the texture's BOTTOM (v = 1) to its "up" side and
        -- builds right = normal x up, so a true up shows the page rotated 180 degrees.
        localUp = AtmWorldDir(entity, p.up or vector3(0.0, 0.0, 1.0)) * -1.0,
        rotateNormal = false,
        width = p.width, height = p.height, zOffset = p.zOffset,
        depthCompensation = 'screen', frontOnly = true,
    }
end

local function vnorm(v) local l = #v return l > 0 and v / l or v end
local function vdot(a, b) return a.x * b.x + a.y * b.y + a.z * b.z end
local function vcross(a, b) return vector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x) end

-- Where the mouse cursor points on the ATM screen, as page coordinates 0..1 (u right, v down),
-- or nil when it's off the screen. The ray goes from the ATM camera through the cursor.
function AtmCursorUV(entity, p)
    if not cam then return nil end
    local sx, sy = GetControlNormal(0, 239), GetControlNormal(0, 240)
    local camPos, rot = GetCamCoord(cam), GetCamRot(cam, 2)
    local rx, rz = math.rad(rot.x), math.rad(rot.z)
    local forward = vector3(-math.sin(rz) * math.cos(rx), math.cos(rz) * math.cos(rx), math.sin(rx))
    local right = vnorm(vcross(forward, vector3(0.0, 0.0, 1.0)))
    local up = vcross(right, forward)
    local tanV = math.tan(math.rad(GetCamFov(cam)) / 2)
    local aspect = GetAspectRatio(false)
    local dir = vnorm(forward + right * ((sx * 2 - 1) * tanV * aspect) + up * ((1 - sy * 2) * tanV))

    -- The panel: centre, facing, true up and right (as the player sees it).
    local N = AtmWorldDir(entity, p.normal)
    local U = AtmWorldDir(entity, p.up or vector3(0.0, 0.0, 1.0))
    local R = vnorm(vcross(U, N))
    local centre = GetOffsetFromEntityInWorldCoords(entity, p.offset.x, p.offset.y, p.offset.z) + N * (p.zOffset or 0.0)

    local denom = vdot(dir, N)
    if math.abs(denom) < 0.0001 then return nil end
    local t = vdot(centre - camPos, N) / denom
    if t < 0 then return nil end
    local rel = camPos + dir * t - centre
    local lx, ly = vdot(rel, R) / (p.width / 2), vdot(rel, U) / (p.height / 2)
    if math.abs(lx) > 1 or math.abs(ly) > 1 then return nil end
    return (lx + 1) / 2, (1 - ly) / 2
end

function StartAtmDui(entity)
    if panelId then return end
    local p = PlacementFor(entity)
    local opts = AtmPanelOpts(entity, p)
    opts.url, opts.resW, opts.resH = PAGE, 1024, 1024
    panelId = exports['cr-3dnui']:AttachPanelToEntity(opts)
    if not panelId then return failed() end
    atmEntity, lastEntity = entity, entity
    LocalPlayer.state:set('hcBlockPause', true, false)
    AtmCamStart(entity, p)

    CreateThread(function()
        Wait(1500) -- give the page time to load before messaging it
        if not panelId then return end
        sendToPage({ action = 'updateLocale', translations = lib.getLocales(), currency = Config.currency })
        local accounts = lib.callback.await('renewed-banking:server:initalizeBanking', false)
        if not panelId then return end
        if not accounts then return failed() end
        sendToPage({ action = 'setVisible', status = true, accounts = accounts, loading = false, atm = true })

        -- A normal mouse cursor drives the screen. cr-3dnui's own focus raycasts down the middle of
        -- the rendering camera, which is fixed here, so the cursor never moved; we cast our own ray
        -- from the cursor through the ATM camera instead. Esc or walking away closes it.
        while panelId do
            SetMouseCursorActiveThisFrame()
            DisableControlAction(0, 1, true)   -- look left/right (the view stays on the ATM)
            DisableControlAction(0, 2, true)   -- look up/down
            DisableControlAction(0, 24, true)  -- attack
            DisableControlAction(0, 25, true)  -- aim
            DisableControlAction(0, 200, true) -- Esc: close the ATM instead of the pause menu
            DisableControlAction(0, 199, true)

            local u, v = AtmCursorUV(atmEntity, p)
            if u then
                exports['cr-3dnui']:SendMouseMove(panelId, u, v)
                if IsDisabledControlJustPressed(0, 24) then exports['cr-3dnui']:SendMouseDown(panelId, 'left') end
                if IsDisabledControlJustReleased(0, 24) then exports['cr-3dnui']:SendMouseUp(panelId, 'left') end
            end
            if IsDisabledControlJustPressed(0, 200) or not DoesEntityExist(atmEntity)
                or #(GetEntityCoords(cache.ped) - GetEntityCoords(atmEntity)) > 2.5 then
                return endAtmSession()
            end
            Wait(0)
        end
    end)
end

-- Keypad: the page can't take keyboard focus, so digits/backspace/enter are sent as key messages.
-- skin.js types them into the focused input.
local function keypress(key)
    return function() sendToPage({ type = 'key', key = key }) end
end

for i = 0, 9 do
    local k = tostring(i)
    RegisterCommand('atm_key_' .. k, keypress(k), false)
    RegisterKeyMapping('atm_key_' .. k, 'ATM keypad ' .. k, 'keyboard', k)
end
RegisterCommand('atm_key_back', keypress('Backspace'), false)
RegisterKeyMapping('atm_key_back', 'ATM backspace', 'keyboard', 'BACK')
RegisterCommand('atm_key_enter', keypress('Enter'), false)
RegisterKeyMapping('atm_key_enter', 'ATM enter', 'keyboard', 'RETURN')

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then endAtmSession() end
end)
