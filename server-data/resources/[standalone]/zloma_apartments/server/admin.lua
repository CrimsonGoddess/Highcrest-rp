-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- In-game building creator. Buildings are stored in zloma_apartment_hotels.
-- A preset (WiWang) can be overridden; deleting the override restores it.

local function occupancy()
    local result = {}
    for id, rooms in pairs(State.bookings) do
        local count = 0
        for _ in pairs(rooms) do count = count + 1 end
        result[id] = count
    end
    return result
end

-- Lock levels the admin can price per building (level 1 is always included).
local function securityInfo()
    local info = { enabled = Security.enabled, configured = Config.Security and Config.Security.Enabled == true,
        errors = Security.errors, safe = Config.Safe.Enabled == true }
    if not Security.enabled then return info end
    for _, kind in ipairs({ 'door', 'safe' }) do
        local levels = {}
        for level, l in ipairs(Security.levelsConfig(kind)) do
            levels[level] = { level = level, label = l.label, game = l.game, difficulty = l.difficulty, price = tonumber(l.price) or 0 }
        end
        info[kind] = levels
    end
    return info
end

local function adminPayload()
    local presets = {}
    for id in pairs(State.presets()) do presets[id] = true end
    return {
        success = true,
        hotels = State.hotels, custom = State.custom, presets = presets, occupancy = occupancy(),
        sets = Furniture.sets, placements = Furniture.placements, catalog = Furniture.catalog,
        defaults = Config.BuildingDefaults, locale = UiLocale(), security = securityInfo(),
    }
end

lib.callback.register('zloma_apartments:admin:open', function(src)
    if not Bridge.isAdmin(src) then return Fail('error_no_permission') end
    return adminPayload()
end)

local function broadcast()
    State.syncHotels()
    SyncDoors()
end

-- Every room that has a booking must still exist after the change.
function ValidateHotelChange(def)
    local booked = State.bookings[def.id]
    if not booked then return true end
    for number in pairs(booked) do
        if not Hotels.room(def, number) then return false, number end
    end
    return true
end

function SaveHotel(raw)
    local def, err = Hotels.normalize(raw)
    if not def then return nil, 'error_hotel_' .. err end
    local ok, number = ValidateHotelChange(def)
    if not ok then return nil, 'error_hotel_booked_room', number end
    def.preset = State.presets()[def.id] ~= nil
    local stored = Hotels.copy(def)
    stored.preset = nil
    DB.saveHotel(def.id, json.encode(stored))
    State.hotels[def.id], State.custom[def.id] = def, true
    Hotels.defs = State.hotels
    broadcast()
    return def
end

AdminMutation('saveHotel', function(_, data)
    local def, err, extra = SaveHotel(data.hotel)
    if not def then return Fail(err, extra) end
    local payload = adminPayload()
    payload.saved = def.id
    return payload
end)

function DeleteHotel(id)
    if not State.custom[id] then return nil, 'error_hotel_not_custom' end
    local preset = State.presets()[id]
    if not preset and State.occupied(id) then return nil, 'error_hotel_occupied' end
    if preset then
        local def = Hotels.normalize(Hotels.copy(preset))
        local ok = def and ValidateHotelChange(def)
        if not ok then return nil, 'error_hotel_booked_room' end
        DB.deleteHotelOverride(id)
        def.preset = true
        State.hotels[id] = def
    else
        DB.deleteHotel(id)
        State.hotels[id] = nil
        for k, p in pairs(Furniture.placements) do if p.hotel == id then Furniture.placements[k] = nil end end
        Furniture.publish()
    end
    State.custom[id] = nil
    Hotels.defs = State.hotels
    broadcast()
    return true
end

AdminMutation('deleteHotel', function(_, data)
    local ok, err = DeleteHotel(data.id)
    if not ok then return Fail(err) end
    return adminPayload()
end)

AdminMutation('evictRoom', function(src, data)
    local number = tonumber(data.room)
    if not State.booking(data.hotel, number) then return Fail('error_room_free') end
    EvictApartment(data.hotel, number, 'admin')
    Bridge.notify(src, _L('notify_admin_evicted', number), 'success')
    return adminPayload()
end)

lib.callback.register('zloma_apartments:admin:roomCoords', function(src, data)
    if not Bridge.isAdmin(src) or type(data) ~= 'table' then return nil end
    local room = State.room(data.hotel, data.room)
    return room and room.door or nil
end)
