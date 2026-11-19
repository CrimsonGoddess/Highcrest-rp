ZlomaCore.RegisterClientFuel('x-fuel',
    function(vehicle) return exports['x-fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['x-fuel']:SetFuel(vehicle, fuelLevel) end
)