-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- State-changing callbacks run one at a time. A request that arrives while
-- another runs waits up to two seconds instead of failing.
local busy = false

local function run(name, handler, src, data)
    local waited = 0
    while busy and waited < 2000 do Wait(10); waited = waited + 10 end
    if busy then return { success = false, error = _L('error_busy') } end
    busy = true
    local ok, result = pcall(handler, src, data)
    busy = false
    if not ok then
        print(('^1[zloma_apartments]^0 %s failed: %s'):format(name, result))
        return { success = false, error = _L('error_generic') }
    end
    return result
end

function Mutation(name, handler)
    lib.callback.register('zloma_apartments:' .. name, function(src, data)
        if not DB.ready then return { success = false, error = _L('error_busy') } end
        return run(name, handler, src, data)
    end)
end

function AdminMutation(name, handler)
    lib.callback.register('zloma_apartments:admin:' .. name, function(src, data)
        if not Bridge.isAdmin(src) then return { success = false, error = _L('error_no_permission') } end
        if not DB.ready or type(data) ~= 'table' then return { success = false, error = _L('error_invalid') } end
        return run('admin:' .. name, handler, src, data)
    end)
end

function NearPoint(src, p, distance)
    local ped = GetPlayerPed(src)
    if not p or ped == 0 then return false end
    local c = GetEntityCoords(ped)
    local dx, dy, dz = c.x - p.x, c.y - p.y, c.z - p.z
    return dx * dx + dy * dy + dz * dz <= distance * distance
end

function Fail(key, ...) return { success = false, error = _L(key, ...) } end

-- Calls a function from server/customization.lua without letting it break us.
function Hook(name, ...)
    local fn = Customization and Customization[name]
    if type(fn) ~= 'function' then return end
    local ok, err = pcall(fn, ...)
    if not ok then print(('^1[zloma_apartments]^0 Customization.%s: %s'):format(name, err)) end
end
