-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- In-memory state. The database is written first; the cache follows.
State = {
    hotels = {},        -- [id] = normalized definition
    custom = {},        -- [id] = true when the definition is stored in the database
    bookings = {},      -- [hotelId] = { [room] = booking }
    residents = {},     -- [identifier] = { hotel = id, room = number }
}

local function decode(value)
    local ok, result = pcall(json.decode, value)
    return ok and type(result) == 'table' and result or nil
end

function State.presets()
    local list = {}
    if Config.WiWang ~= false and ApartmentPresets and ApartmentPresets.wiwang then
        list.wiwang = ApartmentPresets.wiwang
    end
    return list
end

-- Presets first; a database row with the same id is an admin override.
function State.loadHotels()
    local hotels, custom = {}, {}
    for id, raw in pairs(State.presets()) do
        local def, err = Hotels.normalize(Hotels.copy(raw))
        if def then def.preset = true; hotels[id] = def
        else print(('^1[zloma_apartments]^0 Preset %s is invalid: %s'):format(id, err)) end
    end
    for _, row in ipairs(DB.loadHotels()) do
        local raw = decode(row.data)
        if raw then
            raw.id = row.id
            -- Existing overrides created before photos inherit the preset once.
            -- An explicitly saved empty string still disables the default photo.
            if raw.imageUrl == nil then
                local preset = State.presets()[row.id]
                raw.imageUrl = preset and preset.imageUrl or nil
            end
            local def, err = Hotels.normalize(raw)
            if def then
                def.preset = hotels[row.id] ~= nil and hotels[row.id].preset or false
                hotels[row.id] = def
                custom[row.id] = true
            else
                print(('^1[zloma_apartments]^0 Building %s in the database is invalid: %s'):format(row.id, err))
            end
        end
    end
    State.hotels, State.custom = hotels, custom
    Hotels.defs = hotels
end

function State.hotel(id) return State.hotels[id] end

function State.room(hotelId, number)
    return Hotels.room(State.hotels[hotelId], tonumber(number))
end

function State.booking(hotelId, number)
    local list = State.bookings[hotelId]
    return list and list[tonumber(number)] or nil
end

function State.apartmentOf(identifier)
    local ref = identifier and State.residents[identifier]
    if not ref then return nil end
    return State.booking(ref.hotel, ref.room), ref
end

function State.put(booking)
    State.bookings[booking.hotel] = State.bookings[booking.hotel] or {}
    State.bookings[booking.hotel][booking.room] = booking
    if booking.owner then State.residents[booking.owner] = { hotel = booking.hotel, room = booking.room } end
    if booking.roommate then State.residents[booking.roommate] = { hotel = booking.hotel, room = booking.room } end
end

function State.remove(hotelId, number)
    local booking = State.booking(hotelId, number)
    if not booking then return nil end
    State.bookings[hotelId][booking.room] = nil
    if booking.owner then State.residents[booking.owner] = nil end
    if booking.roommate then State.residents[booking.roommate] = nil end
    return booking
end

function State.setRoommate(booking, identifier)
    if booking.roommate then State.residents[booking.roommate] = nil end
    booking.roommate = identifier
    if identifier then State.residents[identifier] = { hotel = booking.hotel, room = booking.room } end
end

function State.occupied(hotelId)
    local list = State.bookings[hotelId]
    return list and next(list) ~= nil
end

function State.loadBookings()
    State.bookings, State.residents = {}, {}
    local skipped = 0
    for _, row in ipairs(DB.loadBookings()) do
        local number = tonumber(row.room_number)
        if State.room(row.hotel_id, number) then
            State.put({
                hotel = row.hotel_id, room = number, floor = math.floor(number / 100),
                status = row.status, owner = row.owner_id, roommate = row.roommate_id,
                rentType = row.rent_type, dailyPrice = tonumber(row.daily_price) or 0,
                safeLevel = math.max(1, math.min(#Config.Safe.Upgrades, tonumber(row.safe_level) or 1)),
                doorSecurity = tonumber(row.door_security) or 1,
                rentStart = tonumber(row.rent_start), rentEnd = tonumber(row.rent_end),
                nextPayment = tonumber(row.next_payment),
            })
        else
            skipped = skipped + 1
        end
    end
    if skipped > 0 then
        print(('^3[zloma_apartments]^0 %d booking(s) belong to a building or room that is not loaded. They are kept in the database.'):format(skipped))
    end
end

-- Client copy: geometry for doors/props, never owners.
function State.clientHotels()
    return State.hotels
end

function State.syncHotels(target)
    TriggerClientEvent('zloma_apartments:client:hotels', target or -1, State.clientHotels())
end
