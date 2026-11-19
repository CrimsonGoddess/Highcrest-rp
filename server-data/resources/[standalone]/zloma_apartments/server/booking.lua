-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Renting, buying, cancelling and eviction.
local DAY = 86400
local RECEPTION_DISTANCE = 12.0

function RoomView(booking, identifier, hotelId, number)
    local view = {
        hotel_id = hotelId, room_number = number, floor = math.floor(number / 100),
        status = booking and booking.status or 'free',
    }
    if booking and identifier and (booking.owner == identifier or booking.roommate == identifier) then
        view.is_owner = booking.owner == identifier
        view.rent_type = booking.rentType
        view.daily_price = booking.dailyPrice
        view.safe_level = booking.safeLevel
        view.next_payment = booking.nextPayment and booking.nextPayment * 1000 or nil
        view.rent_end = booking.rentEnd and booking.rentEnd * 1000 or nil
        view.has_roommate = booking.roommate ~= nil
        if booking.roommate and view.is_owner then view.roommate_name = Bridge.name(booking.roommate) end
        if not view.is_owner then view.owner_name = Bridge.name(booking.owner) end
        if view.is_owner and SecurityView then view.security = SecurityView(booking) end
    end
    return view
end

-- Returns total, daily price, rent type, rent end, next payment, status.
function QuotePrice(hotel, paymentType, days, now)
    local p = hotel.pricing
    if paymentType == 'buy' then
        if not hotel.enableBuy then return nil end
        return p.buy, 0, nil, nil, nil, 'owned'
    elseif paymentType == 'prepaid' then
        if not hotel.enablePrepaid then return nil end
        return p.daily, p.daily, 'prepaid', nil, now + DAY, 'rented'
    elseif paymentType == 'contract' then
        if not hotel.enableContract then return nil end
        days = math.floor(tonumber(days) or 0)
        if days < p.contractMinDays or days > p.contractMaxDays then return nil, 'invalid_days' end
        return p.contractDaily * days, p.contractDaily, 'contract', now + days * DAY, nil, 'rented'
    end
end

Mutation('rentOrBuy', function(src, data)
    if type(data) ~= 'table' then return Fail('error_invalid') end
    local hotel = State.hotel(data.hotel_id)
    local number = tonumber(data.room_number)
    local room = hotel and State.room(hotel.id, number)
    if not room then return Fail('error_invalid') end
    if not NearPoint(src, hotel.reception, RECEPTION_DISTANCE) then return Fail('error_too_far') end

    local identifier = Bridge.identifier(src)
    if not identifier then return Fail('error_no_player') end
    if State.apartmentOf(identifier) then return Fail('notify_already_rented') end
    if State.booking(hotel.id, number) then return Fail('notify_room_occupied') end

    local now = os.time()
    local total, daily, rentType, rentEnd, nextPayment, status = QuotePrice(hotel, data.payment_type, data.days, now)
    if not total then return Fail(daily == 'invalid_days' and 'error_invalid_days' or 'error_invalid_payment') end
    if Bridge.money(src) < total then return Fail('notify_insufficient_funds', total) end
    if not Bridge.removeMoney(src, total) then return Fail('error_payment_failed') end

    local booking = {
        hotel = hotel.id, room = number, floor = room.floor, status = status, owner = identifier,
        rentType = rentType, dailyPrice = daily, safeLevel = 1, doorSecurity = 1,
        rentStart = now, rentEnd = rentEnd, nextPayment = nextPayment,
    }
    local saved, err = pcall(DB.insertBooking, booking)
    if not saved then
        Bridge.addMoney(src, total)
        print(('^1[zloma_apartments]^0 Booking write failed: %s'):format(err))
        return Fail('error_booking_failed')
    end
    State.put(booking)
    if RegisterApartmentSafe then RegisterApartmentSafe(booking) end
    SetDoorState(hotel.id, number, true)
    TriggerClientEvent('zloma_apartments:client:refreshAccess', src)
    Bridge.notify(src, _L(status == 'owned' and 'notify_bought' or 'notify_rented', number), 'success')
    return { success = true, room = RoomView(booking, identifier, hotel.id, number), totalPaid = total }
end)

function EvictApartment(hotelId, number, reason)
    local booking = State.booking(hotelId, number)
    if not booking then return false end
    DB.deleteBooking(hotelId, number)
    State.remove(hotelId, number)
    if ReleaseApartmentSafe then ReleaseApartmentSafe(booking) end
    SetDoorState(hotelId, number, true)
    for _, identifier in ipairs({ booking.owner, booking.roommate }) do
        local target = identifier and Bridge.source(identifier)
        if target then
            if reason == 'evict' then Bridge.notify(target, _L('notify_evicted', number), 'error', 10000)
            elseif reason == 'contract_expired' then Bridge.notify(target, _L('notify_contract_expired', number), 'error', 10000) end
            TriggerClientEvent('zloma_apartments:client:evicted', target, { hotel_id = hotelId, room_number = number })
        end
    end
    if Config.Debug then print(('[zloma_apartments] Released %s %d (%s)'):format(hotelId, number, tostring(reason))) end
    return true
end

Mutation('cancelRent', function(src)
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    if not booking then return Fail('notify_no_apartment') end
    if booking.owner ~= identifier then return Fail('notify_not_owner') end
    if booking.status == 'owned' then return Fail('error_cannot_cancel_owned') end
    if booking.rentType == 'contract' then return Fail('error_cannot_cancel_contract') end
    EvictApartment(booking.hotel, booking.room, 'cancel')
    Bridge.notify(src, _L('notify_rent_cancelled', booking.room), 'success')
    return { success = true }
end)

Mutation('upgradeSafe', function(src, data)
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    if not booking then return Fail('notify_no_apartment') end
    if booking.owner ~= identifier then return Fail('notify_not_owner') end
    local record = SafeRecord(booking)
    if not record then return Fail('error_generic') end
    local level = type(data) == 'table' and tonumber(data.new_level)
    if level ~= record.capacity + 1 then return Fail('notify_already_max_level') end
    local upgrade = Config.Safe.Upgrades[level]
    if not upgrade then return Fail('notify_already_max_level') end
    if Bridge.money(src) < upgrade.price then return Fail('notify_insufficient_funds', upgrade.price) end
    if not Bridge.removeMoney(src, upgrade.price) then return Fail('error_payment_failed') end
    local ok = pcall(record.setCapacity, level)
    if not ok then Bridge.addMoney(src, upgrade.price); return Fail('error_generic') end
    RegisterApartmentSafe(booking)
    Bridge.notify(src, _L('notify_safe_upgraded', upgrade.label), 'success')
    return { success = true, new_level = level, security = SecurityView and SecurityView(booking) }
end)
