-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Startup, UI data and exports.

local function upgradesMap()
    local result = {}
    for level, u in pairs(Config.Safe.Upgrades) do result[tostring(level)] = u end
    return result
end

lib.callback.register('zloma_apartments:getRooms', function(src, hotelId)
    local hotel = State.hotel(hotelId)
    if not hotel then return nil end
    local identifier = Bridge.identifier(src)
    local rooms = {}
    Hotels.each(hotel, function(number, floor)
        local booking = State.booking(hotel.id, number)
        rooms[#rooms + 1] = { room_number = number, floor = floor, status = booking and booking.status or 'free', image_url = Hotels.image(hotel, number) }
    end)
    table.sort(rooms, function(a, b) return a.room_number < b.room_number end)
    local mine = State.apartmentOf(identifier)
    local myApartment
    if mine then
        myApartment = RoomView(mine, identifier, mine.hotel, mine.room)
        myApartment.hotel_label = State.hotel(mine.hotel) and State.hotel(mine.hotel).label or mine.hotel
    end
    return {
        rooms = rooms,
        myApartment = myApartment,
        playerMoney = Bridge.money(src),
        playerName = identifier and Bridge.name(identifier, src) or GetPlayerName(src),
        hotel = Hotels.public(hotel),
        safeUpgrades = upgradesMap(),
        features = { roommates = Config.Roommates.Enabled, safe = Config.Safe.Enabled, roommateDistance = Config.Roommates.Distance, pinLength = Config.Safe.PinLength, security = Security.enabled },
        locale = UiLocale(),
        lang = Config.Locale,
    }
end)

lib.callback.register('zloma_apartments:getSettings', function(src)
    local identifier = Bridge.identifier(src)
    return identifier and DB.settings(identifier) or {}
end)

Mutation('saveSettings', function(src, data)
    local identifier = Bridge.identifier(src)
    if not identifier or type(data) ~= 'table' then return Fail('error_invalid') end
    DB.saveSettings(identifier, { doorbell_notify = data.doorbell_notify == true, payment_remind = data.payment_remind == true })
    return { success = true }
end)

-- Everything a client needs after joining or after a resource restart.
lib.callback.register('zloma_apartments:bootstrap', function()
    if not DB.ready then return nil end
    return { hotels = State.clientHotels(), doors = DoorStatesFor(), sets = Furniture.sets, placements = Furniture.placements,
        lockpick = Security.lockpick, safeMode = SafeMode() }
end)

local function migrateLegacyHotelId()
    if Config.WiWang == false or DB.meta('migrated_main_hotel') then return end
    local moved = DB.renameHotel('main_hotel', 'wiwang')
    if moved and moved > 0 then print(('^2[zloma_apartments]^0 Moved %d booking(s) from main_hotel to wiwang.'):format(moved)) end
    DB.setMeta('migrated_main_hotel', '1')
end

function StartApartments()
    DB.init()
    migrateLegacyHotelId()
    State.loadHotels()
    State.loadBookings()
    Furniture.load()
    local seeded = Furniture.seed()
    for _, rooms in pairs(State.bookings) do
        for _, booking in pairs(rooms) do pcall(RegisterApartmentSafe, booking) end
    end
    State.syncHotels()
    SyncDoors()
    Furniture.publish()
    local count = 0
    for _ in pairs(State.hotels) do count = count + 1 end
    print(('^2[zloma_apartments]^0 Ready: %d building(s)%s.'):format(count, seeded > 0 and (', %d furnished rooms installed'):format(seeded) or ''))
end

CreateThread(function()
    local ok, err = pcall(StartApartments)
    if not ok then print(('^1[zloma_apartments]^0 Startup failed: %s'):format(err)) end
end)

-- Exports ---------------------------------------------------------------------

-- Returns { hotel, room, role = 'owner'|'roommate', status } or nil.
exports('GetPlayerApartment', function(src)
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    if not booking then return nil end
    return { hotel = booking.hotel, room = booking.room, status = booking.status, role = booking.owner == identifier and 'owner' or 'roommate' }
end)

exports('GetBuildings', function()
    local result = {}
    for id, def in pairs(State.hotels) do result[id] = Hotels.public(def) end
    return result
end)
