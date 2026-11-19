-- ZLOMA CORE - Server Billing Wrapper
-- Unified interface with strict validation for any network-facing entry point.

local BillingType = nil
local billingCooldowns = {}

local function ResolveBillingType()
    if BillingType and GetResourceState(BillingType) == 'started' then
        return BillingType
    end

    BillingType = ZlomaCore.DetectBilling()
    ZlomaCore.Cache.Billing = BillingType
    return BillingType
end

local function IsValidPlayer(playerId)
    return type(playerId) == 'number'
        and playerId > 0
        and playerId % 1 == 0
        and GetPlayerName(playerId) ~= nil
end

local function ValidateBill(sourceId, targetId, amount, reason, society)
    if not IsValidPlayer(sourceId) or not IsValidPlayer(targetId) then
        return nil, 'invalid source or target'
    end

    if type(amount) ~= 'number' or amount ~= amount or amount == math.huge or amount == -math.huge then
        return nil, 'invalid amount'
    end

    local maximum = tonumber(ZlomaCore.Config.Security and ZlomaCore.Config.Security.BillingMaxAmount) or 1000000
    amount = math.floor(amount)
    if amount <= 0 or amount > maximum then
        return nil, ('amount must be between 1 and %s'):format(maximum)
    end

    if type(reason) ~= 'string' or reason == '' or #reason > 128 then
        return nil, 'reason must be a non-empty string of at most 128 characters'
    end

    if society ~= nil and (type(society) ~= 'string' or society == '' or #society > 64) then
        return nil, 'invalid society'
    end

    return {
        source = sourceId,
        target = targetId,
        amount = amount,
        reason = reason,
        society = society
    }
end

local function ArePlayersNear(sourceId, targetId)
    local sourcePed = GetPlayerPed(sourceId)
    local targetPed = GetPlayerPed(targetId)
    if sourcePed <= 0 or targetPed <= 0 then return false end

    local sourceCoords = GetEntityCoords(sourcePed)
    local targetCoords = GetEntityCoords(targetPed)
    local dx = sourceCoords.x - targetCoords.x
    local dy = sourceCoords.y - targetCoords.y
    local dz = sourceCoords.z - targetCoords.z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    local maximum = tonumber(ZlomaCore.Config.Security and ZlomaCore.Config.Security.BillingMaxDistance) or 10.0

    return distance <= maximum
end

local function DispatchBill(bill)
    local billingType = ResolveBillingType()
    if not billingType then
        ZlomaCore.Warn('Billing', 'SendBill')
        return false
    end

    local adapter = ZlomaCore.GetAdapter('server', 'Billing', billingType)
    if not adapter or type(adapter.send) ~= 'function' then
        print(('^1[ZLOMA CORE ERROR]^0 No billing adapter is registered for %s'):format(tostring(billingType)))
        return false
    end

    local success, result = xpcall(function()
        return adapter.send(bill)
    end, debug.traceback)

    if not success or result == false then
        print(('^1[ZLOMA CORE ERROR]^0 SendBill failed:\n%s'):format(success and 'Provider rejected the bill' or result))
        return false
    end

    ZlomaCore.Debug(('Billing: sent $%s from %s to %s through %s'):format(
        bill.amount, bill.source, bill.target, billingType
    ))
    return true
end

exports('SendBill', function(sourceId, targetId, amount, reason, society)
    local bill, validationError = ValidateBill(sourceId, targetId, amount, reason, society)
    if not bill then
        print(('^1[ZLOMA CORE ERROR]^0 SendBill rejected: %s'):format(validationError))
        return false
    end

    return DispatchBill(bill)
end)

exports('GetBills', function(sourceId)
    if not IsValidPlayer(sourceId) then return {} end

    local billingType = ResolveBillingType()
    if not billingType then
        ZlomaCore.Warn('Billing', 'GetBills')
        return {}
    end

    local adapter = ZlomaCore.GetAdapter('server', 'Billing', billingType)
    if adapter and type(adapter.getBills) == 'function' then
        local success, result = pcall(adapter.getBills, sourceId)
        return success and type(result) == 'table' and result or {}
    end

    ZlomaCore.Debug(('GetBills is not exposed generically by %s'):format(billingType))
    return {}
end)

-- Legacy compatibility. Disabled by default because arbitrary clients must not
-- be allowed to choose invoice amounts and societies without server authority.
RegisterNetEvent('zloma_core:server:sendBill', function(target, amount, reason, society)
    local sourceId = source
    local security = ZlomaCore.Config.Security or {}
    if not security.EnableLegacyClientBillingEvent then return end

    local now = GetGameTimer()
    local cooldown = tonumber(security.BillingEventCooldownMs) or 1000
    if now < (billingCooldowns[sourceId] or 0) then return end
    billingCooldowns[sourceId] = now + math.max(0, cooldown)

    local job = exports['zloma_core']:GetPlayerJob(sourceId)
    if not job or type(job.name) ~= 'string' or job.name == '' then return end

    local bill, validationError = ValidateBill(sourceId, target, amount, reason, society or job.name)
    if not bill then
        ZlomaCore.Debug(('Rejected legacy billing event from %s: %s'):format(sourceId, validationError))
        return
    end

    local normalizedSociety = bill.society:gsub('^society_', '')
    if normalizedSociety ~= job.name or not ArePlayersNear(bill.source, bill.target) then return end

    DispatchBill(bill)
end)

AddEventHandler('playerDropped', function()
    billingCooldowns[source] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == 'zloma_banking' or resourceName == 'okokBilling' or resourceName == 'okok_billing'
        or resourceName == 'esx_billing' or resourceName == 'qb-billing' then
        BillingType = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == BillingType then BillingType = nil end
end)

CreateThread(function()
    Wait(0)
    BillingType = ResolveBillingType()

    if BillingType then
        ZlomaCore.Debug(('Billing system loaded: %s'):format(BillingType))
    else
        print('^3[ZLOMA WARNING]^0 No billing system detected. Billing functions will not work.')
    end
end)
