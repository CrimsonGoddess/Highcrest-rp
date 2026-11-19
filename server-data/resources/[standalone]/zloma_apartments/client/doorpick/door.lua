-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Where the door lockpick's lock sits on an apartment door.
-- Lock space (from tr_minigames, TR Scripts): origin at the plug's face, +Y into the door, +Z up.
local cfg = Config.DoorPick

DoorPick = DoorPick or {}
DoorPick.liveFits = {} -- being tuned with /doorpick_rig, until a restart

local fits = {}
for model, fit in pairs(cfg.doorFits) do
    fits[type(model) == 'string' and joaat(model) or model] = fit
end

---@return table fit, string source
function DoorPick.fit(model)
    if DoorPick.liveFits[model] then return DoorPick.liveFits[model], 'live' end
    if fits[model] then return fits[model], 'config' end
    return cfg.rig, 'default'
end

-- The lock on the side of the door the player stands on, near the free edge.
---@return vector3? offset, number pitch, number yaw
function DoorPick.placement(door, from)
    if not door or not DoesEntityExist(door) then return end
    local model = GetEntityModel(door)
    local fit = DoorPick.fit(model)
    local min, max = GetModelDimensions(model)
    local me = GetOffsetFromEntityGivenWorldCoords(door, from.x, from.y, from.z)

    local x = math.abs(max.x) >= math.abs(min.x) and max.x - fit.inset or min.x + fit.inset
    local z = math.min(min.z + fit.height, max.z - 0.05)
    if me.y < (min.y + max.y) / 2 then
        return vec3(x, min.y - fit.out, z), 0.0, 0.0
    end
    return vec3(x, max.y + fit.out, z), 0.0, 180.0
end

-- 5 mm a press, 1 mm with Shift held (dev mode, while picking)
local NUDGE = {
    { 174, 'inset', 1 }, { 175, 'inset', -1 }, -- arrow left / right: along the door
    { 172, 'height', 1 }, { 173, 'height', -1 }, -- arrow up / down
    { 44, 'out', 1 }, { 38, 'out', -1 },        -- Q / E: out of / into the door
}

local function mm(v) return math.floor(v * 1000 + 0.5) / 1000 end

function DoorPick.nudged(model)
    local step = IsDisabledControlPressed(0, 21) and 0.001 or 0.005
    for _, n in ipairs(NUDGE) do
        if IsDisabledControlJustPressed(0, n[1]) then
            local fit = DoorPick.fit(model)
            local moved = { inset = fit.inset, height = fit.height, out = fit.out }
            moved[n[2]] = mm(moved[n[2]] + n[3] * step)
            return moved
        end
    end
end

function DoorPick.fitLine(model)
    local fit, source = DoorPick.fit(model)
    return ('[%d] = { inset = %.3f, height = %.3f, out = %.3f },'):format(model, fit.inset, fit.height, fit.out), source
end
