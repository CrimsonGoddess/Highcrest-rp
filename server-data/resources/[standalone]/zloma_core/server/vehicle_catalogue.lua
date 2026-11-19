-- Trusted operator-reviewed catalogue. No client upload/net event exists.
local catalogue = {}
local function finite(v) return type(v)=='number' and v==v and math.abs(v)<math.huge end
local function integer(v,lo,hi) return finite(v) and v%1==0 and v>=lo and v<=hi end
local function validate(entry)
    if type(entry)~='table' or not integer(entry.class,0,22) or type(entry.mods)~='table'
        or type(entry.wheels)~='table' or type(entry.extras)~='table' or not integer(entry.liveryCount,0,256) then return false end
    for slot,mod in pairs(entry.mods) do
        if not integer(tonumber(slot),0,49) or type(mod)~='table' or not integer(mod.count,0,256) then return false end
        for index,denied in pairs(mod.forbidden or {}) do
            if not integer(tonumber(index),0,255) or type(denied)~='boolean' then return false end
        end
    end
    for wheel,counts in pairs(entry.wheels) do
        if not integer(tonumber(wheel),0,12) or type(counts)~='table'
            or not integer(counts.front,0,256) or not integer(counts.rear,0,256) then return false end
    end
    for id,exists in pairs(entry.extras) do if not integer(tonumber(id),0,20) or type(exists)~='boolean' then return false end end
    if entry.toggles~=nil then
        if type(entry.toggles)~='table' then return false end
        for field,allowed in pairs(entry.toggles) do
            if (field~='modTurbo' and field~='modXenon' and field~='modSmokeEnabled') or type(allowed)~='boolean' then return false end
        end
    end
    if entry.weaponPolicyReviewed~=nil and type(entry.weaponPolicyReviewed)~='boolean' then return false end
    return true
end
local function key(model)
    local value=type(model)=='string' and (tonumber(model) or GetHashKey(model)) or model
    if not integer(value,-2147483648,4294967295) then return end
    return tostring(value & 0xffffffff)
end
local function register(model,entry)
    local id=key(model)
    if not id or not validate(entry) then return false end
    catalogue[id]=json.decode(json.encode(entry)); return true
end
exports('RegisterTrustedVehicleCatalogue',register)
exports('GetVehicleCatalogue',function(model)
    local entry=catalogue[key(model)]
    return entry and json.decode(json.encode(entry)) or nil
end)
local function reload()
    local raw=LoadResourceFile(GetCurrentResourceName(),'data/vehicle_catalogue.json')
    local ok,entries=pcall(json.decode,raw or '{}')
    if not ok or type(entries)~='table' then print('[zloma_core] [ERROR] Invalid trusted vehicle catalogue'); return false end
    local staged={}
    for model,entry in pairs(entries) do
        local id=key(model)
        if not id or not validate(entry) then print('[zloma_core] [ERROR] Invalid catalogue entry: '..tostring(model)); return false end
        staged[id]=entry
    end
    catalogue=staged; return true
end
reload()
RegisterCommand('zloma_catalogue_reload',function(src)
    if src~=0 then return end -- Console/operator file promotion only, not a client authority API.
    reload()
end,true)
