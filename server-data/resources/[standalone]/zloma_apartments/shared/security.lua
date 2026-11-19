-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Lock levels and lockpick minigames, shared by server and client.
-- The server validates config.lua + config_minigame.lua once at start and
-- sends the resulting flags to clients; clients never trust their own copy.
Security = { enabled = false, lockpick = { door = false, safe = false }, alarms = { door = {}, safe = {} }, errors = {} }

local KINDS = { door = 'Door', safe = 'Safe' }
Security.MAX_LEVELS = 10

function Security.levelsConfig(kind)
    return Config.Security and Config.Security[KINDS[kind]] or nil
end

local function gameOf(m)
    if type(m) ~= 'table' or type(m.game) ~= 'string' or type(m.difficulty) ~= 'string' then return nil end
    local game = MinigameConfig and MinigameConfig[m.game]
    if type(game) ~= 'table' or type(game.run) ~= 'function' or type(game.difficulties) ~= 'table' then return nil end
    local settings = game.difficulties[m.difficulty]
    if type(settings) ~= 'table' then return nil end
    return game, settings
end

-- kind: 'door' | 'safe' | 'alarm' (nil: any). A game that can be unavailable
-- needs a valid fallback for every difficulty used.
function Security.validMinigame(m, kind)
    local game, settings = gameOf(m)
    if not game then return false end
    if kind and type(game.kinds) == 'table' and not game.kinds[kind] then return false end
    if game.available then
        local fallback = settings.fallback
        if not gameOf(fallback) or MinigameConfig[fallback.game].available then return false end
        local fb = MinigameConfig[fallback.game]
        if kind and type(fb.kinds) == 'table' and not fb.kinds[kind] then return false end
    end
    return true
end

-- The minigame to play now: the fallback while a game is unavailable.
function Security.resolve(m)
    local game, settings = gameOf(m)
    if game and game.available then
        local ok, available = pcall(game.available)
        if not (ok and available) then return { game = settings.fallback.game, difficulty = settings.fallback.difficulty } end
    end
    return { game = m.game, difficulty = m.difficulty }
end

function Security.settings(m)
    local _, settings = gameOf(m)
    return settings
end

function Security.gameDef(m) return (gameOf(m)) end

local function wholePrice(v) return type(v) == 'number' and v == v and v % 1 == 0 and v >= 0 and v <= 2e9 end

