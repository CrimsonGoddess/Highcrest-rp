-- Trusted SERVER participants only. Regular Add/RemoveMoney compatibility APIs
-- are not silently advertised as crash-idempotent participants.
local custom={}
local function operation(id)
    local caller=GetInvokingResource()
    if not caller or type(id)~='string' or #id<1 or #id>100 or not id:match('^[%w_:%-%.]+$') then return end
    return caller..':'..id
end
local function validDelta(delta)
    return type(delta)=='number' and delta==delta and math.abs(delta)<math.huge and delta%1==0 and math.abs(delta)<=1000000000
end
local function selected(kind)
    if kind=='bank' then return exports.zloma_core:GetFrameworkType() end
    return ZlomaCore.DetectSociety()
end
local function available(kind,provider)
    local contract=custom[kind..':'..tostring(provider)]
    if contract then local ok,value=pcall(contract.ready);return ok and value==true end
    local ok,value=pcall(function()
        if kind=='bank' and provider=='ESX' then return exports.es_extended:HasDurableBankMoney() end
        if kind=='society' and provider=='esx_addonaccount' then return exports.esx_addonaccount:HasDurableSharedAccountMoney() end
        return false
    end)
    return ok and value==true
end
exports('RegisterDurableMoneyProvider',function(kind,provider,ready,apply)
    local caller=GetInvokingResource()
    if not caller or (kind~='bank' and kind~='society') or type(provider)~='string' or #provider>100
        or type(ready)~='function' or type(apply)~='function' then return false end
    custom[kind..':'..provider]={resource=caller,ready=ready,apply=apply}
    return true
end)
local function apply(kind,id,identity,delta,expectedProvider)
    id=operation(id)
    if not id or type(identity)~='string' or #identity<1 or #identity>100 or not validDelta(delta) then
        return {success=false,reason='invalid_durable_money_request'}
    end
    local provider=selected(kind)
    if expectedProvider~=nil and expectedProvider~=provider then return {success=false,reason='durable_money_provider_changed:'..kind} end
    if not available(kind,provider) then return {success=false,reason='durable_money_integration_required:'..kind..':'..tostring(provider)} end
    local contract=custom[kind..':'..tostring(provider)]
    local ok,result=pcall(function()
        if contract then return contract.apply(id,identity,delta) end
        if kind=='bank' then return exports.es_extended:ApplyBankMoneyOnce(id,identity,delta) end
        return exports.esx_addonaccount:ApplySharedAccountMoneyOnce(id,'society_'..identity,delta)
    end)
    if not ok or type(result)~='table' then return {success=false,reason='durable_participant_exception'} end
    -- An acknowledgement must explicitly describe an applied durable receipt.
    if result.success==true and result.status~='applied' then return {success=false,reason='invalid_durable_participant_receipt'} end
    return result
end
exports('ApplyBankMoneyOnce',function(id,identifier,delta,provider) return apply('bank',id,identifier,delta,provider) end)
exports('ApplySocietyMoneyOnce',function(id,name,delta,provider) return apply('society',id,name,delta,provider) end)
exports('GetDurableMoneyCapabilities',function()
    local bank,society=selected('bank'),selected('society')
    return {bank=bank,society=society,bankReady=available('bank',bank),societyReady=available('society',society)}
end)
AddEventHandler('onResourceStop',function(resource)
    for key,contract in pairs(custom) do if contract.resource==resource then custom[key]=nil end end
end)
