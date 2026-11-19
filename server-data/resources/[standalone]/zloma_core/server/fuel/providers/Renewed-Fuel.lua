ZlomaCore.RegisterServerFuel('Renewed-Fuel',
    function(vehicle) return exports['Renewed-Fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['Renewed-Fuel']:SetFuel(vehicle, fuelLevel) end
)