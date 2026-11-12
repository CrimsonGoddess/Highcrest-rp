-- Highcrest: every garage lists all of a player's cars and where they are.
--   parked here         -> take it out (free)
--   at another garage   -> Config.transferFee to bring it here
--   out in the city     -> Config.recoverFee to bring it back (the car in the world is removed)
--   impounded by police -> collected at the impound lot as before

local function vehicleTypeOf(modelName)
    local vehicle = VEHICLES[modelName]
    if not vehicle then return VehicleType.CAR end -- addon cars missing from the vehicle list count as cars
    if vehicle.category == 'helicopters' or vehicle.category == 'planes' then return VehicleType.AIR end
    if vehicle.category == 'boats' then return VehicleType.SEA end
    return VehicleType.CAR
end

local function canUse(player, garage)
    if not player or not garage or garage.type == GarageType.DEPOT then return false end
    if garage.groups and not exports.qbx_core:HasPrimaryGroup(player.PlayerData.source, garage.groups) then return false end
    if garage.canAccess ~= nil and not garage.canAccess(player.PlayerData.source) then return false end
    return true
end

local function normalPlate(plate)
    return (plate or ''):match('^%s*(.-)%s*$'):upper()
end

-- The car's entity if it's spawned somewhere in the world.
local function worldVehicle(plate)
    plate = normalPlate(plate)
    for _, vehicle in ipairs(GetAllVehicles()) do
        if normalPlate(GetVehicleNumberPlateText(vehicle)) == plate then return vehicle end
    end
end

local function isOccupied(vehicle)
    for seat = -1, 6 do
        if GetPedInVehicleSeat(vehicle, seat) ~= 0 then return true end
    end
    return false
end

-- Highcrest VIP: the freeTransfers perk makes moving a car between garages free.
local function vipPerk(source, perk)
    return source and GetResourceState('highcrest_vip') == 'started' and exports.highcrest_vip:HasPerk(source, perk) == true
end

local function feeFor(vehicle, garageName, source)
    if vehicle.state == VehicleState.GARAGED then
        if vehicle.garage == garageName then return 0 end
        return vipPerk(source, 'freeTransfers') and 0 or Config.transferFee
    elseif vehicle.state == VehicleState.OUT then
        return Config.recoverFee
    end
end

lib.callback.register('qbx_garages:server:hcVehicles', function(source, garageName)
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]
    if not canUse(player, garage) then return end
    local list = {}
    for _, vehicle in pairs(exports.qbx_vehicles:GetPlayerVehicles({ citizenid = player.PlayerData.citizenid }) or {}) do
        if vehicleTypeOf(vehicle.modelName) == garage.vehicleType and type(vehicle.props) == 'table' then
            local entity = worldVehicle(vehicle.props.plate)
            local where
            if vehicle.state == VehicleState.GARAGED then
                where = vehicle.garage == garageName and 'here' or 'garage'
            elseif vehicle.state == VehicleState.OUT then
                where = 'out'
            else
                where = 'impound'
            end
            list[#list + 1] = {
                id = vehicle.id, modelName = vehicle.modelName, plate = vehicle.props.plate, props = vehicle.props,
                where = where, garageLabel = Garages[vehicle.garage] and Garages[vehicle.garage].label or vehicle.garage,
                fee = feeFor(vehicle, garageName, source), inWorld = entity ~= nil, occupied = entity ~= nil and isOccupied(entity),
            }
        end
    end
    return list
end)

-- Pay the fee and move the car into this garage. The client then takes it out as normal.
lib.callback.register('qbx_garages:server:hcBringHere', function(source, vehicleId, garageName, accessPointIndex)
    local player = exports.qbx_core:GetPlayer(source)
    local garage = Garages[garageName]
    if not canUse(player, garage) then return false, 'You can\'t use this garage.' end
    local accessPoint = garage.accessPoints[tonumber(accessPointIndex) or 0]
    if not accessPoint or #(GetEntityCoords(GetPlayerPed(source)) - accessPoint.coords.xyz) > 3.0 then
        return false, 'Stand at the garage.'
    end

    local vehicle = exports.qbx_vehicles:GetPlayerVehicle(tonumber(vehicleId) or 0)
    if not vehicle or vehicle.citizenid ~= player.PlayerData.citizenid then return false, 'That isn\'t your car.' end
    if vehicleTypeOf(vehicle.modelName) ~= garage.vehicleType then return false, 'That vehicle can\'t be parked here.' end
    local fee = feeFor(vehicle, garageName, source)
    if not fee then return false, 'This car was impounded by the police. Collect it at the impound lot.' end
    if fee == 0 then return true end

    local spawnCoords = (accessPoint.spawn or accessPoint.coords).xyz
    if Config.distanceCheck and lib.getClosestVehicle(spawnCoords, Config.distanceCheck, false) then
        return false, 'The parking spot is blocked. Move the car that\'s in the way first.'
    end

    local entity = vehicle.state == VehicleState.OUT and worldVehicle(vehicle.props.plate) or nil
    if entity and isOccupied(entity) then return false, 'Someone is in that car right now.' end

    local paid = false
    if player.Functions.GetMoney('bank') >= fee then
        paid = player.Functions.RemoveMoney('bank', fee, vehicle.state == VehicleState.OUT and 'vehicle-recovery' or 'garage-transfer')
    elseif player.Functions.GetMoney('cash') >= fee then
        paid = player.Functions.RemoveMoney('cash', fee, vehicle.state == VehicleState.OUT and 'vehicle-recovery' or 'garage-transfer')
    end
    if not paid then return false, ('You need $%s.'):format(lib.math.groupdigits(fee)) end

    if entity then exports.qbx_core:DeleteVehicle(entity) end
    local ok = exports.qbx_garages:SetVehicleGarage(vehicle.id, garageName)
    if not ok then
        player.Functions.AddMoney('bank', fee, 'garage-transfer-refund')
        return false, 'Something went wrong. You were refunded.'
    end
    return true
end)
