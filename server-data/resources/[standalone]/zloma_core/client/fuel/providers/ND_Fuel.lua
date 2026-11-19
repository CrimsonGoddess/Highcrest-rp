ZlomaCore.RegisterClientFuel('ND_Fuel',
    function(vehicle) return DecorGetFloat(vehicle, '_FUEL_LEVEL') or GetVehicleFuelLevel(vehicle) end,
    function(vehicle, fuelLevel)
        DecorSetFloat(vehicle, '_FUEL_LEVEL', fuelLevel + 0.0)
        SetVehicleFuelLevel(vehicle, fuelLevel + 0.0)
    end
)