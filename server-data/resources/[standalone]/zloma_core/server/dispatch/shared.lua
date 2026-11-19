-- Shared dispatch helpers and adapter registry.
ZlomaCore.DispatchAdapters = ZlomaCore.DispatchAdapters or {}
setmetatable(ZlomaCore.DispatchAdapters, {
    __newindex = function(adapters, provider, adapter)
        rawset(adapters, provider, adapter)
        ZlomaCore.RegisterAdapter('server', 'Dispatch', provider, { send = adapter })
    end
})
ZlomaCore.Dispatch = ZlomaCore.Dispatch or {}

function ZlomaCore.Dispatch.NormalizeJobs(job)
    if type(job) == 'table' and #job > 0 then return job end
    if type(job) == 'string' and job ~= '' then return { job } end
    return { 'police' }
end

function ZlomaCore.Dispatch.GetCoords(source, coords)
    if coords then return coords end

    local playerPed = GetPlayerPed(source)
    if playerPed and playerPed > 0 then return GetEntityCoords(playerPed) end
    return vec3(0.0, 0.0, 0.0)
end

local streetLookupUnavailableWarned = false

local function fallbackStreet(coords)
    return ('GPS: %.1f, %.1f'):format(coords.x or 0.0, coords.y or 0.0)
end

function ZlomaCore.Dispatch.GetStreet(coords)
    if type(GetStreetNameAtCoord) ~= 'function' or type(GetStreetNameFromHashKey) ~= 'function' then
        if not streetLookupUnavailableWarned then
            streetLookupUnavailableWarned = true
            ZlomaCore.Debug('Dispatch street lookup native is unavailable on the server; using coordinate fallback labels.')
        end
        return fallbackStreet(coords)
    end

    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    if streetHash and streetHash ~= 0 then
        local streetName = GetStreetNameFromHashKey(streetHash)
        if streetName and streetName ~= '' then return streetName end
    end

    return fallbackStreet(coords)
end
