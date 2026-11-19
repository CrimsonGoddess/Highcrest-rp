ZlomaCore.RegisterServerFuel('ND_Fuel', nil,
    function(vehicle, fuelLevel) Entity(vehicle).state:set('fuel', fuelLevel, true) end
)