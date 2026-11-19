ZlomaCore.RegisterClientFuel('LegacyFuel',
    function(vehicle) return exports['LegacyFuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['LegacyFuel']:SetFuel(vehicle, fuelLevel) end
)