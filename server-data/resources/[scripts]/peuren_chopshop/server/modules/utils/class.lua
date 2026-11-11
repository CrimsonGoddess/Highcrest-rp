Utils = {
    ---Generates random location coordinates for vehicle key
    ---@param data table
    ---@return vector3
    GenerateKeyPos = function(data)
        return data[math.random(1, #data)]
    end,

    ---Generates random drop off location
    ---@return table
    GenerateDropOff = function()
        math.randomseed(os.time())
        return Config.DropoffLocations[math.random(1, #Config.DropoffLocations)]
    end,

    ---Generates random number string
    ---@param length number
    ---@return string
    GetRandomNumber = function(length)
        local NumberCharset = {}
        for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

        Citizen.Wait(1)
        math.randomseed(os.time())
        if length > 0 then
            return Utils.GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
        else
            return ''
        end
    end,
    
    ---Generates random letter string
    ---@param length number
    ---@return string
    GetRandomLetter = function(length)
        local Charset = {}
        for i = 65,  90 do table.insert(Charset, string.char(i)) end
        for i = 97, 122 do table.insert(Charset, string.char(i)) end

        Citizen.Wait(1)
        math.randomseed(os.time())
        if length > 0 then
            return Utils.GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
        else
            return ''
        end
    end,

    ---Spawns vehicle
    ---@param data table
    ---@return table | nil
    SpawnVehicle = function(data)
        local vehicle = {}

        local veh = CreateVehicleServerSetter(data.model, data.type, data.vehicle.pos.x, data.vehicle.pos.y, data.vehicle.pos.z, data.vehicle.heading)
        if not DoesEntityExist(veh) then
            return print("[^1ERROR^7] Unfortunately, this vehicle has not spawned")
        end

        local plate = string.upper(Utils.GetRandomLetter(4) .. '-' ..  Utils.GetRandomNumber(4))
        SetVehicleNumberPlateText(veh, plate)
        Config.SetVehicleAtributes(veh, plate)

        vehicle = { 
            entity = veh,
            plate = plate,
            netId = NetworkGetNetworkIdFromEntity(veh) 
        }

        return vehicle
    end,

    RequiredItems = function(dealer)
        if Config.Dealers[dealer].RequiredItems then 
            local passed, length = 0, 0
    
            for item, amount in pairs(Config.Dealers[dealer].RequiredItems) do 
                if lib.Inventory.HasPlayerItem(source, item, amount) then 
                    passed += 1
                end
                length += 1
            end
            if passed < length then return false end
        end
        return true
    end
}