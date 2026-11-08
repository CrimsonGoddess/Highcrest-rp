-- /addhouse: set the front door, preview and pick a shell, enter the address and prices,
-- then photograph the house. The server checks everything again before saving.
local propertiesConfig = require '@qbx_properties.config.shared'

local NOTIFY_POSITION = 'top-left'
local KEY_CONFIRM = 38      -- E
local KEY_CANCEL = 177      -- Backspace

local busy = false
local previewShell = 0
local returnPoint = nil   -- Where to put the player back after a shell preview.

local function notify(description, kind)
    lib.notify({ title = 'Housing', description = description, type = kind, position = NOTIFY_POSITION })
end

-- Waits for E or Backspace while drawing a marker at the player's feet if asked.
local function waitForKey(text, drawMarker)
    lib.showTextUI(text)
    while true do
        if drawMarker then
            local coords = GetEntityCoords(cache.ped)
            DrawMarker(1, coords.x, coords.y, coords.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.4, 200, 16, 46, 160, false, false, 2, false, nil, nil, false)
        end
        if IsControlJustPressed(0, KEY_CONFIRM) then lib.hideTextUI() return true end
        if IsControlJustPressed(0, KEY_CANCEL) then lib.hideTextUI() return false end
        Wait(0)
    end
end

local function clearPreview()
    if DoesEntityExist(previewShell) then DeleteEntity(previewShell) end
    previewShell = 0
end

-- Shells sit underground below the front door, as qbx_properties places them.
local function preview(door, shell)
    clearPreview()
    lib.requestModel(shell.hash, 10000)
    previewShell = CreateObject(shell.hash, door.x, door.y, door.z - propertiesConfig.shellUndergroundOffset, false, false, false)
    FreezeEntityPosition(previewShell, true)
    SetModelAsNoLongerNeeded(shell.hash)
    local exit = propertiesConfig.interiors[shell.hash].exit
    SetEntityCoords(cache.ped, door.x + exit.x, door.y + exit.y, door.z - propertiesConfig.shellUndergroundOffset + exit.z, false, false, false, false)
end

local function pickShell(door, shells)
    local labels = {}
    for i, shell in ipairs(shells) do labels[i] = shell.label end

    local chosen = promise.new()
    local settled = false
    local function settle(value)
        if settled then return end
        settled = true
        chosen:resolve(value)
    end

    lib.registerMenu({
        id = 'highcrest_housing_shell',
        title = 'Choose a shell',
        position = 'top-right',
        onSideScroll = function(_, scrollIndex) preview(door, shells[scrollIndex]) end,
        onClose = function() settle(false) end,
        options = {
            { label = 'Shell', values = labels, icon = 'house', description = 'Left and right to preview, Enter to choose' },
        },
    }, function(_, scrollIndex) settle(shells[scrollIndex or 1]) end)

    returnPoint = door
    preview(door, shells[1])
    lib.showMenu('highcrest_housing_shell')
    local shell = Citizen.Await(chosen)

    clearPreview()
    SetEntityCoords(cache.ped, door.x, door.y, door.z, false, false, false, false)
    returnPoint = nil
    return shell
end

local function askDetails(defaultHours)
    while true do
        local input = lib.inputDialog('New house', {
            { type = 'input', label = 'Address', description = 'For example: 1420 Grove Street', required = true, min = 3, max = 60, icon = 'location-dot' },
            { type = 'number', label = 'Sale price', description = 'Leave empty if it is not for sale', min = 1, icon = 'dollar-sign' },
            { type = 'number', label = 'Rent price', description = 'Leave empty if it is not for rent', min = 1, icon = 'dollar-sign' },
            { type = 'number', label = 'Rent is taken every (hours)', default = defaultHours, min = 1, max = 24, step = 1, icon = 'clock' },
        })
        if not input then return nil end
        if input[2] or input[3] then
            return { address = input[1], salePrice = input[2], rentPrice = input[3], rentHours = input[4] }
        end
        notify('Set a sale price, a rent price, or both.', 'error')
    end
end

local function takePhoto()
    while true do
        if not waitForKey('[E] Take the photo  \nFrame the house with your camera first  \n[Backspace] Cancel') then return false end
        DisplayRadar(false)
        Wait(300)
        local result = lib.callback.await('highcrest_phone:server:housingPhoto', false)
        DisplayRadar(true)
        if result and result.ok then
            local answer = lib.alertDialog({
                header = 'Photo taken',
                content = 'Save this house now, or retake the photo?',
                centered = true,
                cancel = true,
                labels = { confirm = 'Save house', cancel = 'Retake photo' },
            })
            if answer == 'confirm' then return true end
        else
            notify((result and result.error) or 'The photo could not be taken.', 'error')
        end
    end
end

RegisterNetEvent('highcrest_phone:client:addHouse', function(shells, defaultHours)
    if busy then return end

    -- Shells come from separate shell packs, so skip any whose model isn't installed.
    local installed = {}
    for _, shell in ipairs(shells) do
        if IsModelInCdimage(shell.hash) then installed[#installed + 1] = shell end
    end
    if #installed == 0 then
        return notify('No shells are installed yet. Add a shell pack to the server first.', 'error')
    end
    shells = installed

    busy = true
    local ok, err = pcall(function()
        if not waitForKey('[E] Set the front door here  \n[Backspace] Cancel', true) then return end
        local coords = GetEntityCoords(cache.ped)
        local door = vec3(coords.x, coords.y, coords.z)

        local shell = pickShell(door, shells)
        if not shell then return notify('Cancelled.') end

        local details = askDetails(defaultHours)
        if not details then return notify('Cancelled.') end

        if not takePhoto() then return notify('Cancelled.') end

        details.shell = shell.model
        details.door = { x = door.x, y = door.y, z = door.z }
        local result = lib.callback.await('highcrest_phone:server:housingCreate', false, details)
        if result and result.ok then
            notify(('%s is now listed in the Housing app.'):format(result.address), 'success')
        else
            notify((result and result.error) or 'The house could not be saved.', 'error')
        end
    end)
    if not ok then
        print(('[highcrest_phone] addhouse failed: %s'):format(err))
        notify('Something went wrong. Nothing was saved.', 'error')
    end
    clearPreview()
    if returnPoint then
        SetEntityCoords(cache.ped, returnPoint.x, returnPoint.y, returnPoint.z, false, false, false, false)
        returnPoint = nil
    end
    lib.hideTextUI()
    DisplayRadar(true)
    busy = false
end)

RegisterNetEvent('highcrest_phone:client:housePhoto', function(id, src)
    SendNUIMessage({ action = 'housePhoto', id = id, src = src })
end)

RegisterNUICallback('housingPhotoGet', function(id, cb)
    TriggerServerEvent('highcrest_phone:server:requestHousePhoto', id)
    cb(1)
end)

for _, name in ipairs({ 'housingGet', 'housingBuy', 'housingRent', 'housingRemove' }) do
    RegisterNUICallback(name, function(data, cb)
        cb(lib.callback.await('highcrest_phone:server:' .. name, false, data) or false)
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then clearPreview() end
end)
