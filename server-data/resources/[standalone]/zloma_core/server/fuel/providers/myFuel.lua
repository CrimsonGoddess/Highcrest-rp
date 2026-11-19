ZlomaCore.RegisterServerFuel('myFuel',
    function(vehicle) return exports['myFuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['myFuel']:SetFuel(vehicle, fuelLevel) end
)