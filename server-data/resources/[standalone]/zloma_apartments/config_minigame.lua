-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

--[[
    MINIGAMES for lockpicking doors and safes and for hacking door alarms.

    config.lua refers to a minigame by name and difficulty, for example
        { game = 'lockpick', difficulty = 'hard' }
        alarm_game = 'hacking', alarm_difficulty = 'medium'

    Every game below has:
      difficulties   named settings you can pick in config.lua
      run(settings, ctx)  runs on the player's client and returns true (success) or false.
                     ctx.kind is 'door', 'safe' or 'alarm'; ctx.door has the door's
                     coords, model and entity (doors and alarms only).
    Optional:
      kinds          { door = true } limits where the game can be used
      available()    false when the game can't run now (e.g. another resource is
                     stopped); then the difficulty's `fallback` minigame is used
      prepare(source, settings, ctx) / verify(source, settings)
                     server side, for games whose own server checks the result

    ox_lib skill check (https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck)
      lib.skillCheck(rounds, keys)
      rounds: one entry per round. 'easy' | 'medium' | 'hard' or a custom
              { areaSize = 50, speedMultiplier = 1.0 }  (smaller area / faster = harder)
      keys:   keys the player must press, a random one each round

    Make a game harder: add rounds, use 'hard', or a smaller areaSize / higher
    speedMultiplier (hacking: a longer code, shown for less time). Make it easier:
    the opposite.

    Add a new game: copy a block, give it a new name (e.g. 'hacking5' below),
    then use that name in config.lua. To use another resource's minigame, call
    its export in run() and return true/false (see the commented example at the bottom).

    This file is loaded on server and client. The server checks that the names
    in config.lua exist; run() only executes on the client.
]]

local function L(key, fallback)
    local text = _L and _L(key)
    return text and text ~= key and text or fallback
end

