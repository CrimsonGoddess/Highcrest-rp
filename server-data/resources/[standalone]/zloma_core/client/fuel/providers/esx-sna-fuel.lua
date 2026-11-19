ZlomaCore.RegisterClientFuel('esx-sna-fuel',
    function(vehicle) return exports['esx-sna-fuel']:GetFuel(vehicle) end,
    function(vehicle, fuelLevel) exports['esx-sna-fuel']:SetFuel(vehicle, fuelLevel) end
)