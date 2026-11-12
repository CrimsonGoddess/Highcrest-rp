-- Applies realism (realism.lua) to a car model the first time this player drives it, and sets the
-- car's top speed from its speed class and its upgrades.
--
-- GTA shares handling between all cars of the same model and keeps changes until the game closes,
-- so each model's original values are remembered for the whole session (on the player's state,
-- which survives a resource restart). New values are always original x multiplier, never stacked.
-- The top-speed cap is per car, so two of the same model with different upgrades differ.

local MPH = 2.236936 -- m/s -> mph
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

-- Original values for this model (captured once per game session).
local function baseFor(vehicle, fields)
    local all = originals()
    local key = tostring(GetEntityModel(vehicle))
    local base = all[key]
    local changed = false
    if not base or not base.values then
        -- (An older version stored plain values; keep them as the originals.)
        base = { estMph = GetVehicleEstimatedMaxSpeed(vehicle) * MPH, values = base or {} }
        all[key] = base
        changed = true
    end
    for field in pairs(fields) do
        if base.values[field] == nil then
            base.values[field] = GetVehicleHandlingFloat(vehicle, 'CHandlingData', field)
            changed = true
        end
    end
    if changed then LocalPlayer.state:set('hcHandlingOrig', all, false) end
    return base
end

-- Fully upgraded top speed (mph) for this model, placed within its class by its original speed.
local function classTopSpeed(vehicle, base)
    local classId = Realism.speedClassOf[GetVehicleClass(vehicle)]
    local class = classId and Realism.speedClasses[classId]
    if not class then return nil end
    local lo, hi = class.from[1], class.from[2]
    local t = math.max(0.0, math.min(1.0, (base.estMph - lo) / (hi - lo)))
    return class.min + (class.max - class.min) * t
end

-- 0..1: how upgraded this car is for top speed.
local function upgradeShare(vehicle)
    local w = Realism.upgradeWeights
    local function level(slot)
        local max = GetNumVehicleMods(vehicle, slot)
        if max <= 0 then return 1.0 end -- can't be upgraded: counts as full
        return (GetVehicleMod(vehicle, slot) + 1) / max
    end
    local turbo = IsToggleModOn(vehicle, 18) and 1.0 or 0.0
    return w.engine * level(11) + w.transmission * level(13) + w.turbo * turbo
end

local function apply(vehicle)
    if not Realism.enabled or not DoesEntityExist(vehicle) then return end
    if tunedByStaff(vehicle) then return end
    local model = GetEntityModel(vehicle)
    local mults = multipliersFor(GetVehicleClass(vehicle)) or {}
    local fields = { fInitialDriveMaxFlatVel = true }
    for field in pairs(mults) do fields[field] = true end
    local base = baseFor(vehicle, fields)
    local fullMph = classTopSpeed(vehicle, base)

    -- Model handling: once per model this resource run.
    if not applied[model] then
        for field, mult in pairs(mults) do
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', field, base.values[field] * mult)
        end
        if fullMph and base.estMph > 1 then
            -- Gear the model so its class speed is reachable when fully upgraded (a little headroom).
            local ratio = (fullMph * 1.03) / base.estMph
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel', base.values.fInitialDriveMaxFlatVel * ratio)
        end
        applied[model] = true
    end

    -- This car's cap: stock share of the class speed, up to the full speed with upgrades.
    if fullMph then
        local share = Realism.stockShare + (1.0 - Realism.stockShare) * upgradeShare(vehicle)
        SetVehicleMaxSpeed(vehicle, (fullMph * share) / MPH)
    end
end

lib.onCache('vehicle', function(vehicle)
    if vehicle then SetTimeout(250, function() apply(vehicle) end) end
end)

CreateThread(function()
    if cache.vehicle then apply(cache.vehicle) end
end)

-- /topspeed: show the current car's class and top speed (stock vs fully upgraded).
RegisterCommand('topspeed', function()
    local vehicle = cache.vehicle
    if not vehicle then return lib.notify({ description = 'Get in a car first.', type = 'error' }) end
    local base = (originals())[tostring(GetEntityModel(vehicle))]
    local classId = Realism.speedClassOf[GetVehicleClass(vehicle)]
    local fullMph = base and classTopSpeed(vehicle, base)
    if tunedByStaff(vehicle) or not fullMph then
        return lib.notify({ title = 'Top speed', description = 'This car uses its own tuning (no speed class).' })
    end
    local now = fullMph * (Realism.stockShare + (1.0 - Realism.stockShare) * upgradeShare(vehicle))
    lib.notify({ title = ('Class %s'):format(classId), duration = 8000,
        description = ('Now: %d mph · Stock: %d mph · Fully upgraded: %d mph'):format(math.floor(now), math.floor(fullMph * Realism.stockShare), math.floor(fullMph)) })
end, false)
