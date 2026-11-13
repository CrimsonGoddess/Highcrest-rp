local function _dbg(...)
    if not Config.Debug then return end
    lib.print.info(...)
end

Utils = {}

function Utils.dbg(...)
    _dbg(...)
end

function Utils.vecToTable(v)
    return { x = v.x + 0.0, y = v.y + 0.0, z = v.z + 0.0 }
end

function Utils.tableToVec(t)
    return vec3(t.x + 0.0, t.y + 0.0, t.z + 0.0)
end

function Utils.dist(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Utils.ensureDir(path)
    -- FiveM doesn't provide mkdir; directory is created by ensuring a file exists in it.
    -- We keep this utility in case we ever need it; safe no-op.
    return path
end

return Utils
