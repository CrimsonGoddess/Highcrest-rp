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
