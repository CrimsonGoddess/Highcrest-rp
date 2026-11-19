-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- One roommate per apartment. The roommate can use the door; the safe stays private.
local function nearbyPlayers(src)
    local result = {}
    local ped = GetPlayerPed(src)
    if ped == 0 then return result end
    local coords = GetEntityCoords(ped)
    local bucket = GetPlayerRoutingBucket(src)
    for _, p in ipairs(Bridge.onlinePlayers()) do
        local target = tonumber(p.source)
        local targetPed = target and target ~= src and GetPlayerPed(target) or 0
        if targetPed ~= 0 and GetPlayerRoutingBucket(target) == bucket then
            local distance = #(coords - GetEntityCoords(targetPed))
            if distance <= Config.Roommates.Distance then
                result[#result + 1] = { source = target, name = p.name or GetPlayerName(target), distance = math.floor(distance * 10) / 10 }
            end
        end
    end
    table.sort(result, function(a, b) return a.distance < b.distance end)
    return result
end

lib.callback.register('zloma_apartments:getNearbyPlayers', function(src)
    if not Config.Roommates.Enabled then return {} end
    return nearbyPlayers(src)
end)

Mutation('addRoommate', function(src, data)
    if not Config.Roommates.Enabled then return Fail('error_invalid') end
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    if not booking or booking.owner ~= identifier then return Fail('notify_not_owner') end
    if booking.roommate then return Fail('notify_already_has_roommate') end
    local target = type(data) == 'table' and tonumber(data.target_source)
    local valid = false
    for _, p in ipairs(target and nearbyPlayers(src) or {}) do if p.source == target then valid = true end end
    if not valid then return Fail('error_roommate_distance', Config.Roommates.Distance) end
    local targetId = Bridge.identifier(target)
    if not targetId or targetId == identifier then return Fail('error_invalid') end
    if State.apartmentOf(targetId) then return Fail('notify_roommate_has_apartment') end
    DB.setRoommate(booking.hotel, booking.room, targetId)
    State.setRoommate(booking, targetId)
    Bridge.notify(target, _L('notify_roommate_joined', booking.room), 'success')
    TriggerClientEvent('zloma_apartments:client:refreshAccess', target)
    return { success = true, roommate_name = Bridge.name(targetId, target) }
end)

local function release(booking)
    local previous = booking.roommate
    DB.setRoommate(booking.hotel, booking.room, nil)
    State.setRoommate(booking, nil)
    SetDoorState(booking.hotel, booking.room, true)
    local target = Bridge.source(previous)
    if target then
        TriggerClientEvent('zloma_apartments:client:refreshAccess', target)
        return target
    end
end

Mutation('removeRoommate', function(src)
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    if not booking or booking.owner ~= identifier then return Fail('notify_not_owner') end
    if not booking.roommate then return Fail('error_no_roommate') end
    local target = release(booking)
    if target then
        Bridge.notify(target, _L('notify_roommate_removed_you', booking.room), 'error')
        TriggerClientEvent('zloma_apartments:client:closeUI', target)
    end
    Bridge.notify(src, _L('notify_roommate_removed'), 'success')
    return { success = true }
end)

Mutation('leaveApartment', function(src)
    local identifier = Bridge.identifier(src)
    local booking = State.apartmentOf(identifier)
    if not booking or booking.roommate ~= identifier then return Fail('notify_no_apartment') end
    release(booking)
    local owner = Bridge.source(booking.owner)
    if owner then Bridge.notify(owner, _L('notify_roommate_left', booking.room), 'info') end
    Bridge.notify(src, _L('notify_left_apartment', booking.room), 'success')
    return { success = true }
end)
