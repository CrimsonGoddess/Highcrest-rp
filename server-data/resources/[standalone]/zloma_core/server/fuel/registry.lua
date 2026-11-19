ZlomaCore.ServerFuelAdapters = ZlomaCore.ServerFuelAdapters or {}

function ZlomaCore.RegisterServerFuel(provider, getFuel, setFuel)
    local adapter = { get = getFuel, set = setFuel }
    ZlomaCore.ServerFuelAdapters[provider] = adapter
    ZlomaCore.RegisterAdapter('server', 'Fuel', provider, adapter)
end
