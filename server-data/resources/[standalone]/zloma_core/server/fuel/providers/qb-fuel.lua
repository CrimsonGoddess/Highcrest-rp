ZlomaCore.RegisterServerFuel('qb-fuel',
    function(vehicle) return Entity(vehicle).state.fuel or 100 end,
    function(vehicle, fuelLevel) Entity(vehicle).state.fuel = fuelLevel end
)