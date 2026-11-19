ZlomaCore.RegisterServerFuel('ps-fuel',
    function(vehicle) return exports['ps-fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['ps-fuel']:SetFuel(vehicle, fuelLevel) end
)