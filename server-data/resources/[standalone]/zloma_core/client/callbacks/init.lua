-- ZLOMA CORE - Client Callbacks
-- Resource-owned callback transport with server-only response validation.

local callbacks = {}
local callbackResponses = {}
local currentRequestId = 0

local SC_TIMEOUT = 'ServerCallback "%s" timed out after %sms!'
local SC_DOES_NOT_EXIST = 'ServerCallback "%s" does not exist!'
local CC_DOES_NOT_EXIST = 'ClientCallback "%s" does not exist!'

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

local function InvokeCallback(record, data)
    local packed = table.pack(xpcall(function()
        return record.callback(UnpackPacked(data))
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

---@param name string Callback name
---@param callback function Callback function(...)
function ZlomaCore.RegisterClientCallback(name, callback)
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
function ZlomaCore.RemoveClientCallback(name)
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
---@param timeout number|nil Timeout in milliseconds
---@vararg any Arguments to pass
---@return any Callback result
function ZlomaCore.TriggerServerCallback(name, timeout, ...)
    assert(type(name) == 'string' and name ~= '' and #name <= 128, 'Callback name must be 1-128 characters!')

    timeout = tonumber(timeout) or 5000
    if timeout ~= timeout then timeout = 5000 end
    timeout = math.min(60000, math.max(100, timeout))
    local arguments = table.pack(...)
    if arguments.n > 64 then error('Server callback accepts at most 64 arguments') end
    local requestId = NextRequestId()
    local requestName = GetRequestKey(name, requestId)
    local pending = { waiting = true }

    -- Store before sending so a fast local/server response cannot race us.
    callbackResponses[requestName] = pending
    TriggerServerEvent('ZlomaCore:sc', name, requestId, arguments)

    local endTime = GetGameTimer() + timeout
    while pending.waiting do
        Wait(50)
        if GetGameTimer() > endTime then
            pending.waiting = false
            pending.error = true
            LogError(SC_TIMEOUT, name, timeout)
        end
    end

    callbackResponses[requestName] = nil
    if pending.error or type(pending.data) ~= 'table' then return nil end

    return UnpackPacked(pending.data)
end


RegisterNetEvent('ZlomaCore:cc', function(name, requestId, data)
    if source ~= 65535 then return end
    if type(name) ~= 'string' or name == '' or #name > 128
        or type(requestId) ~= 'number' or requestId % 1 ~= 0 or not GetPackedLength(data) then
        return
    end

    local record = callbacks[name]
    if not record then
        LogError(CC_DOES_NOT_EXIST, name)
        TriggerServerEvent('ZlomaCore:ccError', name, requestId)
        return
    end

    local success, result = InvokeCallback(record, data)
    if not success then
        LogError('ClientCallback "%s" owned by "%s" failed:\n%s', name, record.owner, result)
        TriggerServerEvent('ZlomaCore:ccError', name, requestId)
        return
    end

    TriggerServerEvent('ZlomaCore:ccResponse', GetRequestKey(name, requestId), result)
end)

RegisterNetEvent('ZlomaCore:scResponse', function(requestName, data)
    if source ~= 65535 or type(requestName) ~= 'string' or not GetPackedLength(data) then return end

    local pending = callbackResponses[requestName]
    if not pending or not pending.waiting then return end

    pending.data = data
    pending.waiting = false
end)

RegisterNetEvent('ZlomaCore:scError', function(name, requestId)
    if source ~= 65535 or type(name) ~= 'string' or type(requestId) ~= 'number'
        or requestId % 1 ~= 0 then return end

    local requestName = GetRequestKey(name, requestId)
    local pending = callbackResponses[requestName]
    if not pending or not pending.waiting then return end

    pending.error = true
    pending.waiting = false
    LogError(SC_DOES_NOT_EXIST, name)
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    for name, record in pairs(callbacks) do
        if record.owner == resourceName then
            callbacks[name] = nil
        end
    end
end)

exports('RegisterClientCallback', ZlomaCore.RegisterClientCallback)
exports('RemoveClientCallback', ZlomaCore.RemoveClientCallback)
exports('TriggerServerCallback', ZlomaCore.TriggerServerCallback)