-- Remember a code shown on the alarm panel, bypass the panel's checks, type the code.
local function alarmPanel(settings)
    local chars, code = '0123456789ABCDEF', ''
    for _ = 1, settings.length do
        local i = math.random(#chars)
        code = code .. chars:sub(i, i)
    end
    lib.showTextUI(('%s  %s'):format(L('minigame_alarm_panel', 'ALARM PANEL'), code), { position = 'top-center', icon = 'microchip' })
    Wait(math.floor(settings.showSeconds * 1000))
    lib.hideTextUI()
    if not lib.skillCheck(settings.checks, { '1', '2', '3', '4' }) then return false end
    local input = lib.inputDialog(L('minigame_alarm_panel', 'ALARM PANEL'), {
        { type = 'input', label = L('minigame_alarm_code', 'Code'), required = true, max = settings.length },
    })
    return input ~= nil and tostring(input[1] or ''):upper() == code
end

MinigameConfig = {
    -- Classic lock picking: a few skill checks with random WASD keys.
    lockpick = {
        difficulties = {
            easy   = { rounds = { 'easy', 'easy' },                     keys = { 'w', 'a', 's', 'd' } },
            medium = { rounds = { 'easy', 'medium', 'medium' },         keys = { 'w', 'a', 's', 'd' } },
            hard   = { rounds = { 'medium', 'hard', 'hard' },           keys = { 'w', 'a', 's', 'd' } },
            ultra  = { rounds = { 'hard', 'hard', { areaSize = 30, speedMultiplier = 1.6 },
                                  { areaSize = 25, speedMultiplier = 1.8 } }, keys = { 'w', 'a', 's', 'd' } },
        },
        run = function(settings)
            return lib.skillCheck(settings.rounds, settings.keys)
        end,
    },

    -- Electronic lock: many short, fast checks on number keys.
    keypad = {
        difficulties = {
            easy   = { rounds = 4, areaSize = 50, speedMultiplier = 1.0 },
            medium = { rounds = 5, areaSize = 40, speedMultiplier = 1.3 },
            hard   = { rounds = 6, areaSize = 30, speedMultiplier = 1.6 },
            ultra  = { rounds = 8, areaSize = 25, speedMultiplier = 1.9 },
        },
        run = function(settings)
            local rounds = {}
            for i = 1, settings.rounds do
                rounds[i] = { areaSize = settings.areaSize, speedMultiplier = settings.speedMultiplier }
            end
            return lib.skillCheck(rounds, { '1', '2', '3', '4' })
        end,
    },

    -- Door alarm: the panel shows a code for a moment, the player gets past its
    -- checks and types the code. length = code length, showSeconds = how long it shows.
    hacking = {
        difficulties = {
            easy   = { length = 4, showSeconds = 4.0, checks = { 'easy', 'easy' } },
            medium = { length = 5, showSeconds = 3.0, checks = { 'easy', 'medium', 'medium' } },
            hard   = { length = 6, showSeconds = 2.5, checks = { 'medium', 'hard', 'hard' } },
            ultra  = { length = 7, showSeconds = 2.0, checks = { 'hard', 'hard', { areaSize = 25, speedMultiplier = 1.8 } } },
        },
        run = alarmPanel,
    },

    -- A stronger alarm panel (an example of a second game of the same kind).
    hacking5 = {
        difficulties = {
            medium = { length = 8, showSeconds = 2.0, checks = { 'hard', 'hard', 'hard' } },
            hard   = { length = 9, showSeconds = 1.5, checks = { 'hard', { areaSize = 25, speedMultiplier = 1.8 }, { areaSize = 20, speedMultiplier = 2.0 } } },
        },
        run = alarmPanel,
    },

    -- Door alarm panel: after the USB cable is plugged in, the hack runs on the
    -- screen of the hacking device, played with the mouse. Its stages run in
    -- order; config.lua (Config.Security.Alarm.Hack) sets how many mistakes are
    -- allowed, when the police are called and when the item is used up.
    -- Door alarm panels only (Config.Security.Alarm.Panel.Enabled).
    --   sync     match your signal to the alarm's carrier wave with the FREQ and
    --            PHASE sliders and hold the lock until the meter is full.
    --            hold = seconds of lock needed, tolerance = how close (smaller is
    --            harder; the % on screen reaches 100 when you are close enough),
    --            drift = how fast the carrier wanders, glitch = seconds between
    --            small sudden jumps (0 = none), seconds = time limit.
    --   pattern  the grid flashes a sequence, click it back. Every round adds one.
    --            grid = 3 or 4 (3x3 / 4x4), rounds, start = length of the first
    --            sequence, speed = seconds per flash, inputSeconds = time to repeat a round.
    --   pin      crack the panel PIN: green = right digit, right place; amber = in
    --            the code, wrong place. length, attempts, repeats = digits may
    --            repeat, seconds = time limit.
    -- With the panel off (and on safes) the difficulty's `fallback` game is played.
    device_hack = {
        kinds = { alarm = true },
        available = function()
            return Config.Security.Alarm.Panel ~= nil and Config.Security.Alarm.Panel.Enabled == true
        end,
        difficulties = {
            easy = { fallback = { game = 'hacking', difficulty = 'easy' }, stages = {
                { game = 'sync',    hold = 2.0, tolerance = 0.18, drift = 0.28, glitch = 0,  seconds = 50 },
                { game = 'pattern', grid = 3, rounds = 3, start = 2, speed = 0.60, inputSeconds = 10 },
                { game = 'pin',     length = 3, attempts = 7, repeats = false, seconds = 75 },
            } },
            medium = { fallback = { game = 'hacking', difficulty = 'medium' }, stages = {
                { game = 'sync',    hold = 2.5, tolerance = 0.15, drift = 0.40, glitch = 14, seconds = 45 },
                { game = 'pattern', grid = 3, rounds = 4, start = 3, speed = 0.50, inputSeconds = 9 },
                { game = 'pin',     length = 4, attempts = 7, repeats = false, seconds = 75 },
            } },
            hard = { fallback = { game = 'hacking', difficulty = 'hard' }, stages = {
                { game = 'sync',    hold = 3.0, tolerance = 0.12, drift = 0.55, glitch = 9,  seconds = 40 },
                { game = 'pattern', grid = 4, rounds = 5, start = 3, speed = 0.42, inputSeconds = 9 },
                { game = 'pin',     length = 4, attempts = 6, repeats = true, seconds = 70 },
            } },
            expert = { fallback = { game = 'hacking', difficulty = 'ultra' }, stages = {
                { game = 'sync',    hold = 3.5, tolerance = 0.10, drift = 0.70, glitch = 7,  seconds = 35 },
                { game = 'pattern', grid = 4, rounds = 6, start = 4, speed = 0.35, inputSeconds = 8 },
                { game = 'pin',     length = 5, attempts = 6, repeats = true, seconds = 75 },
            } },
        },
        run = function()
            print('^3[zloma_apartments]^0 device_hack only runs on door alarm panels (Config.Security.Alarm.Panel)')
            return false
        end,
    },

    -- Safe cracking: turn the dial with A / D until a pin drops (you hear it),
    -- press W to set it, then turn the other way for the next number. S gives up.
    -- Based on pd-safe by Victor Hall (MIT). Safes only.
    -- pins: how many numbers the combination has. More pins = harder.
    safecrack = {
        kinds = { safe = true },
        difficulties = {
            easy   = { pins = 2 },
            medium = { pins = 3 },
            hard   = { pins = 4 },
            ultra  = { pins = 5 },
            expert = { pins = 6 },
        },
        run = function(settings, ctx)
            local combination = {}
            for i = 1, settings.pins do combination[i] = math.random(0, 99) end
            return SafeCrack(combination, ctx and ctx.safe)
        end,
    },

    -- Real wafer lock on the door, picked with a Lishi-style pick by feel.
    -- Made by TR Scripts (tr_minigames). Doors only. Placement, camera and
    -- strikes are in config.lua (Config.DoorPick).
    -- wafers: how many (1-8); overset: mm of lifting too far that is forgiven;
    -- speed: mm/s a stiff wafer gives. Fewer wafers, more overset and more
    -- speed = easier.
    tr_lockpick = {
        kinds = { door = true },
        difficulties = {
            easy   = { wafers = 4, overset = 1.0,  speed = 3.2 },
            medium = { wafers = 5, overset = 0.8,  speed = 2.8 },
            hard   = { wafers = 6, overset = 0.6,  speed = 2.4 },
            expert = { wafers = 7, overset = 0.45, speed = 2.0 },
        },
        prepare = function(source, settings, ctx)
            return DoorPickAuthorize(source, ctx.key, ctx.coords, settings)
        end,
        run = function(_, ctx)
            return DoorPickPlay(ctx.door or {})
        end,
        verify = function(source)
            return DoorPickConsume(source)
        end,
    },

    -- Example of another resource's minigame (remove the comment to use it):
    -- circle = {
    --     difficulties = {
    --         medium = { circles = 3, seconds = 12 },
    --         hard   = { circles = 5, seconds = 9 },
    --     },
    --     run = function(settings)
    --         local p = promise.new()
    --         exports['ps-ui']:Circle(function(success) p:resolve(success) end, settings.circles, settings.seconds)
    --         return Citizen.Await(p)
    --     end,
    -- },
}

-- Independent safe-device stages: edit this entry without changing door alarms.
local function copySafeHack(value)
    if type(value) ~= 'table' then return value end
    local out={} for k,v in pairs(value) do out[k]=copySafeHack(v) end return out
end
MinigameConfig.safe_device_hack = copySafeHack(MinigameConfig.device_hack)
