-- Highcrest status bar and minimap border (the border is placed in CSS, matching qbx_hud's square minimap). Replaces qbx_hud's status circles (hidden in its
-- styles.css); qbx_hud still runs the minimap and the vehicle speedometer.
local UPDATE_MS = 200

local metadata = {}
local function refreshMetadata(data)
    if data and data.metadata then metadata = data.metadata end
end
RegisterNetEvent('QBCore:Player:SetPlayerData', refreshMetadata)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() refreshMetadata(exports.qbx_core:GetPlayerData()) end)
CreateThread(function() refreshMetadata(exports.qbx_core:GetPlayerData()) end)

local hiddenByApp = false
AddEventHandler('highcrest_ui:setHidden', function(hidden) hiddenByApp = hidden == true end)

local function clamp(value)
    value = tonumber(value) or 0
    return math.max(0, math.min(100, math.floor(value + 0.5)))
end

CreateThread(function()
    local wasVisible = false

    while true do
        Wait(UPDATE_MS)
        local visible = LocalPlayer.state.isLoggedIn == true and not IsPauseMenuActive() and not hiddenByApp

        if not visible then
            if wasVisible then SendNUIMessage({ status = { visible = false } }) end
            wasVisible = false
        else
            wasVisible = true
            local ped, playerId = cache.ped, cache.playerId

            local underwater = IsPedSwimmingUnderWater(ped)
            local proximity = LocalPlayer.state.proximity
            local vehicle = cache.vehicle

            SendNUIMessage({
                status = {
                    visible = true,
                    minimapShown = IsRadarEnabled() and not IsRadarHidden(),
                    health = clamp(GetEntityHealth(ped) - 100),
                    armor = clamp(GetPedArmour(ped)),
                    hunger = clamp(metadata.hunger or 100),
                    thirst = clamp(metadata.thirst or 100),
                    stress = clamp(metadata.stress or 0),
                    stamina = clamp(100 - GetPlayerSprintStaminaRemaining(playerId)),
                    air = underwater and clamp(GetPlayerUnderwaterTimeRemaining(playerId) * 10) or nil,
                    talking = NetworkIsPlayerTalking(playerId),
                    voiceRange = proximity and proximity.index or 2,
                    engine = vehicle and clamp(GetVehicleEngineHealth(vehicle) / 10) or nil,
                },
            })
        end
    end
end)

-- /hudborder: line the map border up with the minimap on this screen. Arrow keys move it,
-- Shift + arrows resize it, Enter saves, Backspace cancels. Values are in vh and saved per player.
-- v2: offsets are relative to the defaults lined up on 2026-11-08, so older saves are ignored.
local BORDER_KVP = 'highcrest_map_border_v2'
local STEP = 0.1
local border = { x = 0.0, y = 0.0, w = 0.0, h = 0.0 }
do
    local ok, saved = pcall(json.decode, GetResourceKvpString(BORDER_KVP) or '')
    if ok and type(saved) == 'table' then
        for key in pairs(border) do border[key] = tonumber(saved[key]) or 0.0 end
    end
end

local function sendBorder(adjusting)
    SendNUIMessage({ mapBorder = { x = border.x, y = border.y, w = border.w, h = border.h, adjusting = adjusting } })
end
CreateThread(function() Wait(1000) sendBorder(false) end)

local adjusting = false
local function adjustBorder()
    if adjusting then return end
    adjusting = true
    local before = { x = border.x, y = border.y, w = border.w, h = border.h }
    lib.showTextUI('Arrows: move border  \nShift + arrows: resize  \nEnter: save  \nBackspace: cancel')
    sendBorder(true)
    local KEYS = { up = 172, down = 173, left = 174, right = 175 }
    while true do
        for _, control in pairs(KEYS) do DisableControlAction(0, control, true) end
        local resize = IsControlPressed(0, 21) -- Shift
        local changed = false
        local function press(control, dx, dy)
            if IsDisabledControlJustPressed(0, control) or (IsDisabledControlPressed(0, control) and GetGameTimer() % 4 == 0) then
                if resize then
                    border.w += dx; border.h += dy
                else
                    border.x += dx; border.y += dy
                end
                changed = true
            end
        end
        press(KEYS.left, -STEP, 0)
        press(KEYS.right, STEP, 0)
        press(KEYS.up, 0, STEP)
        press(KEYS.down, 0, -STEP)
        if changed then sendBorder(true) end

        if IsControlJustPressed(0, 191) then -- Enter
            SetResourceKvp(BORDER_KVP, json.encode(border))
            lib.notify({ title = 'Map border saved', description = ('Move %.1f, %.1f | Size %.1f, %.1f (vh)'):format(border.x, border.y, border.w, border.h), type = 'success' })
            print(('[highcrest_ui] map border offsets: x=%.1f y=%.1f w=%.1f h=%.1f'):format(border.x, border.y, border.w, border.h))
            break
        end
        if IsControlJustPressed(0, 177) then -- Backspace
            border = before
            break
        end
        Wait(0)
    end
    lib.hideTextUI()
    sendBorder(false)
    adjusting = false
end

RegisterCommand('hudborder', adjustBorder, false)
exports('AdjustMapBorder', adjustBorder)

-- /hudedit: drag the status items anywhere. The layout is saved per player.
local LAYOUT_KVP = 'highcrest_hud_layout'

local function savedLayout()
    local ok, layout = pcall(json.decode, GetResourceKvpString(LAYOUT_KVP) or '')
    return ok and type(layout) == 'table' and layout or {}
end

CreateThread(function()
    Wait(1000)
    SendNUIMessage({ hudLayout = savedLayout() })
end)

local function editHud()
    SetNuiFocus(true, true)
    SendNUIMessage({ editHud = true })
end

RegisterNUICallback('saveLayout', function(layout, cb)
    local clean = {}
    if type(layout) == 'table' then
        for key, spot in pairs(layout) do
            local x, y = type(spot) == 'table' and tonumber(spot.x), type(spot) == 'table' and tonumber(spot.y)
            if type(key) == 'string' and x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                clean[key] = { x = x, y = y }
            end
        end
    end
    SetResourceKvp(LAYOUT_KVP, json.encode(clean))
    SetNuiFocus(false, false)
    lib.notify({ description = 'HUD layout saved.', type = 'success' })
    cb(1)
end)

RegisterNUICallback('cancelEdit', function(_, cb)
    SetNuiFocus(false, false)
    cb(1)
end)

RegisterCommand('hudedit', editHud, false)
exports('EditHud', editHud)
