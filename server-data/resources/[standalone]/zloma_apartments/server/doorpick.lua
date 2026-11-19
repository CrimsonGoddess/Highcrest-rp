-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- The door lockpick's lock. server/security.lua decides who may pick which
-- door (DoorPickAuthorize) and asks afterwards whether it was really picked
-- (DoorPickConsume); this file holds the lock and checks every click.
-- The client learns a wafer's depth only when the player feels it bind, never before.
-- From tr_minigames/minigames/lockpick/server/main.lua (TR Scripts, GPL-3.0),
-- changed for apartment doors and ox_lib callbacks.

local cfg = Config.DoorPick
local Rig = DoorPick.rig

local POSITIONS = #Rig.wafers
local SET_SLACK = 150 -- µm the client's reading may be off (network, rounding)
local MAX_LOCKS = 2000
local AUTHORIZE_SECONDS = 30
local RESULT_SECONDS = 30

local locks = {}      ---@type table<string, table> by door: the same door keeps the same lock
local lockCount = 0
local sessions = {}   ---@type table<integer, table>
local authorized = {} ---@type table<integer, { key: string, coords: vector3, tier: table, at: integer }>
local picked = {}     ---@type table<integer, integer> when the player opened their lock

local function shuffled(list)
    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
    return list
end

local function newLock(tier)
    local positions = {}
    for i = 1, POSITIONS do positions[i] = i end
    shuffled(positions)

    local lock = { tier = tier, signature = ('%d:%s:%s'):format(tier.wafers, tier.overset, tier.speed), present = {}, depth = {}, order = {}, used = os.time() }
    for i = 1, math.min(tier.wafers, POSITIONS) do
        local pos = positions[i]
        lock.present[pos] = true
        lock.depth[pos] = math.random(Rig.depths)
        lock.order[i] = pos -- positions are shuffled, so this is a random binding order
    end
    return lock
end

-- The same door keeps the same lock until it is upgraded or the server restarts.
local function lockFor(key, tier)
    local lock = locks[key]
    if not lock or lock.signature ~= ('%d:%s:%s'):format(tier.wafers, tier.overset, tier.speed) then
        if not lock and lockCount >= MAX_LOCKS then locks, lockCount = {}, 0 end
        if not lock then lockCount = lockCount + 1 end
        lock = newLock(tier)
        locks[key] = lock
    end
    lock.used = os.time()
    return lock
end

local function binding(s)
    for _, pos in ipairs(s.lock.order) do
        if not s.set[pos] then return pos end
    end
end

local function near(src, coords)
    local ped = GetPlayerPed(src)
    return ped ~= 0 and #(GetEntityCoords(ped) - coords) <= cfg.reach
end

-- Ends the attempt when it's no longer valid.
local function current(src)
    local s = sessions[src]
    if not s then return nil, 'no_session' end

    local reason
    if os.time() - s.started > cfg.timeLimit then
        reason = 'expired'
    elseif not near(src, s.coords) then
        reason = 'moved_away'
    end

    if reason then
        sessions[src] = nil
        return nil, reason
    end

    return s
end

-- A new grip starts from scratch, so requests from an earlier grip are stale.
---@return boolean fresh
local function grip(s, epoch)
    if epoch == 0 then return true end
    if epoch < s.epoch then return false end
    if epoch > s.epoch then
        s.epoch, s.set, s.jammed = epoch, {}, nil
    end
    return true
end

local function number(v, lo, hi) return type(v) == 'number' and v == v and v >= lo and v <= hi end

local function validTier(tier)
    return type(tier) == 'table' and math.type(tier.wafers) == 'integer' and tier.wafers >= 1 and tier.wafers <= POSITIONS
        and number(tier.overset, 0.05, 5.0) and number(tier.speed, 0.1, 20.0)
end

-- server/security.lua: this player may pick this door now. tier: { wafers, overset, speed }.
function DoorPickAuthorize(src, key, coords, tier)
    if not validTier(tier) then return false end
    authorized[src] = {
        key = key,
        coords = vector3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0),
        tier = tier,
        at = os.time(),
    }
    picked[src] = nil
    return true
end

-- server/security.lua: did this player just pick their lock? Answers once.
function DoorPickConsume(src)
    local at = picked[src]
    picked[src] = nil
    return at ~= nil and os.time() - at <= RESULT_SECONDS
end

