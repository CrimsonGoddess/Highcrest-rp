ZlomaCore.RegisterServerFuel('okokGasStation',
    function(vehicle) return exports['okokGasStation']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['okokGasStation']:SetFuel(vehicle, fuelLevel) end
)