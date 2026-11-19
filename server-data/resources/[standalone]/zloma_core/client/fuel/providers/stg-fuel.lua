ZlomaCore.RegisterClientFuel('stg-fuel',
    function(vehicle) return exports['stg-fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['stg-fuel']:SetFuel(vehicle, fuelLevel) end
)