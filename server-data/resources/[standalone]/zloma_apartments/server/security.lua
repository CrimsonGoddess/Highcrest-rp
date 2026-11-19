-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Lock levels (Security tab), lockpicking of doors and safes, and their alarms.
-- The minigame runs on the client; the server picks it, checks distance,
-- item, cooldown and a minimum play time, and does the unlocking itself.
local MIN_PLAY_SECONDS = 2
local pending, cooldowns = {}, {}

local function pickConfig(kind) return kind == 'door' and Config.Doors.Lockpick or Config.Safe.Lockpick end

local function startupCheck()
    local errors = Security.validate()
    for _, e in ipairs(errors) do print(('^1[zloma_apartments]^0 %s'):format(e)) end
    if Config.Security and Config.Security.Enabled and not Security.enabled then
        print('^1[zloma_apartments]^0 Security upgrades are off until the errors above are fixed.')
    end
end
startupCheck()

-- Alarm of a door or safe level, or nil when it has none or its item doesn't exist.
function ActiveAlarm(kind, level)
    local alarm = Security.alarm(kind, level)
    if alarm and (Config.Debug or Bridge.itemExists(alarm.item)) then return alarm end
    return nil
end

-- Every active alarm of a kind, lowest level first.
local function activeAlarms(kind)
    local list = {}
    if not Security.enabled then return list end
    for level = 1, Security.levelCount(kind) do
        local alarm = ActiveAlarm(kind, level)
        if alarm then list[#list + 1] = alarm end
    end
    return list
end

local function residentOf(booking, identifier)
    return booking and identifier and (booking.owner == identifier or booking.roommate == identifier)
end

-- Current lock level of a booking's door or safe.
local function currentLevel(booking, kind)
    if kind == 'door' then return Security.clampLevel('door', booking.doorSecurity or 1) end
    local record = SafeRecord(booking)
    return Security.clampLevel('safe', record and record.security or 1), record
end

-- An alarm needs enough physical safe capacity, including migrated bookings.
local function safeAlarmReady(record)
    return record and record.capacity >= (Config.Safe.AlarmMinCapacity or 2)
end
local function currentAlarm(booking, kind)
    local level, record = currentLevel(booking, kind)
    if kind == 'safe' and not safeAlarmReady(record) then return nil end
    return ActiveAlarm(kind, level)
end

-- What the Security tab shows for the owner. nil when upgrades are off.
function SecurityView(booking)
    if not Security.enabled then return nil end
    local hotel = State.hotel(booking.hotel)
    local view = {}
    for _, kind in ipairs({ 'door', 'safe' }) do
        if kind == 'door' or Config.Safe.Enabled then
            local level, record = currentLevel(booking, kind)
            local max = Security.levelCount(kind)
            local entry = { level = level, max = max, label = Security.label(kind, level) }
            entry.alarm = currentAlarm(booking, kind) ~= nil
            if level < max then
                entry.next = { level = level + 1, label = Security.label(kind, level + 1), price = Security.price(hotel, kind, level + 1) }
                entry.next.alarm = ActiveAlarm(kind, level + 1) ~= nil
                if kind == 'safe' and entry.next.alarm and not safeAlarmReady(record) then
                    entry.next.blocked = _L('error_safe_alarm_capacity', Config.Safe.AlarmMinCapacity or 2)
                end
            end
            view[kind] = entry
        end
    end
    return view
end

Mutation('upgradeSecurity', function(src, data)
    if not Security.enabled then return Fail('error_invalid') end
    local kind = type(data) == 'table' and data.kind
    if kind ~= 'door' and (kind ~= 'safe' or not Config.Safe.Enabled) then return Fail('error_invalid') end
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    if not booking then return Fail('notify_no_apartment') end
    if booking.owner ~= identifier then return Fail('notify_not_owner') end
    local level, record = currentLevel(booking, kind)
    if level >= Security.levelCount(kind) then return Fail('notify_already_max_level') end
    local nextLevel = level + 1
    if kind == 'safe' and ActiveAlarm(kind, nextLevel) and not safeAlarmReady(record) then
        return Fail('error_safe_alarm_capacity', Config.Safe.AlarmMinCapacity or 2)
    end
    local price = Security.price(State.hotel(booking.hotel), kind, nextLevel)
    if Bridge.money(src) < price then return Fail('notify_insufficient_funds', price) end
    if not Bridge.removeMoney(src, price) then return Fail('error_payment_failed') end
    local ok
    if kind == 'door' then
        ok = pcall(DB.setDoorSecurity, booking.hotel, booking.room, nextLevel)
        if ok then booking.doorSecurity = nextLevel end
    else
        ok = record and pcall(record.setSecurity, nextLevel)
    end
    if not ok then Bridge.addMoney(src, price); return Fail('error_generic') end
    Bridge.notify(src, _L('notify_security_upgraded', Security.label(kind, nextLevel) or nextLevel), 'success')
    return { success = true, security = SecurityView(booking) }
end)

-- Lockpicking and alarms --------------------------------------------------------
-- kind 'door' / 'safe': pick the lock. kind 'alarm': hack the alarm panel of
-- data.target ('door' or 'safe'). A door or safe whose level has an alarm calls
-- the police and tells the owner and roommate when it is picked (whether it
-- works or not) or its hack fails, unless the alarm was hacked first. Locks
-- without an alarm can be "hacked" too, with the same result shown, so players
-- can't tell; nobody is told about breaking into them.
local alarmOff = {} -- 'hotel:room:kind' -> { booking, expires }

-- Config.Debug: test alone. No items needed or used up, no cooldowns, and
-- residents may break into their own door and safe (and get the alarm notification).
local function hasItem(src, item) return Config.Debug == true or Bridge.hasItem(src, item) end
local function useItem(src, item) if not Config.Debug then Bridge.removeItem(src, item) end end

local function doorKey(booking) return booking.hotel .. ':' .. booking.room end
local function alarmKey(booking, kind) return doorKey(booking) .. ':' .. kind end

local alarmVersions={}
local function alarmVersion(booking,kind)
    local entry=alarmVersions[alarmKey(booking,kind)]
    return entry and entry.booking==booking and entry.version or 0
end
function SetApartmentAlarmDisabled(booking,kind,disabled)
    local key=alarmKey(booking,kind)
    alarmVersions[key]={booking=booking,version=alarmVersion(booking,kind)+1}
    alarmOff[key]=disabled and {booking=booking} or nil
    TriggerClientEvent('zloma_apartments:alarmStateChanged',-1,booking.hotel,booking.room,kind,disabled==true)
end
local function alarmHacked(booking, kind)
    local off = alarmOff[alarmKey(booking, kind)]
    return off ~= nil and off.booking == booking
end

-- Who gets told when an alarm goes off. Other resources can take this over,
-- e.g. to send a phone notification instead of the ox_lib one:
--   exports.zloma_apartments:RegisterAlarmNotifier(function(target, identifier, info)
--       -- info = { hotel, hotelLabel, room, kind = 'door'|'safe', reason, coords }
--       return true -- handled: no ox_lib notification
--   end)
local notifiers = {} -- id -> { resource, fn }
local notifierId = 0

exports('RegisterAlarmNotifier', function(fn)
    if type(fn) ~= 'function' and type(fn) ~= 'table' then return nil end
    notifierId = notifierId + 1
    notifiers[notifierId] = { resource = GetInvokingResource(), fn = fn }
    return notifierId
end)

exports('RemoveAlarmNotifier', function(id) notifiers[id] = nil end)

AddEventHandler('onResourceStop', function(name)
    for id, n in pairs(notifiers) do
        if n.resource == name then notifiers[id] = nil end
    end
end)

local function tellResident(target, identifier, info)
    local handled = false
    for _, n in pairs(notifiers) do
        local ok, result = pcall(n.fn, target, identifier, info)
        if not ok then print(('^1[zloma_apartments]^0 alarm notifier from %s: %s'):format(n.resource, result)) end
        handled = handled or (ok and result == true)
    end
    local hook = Customization and Customization.OnAlarmOwner
    if type(hook) == 'function' then
        local ok, result = pcall(hook, target, identifier, info)
        if not ok then print(('^1[zloma_apartments]^0 Customization.OnAlarmOwner: %s'):format(result)) end
        handled = handled or (ok and result == true)
    end
    if not handled and (Config.Security.Alarm or {}).NotifyOwner ~= false then
        TriggerClientEvent('zloma_apartments:alarmNotify', target, info)
    end
end

local function alarmCoords(booking, room, kind)
    local p = kind == 'safe' and room.safe or room.door
    return vector3(p.x, p.y, p.z)
end

-- The alarm goes off: police dispatch, owner and roommate notification, hook.
local function sendAlarm(src, booking, room, kind, reason)
    local d = (Config.Security.Alarm or {}).Dispatch or {}
    local blip = d.blip or {}
    local hotel = State.hotel(booking.hotel)
    local hotelLabel = hotel and hotel.label or booking.hotel
    local coords = alarmCoords(booking, room, kind)
    local title = _L('dispatch_alarm_title')
    Bridge.dispatch(src, {
        job = d.job or { 'police' },
        code = d.code or '10-90',
        title = title,
        description = _L(kind == 'safe' and 'dispatch_alarm_description_safe' or 'dispatch_alarm_description', booking.room, hotelLabel),
        coords = coords,
        priority = d.priority or 'high',
        icon = d.icon,
        time = d.time or 5,
        blip = { sprite = blip.sprite or 40, color = blip.color or 1, scale = blip.scale or 1.2, name = title },
    })
    local info = { hotel = booking.hotel, hotelLabel = hotelLabel, room = booking.room, kind = kind, reason = reason,
        coords = { x = coords.x, y = coords.y, z = coords.z } }
    for _, identifier in ipairs({ booking.owner, booking.roommate }) do
        local target = identifier and Bridge.source(identifier)
        if target and (target ~= src or Config.Debug) then tellResident(target, identifier, info) end
    end
    TriggerEvent('zloma_apartments:alarm', src, info)
    Hook('OnAlarm', src, Bridge.identifier(src), booking.hotel, booking.room, reason, kind)
end

local function target(data)
    if type(data) ~= 'table' or type(data.hotel_id) ~= 'string' then return nil end
    local number = tonumber(data.room_number)
    local room = number and State.room(data.hotel_id, number)
    local booking = room and State.booking(data.hotel_id, number)
    return booking, room
end

local function near(src, kind, booking, room)
    if kind == 'safe' then return NearSafe(src, booking) end
    return NearPoint(src, room.door, 2.5)
end

-- Why the player can't break into this door or safe now (nil: they can).
local function breakInProblem(src, kind, booking, room)
    if not booking then return 'error_room_free' end
    if not near(src, kind, booking, room) then return 'error_too_far' end
    if not Config.Debug and residentOf(booking, Bridge.identifier(src)) then
        return kind == 'safe' and 'error_lockpick_own_safe' or 'error_lockpick_own_door'
    end
    if kind == 'door' and not Config.Debug and not DoorIsLocked(booking.hotel, booking.room) then return 'error_door_open' end
end

-- The alarm a hack plays against: its own, else (no alarm) one the player
-- has the item for, so the attempt looks the same.
local function hackTarget(booking, kind, src)
    local own = currentAlarm(booking, kind)
    if own then return own, true end
    local list = activeAlarms(kind)
    for _, alarm in ipairs(list) do
        if hasItem(src, alarm.item) then return alarm, false end
    end
    return list[1], false
end

local function hasAlarmItem(src, kind)
    for _, alarm in ipairs(activeAlarms(kind)) do
        if hasItem(src, alarm.item) then return true end
    end
    return false
end

-- The options a player gets: only those whose items they have.
lib.callback.register('zloma_apartments:lockpickOptions', function(src, data)
    local kind = type(data) == 'table' and data.kind == 'safe' and 'safe' or 'door'
    local booking, room = target(data)
    if breakInProblem(src, kind, booking, room) then return { lockpick = false, hack = false } end
    local pick = pickConfig(kind)
    if kind=='safe' and SafeLifecycle.isBreached(booking) then return {lockpick=false,hack=false,panelHack=false}end
    local panel = Config.Security.Alarm.Panel and Config.Security.Alarm.Panel.Enabled and (kind == 'door' or Config.Security.Alarm.Panel.SafeEnabled ~= false)
    local actual = panel and currentAlarm(booking, kind)
    return { lockpick = Security.lockpick[kind] and hasItem(src, pick.Item), hack = not panel and hasAlarmItem(src, kind),
        panelHack = actual ~= nil and actual ~= false and hasItem(src, actual.item) and not alarmHacked(booking, kind) }
end)

lib.callback.register('zloma_apartments:lockpickStart', function(src, data)
    local kind = type(data) == 'table' and data.kind
    if kind ~= 'door' and kind ~= 'safe' and kind ~= 'alarm' then return Fail('error_invalid') end
    if kind ~= 'alarm' and not Security.lockpick[kind] then return Fail('error_invalid') end
    local lockKind = kind == 'alarm' and (data.target == 'safe' and 'safe' or 'door') or kind
    if kind == 'alarm' and Config.Security.Alarm.Panel and Config.Security.Alarm.Panel.Enabled and (lockKind == 'door' or Config.Security.Alarm.Panel.SafeEnabled ~= false) then
        return Fail('error_invalid') -- the connection demo must never grant the old alarm bypass
    end
    if lockKind == 'safe' and not Config.Safe.Enabled then return Fail('error_invalid') end
    local booking, room = target(data)
    local problem = breakInProblem(src, lockKind, booking, room)
    if problem then return Fail(problem) end
    local now = os.time()
    local key = src .. ':' .. kind
    if not Config.Debug and (cooldowns[key] or 0) > now then return Fail('error_lockpick_cooldown', cooldowns[key] - now) end

    local minigame, item, cooldown, level, alarmed
    if kind == 'alarm' then
        local alarm, own = hackTarget(booking, lockKind, src)
        if not alarm then return Fail('error_invalid') end
        if not hasItem(src, alarm.item) then return Fail('error_alarm_item') end
        minigame, item, alarmed = { game = alarm.game, difficulty = alarm.difficulty }, alarm.item, own
        cooldown = (Config.Security.Alarm or {}).Cooldown or 30
    else
        local cfg = pickConfig(kind)
        if not hasItem(src, cfg.Item) then return Fail('error_lockpick_item') end
        level = currentLevel(booking, kind)
        minigame, item, cooldown = Security.minigame(kind, level), cfg.Item, cfg.Cooldown or 30
        alarmed = currentAlarm(booking, kind) ~= nil
    end
    minigame = Security.resolve(minigame)
    local def, settings = Security.gameDef(minigame), Security.settings(minigame)
    if not def then return Fail('error_generic') end
    if def.prepare then
        local ok, ready = pcall(def.prepare, src, settings, { kind = kind, key = doorKey(booking), coords = alarmCoords(booking, room, lockKind) })
        if not (ok and ready) then return Fail('error_generic') end
    end

    cooldowns[key] = now + cooldown
    local token = ('%d:%d:%d'):format(src, now, math.random(100000, 999999))
    pending[src] = { token = token, kind = kind, lockKind = lockKind, booking = booking, started = now, expires = now + 300,
        minigame = minigame, item = item, alarmed = alarmed, safeVersion=kind=='safe' and SafeLifecycle.generation(booking) or nil }
    Hook('OnLockpickStart', src, Bridge.identifier(src), kind, booking.hotel, booking.room)
    return { success = true, token = token, minigame = minigame, level = level }
end)

-- Door-panel connection demo. Separate from lockpickFinish: even a forged
-- successful reply cannot set alarmOff, unlock a door, or suppress dispatch.
local connections, panelLocks, panelQueries = {}, {}, {}
local function panelEnabled(kind)
    return Security.enabled and Config.Security.Alarm.Panel and Config.Security.Alarm.Panel.Enabled == true
        and (kind ~= 'safe' or (Config.Safe.Enabled and Config.Security.Alarm.Panel.SafeEnabled ~= false))
end

lib.callback.register('zloma_apartments:alarmPanels', function(src)
    if not panelEnabled() then return {} end
    local now = os.time()
    if panelQueries[src] == now then return nil end
    panelQueries[src] = now
    local out = {}
    for _, rooms in pairs(State.bookings) do
        for _, booking in pairs(rooms) do
            if currentAlarm(booking, 'door') then
                local off = alarmOff[alarmKey(booking, 'door')]
                out[doorKey(booking)] = { disabled = off ~= nil and off.booking == booking, canArm=residentOf(booking,Bridge.identifier(src)) }
            end
            local room=State.room(booking.hotel,booking.room)
            -- SafeRecord reads SQL: only inspect safes within this client's stream range.
            if panelEnabled('safe') and room and room.safe and NearPoint(src,room.safe,(Config.Safe.StreamDistance or 18)+5)
                and currentAlarm(booking, 'safe') then
                local off = alarmOff[alarmKey(booking, 'safe')]
                out['safe:' .. doorKey(booking)] = { kind = 'safe', disabled = off ~= nil and off.booking == booking, canArm=residentOf(booking,Bridge.identifier(src)) }
            end
        end
    end
    return out
end)

lib.callback.register('zloma_apartments:alarmConnectStart', function(src, data)
    local kind = type(data)=='table' and data.kind or 'door'
    if kind ~= 'door' and kind ~= 'safe' then return Fail('error_invalid') end
    if not panelEnabled(kind) then return Fail('error_invalid') end
    local booking, room = target(data)
    local problem = breakInProblem(src, kind, booking, room)
    if problem then return Fail(problem) end
    local alarm = currentAlarm(booking, kind)
    if not alarm then return Fail('error_invalid') end
    if not hasItem(src, alarm.item) then return Fail('error_alarm_item') end
    if alarmHacked(booking, kind) then return Fail('alarm_panel_disabled') end
    local now, key = os.time(), (kind == 'safe' and 'safe:' or '') .. doorKey(booking)
    local previous = connections[src]
    if previous and previous.expires > now then return Fail('alarm_panel_busy') end
    local held = panelLocks[key]
    if held and held.expires > now then return Fail('alarm_panel_busy') end
    local cooldownKey = src .. ':alarm' .. (kind == 'safe' and ':safe' or '')
    if not Config.Debug and (cooldowns[cooldownKey] or 0) > now then return Fail('error_lockpick_cooldown', cooldowns[cooldownKey] - now) end
    local cfg = Config.Security.Alarm
    local token = ('c:%d:%d:%d'):format(src, now, math.random(100000, 999999))
    local session = { token = token, kind = kind, booking = booking, key = key, alarmVersion=alarmVersion(booking,kind), item = alarm.item, started = now,
        expires = now + math.max(15, math.min(300, tonumber(cfg.Panel.SessionSeconds) or 90)) }
    connections[src], panelLocks[key] = session, session
    cooldowns[cooldownKey] = now + (cfg.Cooldown or 30)
    return { success = true, token = token, seconds = math.max(1, math.min(20, tonumber(cfg.Panel.ConnectSeconds) or 4)) }
end)

-- Stages of the device hack for a door alarm (device_hack in config_minigame.lua).
-- Only plain values go to the client.
local HACK_GAMES = { sync = true, pattern = true, pin = true }
local function hackStages(alarm, kind)
    local name = kind == 'safe' and 'safe_device_hack' or 'device_hack'
    local game = MinigameConfig[name]
    if not game then return nil end
    local settings = alarm.game == name and game.difficulties[alarm.difficulty]
        or game.difficulties.medium or select(2, next(game.difficulties))
    local stages = {}
    for _, stage in ipairs(settings and settings.stages or {}) do
        if type(stage) == 'table' and HACK_GAMES[stage.game] then
            local copy = {}
            for k, v in pairs(stage) do
                if type(v) == 'number' or type(v) == 'boolean' or type(v) == 'string' then copy[k] = v end
            end
            stages[#stages + 1] = copy
        end
    end
    return #stages > 0 and stages or nil
end

local function hackConfig(kind)
    local base=Config.Security.Alarm.Hack or {}
    if kind~='safe' then return base end
    return setmetatable(Config.Security.Alarm.SafeHack or {},{__index=base})
end

-- Most time a hack can take: every stage played once more per allowed mistake.
local function hackBudget(stages, kind)
    local total = 0
    for _, stage in ipairs(stages) do
        local seconds = stage.seconds
        if stage.game == 'pattern' then
            local rounds = stage.rounds or 4
            seconds = rounds * ((stage.inputSeconds or 9) + ((stage.start or 3) + rounds) * (stage.speed or .5) * 1.5 + 2)
        end
        total = total + math.max(10, math.min(300, tonumber(seconds) or 60))
    end
    return math.min(1800, math.floor(total * ((tonumber(hackConfig(kind).Strikes) or 0) + 1) + 60))
end

local function releaseConnection(src, p)
    if connections[src] == p then connections[src] = nil end
    if panelLocks[p.key] == p then panelLocks[p.key] = nil end
end

local hackFails = {} -- 'src:hotel:room' -> { count, expires }
local HACK_STAGE_SECONDS = 2 -- no real stage is played faster

-- outcome: 'success' | 'fail' | 'cancel' as the client reports it; the server
-- decides what it really was.
local function finishDeviceHack(src, p, outcome, fails)
    releaseConnection(src, p)
    local cfg = hackConfig(p.kind)
    local booking = p.booking
    local now = os.time()
    local strikes = math.max(0, math.floor(tonumber(cfg.Strikes) or 0))
    fails = math.max(0, math.floor(tonumber(fails) or 0))
    local alive = State.booking(booking.hotel, booking.room) == booking
    local room = alive and State.room(booking.hotel, booking.room)
    if outcome == 'success' then
        local valid = alive and p.expires >= now and fails <= strikes
            and now - p.hackStarted >= #p.stages * HACK_STAGE_SECONDS
            and not breakInProblem(src, p.kind or 'door', booking, room)
            and currentAlarm(booking, p.kind or 'door') ~= nil
            and p.alarmVersion==alarmVersion(booking,p.kind or 'door')
            and hasItem(src, p.item)
        if not valid then outcome = 'fail' end
    elseif outcome == 'cancel' then
        if cfg.AllowCancel == false or cfg.CancelCountsAsFail then outcome = 'fail' end
    else
        outcome = 'fail'
    end
    local remove = cfg.RemoveItem or {}
    Hook('OnLockpickFinish', src, Bridge.identifier(src), 'alarm', booking.hotel, booking.room, outcome == 'success')

    if outcome == 'success' then
        if remove.OnSuccess and p.item then useItem(src, p.item) end
        SetApartmentAlarmDisabled(booking,p.kind or 'door',true)
        Bridge.notify(src, _L('notify_alarm_hacked'), 'success')
        return { success = true, result = 'success' }
    end
    if outcome == 'cancel' then
        if remove.OnCancel and p.item then useItem(src, p.item) end
        return { success = true, result = 'cancel' }
    end

    if remove.OnFail and p.item then useItem(src, p.item) end
    local dispatched = false
    if alive and cfg.DispatchOnFail ~= false then
        local key = src .. ':' .. p.key
        local entry = hackFails[key]
        if not entry or entry.expires < now then entry = { count = 0 } end
        entry.count = entry.count + 1
        entry.expires = now + (tonumber(cfg.FailMemorySeconds) or 900)
        if entry.count >= math.max(1, math.floor(tonumber(cfg.FailsBeforeDispatch) or 1)) then
            hackFails[key] = nil
            sendAlarm(src, booking, room, p.kind or 'door', 'hack_failed')
            dispatched = true
        else
            hackFails[key] = entry
        end
    end
    Bridge.notify(src, _L('notify_hack_failed'), 'error')
    return { success = true, result = 'fail', dispatched = dispatched }
end

lib.callback.register('zloma_apartments:alarmConnectFinish', function(src, data)
    local p = connections[src]
    if not p or type(data) ~= 'table' or data.token ~= p.token then return Fail('error_invalid') end
    if data.connected ~= true then
        -- Leaving after the hack started counts as stopping it.
        if p.hackStarted then return finishDeviceHack(src, p, 'cancel', 0) end
        releaseConnection(src, p)
        return { success = true, connected = false }
    end
    if p.linked then return Fail('error_invalid') end -- connects once
    local function failed(reason, ...) releaseConnection(src, p); return Fail(reason, ...) end
    if not panelEnabled(p.kind) or p.expires < os.time() or State.booking(p.booking.hotel, p.booking.room) ~= p.booking then return failed('error_invalid') end
    local room = State.room(p.booking.hotel, p.booking.room)
    local problem = breakInProblem(src, p.kind or 'door', p.booking, room)
    if problem then return failed(problem) end
    local alarm = currentAlarm(p.booking, p.kind or 'door')
    if not alarm then return failed('error_invalid') end
    if not hasItem(src, p.item) then return failed('error_alarm_item') end
    local seconds = math.max(1, math.min(20, tonumber(Config.Security.Alarm.Panel.ConnectSeconds) or 4))
    if os.time() - p.started < seconds then return failed('error_invalid') end
    local stages = hackStages(alarm, p.kind)
    if not stages then return failed('error_generic') end
    -- Plugged in: the session stays open for the hack. Connecting alone never
    -- disables the alarm.
    local cfg = hackConfig(p.kind)
    p.linked, p.stages, p.expires = true, stages, os.time() + 120
    return { success = true, connected = true, hack = {
        stages = stages,
        strikes = math.max(0, math.floor(tonumber(cfg.Strikes) or 0)),
        cancel = cfg.AllowCancel ~= false,
    } }
end)

lib.callback.register('zloma_apartments:alarmHackStart', function(src, data)
    local p = connections[src]
    if not p or type(data) ~= 'table' or data.token ~= p.token or not p.linked or p.hackStarted then return Fail('error_invalid') end
    local now = os.time()
    if p.expires < now then releaseConnection(src, p); return Fail('error_invalid') end
    p.hackStarted, p.expires = now, now + hackBudget(p.stages, p.kind)
    Hook('OnLockpickStart', src, Bridge.identifier(src), 'alarm', p.booking.hotel, p.booking.room)
    return { success = true }
end)

lib.callback.register('zloma_apartments:alarmHackFinish', function(src, data)
    local p = connections[src]
    if not p or type(data) ~= 'table' or data.token ~= p.token or not p.linked then return Fail('error_invalid') end
    if not p.hackStarted then releaseConnection(src, p); return { success = true, result = 'cancel' } end
    local outcome = data.result == 'success' and 'success' or data.result == 'cancel' and 'cancel' or 'fail'
    return finishDeviceHack(src, p, outcome, data.fails)
end)

AddEventHandler('playerDropped', function()
    local p = connections[source]
    if p and p.hackStarted then pcall(finishDeviceHack, source, p, 'cancel', 0) end
    if p and panelLocks[p.key] == p then panelLocks[p.key] = nil end
    connections[source], panelQueries[source] = nil, nil
end)

local function finishAlarm(src, p, booking, room, success)
    local alarm = Config.Security.Alarm or {}
    if not success then
        if alarm.RemoveItemOnFail and p.item then useItem(src, p.item) end
        if p.alarmed and alarm.DispatchOnHackFail ~= false then sendAlarm(src, booking, room, p.lockKind, 'hack_failed') end
        return Fail('notify_hack_failed')
    end
    SetApartmentAlarmDisabled(booking,p.lockKind,true)
    Bridge.notify(src, _L('notify_alarm_hacked'), 'success')
    return { success = true }
end

lib.callback.register('zloma_apartments:lockpickFinish', function(src, data)
    local p = pending[src]
    pending[src] = nil
    if not p or type(data) ~= 'table' or data.token ~= p.token or os.time() > p.expires then return Fail('error_invalid') end
    local booking = p.booking
    if State.booking(booking.hotel, booking.room) ~= booking then return Fail('error_room_free') end
    local room = State.room(booking.hotel, booking.room)
    if not near(src, p.lockKind, booking, room) then return Fail('error_too_far') end
    -- A reply faster than any real minigame is a failure, and games with their
    -- own server check must confirm it.
    local success = data.success == true and os.time() - p.started >= MIN_PLAY_SECONDS
    local def = Security.gameDef(p.minigame)
    if success and def and def.verify then
        local ok, verified = pcall(def.verify, src, Security.settings(p.minigame))
        success = ok and verified == true
    end
    Hook('OnLockpickFinish', src, Bridge.identifier(src), p.kind, booking.hotel, booking.room, success)

    if p.kind=='safe' and p.safeVersion~=SafeLifecycle.generation(booking)then success=false end
    if p.kind == 'alarm' then return finishAlarm(src, p, booking, room, success) end
    if p.alarmed and not alarmHacked(booking, p.kind) then
        sendAlarm(src, booking, room, p.kind, success and 'picked' or 'failed')
    end
    if not success then
        if pickConfig(p.kind).RemoveItemOnFail and p.item then useItem(src, p.item) end
        return Fail('notify_lockpick_failed')
    end
    SetApartmentAlarmDisabled(booking,p.kind,true)
    if p.kind == 'door' then
        SetDoorState(booking.hotel, booking.room, false, true)
        Bridge.notify(src, _L('notify_lockpick_door'), 'success')
        return { success = true }
    end
    return GrantSafeOpen(src, booking, true, p.safeVersion)
end)

AddEventHandler('playerDropped', function()
    pending[source] = nil
    for _, kind in ipairs({ 'door', 'safe', 'alarm' }) do cooldowns[source .. ':' .. kind] = nil end
end)

-- Only the current residents beside this panel can re-arm it; no debug bypass.
lib.callback.register('zloma_apartments:activateAlarm',function(src,data)
    local kind=type(data)=='table' and data.kind
    if kind~='door' and kind~='safe'then return Fail('error_invalid')end
    local booking,room=target(data)
    if not booking or not residentOf(booking,Bridge.identifier(src))then return Fail('error_door_no_access')end
    if not near(src,kind,booking,room)then return Fail('error_too_far')end
    if not currentAlarm(booking,kind)then return Fail('error_invalid')end
    if not alarmHacked(booking,kind)then return {success=true}end
    SetApartmentAlarmDisabled(booking,kind,false)
    return {success=true}
end)