-- Returns a list of problems; empty when the levels are usable.
local function checkLevels(kind)
    local errors, levels = {}, Security.levelsConfig(kind)
    if type(levels) ~= 'table' or #levels < 1 or #levels > Security.MAX_LEVELS then
        return { ('Config.Security.%s needs 1-%d levels'):format(KINDS[kind], Security.MAX_LEVELS) }
    end
    for i = 1, #levels do
        local l = levels[i]
        if type(l) ~= 'table' or not Security.validMinigame(l, kind) then
            errors[#errors + 1] = ('Config.Security.%s[%d]: unknown game/difficulty (see config_minigame.lua)'):format(KINDS[kind], i)
        elseif l.price ~= nil and not wholePrice(l.price) then
            errors[#errors + 1] = ('Config.Security.%s[%d]: price must be a whole number >= 0'):format(KINDS[kind], i)
        end
    end
    return errors
end

-- Alarms (door and safe separately): a level with alarm = true and every level
-- above it. Higher levels take over alarm_game/alarm_difficulty/alarm_item
-- unless they set their own.
local function buildAlarms(kind)
    local errors, alarms, inherited = {}, {}, nil
    local levels = Security.levelsConfig(kind) or {}
    for i = 1, #levels do
        local l = levels[i]
        if type(l) == 'table' and (l.alarm == true or inherited) then
            local a = {
                game = l.alarm_game or (inherited and inherited.game),
                difficulty = l.alarm_difficulty or (inherited and inherited.difficulty),
                item = l.alarm_item,
            }
            if a.item == nil and inherited then a.item = inherited.item end
            if a.item == false then a.item = nil end
            if not Security.validMinigame(a, 'alarm') then
                errors[#errors + 1] = ('Config.Security.%s[%d]: unknown alarm_game/alarm_difficulty (see config_minigame.lua)'):format(KINDS[kind], i)
            elseif a.item ~= nil and type(a.item) ~= 'string' then
                errors[#errors + 1] = ('Config.Security.%s[%d]: alarm_item must be an item name'):format(KINDS[kind], i)
            end
            alarms[i], inherited = a, a
        end
    end
    return alarms, errors
end

-- Server: decide what is active. Invalid parts are switched off with a message.
function Security.validate()
    local errors = {}
    Security.enabled = Config.Security and Config.Security.Enabled == true or false
    if Security.enabled then
        for _, kind in ipairs({ 'door', 'safe' }) do
            for _, e in ipairs(checkLevels(kind)) do errors[#errors + 1] = e end
        end
        Security.alarms = {}
        for _, kind in ipairs({ 'door', 'safe' }) do
            local alarms, alarmErrors = buildAlarms(kind)
            for _, e in ipairs(alarmErrors) do errors[#errors + 1] = e end
            Security.alarms[kind] = alarms
        end
        if #errors > 0 then Security.enabled = false end
    end
    if not Security.enabled then Security.alarms = { door = {}, safe = {} } end
    local doorPick = Config.Doors.Lockpick or {}
    local safePick = Config.Safe.Lockpick or {}
    Security.lockpick.door = doorPick.Enabled == true and (Security.enabled or Security.validMinigame(doorPick.Minigame, 'door'))
    Security.lockpick.safe = Config.Safe.Enabled == true and safePick.Enabled == true
        and (Security.enabled or Security.validMinigame(safePick.Minigame, 'safe'))
    if doorPick.Enabled and not Security.lockpick.door then errors[#errors + 1] = 'Config.Doors.Lockpick.Minigame is not in config_minigame.lua' end
    if safePick.Enabled and Config.Safe.Enabled and not Security.lockpick.safe then errors[#errors + 1] = 'Config.Safe.Lockpick.Minigame is not in config_minigame.lua' end
    Security.errors = errors
    return errors
end

function Security.levelCount(kind)
    if not Security.enabled then return 1 end
    return #Security.levelsConfig(kind)
end

function Security.clampLevel(kind, level)
    return math.max(1, math.min(Security.levelCount(kind), math.floor(tonumber(level) or 1)))
end

-- Minigame for a lock at this level ({ game, difficulty }).
function Security.minigame(kind, level)
    if Security.enabled then
        local l = Security.levelsConfig(kind)[Security.clampLevel(kind, level)]
        return { game = l.game, difficulty = l.difficulty }
    end
    local pick = kind == 'door' and Config.Doors.Lockpick or Config.Safe.Lockpick
    return { game = pick.Minigame.game, difficulty = pick.Minigame.difficulty }
end

-- Price of a level in a building: the building's own price, else config.lua.
function Security.price(hotel, kind, level)
    local own = hotel and hotel.security and hotel.security[kind] and hotel.security[kind][tostring(level)]
    if wholePrice(own) then return own end
    local l = Security.levelsConfig(kind) and Security.levelsConfig(kind)[level]
    return l and tonumber(l.price) or 0
end

function Security.label(kind, level)
    local l = Security.enabled and Security.levelsConfig(kind)[level]
    return l and l.label or nil
end

-- Normalizes a building's { door = { ["2"] = price }, safe = {...} } table.
function Security.normalizePrices(raw)
    if raw == nil then return {} end
    if type(raw) ~= 'table' then return nil end
    local out = {}
    for _, kind in ipairs({ 'door', 'safe' }) do
        local list = raw[kind]
        if list ~= nil then
            if type(list) ~= 'table' then return nil end
            out[kind] = {}
            for key, value in pairs(list) do
                local level = tonumber(key)
                if not level or level % 1 ~= 0 or level < 2 or level > Security.MAX_LEVELS then return nil end
                if value ~= nil and value ~= json.null then
                    if not wholePrice(value) then return nil end
                    out[kind][tostring(level)] = value
                end
            end
        end
    end
    return out
end

-- Alarm of a door or safe level ({ game, difficulty, item }) or nil. The server also
-- checks that the item exists (server/security.lua).
function Security.alarm(kind, level)
    return Security.enabled and Security.alarms[kind] and Security.alarms[kind][Security.clampLevel(kind, level)] or nil
end

-- Client: run a minigame by name. Returns true on success.
function Security.play(minigame, ctx)
    local game, settings = gameOf(minigame)
    if not game then return false end
    local ok, result = pcall(game.run, settings, ctx or {})
    if not ok then print(('^1[zloma_apartments]^0 minigame %s failed: %s'):format(minigame.game, result)) end
    return ok and result == true
end
