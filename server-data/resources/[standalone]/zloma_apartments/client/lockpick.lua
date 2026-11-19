-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Lockpicking apartment doors (key) and safes (target option on the safe), and
-- hacking their alarms (door: key, safe: target option). The server chooses the minigame; this file plays it.
-- Options are shown only when the player has the items for them (asked from
-- the server, cached for a moment).
local busy = false
function IsApartmentMinigameBusy() return busy end
local DICT, ANIM = 'mp_arresting', 'a_uncuff'
local OPTIONS_TTL = 2000
local options = {} -- 'kind:hotel:room' -> { at, value, asking }

-- Cached server answer { lockpick, hack }; refreshed in the background.
function LockpickOptions(kind, hotel, number)
    local key = ('%s:%s:%s'):format(kind, hotel, number)
    local entry = options[key]
    local now = GetGameTimer()
    if not entry then
        entry = { at = 0, value = {} }
        options[key] = entry
    end
    if now - entry.at > OPTIONS_TTL and not entry.asking then
        entry.asking = true
        CreateThread(function()
            local value = lib.callback.await('zloma_apartments:lockpickOptions', false, { kind = kind, hotel_id = hotel, room_number = number })
            entry.value, entry.at, entry.asking = type(value) == 'table' and value or {}, GetGameTimer(), false
        end)
    end
    return entry.value
end

local function forget(kind, hotel, number) options[('%s:%s:%s'):format(kind, hotel, number)] = nil end

local function doorContext(door)
    if not door then return nil end
    local entity = door.entity and DoesEntityExist(door.entity) and door.entity or nil
    return { coords = door.coords, model = door.model, entity = entity }
end

-- kind: 'door' | 'safe' | 'alarm'; lock: what is broken into ('door' | 'safe').
local function play(kind, hotel, number, door, lock)
    if busy or (AlarmPanels and (AlarmPanels.busy or AlarmPanels.editing)) then return end
    busy = true
    local start = lib.callback.await('zloma_apartments:lockpickStart', false,
        { kind = kind, target = lock, hotel_id = hotel, room_number = number })
    if not start or not start.success then
        busy = false
        ClientBridge.notify(start and start.error or _L('error_generic'), 'error')
        return
    end
    -- Games with their own scene (tr_lockpick) animate the player themselves.
    local own = start.minigame and (start.minigame.game == 'tr_lockpick' or start.minigame.game == 'safecrack')
    local ped = PlayerPedId()
    if not own then
        lib.requestAnimDict(DICT)
        TaskPlayAnim(ped, DICT, ANIM, 8.0, -8.0, -1, 49, 0, false, false, false)
    end
    MinigameLockBegin(false) -- no inventory while breaking in
    local success = Security.play(start.minigame, { kind = kind, door = doorContext(door), safe = SafeProps and SafeProps.entities[hotel..':'..number] })
    MinigameLockEnd(false)
    if not own then
        StopAnimTask(ped, DICT, ANIM, 1.0)
        RemoveAnimDict(DICT)
    end
    local result = lib.callback.await('zloma_apartments:lockpickFinish', false, { token = start.token, success = success })
    busy = false
    forget(lock, hotel, number)
    if not result or not result.success then
        ClientBridge.notify(result and result.error or _L('notify_lockpick_failed'), 'error')
    end
end

local function atLockedDoor()
    local door, hasAccess, isLocked = CurrentApartmentDoor()
    if not door or (hasAccess and not Config.Debug) or not isLocked then return nil end
    return door
end

-- Called by the door's sleepless_interact options (client/doors.lua).
function LockpickApartmentDoor()
    local door = atLockedDoor()
    if not door or not LockpickOptions('door', door.hotel, door.number).lockpick then return end
    play('door', door.hotel, door.number, door, 'door')
end

function HackApartmentDoor()
    local door = atLockedDoor()
    if not door or not LockpickOptions('door', door.hotel, door.number).hack then return end
    play('alarm', door.hotel, door.number, door, 'door')
end

-- Called by the safe target options (client/safe.lua).
function LockpickApartmentSafe(hotel, number)
    if ClientState.lockpick and ClientState.lockpick.safe then play('safe', hotel, number, nil, 'safe') end
end

function HackApartmentSafe(hotel, number)
    if Config.Security.Alarm.Panel.Enabled and Config.Security.Alarm.Panel.SafeEnabled ~= false then return StartAlarmConnection(hotel,number,'safe') end
    play('alarm', hotel, number, nil, 'safe')
end

-- The owner/roommate's alarm went off (unless another resource handles it,
-- see RegisterAlarmNotifier / Customization.OnAlarmOwner on the server).
RegisterNetEvent('zloma_apartments:alarmNotify', function(info)
    if type(info) ~= 'table' then return end
    lib.notify({
        title = _L('alarm_notify_title'),
        description = _L(info.kind == 'safe' and 'alarm_notify_safe' or 'alarm_notify_door', info.room, info.hotelLabel or ''),
        type = 'error',
        icon = 'bell',
        duration = 10000,
    })
end)
