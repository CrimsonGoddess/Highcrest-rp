-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Client calls into zloma_core (notifications and target system).
ClientBridge = {}

function ClientBridge.notify(message, kind, duration)
    local ok = pcall(function() exports.zloma_core:Notify(message, kind or 'info', duration or 5000) end)
    if not ok then lib.notify({ description = message, type = kind or 'inform' }) end
end

function ClientBridge.addEntity(entity, options)
    return pcall(function() exports.zloma_core:AddEntity(entity, options) end)
end

function ClientBridge.removeEntity(entity, names)
    pcall(function() exports.zloma_core:RemoveEntity(entity, names) end)
end

function ToVec3(p) return vec3(p.x, p.y, p.z) end

-- Shared client state, filled by the server on join and on every change.
ClientState = { ready = false, hotels = {}, doors = {}, sets = {}, placements = {} }

local listeners = {}
function OnHotelsChanged(fn) listeners[#listeners + 1] = fn end

local function applyHotels(hotels)
    ClientState.hotels = hotels or {}
    Hotels.defs = ClientState.hotels
    for _, fn in ipairs(listeners) do
        local ok, err = pcall(fn, ClientState.hotels)
        if not ok then print(('^1[zloma_apartments]^0 hotel listener: %s'):format(err)) end
    end
end

RegisterNetEvent('zloma_apartments:client:hotels', function(hotels)
    applyHotels(hotels)
end)

CreateThread(function()
    local data
    while not data do
        data = lib.callback.await('zloma_apartments:bootstrap', false)
        if not data then Wait(2000) end
    end
    ClientState.sets, ClientState.placements = data.sets or {}, data.placements or {}
    ClientState.doors = data.doors or {}
    ClientState.lockpick = data.lockpick or {}
    ClientState.ready = true
    applyHotels(data.hotels)
    TriggerEvent('zloma_apartments:client:furnitureLoaded')
end)
