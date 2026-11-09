Locations = {
    Data = {}, 
    
    GetAvailableVehicles = function(id, dealer)
        local rep = Reputation.Get(id, dealer)
        if not rep then return end 

        local vehicles = {}

        for vehicle, minRep in pairs(Config.Dealers[dealer].AvailableVehicleClasses) do
            if minRep <= rep.Level then
                vehicles[vehicle] = true
            end
        end

        return vehicles
    end,

    GenerateLocations = function(id, dealer)
        local vehicle, chop = {}, {}
        local aVehicles = Locations.GetAvailableVehicles(id, dealer)

        if not aVehicles then return false, false end
        if not Locations.Data['chop'] then Locations.Data['chop'] = {} end 
        if not Locations.Data['vehicle'] then Locations.Data['vehicle'] = {} end 

        for k,v in pairs(Config.DropoffLocations) do 
            if not Locations.Data['chop'][k] then 
                chop[#chop + 1] = { id = k, data = v }
            end
        end

        for k,v in pairs(Config.Locations) do 
            if not Locations.Data['vehicle'][k] and aVehicles[v.class] then
                vehicle[#vehicle + 1] = { id = k, data = v }
            end
        end

        if not next(vehicle) or not next(chop) then return false, false end 

        math.randomseed(os.time())
        local rndChop = chop[math.random(1, #chop)]
        local rndVeh = vehicle[math.random(1, #vehicle)]

        Locations.Data['chop'][rndChop.id] = rndChop.data
        Locations.Data['vehicle'][rndVeh.id] = rndVeh.data

        return rndVeh, rndChop
    end,

    Remove = function(type, id)
        if not type or not id then return end 
        if not Locations.Data[type] then return end
        Locations.Data[type][id] = nil
    end
}