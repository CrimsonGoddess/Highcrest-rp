-- Esc (and P) open the GTA map first. Closing the map (Esc) opens the Highcrest city menu
-- (character, staff, rules, links); Esc again closes it. Map and settings are also in the city menu.

local isOpen = false
local blockedUntil = 0

local PAUSE_CONTROLS = { 199, 200 } -- P, Esc

local function close()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    TriggerScreenblurFadeOut(250)
    -- The key press that closed the menu must not reopen it.
    blockedUntil = GetGameTimer() + 400
end

local function open()
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)
    TriggerScreenblurFadeIn(250)
    SendNUIMessage({
        action = 'open',
        links = Config.links,
        rules = Config.rules,
    })
    local info = lib.callback.await('highcrest_pause:getInfo', false)
    if isOpen and info then
        SendNUIMessage({ action = 'info', info = info })
    end
end

-- Esc order: GTA map first; closing the map (Esc) opens the city menu; Esc again closes that.
local returnToCity = false  -- open the city menu when the GTA menu we opened closes
local wasPaused = false

-- Opens a GTA frontend menu (map or settings), closing ours first.
local function openFrontend(menu)
    close()
    returnToCity = true
    blockedUntil = GetGameTimer() + 400
    CreateThread(function()
        Wait(150)
        ActivateFrontendMenu(joaat(menu), false, -1)
    end)
end

CreateThread(function()
    while true do
        if isOpen then
            Wait(250)
        else
            for _, control in ipairs(PAUSE_CONTROLS) do
                DisableControlAction(0, control, true)
            end

            if IsPauseMenuActive() then
                -- While the GTA map or settings are open, Esc belongs to them.
                wasPaused = true
                blockedUntil = GetGameTimer() + 400
            elseif wasPaused then
                -- The GTA menu just closed: go on to the city menu if we opened it.
                wasPaused = false
                if returnToCity then
                    returnToCity = false
                    open()
                end
            elseif GetGameTimer() > blockedUntil and not IsNuiFocused() then
                for _, control in ipairs(PAUSE_CONTROLS) do
                    if IsDisabledControlJustReleased(0, control) then
                        openFrontend('FE_MENU_VERSION_MP_PAUSE')
                        break
                    end
                end
            end
            Wait(0)
        end
    end
end)

RegisterNUICallback('close', function(_, cb)
    close()
    cb(1)
end)

RegisterNUICallback('map', function(_, cb)
    openFrontend('FE_MENU_VERSION_MP_PAUSE')
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
    end
end)