-- ox_lib callbacks with argument checks and a rate limit per player.
local calls = {}
local function register(name, limit, check, handler)
    lib.callback.register('zloma_apartments:dp_' .. name, function(src, ...)
        local now = GetGameTimer()
        local key = src .. ':' .. name
        local window = calls[key]
        if not window or now - window.at > 1000 then
            window = { at = now, count = 0 }
            calls[key] = window
        end
        window.count = window.count + 1
        if window.count > limit then return nil end
        if check and not check(...) then return false, 'try_again' end
        return handler(src, ...)
    end)
end

local function position(v) return math.type(v) == 'integer' and v >= 1 and v <= POSITIONS end
local function epoch(v) return math.type(v) == 'integer' and v >= 0 and v <= 100000 end

register('start', 1, nil, function(src)
    if sessions[src] and current(src) then return false, 'busy' end
    local auth = authorized[src]
    authorized[src] = nil
    if not auth or os.time() - auth.at > AUTHORIZE_SECONDS then return false, 'no_session' end
    if not near(src, auth.coords) then return false, 'too_far' end

    local lock = lockFor(auth.key, auth.tier)
    sessions[src] = {
        coords = auth.coords,
        lock = lock,
        started = os.time(),
        strikes = 0,
        epoch = 0,
        set = {},
    }

    return true, {
        maxStrikes = cfg.maxStrikes,
        overset = lock.tier.overset / 1000, -- metres
        speed = lock.tier.speed / 1000,     -- metres per second
    }
end)

-- Answers 'empty', 'spring', 'binding' (with its depth), 'set' (with its depth) or 'stuck'.
register('probe', 12, function(pos, e) return position(pos) and epoch(e) end, function(src, pos, epoch)
    local s, reason = current(src)
    if not s then return false, reason end
    if not grip(s, epoch) then return 'stale' end

    local lock = s.lock
    if not lock.present[pos] then return 'empty' end
    if epoch == 0 then return 'spring' end
    if s.jammed == pos then return 'stuck', lock.depth[pos] end
    if s.set[pos] then return 'set', lock.depth[pos] end
    if not s.jammed and binding(s) == pos then return 'binding', lock.depth[pos] end
    return 'spring'
end)

-- lift: µm
register('set', 4, function(pos, e, lift) return position(pos) and epoch(e) and math.type(lift) == 'integer' and lift >= 0 and lift <= 20000 end,
function(src, pos, epoch, lift)
    local s, reason = current(src)
    if not s then return false, reason end
    if epoch == 0 or epoch ~= s.epoch or s.jammed or binding(s) ~= pos then return 'slipped' end

    local line = math.floor(s.lock.depth[pos] * Rig.depthStep * 1e6 + 0.5)
    if lift < line - SET_SLACK or lift > line + s.lock.tier.overset * 1000 + SET_SLACK then return 'slipped' end

    s.set[pos] = true
    if binding(s) then return 'set' end

    sessions[src] = nil
    if os.time() - s.started < cfg.minTime then
        print(('^3[zloma_apartments]^0 player %s picked a door lock faster than possible'):format(src))
        return false, 'try_again'
    end

    picked[src] = os.time()
    return 'open', false
end)

register('overset', 4, function(pos, e) return position(pos) and epoch(e) end, function(src, pos, epoch)
    local s, reason = current(src)
    if not s then return false, reason end
    if epoch == 0 or epoch ~= s.epoch or not s.lock.present[pos] then return 'nothing' end
    if not (s.set[pos] or binding(s) == pos) then return 'nothing' end

    s.set[pos] = nil
    s.jammed = pos
    return 'jammed'
end)

-- Only ever hurts the player, so the client may report it. The item is taken
-- in server/security.lua (Config.Doors.Lockpick.RemoveItemOnFail).
register('bend', 2, nil, function(src)
    local s, reason = current(src)
    if not s then return false, reason end

    s.strikes = s.strikes + 1
    if s.strikes >= cfg.maxStrikes then
        sessions[src] = nil
        return 'snapped', s.strikes, false
    end
    return 'bent', s.strikes
end)

register('cancel', 2, nil, function(src)
    sessions[src] = nil
    return true
end)

AddEventHandler('playerDropped', function()
    sessions[source], authorized[source], picked[source] = nil, nil, nil
    for _, name in ipairs({ 'start', 'probe', 'set', 'overset', 'bend', 'cancel' }) do calls[source .. ':' .. name] = nil end
end)
