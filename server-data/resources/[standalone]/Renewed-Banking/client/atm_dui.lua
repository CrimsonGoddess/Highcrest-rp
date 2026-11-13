-- ATM screen as a 3D panel on the machine (cr-3dnui). The bank branch keeps the NUI popup.
-- Flow: panel attached to the ATM -> page gets locale + accounts -> crosshair drives the mouse -> ESC or walking away closes it.

local PAGE = ('nui://%s/web/public/index.html'):format(GetCurrentResourceName())
local panelId, atmEntity

local function sendToPage(message)
    if panelId then exports['cr-3dnui']:SendMessage(panelId, message) end
end

local function endAtmSession()
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
    atmEntity = entity
    lib.notify({ title = 'ATM debug', description = 'step 1: panel attached ' .. tostring(panelId), type = 'inform' }) -- DEBUG

    CreateThread(function()
        Wait(1500) -- give the page time to load before messaging it
        if not panelId then return end
        sendToPage({ action = 'updateLocale', translations = lib.getLocales(), currency = Config.currency })
        lib.notify({ title = 'ATM debug', description = 'step 2: waiting for accounts', type = 'inform' }) -- DEBUG
        local accounts = lib.callback.await('renewed-banking:server:initalizeBanking', false)
        lib.notify({ title = 'ATM debug', description = 'step 3: accounts ' .. tostring(accounts ~= nil), type = 'inform' }) -- DEBUG
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
