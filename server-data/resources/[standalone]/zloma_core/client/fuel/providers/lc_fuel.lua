ZlomaCore.RegisterClientFuel('lc_fuel',
    function(vehicle) return exports['lc_fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['lc_fuel']:SetFuel(vehicle, fuelLevel) end
)