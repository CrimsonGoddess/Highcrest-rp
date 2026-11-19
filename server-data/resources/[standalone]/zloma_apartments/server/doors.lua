-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Door lock state and doorbell. Free rooms are always locked.
local locked = {}      -- [key] = false when unlocked
local timers = {}
local breached = {}
local knocks = {}

function DoorKey(hotelId, number) return ('%s:%d'):format(hotelId, tonumber(number) or 0) end

local function isLocked(hotelId, number)
    return not State.booking(hotelId, number) or locked[DoorKey(hotelId, number)] ~= false
end

function DoorIsLocked(hotelId, number) return isLocked(hotelId, number) end

function DoorStatesFor(hotelId)
    local result = {}
    for id, list in pairs(State.bookings) do
        if not hotelId or id == hotelId then
            for number in pairs(list) do result[DoorKey(id, number)] = isLocked(id, number) end
        end
    end
    return result
end

function SyncDoors(target)
    TriggerClientEvent('zloma_apartments:client:doors', target or -1, DoorStatesFor())
end

function SetDoorState(hotelId, number, value, picked)
    number = tonumber(number)
    if not hotelId or not number then return false end
    local key = DoorKey(hotelId, number)
    local booking=State.booking(hotelId,number)
    if picked and not value then breached[key]=booking
    elseif value or breached[key]~=booking then breached[key]=nil end
    locked[key] = value == true
    timers[key] = nil
    local seconds = Config.Doors.AutoLockSeconds or 0
    if not locked[key] and not breached[key] and seconds > 0 then
        local timer = {}
        timers[key] = timer
        SetTimeout(seconds * 1000, function()
            if timers[key] == timer and locked[key] == false then SetDoorState(hotelId, number, true) end
        end)
    end
    TriggerClientEvent('zloma_apartments:client:door', -1, key, isLocked(hotelId, number), State.booking(hotelId, number) ~= nil)
    return true
end

local function resident(booking, identifier)
    return booking and identifier and (booking.owner == identifier or booking.roommate == identifier)
end

lib.callback.register('zloma_apartments:useDoor', function(src, data)
    if type(data) ~= 'table' then return Fail('error_invalid') end
    local number = tonumber(data.room_number)
    local room = State.room(data.hotel_id, number)
    local booking = room and State.booking(data.hotel_id, number)
    if not booking then return Fail('error_room_free') end
    if not NearPoint(src, room.door, 4.0) then return Fail('error_too_far') end
    if not resident(booking, Bridge.identifier(src)) then return Fail('error_door_no_access') end
    local value
    if data.action == 'lock' then value = true
    elseif data.action == 'unlock' then value = false
    else value = not isLocked(data.hotel_id, number) end
    SetDoorState(data.hotel_id, number, value)
    Bridge.notify(src, _L(value and 'notify_door_locked' or 'notify_door_unlocked'), 'success', 3000)
    return { success = true, locked = value }
end)

-- Only this character's own door permissions, plus which rooms are occupied.
lib.callback.register('zloma_apartments:getAccess', function(src)
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    local control, owner = {}, {}
    if booking then
        local key = DoorKey(booking.hotel, booking.room)
        control[key] = true
        if booking.owner == identifier then owner[key] = true end
    end
    return { control = control, owner = owner, doors = DoorStatesFor() }
end)

local function canKnock(src)
    local now, list, active = os.time(), knocks[src] or {}, {}
    for _, t in ipairs(list) do if now - t < Config.Doorbell.Window then active[#active + 1] = t end end
    if #active >= Config.Doorbell.MaxKnocks then knocks[src] = active; return false end
    active[#active + 1] = now
    knocks[src] = active
    return true
end

lib.callback.register('zloma_apartments:ringDoorbell', function(src, data)
    if type(data) ~= 'table' then return Fail('error_invalid') end
    local number = tonumber(data.room_number)
    local room = State.room(data.hotel_id, number)
    local booking = room and State.booking(data.hotel_id, number)
    if not booking then return Fail('error_room_free') end
    if not NearPoint(src, room.door, 2.5) then return Fail('error_too_far') end
    if not canKnock(src) then
        Bridge.notify(src, _L('notify_doorbell_rate_limited'), 'error', 3000)
        return Fail('notify_doorbell_rate_limited')
    end
    for _, identifier in ipairs({ booking.owner, booking.roommate }) do
        local target = identifier and Bridge.source(identifier)
        if target and DB.settings(identifier).doorbell_notify then
            TriggerClientEvent('zloma_apartments:client:doorbell', target)
            Bridge.notify(target, _L('notify_doorbell', number), 'info', 6000)
            Hook("OnDoorbell", target, identifier, data.hotel_id, number)
        end
    end
    return { success = true }
end)

AddEventHandler('playerDropped', function() knocks[source] = nil end)
