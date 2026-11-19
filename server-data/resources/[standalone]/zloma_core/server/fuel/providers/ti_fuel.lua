ZlomaCore.RegisterServerFuel('ti_fuel',
    function(vehicle) return exports['ti_fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['ti_fuel']:SetFuel(vehicle, fuelLevel) end
)