ZlomaCore.RegisterClientFuel('ox_fuel',
    function(vehicle) return Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle) end,
    function(vehicle, fuelLevel)
        -- Strict mode rejects even non-replicated writes on network entities.
        -- Server fuel exports own their state; only local previews use this bag.
        if not NetworkGetEntityIsNetworked(vehicle) then
            Entity(vehicle).state:set('fuel', fuelLevel, false)
        end
        SetVehicleFuelLevel(vehicle, fuelLevel + 0.0)
    end
)
