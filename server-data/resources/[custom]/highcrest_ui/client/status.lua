-- Highcrest status bar and minimap border. Replaces qbx_hud's status circles (hidden in its
-- styles.css); qbx_hud still runs the minimap and the vehicle speedometer.
local UPDATE_MS = 200

-- Where qbx_hud places the square minimap (see qbx_hud LoadMap). If the border looks off,
-- nudge these: BORDER_PAD widens the frame, and X/Y shift it, all as fractions of the screen.
local MINIMAP = { x = 0.0, y = -0.047, w = 0.1638, h = 0.183 }
local BORDER_PAD, BORDER_SHIFT_X, BORDER_SHIFT_Y = 0.002, 0.0, 0.0

local metadata = {}
local function refreshMetadata(data)
    if data and data.metadata then metadata = data.metadata end
end
RegisterNetEvent('QBCore:Player:SetPlayerData', refreshMetadata)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() refreshMetadata(exports.qbx_core:GetPlayerData()) end)
CreateThread(function() refreshMetadata(exports.qbx_core:GetPlayerData()) end)

local hiddenByApp = false
AddEventHandler('highcrest_ui:setHidden', function(hidden) hiddenByApp = hidden == true end)

-- The minimap's rectangle on screen, as fractions of the screen size.
local function minimapRect()
    local resX, resY = GetActiveScreenResolution()
    local aspect = resX / resY
    local offset = 0.0
    if aspect > 1920 / 1080 then offset = ((1920 / 1080 - aspect) / 3.6) - 0.008 end

    local x = MINIMAP.x + offset
    SetScriptGfxAlign(string.byte('L'), string.byte('B'))
    local left, top = GetScriptGfxPosition(x, MINIMAP.y - MINIMAP.h)
    local right, bottom = GetScriptGfxPosition(x + MINIMAP.w, MINIMAP.y)
    ResetScriptGfxAlign()
    return {
        left = left - BORDER_PAD + BORDER_SHIFT_X,
        top = top - BORDER_PAD + BORDER_SHIFT_Y,
        width = (right - left) + BORDER_PAD * 2,
        height = (bottom - top) + BORDER_PAD * 2,
    }
end

local function clamp(value)
    value = tonumber(value) or 0
    return math.max(0, math.min(100, math.floor(value + 0.5)))
end

CreateThread(function()
    local wasVisible = false
    local rect, rectAt = nil, 0

    while true do
        Wait(UPDATE_MS)
        local visible = LocalPlayer.state.isLoggedIn == true and not IsPauseMenuActive() and not hiddenByApp

        if not visible then
            if wasVisible then SendNUIMessage({ status = { visible = false } }) end
            wasVisible = false
        else
            wasVisible = true
            local ped, playerId = cache.ped, cache.playerId
            local now = GetGameTimer()
            if not rect or now - rectAt > 2000 then rect, rectAt = minimapRect(), now end

            local underwater = IsPedSwimmingUnderWater(ped)
            local proximity = LocalPlayer.state.proximity
            local vehicle = cache.vehicle

            SendNUIMessage({
                status = {
                    visible = true,
                    minimapShown = IsRadarEnabled() and not IsRadarHidden(),
                    minimap = rect,
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
