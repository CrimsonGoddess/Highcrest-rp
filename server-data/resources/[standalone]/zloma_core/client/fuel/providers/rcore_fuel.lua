ZlomaCore.RegisterClientFuel('rcore_fuel',
    function(vehicle) return exports['rcore_fuel']:GetVehicleFuelPercentage(vehicle) end,
    function(vehicle, fuelLevel) exports['rcore_fuel']:SetVehicleFuel(vehicle, fuelLevel) end
)