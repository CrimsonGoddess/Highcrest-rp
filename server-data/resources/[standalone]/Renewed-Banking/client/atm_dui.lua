-- ATM screen as a 3D panel on the machine (cr-3dnui). The bank branch keeps the NUI popup.
-- Flow: camera zooms to the ATM -> panel attached -> page gets locale + accounts -> crosshair drives the mouse -> ESC or walking away closes it.

local PAGE = ('nui://%s/web/public/index.html'):format(GetCurrentResourceName())
local panelId, atmEntity, lastEntity, cam

local function sendToPage(message)
    if panelId then exports['cr-3dnui']:SendMessage(panelId, message) end
end

local function startCam(entity)
    local p = Config.atmPanel
    local n = p.normal
    local d = p.camDistance
    local camPos = GetOffsetFromEntityInWorldCoords(entity, p.offset.x + n.x * d, p.offset.y + n.y * d, p.offset.z + n.z * d)
    local target = GetOffsetFromEntityInWorldCoords(entity, p.offset.x, p.offset.y, p.offset.z)
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', camPos.x, camPos.y, camPos.z, 0.0, 0.0, 0.0, 45.0, false, 0)
    PointCamAtCoord(cam, target.x, target.y, target.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 700, true, false, 0)
end

local function stopCam()
    if not cam then return end
    RenderScriptCams(false, true, 700, true, false, 0)
    DestroyCam(cam, false)
    cam = nil
end

local function endAtmSession()
    stopCam()
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
    local p = Config.atmPanel
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
    startCam(entity)

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

-- Tuning: /atmtune x y z width height camDistance (metres, in the ATM's local space).
-- Applies to the ATM you're using, restarting the session so you see the change at once.
RegisterCommand('atmtune', function(_, args)
    local p = Config.atmPanel
    if #args >= 5 then
        p.offset = vector3(tonumber(args[1]) or p.offset.x, tonumber(args[2]) or p.offset.y, tonumber(args[3]) or p.offset.z)
        p.width = tonumber(args[4]) or p.width
        p.height = tonumber(args[5]) or p.height
        if args[6] then p.camDistance = tonumber(args[6]) or p.camDistance end
    end
    local msg = ('offset %.2f %.2f %.2f  size %.2f x %.2f  cam %.2f'):format(
        p.offset.x, p.offset.y, p.offset.z, p.width, p.height, p.camDistance)
    lib.notify({ title = 'ATM tune', description = msg, type = 'inform' })
    print('[Renewed-Banking] atmPanel: ' .. msg)
    if panelId and lastEntity then
        endAtmSession()
        StartAtmDui(lastEntity)
    end
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then endAtmSession() end
end)
