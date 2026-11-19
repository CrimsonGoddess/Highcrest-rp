ZlomaCore.RegisterClientFuel('qb-fuel',
    function(vehicle) return exports['qb-fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['qb-fuel']:SetFuel(vehicle, fuelLevel) end
)