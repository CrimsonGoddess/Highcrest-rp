ZlomaCore.FuelAdapters = ZlomaCore.FuelAdapters or {}

function ZlomaCore.RegisterClientFuel(provider, getFuel, setFuel)
    local adapter = { get = getFuel, set = setFuel }
    ZlomaCore.FuelAdapters[provider] = adapter
    ZlomaCore.RegisterAdapter('client', 'Fuel', provider, adapter)
end
