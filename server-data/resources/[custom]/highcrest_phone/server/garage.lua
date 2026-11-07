-- Garage: read-only view of a character's vehicles. Taking vehicles out still happens at a garage.
local STATE_LABELS = { [0] = 'Out', [1] = 'In garage', [2] = 'Impounded' }
local HEALTH_MAX = 1000

local function percent(value)
    return math.floor(math.max(0, math.min(HEALTH_MAX, tonumber(value) or 0)) / HEALTH_MAX * 100 + 0.5)
end

lib.callback.register('highcrest_phone:server:garageGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end

    local rows = MySQL.query.await('SELECT vehicle, plate, garage, state, fuel, engine, body, depotprice FROM player_vehicles WHERE citizenid = ?', {
        player.PlayerData.citizenid,
    }) or {}
    local models = exports.qbx_core:GetVehiclesByName()
    local garages = exports.qbx_garages:GetGarages()

    local vehicles = {}
    for _, row in ipairs(rows) do
        local model = models[row.vehicle]
        local garage = garages[row.garage]
        vehicles[#vehicles + 1] = {
            name = model and model.name or row.vehicle,
            brand = model and model.brand or nil,
            plate = row.plate,
            state = row.state,
            stateLabel = STATE_LABELS[row.state] or 'Unknown',
            garage = garage and garage.label or nil,
            fuel = math.floor(tonumber(row.fuel) or 0),
            engine = percent(row.engine),
            body = percent(row.body),
            depotPrice = tonumber(row.depotprice) or 0,
        }
    end
    return { vehicles = vehicles }
end)

-- Only finds a vehicle the player owns, using the server's own list of spawned vehicles.
lib.callback.register('highcrest_phone:server:garageLocate', function(source, plate)
    local player = GetPhoneOwner(source)
    if not player or type(plate) ~= 'string' then return end
    if IsRateLimited(source, 'garageLocate', 1000) then return { error = 'Hold on a moment.' } end

    local owned = MySQL.scalar.await('SELECT 1 FROM player_vehicles WHERE citizenid = ? AND plate = ?', { player.PlayerData.citizenid, plate })
    if not owned then return { error = 'That is not your vehicle.' } end

    local wanted = TrimText(plate)
    for _, vehicle in ipairs(GetAllVehicles()) do
        if TrimText(GetVehicleNumberPlateText(vehicle)) == wanted then
            local coords = GetEntityCoords(vehicle)
            return { x = coords.x, y = coords.y }
        end
    end
    return { error = 'Your vehicle could not be located.' }
end)
