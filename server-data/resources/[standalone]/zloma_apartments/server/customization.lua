-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Optional hooks for your own systems (phone messages, logs, ...).
-- This file is not escrowed. Every hook is called with pcall-safe arguments.
Customization = {}

-- A tenant's daily rent was charged.
function Customization.OnRentPaid(source, identifier, hotelId, room, amount)
    -- Example: exports['your-phone']:SendMessage(source, 'Apartments', ('Room %s: $%s rent paid.'):format(room, amount))
end

-- Daily rent could not be charged. daysLeft = days until eviction.
function Customization.OnRentFailed(source, identifier, hotelId, room, daysLeft)
end

-- Someone rang the tenant's doorbell.
function Customization.OnDoorbell(source, identifier, hotelId, room)
end

-- Someone started lockpicking a door or safe (kind = 'door' | 'safe') or
-- hacking an alarm (kind = 'alarm').
function Customization.OnLockpickStart(source, identifier, kind, hotelId, room)
end

-- A lockpick attempt ended. success = true when the lock opened.
function Customization.OnLockpickFinish(source, identifier, kind, hotelId, room, success)
end

-- An alarm went off: the police got a dispatch (zloma_core) and the owner and
-- roommate are told. kind = 'door' | 'safe'.
-- reason: 'picked' | 'failed' (lockpick) | 'hack_failed'.
function Customization.OnAlarm(source, identifier, hotelId, room, reason, kind)
end

-- How the owner/roommate (target = their server id) hears about an alarm.
-- Return true to replace the ox_lib notification, e.g. with a phone message:
--   exports['your-phone']:SendNotification(target, { app = 'Apartments', message = ... })
-- info = { hotel, hotelLabel, room, kind = 'door'|'safe', reason, coords }
-- Other resources can do the same with exports.zloma_apartments:RegisterAlarmNotifier.
function Customization.OnAlarmOwner(target, identifier, info)
    return false
end
