-- Esc (and P) open the Highcrest pause menu. It opens on the Map tab: GTA's real pause map fills
-- the screen and our menu panel sits on the left over it. "Server info" swaps the map for the
-- character / city / staff cards.
--
-- While the map shows, the mouse belongs to the map; it hands over to our panel when the cursor
-- moves onto it, and back when it leaves.

local isOpen = false
local mode = nil          -- 'map' or 'info'
local switching = false   -- true while we open or close the GTA map ourselves
local blockedUntil = 0
local panelWidth = 0.24   -- share of the screen the left panel covers (the page tells us the real value)

local PAUSE_CONTROLS = { 199, 200 } -- P, Esc
local MAP_MENU = 'FE_MENU_VERSION_MP_PAUSE'

local function openGtaMap()
    switching = true
    ActivateFrontendMenu(joaat(MAP_MENU), false, -1)
    CreateThread(function()
        local timeout = GetGameTimer() + 1500
        while not IsPauseMenuActive() and GetGameTimer() < timeout do Wait(0) end
        switching = false
    end)
end

local function closeGtaMap()
    if not IsPauseMenuActive() then return end
    switching = true
    SetFrontendActive(false)
    CreateThread(function()
        local timeout = GetGameTimer() + 1500
        while IsPauseMenuActive() and GetGameTimer() < timeout do Wait(0) end
        switching = false
    end)
end

local function setMode(newMode)
    mode = newMode
    SendNUIMessage({ action = 'mode', mode = newMode })
    if newMode == 'map' then
        TriggerScreenblurFadeOut(150)
        SetNuiFocus(false, false) -- the map gets the mouse until the cursor moves onto the panel
        openGtaMap()
    else
        closeGtaMap()
        SetNuiFocus(true, true)
        TriggerScreenblurFadeIn(250)
    end
end

local function close()
    if not isOpen then return end
    isOpen = false
    if mode == 'map' then closeGtaMap() end
    mode = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    TriggerScreenblurFadeOut(250)
    -- The key press that closed the menu must not reopen it.
    blockedUntil = GetGameTimer() + 400
end

local function open()
    if isOpen then return end
    isOpen = true
    SendNUIMessage({ action = 'open', links = Config.links, rules = Config.rules })
    setMode('map')
    local info = lib.callback.await('highcrest_pause:getInfo', false)
    if isOpen and info then
        SendNUIMessage({ action = 'info', info = info })
    end
end

-- Opens a GTA menu (settings) on its own, closing ours first.
local function openFrontend(menu)
    close()
    CreateThread(function()
        Wait(150)
        ActivateFrontendMenu(joaat(menu), false, -1)
    end)
end

CreateThread(function()
    while true do
        if isOpen then
            if mode == 'map' then
                if not IsPauseMenuActive() then
                    -- The player closed the map with Esc (or GTA's own exit): close the whole menu.
                    if not switching then close() end
                elseif not IsNuiFocused() then
                    -- Hand the mouse to our panel when the cursor reaches it.
                    local x = GetDisabledControlNormal(2, 239)
                    if x == 0.0 then x = GetControlNormal(2, 239) end
                    if x > 0.0 and x < panelWidth then SetNuiFocus(true, true) end
                end
                Wait(0)
            else
                Wait(150)
            end
        else
            for _, control in ipairs(PAUSE_CONTROLS) do
                DisableControlAction(0, control, true)
            end

            if IsPauseMenuActive() then
                -- While a GTA menu we didn't open (e.g. settings) is up, Esc belongs to it.
                blockedUntil = GetGameTimer() + 400
            elseif GetGameTimer() > blockedUntil and not IsNuiFocused() then
                for _, control in ipairs(PAUSE_CONTROLS) do
                    if IsDisabledControlJustReleased(0, control) then
                        open()
                        break
                    end
                end
            end
            Wait(0)
        end
    end
end)

RegisterNUICallback('layout', function(data, cb)
    local width = tonumber(data and data.panel)
    if width and width > 0.05 and width < 0.6 then panelWidth = width end
    cb(1)
end)

-- The cursor left our panel while the map is showing: give the mouse back to the map.
RegisterNUICallback('releaseFocus', function(_, cb)
    if isOpen and mode == 'map' then SetNuiFocus(false, false) end
    cb(1)
end)

RegisterNUICallback('close', function(_, cb)
    close()
    cb(1)
end)

RegisterNUICallback('map', function(_, cb)
    if isOpen and mode ~= 'map' then setMode('map') end
    if isOpen then SetNuiFocus(false, false) end
    cb(1)
end)

RegisterNUICallback('info', function(_, cb)
    if isOpen and mode ~= 'info' then setMode('info') end
    cb(1)
end)

RegisterNUICallback('settings', function(_, cb)
    openFrontend('FE_MENU_VERSION_LANDING_MENU')
    cb(1)
end)

RegisterNUICallback('link', function(data, cb)
    local url = Config.links[data and data.name]
    if url and url ~= '' then
        -- FiveM can't open the browser from here, so the link goes to chat to copy, as /discord does.
        TriggerEvent('chat:addMessage', { args = { 'Highcrest', url } })
        lib.setClipboard(url)
        lib.notify({ title = 'Link copied', description = url, type = 'inform' })
    end
    cb(1)
end)

RegisterNUICallback('disconnect', function(_, cb)
    cb(1)
    close()
    TriggerServerEvent('highcrest_pause:server:leave')
end)

RegisterNUICallback('quit', function(_, cb)
    cb(1)
    close()
    -- Closes the game.
    ForceSocialClubUpdate()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and isOpen then
        SetNuiFocus(false, false)
        TriggerScreenblurFadeOut(0)
        if IsPauseMenuActive() then SetFrontendActive(false) end
    end
end)
