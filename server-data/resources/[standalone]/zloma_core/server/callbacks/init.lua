-- ZLOMA CORE - Server Callbacks
-- Resource-owned, source-bound callback transport.

local callbacks = {}
local callbackResponses = {}
local callbackRateLimits = {}
local currentRequestId = 0

local CC_TIMEOUT = 'ClientCallback "%s" timed out after %sms!'
local CC_DOES_NOT_EXIST = 'ClientCallback "%s" does not exist!'
local SC_DOES_NOT_EXIST = 'ServerCallback "%s" does not exist!'

local function LogError(text, ...)
    print(('^1[ZLOMA CORE ERROR]^0 ' .. text):format(...))
end

local function GetCallerResource()
    return GetInvokingResource() or GetCurrentResourceName()
end

local function GetRequestKey(name, requestId)
    return ('%s\31%s'):format(name, requestId)
end

local function NextRequestId()
    local requestId = currentRequestId
    currentRequestId = currentRequestId + 1

    if currentRequestId >= math.maxinteger then
        currentRequestId = 0
    end

    return requestId
end

local function GetPackedLength(data)
    if type(data) ~= 'table' then return nil end
    local length = data.n == nil and #data or data.n
    if type(length) ~= 'number' or length % 1 ~= 0 or length < 0 or length > 64 then return nil end
    return length
end

local function UnpackPacked(data)
    local length = GetPackedLength(data)
    if not length then error('Callback payload must contain between 0 and 64 arguments') end
    return table.unpack(data, 1, length)
end

local function InvokeCallback(record, src, data)
    local packed = table.pack(xpcall(function()
        return record.callback(src, UnpackPacked(data))
    end, debug.traceback))

    if not packed[1] then
        return false, packed[2]
    end

    if packed.n - 1 > 64 then return false, 'Callback returned more than 64 values' end

    local result = { n = packed.n - 1 }
    for index = 2, packed.n do
        result[index - 1] = packed[index]
    end

    return true, result
end

local function IsRateLimited(src, name)
    local security = ZlomaCore.Config and ZlomaCore.Config.Security or {}
    local interval = tonumber(security.CallbackRateLimitMs) or 100
    if interval <= 0 then return false end

    local key = ('%s:%s'):format(src, name)
    local now = GetGameTimer()
    local allowedAt = callbackRateLimits[key] or 0
    callbackRateLimits[key] = now + interval
    return now < allowedAt
end

---@param name string Callback name
---@param callback function Callback function(source, ...)
function ZlomaCore.RegisterCallback(name, callback)
    assert(type(name) == 'string' and name ~= '' and #name <= 128, 'Callback name must be 1-128 characters!')
    assert(type(callback) == 'function', 'Callback must be a function!')

    local owner = GetCallerResource()
    local existing = callbacks[name]
    if existing and existing.owner ~= owner then
        LogError('Resource "%s" tried to overwrite callback "%s" owned by "%s".', owner, name, existing.owner)
        return false
    end

    callbacks[name] = {
        callback = callback,
        owner = owner
    }
    return true
end

---@param name string Callback name
function ZlomaCore.RemoveCallback(name)
    local record = callbacks[name]
    if not record then return end

    local caller = GetCallerResource()
    if caller ~= GetCurrentResourceName() and caller ~= record.owner then
        LogError('Resource "%s" tried to remove callback "%s" owned by "%s".', caller, name, record.owner)
        return
    end

    callbacks[name] = nil
end

---@param name string Callback name
---@param playerId number Player server ID
---@param timeout number|nil Timeout in milliseconds
---@vararg any Arguments to pass
---@return any Callback result
function ZlomaCore.TriggerClientCallback(name, playerId, timeout, ...)
    assert(type(name) == 'string' and name ~= '' and #name <= 128, 'Callback name must be 1-128 characters!')
    assert(type(playerId) == 'number', 'Player ID must be a number!')
    if GetPlayerName(playerId) == nil then return nil end

    timeout = tonumber(timeout) or 5000
    if timeout ~= timeout then timeout = 5000 end
    timeout = math.min(60000, math.max(100, timeout))
    local arguments = table.pack(...)
    if arguments.n > 64 then error('Client callback accepts at most 64 arguments') end
    local requestId = NextRequestId()
    local requestName = GetRequestKey(name, requestId)
    local pending = {
        playerId = playerId,
        waiting = true
    }

    -- Store before sending so an immediate response cannot beat registration.
    callbackResponses[requestName] = pending
    TriggerClientEvent('ZlomaCore:cc', playerId, name, requestId, arguments)

    local endTime = GetGameTimer() + timeout
    while pending.waiting do
        Wait(50)
        if GetGameTimer() > endTime then
            pending.waiting = false
            pending.error = true
            LogError(CC_TIMEOUT, name, timeout)
        end
    end

    callbackResponses[requestName] = nil
    if pending.error or type(pending.data) ~= 'table' then return nil end

    return UnpackPacked(pending.data)
end

RegisterNetEvent('ZlomaCore:sc', function(name, requestId, data)
    local src = source

    if type(name) ~= 'string' or name == '' or #name > 128
        or type(requestId) ~= 'number' or requestId % 1 ~= 0 or not GetPackedLength(data) then
        return
    end

    if IsRateLimited(src, name) then
        TriggerClientEvent('ZlomaCore:scError', src, name, requestId)
        return
    end

    local record = callbacks[name]
    if not record then
        LogError(SC_DOES_NOT_EXIST, name)
        TriggerClientEvent('ZlomaCore:scError', src, name, requestId)
        return
    end

    local success, result = InvokeCallback(record, src, data)
    if not success then
        LogError('ServerCallback "%s" owned by "%s" failed:\n%s', name, record.owner, result)
        TriggerClientEvent('ZlomaCore:scError', src, name, requestId)
        return
    end

    TriggerClientEvent('ZlomaCore:scResponse', src, GetRequestKey(name, requestId), result)
end)

RegisterNetEvent('ZlomaCore:ccResponse', function(requestName, data)
    if type(requestName) ~= 'string' or not GetPackedLength(data) then return end

    local pending = callbackResponses[requestName]
    if not pending or pending.playerId ~= source or not pending.waiting then return end

    pending.data = data
    pending.waiting = false
end)

RegisterNetEvent('ZlomaCore:ccError', function(name, requestId)
    if type(name) ~= 'string' or type(requestId) ~= 'number' or requestId % 1 ~= 0 then return end

    local requestName = GetRequestKey(name, requestId)
    local pending = callbackResponses[requestName]
    if not pending or pending.playerId ~= source or not pending.waiting then return end

    pending.error = true
    pending.waiting = false
    LogError(CC_DOES_NOT_EXIST, name)
end)

AddEventHandler('onResourceStop', function(resourceName)
    for name, record in pairs(callbacks) do
        if record.owner == resourceName then
            callbacks[name] = nil
        end
    end

    for requestName, pending in pairs(callbackResponses) do
        if resourceName == GetCurrentResourceName() then
            pending.error = true
            pending.waiting = false
            callbackResponses[requestName] = nil
        end
    end
end)

AddEventHandler('playerDropped', function()
    local prefix = ('%s:'):format(source)
    for key in pairs(callbackRateLimits) do
        if key:sub(1, #prefix) == prefix then
            callbackRateLimits[key] = nil
        end
    end
end)

exports('RegisterCallback', ZlomaCore.RegisterCallback)
exports('RemoveCallback', ZlomaCore.RemoveCallback)
exports('TriggerClientCallback', ZlomaCore.TriggerClientCallback)
