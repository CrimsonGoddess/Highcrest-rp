-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Daily rent. Due dates live in the database, so restarts never reset the
-- grace period. Rent is charged while the tenant is online; if a day stays
-- unpaid for Config.GracePeriodDays the apartment is released.
local DAY = 86400
local MAX_DAYS_PER_CHECK = 30
local warned, reminded = {}, {}

local function key(b) return b.hotel .. ':' .. b.room end

function ProcessRent(booking, now)
    if booking.status ~= 'rented' then return 'skip' end
    if booking.rentType == 'contract' then
        if booking.rentEnd and booking.rentEnd <= now then
            EvictApartment(booking.hotel, booking.room, 'contract_expired')
            return 'expired'
        end
        return 'ok'
    end
    if booking.rentType ~= 'prepaid' or not booking.nextPayment or booking.nextPayment > now then return 'ok' end

    local src = Bridge.source(booking.owner)
    local paid = 0
    if src then
        while booking.nextPayment <= now and paid < MAX_DAYS_PER_CHECK do
            if Bridge.money(src) < booking.dailyPrice or not Bridge.removeMoney(src, booking.dailyPrice) then break end
            booking.nextPayment = booking.nextPayment + DAY
            paid = paid + 1
        end
        if paid > 0 then
            DB.setNextPayment(booking.hotel, booking.room, booking.nextPayment)
            warned[key(booking)] = nil
            Bridge.notify(src, _L('notify_payment_success', booking.dailyPrice * paid), 'success')
            Hook("OnRentPaid", src, booking.owner, booking.hotel, booking.room, booking.dailyPrice * paid)
        end
    end
    if booking.nextPayment > now then return 'paid' end

    local overdue = now - booking.nextPayment
    if Config.EvictOnNonPayment and overdue >= Config.GracePeriodDays * DAY then
        EvictApartment(booking.hotel, booking.room, 'evict')
        return 'evicted'
    end
    if src and (warned[key(booking)] or 0) <= now then
        warned[key(booking)] = now + 3600
        local daysLeft = math.max(1, math.ceil((Config.GracePeriodDays * DAY - overdue) / DAY))
        Bridge.notify(src, _L('notify_payment_failed', booking.dailyPrice, daysLeft), 'error', 8000)
        Hook("OnRentFailed", src, booking.owner, booking.hotel, booking.room, daysLeft)
    end
    return 'unpaid'
end

function RemindRent(booking, now)
    if booking.rentType ~= 'prepaid' or not booking.nextPayment then return false end
    local left = booking.nextPayment - now
    if left <= 0 or left > Config.PaymentReminderHours * 3600 then return false end
    local k = key(booking) .. ':' .. booking.nextPayment
    if reminded[k] then return false end
    local src = Bridge.source(booking.owner)
    if not src or not DB.settings(booking.owner).payment_remind then return false end
    reminded[k] = true
    Bridge.notify(src, _L('notify_payment_reminder', booking.dailyPrice, Config.PaymentReminderHours), 'warning', 8000)
    return true
end

function RunRentCycle(now)
    now = now or os.time()
    local list = {}
    for _, rooms in pairs(State.bookings) do
        for _, booking in pairs(rooms) do list[#list + 1] = booking end
    end
    for _, booking in ipairs(list) do
        local ok, err = pcall(ProcessRent, booking, now)
        if not ok then print(('^1[zloma_apartments]^0 Rent check failed for %s: %s'):format(key(booking), err))
        elseif State.booking(booking.hotel, booking.room) == booking then pcall(RemindRent, booking, now) end
    end
end

CreateThread(function()
    while not DB.ready do Wait(500) end
    Wait(5000)
    while true do
        RunRentCycle()
        Wait(math.max(10, Config.PaymentCheckInterval) * 1000)
    end
end)
