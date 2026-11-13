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
    if not panelId then return end
    exports['cr-3dnui']:EndFocus()
    exports['cr-3dnui']:DestroyPanel(panelId)
    panelId, atmEntity = nil, nil
end

local function failed()
    endAtmSession()
    lib.notify({ title = locale('bank_name'), description = locale('loading_failed'), type = 'error' })
end

function StartAtmDui(entity)
    if panelId then return end
    local p = PlacementFor(entity)
    panelId = exports['cr-3dnui']:AttachPanelToEntity({
        entity = entity,
        url = PAGE,
        resW = 1024, resH = 1024,
        offset = p.offset, localNormal = p.normal,
        width = p.width, height = p.height, zOffset = p.zOffset,
        depthCompensation = 'screen', frontOnly = true,
    })
    if not panelId then return failed() end
    atmEntity, lastEntity = entity, entity
    AtmCamStart(entity, p)

    CreateThread(function()
        Wait(1500) -- give the page time to load before messaging it
        if not panelId then return end
        sendToPage({ action = 'updateLocale', translations = lib.getLocales(), currency = Config.currency })
        local accounts = lib.callback.await('renewed-banking:server:initalizeBanking', false)
        if not panelId then return end
        if not accounts then return failed() end
        sendToPage({ action = 'setVisible', status = true, accounts = accounts, loading = false, atm = true })

        -- The crosshair is the mouse. Attack/aim are disabled so clicks don't fire a weapon.
        exports['cr-3dnui']:BeginFocus(panelId, { maxDist = 2.0, drawCursor = true, autoExitOnMiss = false })
        while panelId do
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            local hit, u, v = exports['cr-3dnui']:FocusTick()
            if hit then
                exports['cr-3dnui']:SendMouseMove(panelId, u, v)
                if IsDisabledControlJustPressed(0, 24) then exports['cr-3dnui']:SendMouseDown(panelId, 'left') end
                if IsDisabledControlJustReleased(0, 24) then exports['cr-3dnui']:SendMouseUp(panelId, 'left') end
            end
            if not exports['cr-3dnui']:IsFocused() or not DoesEntityExist(atmEntity)
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
