-- Applies the realism multipliers (realism.lua) to a car model the first time this player drives it.
-- GTA shares handling between all cars of the same model and keeps changes until the game closes,
-- so each model's original values are remembered for the whole session (on the player's state,
-- which survives a resource restart). New values are always original x multiplier, never stacked.

local applied = {}

local function originals()
    return LocalPlayer.state.hcHandlingOrig or {}
end

local function tunedByStaff(vehicle)
    local tuned = GlobalState.hcTunedHandling or {}
    local name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):upper()
    return tuned[name] == true
end

local function multipliersFor(class)
    local extra = Realism.classes[class]
    if not extra then return nil end
    local out = {}
    for field, mult in pairs(Realism.base) do out[field] = mult end
    for field, mult in pairs(extra) do out[field] = (out[field] or 1.0) * mult end
    return out
end

local function apply(vehicle)
    if not Realism.enabled or not DoesEntityExist(vehicle) then return end
    local model = GetEntityModel(vehicle)
    if applied[model] or tunedByStaff(vehicle) then return end
    local mults = multipliersFor(GetVehicleClass(vehicle))
    if not mults then return end

    local all = originals()
    local key = tostring(model)
    local base = all[key]
    if not base then
        base = {}
        for field in pairs(mults) do base[field] = GetVehicleHandlingFloat(vehicle, 'CHandlingData', field) end
        all[key] = base
        LocalPlayer.state:set('hcHandlingOrig', all, false)
    end
    for field, mult in pairs(mults) do
        if base[field] then SetVehicleHandlingFloat(vehicle, 'CHandlingData', field, base[field] * mult) end
    end
    applied[model] = true
end

lib.onCache('vehicle', function(vehicle)
    if vehicle then SetTimeout(250, function() apply(vehicle) end) end
end)

CreateThread(function()
    if cache.vehicle then apply(cache.vehicle) end
end)
