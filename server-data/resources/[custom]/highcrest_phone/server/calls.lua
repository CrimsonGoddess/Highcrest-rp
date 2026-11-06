local RING_TIMEOUT_MS = 30000

-- Call state lives only on the server, so a client can't join or answer someone else's call.
local calls = {}
local callOf = {}
local nextCallId = 5000

local function otherParty(call, src)
    return src == call.caller and call.callee or call.caller
end

local function endCall(call, reason)
    if not calls[call.id] then return end
    calls[call.id] = nil
    callOf[call.caller] = nil
    callOf[call.callee] = nil

    if call.state == 'active' then
        exports['pma-voice']:setPlayerCall(call.caller, 0)
        exports['pma-voice']:setPlayerCall(call.callee, 0)
    end

    TriggerClientEvent('highcrest_phone:client:callEnded', call.caller, reason)
    TriggerClientEvent('highcrest_phone:client:callEnded', call.callee, reason)
end

lib.callback.register('highcrest_phone:server:startCall', function(source, value)
    local player = GetPhoneOwner(source)
    local number = CleanPhoneNumber(value)
    if not player or not number then return { error = 'Enter a valid number.' } end
    if callOf[source] then return { error = 'You are already on a call.' } end

    local mine = player.PlayerData.charinfo.phone
    if number == mine then return { error = 'You cannot call yourself.' } end

    local target = exports.qbx_core:GetPlayerByPhone(number)
    if not target or not GetPhoneOwner(target.PlayerData.source) then
        return { error = NumberExists(number) and 'No answer.' or 'That number is not in service.' }
    end

    local targetSrc = target.PlayerData.source
    if callOf[targetSrc] then return { error = 'That line is busy.' } end

    nextCallId += 1
    local call = { id = nextCallId, caller = source, callee = targetSrc, state = 'ringing' }
    calls[call.id] = call
    callOf[source] = call
    callOf[targetSrc] = call

    TriggerClientEvent('highcrest_phone:client:incomingCall', targetSrc, {
        number = mine,
        name = GetContactName(target.PlayerData.citizenid, mine),
    })

    SetTimeout(RING_TIMEOUT_MS, function()
        if calls[call.id] == call and call.state == 'ringing' then endCall(call, 'No answer.') end
    end)

    return { number = number, name = GetContactName(player.PlayerData.citizenid, number) }
end)

lib.callback.register('highcrest_phone:server:answerCall', function(source)
    local call = callOf[source]
    if not call or call.callee ~= source or call.state ~= 'ringing' then return end

    call.state = 'active'
    exports['pma-voice']:setPlayerCall(call.caller, call.id)
    exports['pma-voice']:setPlayerCall(call.callee, call.id)

    TriggerClientEvent('highcrest_phone:client:callConnected', call.caller)
    TriggerClientEvent('highcrest_phone:client:callConnected', call.callee)
    return true
end)

lib.callback.register('highcrest_phone:server:hangUp', function(source)
    local call = callOf[source]
    if call then endCall(call, 'Call ended.') end
    return true
end)

AddEventHandler('playerDropped', function()
    local src = source
    local call = callOf[src]
    if not call then return end

    -- The player who left no longer has a voice session to clear.
    callOf[src] = nil
    if call.state == 'active' then
        exports['pma-voice']:setPlayerCall(otherParty(call, src), 0)
        call.state = 'ended'
    end
    endCall(call, 'Call ended.')
end)
