-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Apartment safe, opened at the safe prop with a PIN (or by lockpicking).
-- Config.Safe.Mode = 'character': one safe per character; contents, size and
--   lock level follow the character to every apartment.
-- Config.Safe.Mode = 'apartment': one safe per room; contents stay when the
--   tenant leaves and the next tenant sets a new PIN.
local PREFIX = { character = 'apt_personal_', apartment = 'apt_room_' }
local grants, attempts, owners, pinVersions = {}, {}, {}, {}

function SafeMode() return Config.Safe.Mode == 'apartment' and 'apartment' or 'character' end

local function upgrade(level) return Config.Safe.Upgrades[level] or Config.Safe.Upgrades[1] end
local function clampCapacity(level) return math.max(1, math.min(#Config.Safe.Upgrades, tonumber(level) or 1)) end

-- The safe that belongs to this booking under the current mode.
function SafeRecord(booking)
    if not booking or not booking.owner then return nil end
    if SafeMode() == 'apartment' then
        local row = DB.roomSafe(booking.hotel, booking.room)
        if not row then return nil end
        return {
            key = ('room:%s:%d'):format(booking.hotel, booking.room), stash = PREFIX.apartment .. row.id,
            pinHash = row.pin_hash, capacity = clampCapacity(row.capacity_level), security = tonumber(row.security_level) or 1,
            setPin = function(pin) return DB.setRoomSafePin(row.id, booking.hotel, booking.room, pin) end,
            hash = function(pin) return DB.roomPinHash(booking.hotel, booking.room, pin) end,
            setCapacity = function(level) return DB.setRoomSafeCapacity(row.id, level) end,
            setSecurity = function(level) return DB.setRoomSafeSecurity(row.id, level) end,
        }
    end
    local row = DB.safe(booking.owner)
    if not row then return nil end
    -- Older builds kept the bought size on the booking; never lose it.
    local capacity = clampCapacity(math.max(tonumber(row.capacity_level) or 1, booking.safeLevel or 1))
    if capacity ~= tonumber(row.capacity_level) then DB.setSafeCapacity(row.id, capacity) end
    return {
        key = 'char:' .. booking.owner, stash = PREFIX.character .. row.id,
        pinHash = row.pin_hash, capacity = capacity, security = tonumber(row.security_level) or 1,
        setPin = function(pin) return DB.setPin(row.id, pin) end,
        hash = function(pin) return DB.pinHash(booking.owner, pin) end,
        setCapacity = function(level) return DB.setSafeCapacity(row.id, level) end,
        setSecurity = function(level) return DB.setSafeSecurity(row.id, level) end,
    }
end

local function ownBooking(src)
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    if not booking or booking.owner ~= identifier then return nil end
    return booking, identifier
end

function NearSafe(src, booking)
    local room = booking and State.room(booking.hotel, booking.room)
    return room and room.safe and NearPoint(src, room.safe, Config.Safe.TargetDistance + 1.0) or false
end

-- Explicit target comes from the selected room safe, never a client stash id.
function SafeTargetBooking(src, data)
    if type(data) == 'table' and (data.hotel_id ~= nil or data.room_number ~= nil) then
        if type(data.hotel_id) ~= 'string' or type(data.room_number) ~= 'number' then return nil end
        return State.booking(data.hotel_id, data.room_number)
    end
    return ownBooking(src)
end

-- Registers (or resizes) the stash of this booking's safe.
function RegisterApartmentSafe(booking)
    if not Config.Safe.Enabled or not booking or not booking.owner then return nil end
    local record = SafeRecord(booking)
    if not record then return nil end
    if record.capacity ~= booking.safeLevel then
        DB.setSafeLevel(booking.hotel, booking.room, record.capacity)
        booking.safeLevel = record.capacity
    end
    local cfg = upgrade(record.capacity)
    owners[record.stash] = record.key
    Bridge.registerStash(record.stash, cfg.label, cfg.slots, cfg.weight)
    -- ox_inventory keeps a loaded inventory's old size until it unloads.
    if GetResourceState('ox_inventory') == 'started' then
        pcall(function()
            local inv = exports.ox_inventory:GetInventory(record.stash)
            if inv then
                exports.ox_inventory:SetSlotCount(inv, cfg.slots)
                exports.ox_inventory:SetMaxWeight(inv, cfg.weight)
            end
        end)
    end
    return record.stash, record, cfg
end

-- A room was released. In apartment mode the next tenant sets a new PIN.
function ReleaseApartmentSafe(booking)
    if SafeLifecycle then SafeLifecycle.release(booking) end
    if SafeMode() ~= 'apartment' or not booking then return end
    DB.clearRoomSafePin(booking.hotel, booking.room)
    local key = ('room:%s:%d'):format(booking.hotel, booking.room)
    pinVersions[key] = (pinVersions[key] or 0) + 1
    attempts[key] = nil
    for player, grant in pairs(grants) do if grant.key == key then grants[player] = nil end end
end

local function validPin(pin)
    return type(pin) == 'string' and #pin == Config.Safe.PinLength and pin:match('^%d+$') ~= nil
end

Mutation('setSafePin', function(src, data)
    local booking = ownBooking(src)
    if not booking then return Fail('error_safe_owner_only') end
    if type(data) ~= 'table' or not validPin(data.pin) then return Fail('error_pin_format', Config.Safe.PinLength) end
    local record = SafeRecord(booking)
    if not record then return Fail('error_generic') end
    if not record.pinHash and not NearSafe(src, booking) then return Fail('error_pin_first_at_safe') end
    record.setPin(data.pin)
    pinVersions[record.key] = (pinVersions[record.key] or 0) + 1
    attempts[record.key] = nil
    for player, grant in pairs(grants) do
        if grant.key == record.key then grants[player] = nil end
    end
    return { success = true }
end)

-- Opens the stash for src right now. Used after a correct PIN or a successful lockpick.
function OpenSafeInventoryNow(src, booking, authorization)
    local identifier, bucket = Bridge.identifier(src), GetPlayerRoutingBucket(src)
    local id, record, cfg = RegisterApartmentSafe(booking)
    if not id then return Fail('error_generic') end
    local current = State.booking(booking.hotel, booking.room)
    if current ~= booking or not NearSafe(src, booking) or not authorization
        or not SafeLifecycle.current(src,authorization) then return Fail('error_safe_too_far') end
    grants[src] = { id = id, key = record.key, identifier = identifier, hotel = booking.hotel, room = booking.room,
        booking = booking, bucket = bucket, authorization=authorization, version = pinVersions[record.key] or 0, expires = os.time() + 10 }
    TriggerClientEvent('zloma_apartments:client:closeUI', src)
    if not Bridge.openStash(src, id, cfg.label, cfg.slots, cfg.weight) then
        RevokeSafeGrant(src,authorization)
        return Fail('error_generic')
    end
    return { success = true }
end

function SafePinVersion(key) return pinVersions[key] or 0 end
function RevokeSafeGrant(src,authorization)
    if not authorization or (grants[src] and grants[src].authorization==authorization)then grants[src]=nil end
end
function GrantSafeOpen(src,booking,mode,generation)
    return SafeLifecycle.open(src,booking,mode,generation or SafeLifecycle.generation(booking))
end

Mutation('openSafe', function(src, data)
    grants[src] = nil
    if not Config.Safe.Enabled then return Fail('error_generic') end
    local identifier = Bridge.identifier(src)
    local booking = SafeTargetBooking(src, data)
    if not identifier or not booking or not booking.owner then return Fail('error_safe_too_far') end
    if not NearSafe(src, booking) then return Fail('error_safe_too_far') end
    local generation=SafeLifecycle.generation(booking)
    if SafeLifecycle.isBreached(booking) then return GrantSafeOpen(src,booking,'breached',generation) end
    local record = SafeRecord(booking)
    if not record then return Fail('error_generic') end
    if not record.pinHash then
        if identifier ~= booking.owner then return Fail('error_pin_not_set') end
        return { success = false, needs_pin_setup = true }
    end
    if type(data) ~= 'table' or not validPin(data.pin) then return { success = false, needs_pin = true } end
    local now = os.time()
    local state = attempts[record.key]
    if state and state.untilTime > now then return Fail('error_pin_locked', state.untilTime - now) end
    if state and state.untilTime ~= 0 then state = nil end
    if record.hash(data.pin) ~= record.pinHash then
        state = state or { count = 0, untilTime = 0 }
        state.count = state.count + 1
        if state.count >= Config.Safe.MaxAttempts then state.untilTime = now + Config.Safe.LockoutSeconds end
        attempts[record.key] = state
        return Fail('error_pin_wrong')
    end
    attempts[record.key] = nil
    if Bridge.identifier(src) ~= identifier then return Fail('error_safe_too_far') end
    return GrantSafeOpen(src, booking, false, generation)
end)

-- One accepted PIN or lockpick grants one inventory open, bound to this player and room.
function SafeOpenAllowed(src, inventoryId)
    local id = tostring(inventoryId)
    if id:sub(1, #PREFIX.character) ~= PREFIX.character and id:sub(1, #PREFIX.apartment) ~= PREFIX.apartment then return true end
    local grant = grants[src]
    local booking = grant and State.booking(grant.hotel, grant.room)
    if not grant or grant.id ~= id or grant.identifier ~= Bridge.identifier(src) or grant.expires < os.time()
        or not booking or booking ~= grant.booking or owners[id] ~= grant.key
        or grant.version ~= (pinVersions[grant.key] or 0) or GetPlayerRoutingBucket(src) ~= grant.bucket
        or not NearSafe(src, booking) or not SafeLifecycle.current(src,grant.authorization) then return false end
    grants[src] = nil
    return true
end

CreateThread(function()
    if GetResourceState('ox_inventory') ~= 'started' then return end
    pcall(function()
        exports.ox_inventory:registerHook('openInventory', function(payload)
            if not SafeOpenAllowed(payload.source, payload.inventoryId) then return false end
        end, { inventoryFilter = { '^' .. PREFIX.character, '^' .. PREFIX.apartment } })
    end)
end)

AddEventHandler('playerDropped', function() grants[source] = nil end)
