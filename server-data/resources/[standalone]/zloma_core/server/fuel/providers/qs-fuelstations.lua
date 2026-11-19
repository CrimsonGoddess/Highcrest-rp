ZlomaCore.RegisterServerFuel('qs-fuelstations',
    function(vehicle) return exports['qs-fuelstations']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['qs-fuelstations']:SetFuel(vehicle, fuelLevel) end
)