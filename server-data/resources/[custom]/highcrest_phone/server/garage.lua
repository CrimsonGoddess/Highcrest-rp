-- Garage: a character's vehicles, plus a paid valet that brings a stored vehicle to the player.
local STATE_LABELS = { [0] = 'Out', [1] = 'In garage', [2] = 'Impounded' }
local GARAGED = 1
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
    return { vehicles = vehicles, valetFee = Config.valet.fee }
end)

local function findSpawnedPlate(plate)
    local wanted = TrimText(plate)
    for _, vehicle in ipairs(GetAllVehicles()) do
        if TrimText(GetVehicleNumberPlateText(vehicle)) == wanted then return vehicle end
    end
end

-- Only finds a vehicle the player owns, using the server's own list of spawned vehicles.
lib.callback.register('highcrest_phone:server:garageLocate', function(source, plate)
    local player = GetPhoneOwner(source)
    if not player or type(plate) ~= 'string' then return end
    if IsRateLimited(source, 'garageLocate', 1000) then return { error = 'Hold on a moment.' } end

    local owned = MySQL.scalar.await('SELECT 1 FROM player_vehicles WHERE citizenid = ? AND plate = ?', { player.PlayerData.citizenid, plate })
    if not owned then return { error = 'That is not your vehicle.' } end

    local vehicle = findSpawnedPlate(plate)
    if vehicle then
        local coords = GetEntityCoords(vehicle)
        return { x = coords.x, y = coords.y }
    end
    return { error = 'Your vehicle could not be located.' }
end)

-- Valet

local valetBusy = {}
local valetLast = {}

local function chargeValet(player)
    local fee = Config.valet.fee
    if fee <= 0 then return 'free' end
    for _, account in ipairs({ 'cash', 'bank' }) do
        if player.PlayerData.money[account] >= fee and player.Functions.RemoveMoney(account, fee, 'phone-valet') then
            return account
        end
    end
end

local function refundValet(player, account)
    if account and account ~= 'free' then
        player.Functions.AddMoney(account, Config.valet.fee, 'phone-valet-refund')
    end
end

-- The client picks a road near itself to start from. The server only accepts one at a sensible distance.
local function bringVehicle(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' or type(data.plate) ~= 'string' then return end
    local x, y, z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
    local heading = tonumber(data.heading) or 0.0
    if not (x and y and z) then return { error = 'There is no road nearby for the valet to use.' } end

    local now = os.time()
    if valetLast[source] and now - valetLast[source] < Config.valet.cooldownSeconds then
        return { error = 'A valet was just sent. Try again in a minute.' }
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local distance = #(vec2(playerCoords.x, playerCoords.y) - vec2(x, y))
    local limits = Config.valet.spawnDistance
    if distance < limits.min * 0.5 or distance > limits.max * 1.5 then
        return { error = 'There is no road nearby for the valet to use.' }
    end

    local citizenid = player.PlayerData.citizenid
    local id = MySQL.scalar.await('SELECT id FROM player_vehicles WHERE citizenid = ? AND plate = ? AND state = ?', {
        citizenid, data.plate, GARAGED,
    })
    if not id then return { error = 'Only vehicles in a garage can be brought to you.' } end

    local vehicle = exports.qbx_vehicles:GetPlayerVehicle(id, { citizenid = citizenid })
    if not vehicle or type(vehicle.props) ~= 'table' or type(vehicle.props.model) ~= 'number' then
        return { error = 'That vehicle could not be found.' }
    end
    if findSpawnedPlate(data.plate) then return { error = 'That vehicle is already out.' } end

    local paidFrom = chargeValet(player)
    if not paidFrom then return { error = ('The valet costs $%d.'):format(Config.valet.fee) } end

    vehicle.props.lockState = 1
    local ok, netId, entity = pcall(qbx.spawnVehicle, {
        spawnSource = vec4(x, y, z, heading),
        model = vehicle.props.model,
        props = vehicle.props,
        bucket = GetPlayerRoutingBucket(source),
    })
    if not ok or not netId or not entity or entity == 0 or not DoesEntityExist(entity) then
        if not ok then lib.print.error(netId) end
        refundValet(player, paidFrom)
        return { error = 'The valet could not get your vehicle out. You were not charged.' }
    end

    Entity(entity).state:set('vehicleid', id, false)
    if not exports.qbx_vehicles:SaveVehicle(entity, { state = 0, depotPrice = 0 }) then
        exports.qbx_core:DeleteVehicle(entity)
        refundValet(player, paidFrom)
        return { error = 'The valet could not get your vehicle out. You were not charged.' }
    end

    valetLast[source] = now
    TriggerClientEvent('vehiclekeys:client:SetOwner', source, vehicle.props.plate)
    TriggerEvent('qbx_garages:server:vehicleSpawned', entity)
    return { netId = netId, x = x, y = y }
end

lib.callback.register('highcrest_phone:server:garageValet', function(source, data)
    if valetBusy[source] then return { error = 'Hold on a moment.' } end
    valetBusy[source] = true
    local ok, result = pcall(bringVehicle, source, data)
    valetBusy[source] = nil
    if not ok then
        lib.print.error(result)
        return { error = 'The valet could not get your vehicle out.' }
    end
    return result
end)

AddEventHandler('playerDropped', function()
    valetLast[source] = nil
end)
