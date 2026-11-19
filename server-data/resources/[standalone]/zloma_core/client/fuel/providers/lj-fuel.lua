ZlomaCore.RegisterClientFuel('lj-fuel',
    function(vehicle) return exports['lj-fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['lj-fuel']:SetFuel(vehicle, fuelLevel) end
)