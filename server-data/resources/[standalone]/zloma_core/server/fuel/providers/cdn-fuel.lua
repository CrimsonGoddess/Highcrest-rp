ZlomaCore.RegisterServerFuel('cdn-fuel',
    function(vehicle) return exports['cdn-fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['cdn-fuel']:SetFuel(vehicle, fuelLevel) end
)