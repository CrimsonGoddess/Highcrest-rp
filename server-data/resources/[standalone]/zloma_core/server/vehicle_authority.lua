-- Private server registry survives a garage/shop resource restart while Core
-- remains running. A replicated marker is never proof of this authorization.
local byPlate, byEntity, resolvers, serial = {}, {}, {}, 0
local epoch=tostring(os.time())..':'..tostring(GetGameTimer())
local function clean(plate)
    if type(plate) ~= 'string' then return end
    plate = plate:match('^%s*(.-)%s*$')
    if #plate > 0 and #plate <= 32 then return plate end
end
local function modelHash(model)
    local hash = type(model)=='string' and (tonumber(model) or GetHashKey(model)) or model
    if type(hash)=='number' and hash==hash and math.abs(hash)<math.huge and hash%1==0 then return hash & 0xffffffff end
end
local function actual(entry)
    return DoesEntityExist(entry.entity) and NetworkGetEntityFromNetworkId(entry.netId)==entry.entity
        and GetEntityType(entry.entity)==2 and clean(GetVehicleNumberPlateText(entry.entity))==entry.entityPlate
        and GetEntityRoutingBucket(entry.entity)==entry.bucket
        and modelHash(GetEntityModel(entry.entity))==entry.model
end
-- Standard server convars are private and survive resource restarts only.
-- Restore only our captured exact bindings; never infer authority from a bag/plate.
local snapshotKey='zloma_core:privateVehicleBindings'
local function restoreBindings()
    if type(GetConvar)~='function' or type(SetConvar)~='function' then return end
    local raw=GetConvar(snapshotKey,'')
    SetConvar(snapshotKey,'') -- one-shot; a full FXServer restart has no snapshot
    if raw=='' then return end
    local ok,snapshot=pcall(json.decode,raw)
    if not ok or type(snapshot)~='table' then return end
    for _,entry in ipairs(snapshot) do
        if type(entry)=='table' and type(entry.entity)=='number' and type(entry.netId)=='number'
            and type(entry.model)=='number' and type(entry.bucket)=='number'
            and clean(entry.plate) and clean(entry.entityPlate) and type(entry.resource)=='string'
            and type(entry.generation)=='string' and type(entry.revision)=='number' and actual(entry)
            and not byEntity[entry.entity] and (entry.transient or not byPlate[entry.plate]) then
            byEntity[entry.entity]=entry
            if not entry.transient then byPlate[entry.plate]=entry end
        end
    end
end
restoreBindings()
-- Product callers retain their private reservation/hybrid compatibility paths.
local products={zloma_garages=true,zloma_simplegarages=true,zloma_vehicleshop=true}
local created={}
local function trusted(caller,kind)
    return caller and ZlomaVehiclePolicy and ZlomaVehiclePolicy[kind]
        and ZlomaVehiclePolicy[kind][caller]==true
end
-- Provenance is captured at creation, not inferred from client-authored script hashes,
-- a migrated network owner, a bag, or the plate on an unrelated entity.
exports('CreateVehicleForAuthorizedBinding',function(model,vehicleType,point,bucket)
    local caller=GetInvokingResource()
    if not trusted(caller,'BindingCallers') then return nil,'caller_not_authorized' end
    local hash=modelHash(model)
    local types={automobile=true,bike=true,boat=true,heli=true,plane=true,submarine=true,trailer=true,train=true}
    local function finite(n) return type(n)=='number' and n==n and math.abs(n)<100000 end
    if not hash or hash==0 or not types[vehicleType] or type(point)~='table' or not finite(point.x)
        or not finite(point.y) or not finite(point.z) or not finite(point.w or 0)
        or type(bucket)~='number' or bucket%1~=0 or bucket<0 then return nil,'invalid_creation_request' end
    local ok,entity=pcall(CreateVehicleServerSetter,hash,vehicleType,point.x,point.y,point.z,point.w or 0)
    if not ok or not entity or entity==0 or not DoesEntityExist(entity) then return nil,'creation_failed' end
    if not pcall(SetEntityRoutingBucket,entity,bucket) then
        if DoesEntityExist(entity) and modelHash(GetEntityModel(entity))==hash then DeleteEntity(entity) end
        return nil,'creation_failed'
    end
    created[entity]={caller=caller,netId=NetworkGetNetworkIdFromEntity(entity),model=hash,bucket=bucket}
    return entity
end)
exports('RegisterAuthorizedVehicle',function(entity,plate,model,authorizedDisplayPlate,descriptor)
    -- SERVER integration only. Caller must already have validated its gameplay
    -- spawn/checkout ticket or a trusted external vehicle lifecycle.
    local caller=GetInvokingResource()
    plate=clean(plate)
    local proof=created[entity]
    if not products[caller] and (not trusted(caller,'BindingCallers') or not proof or proof.caller~=caller
        or proof.netId~=NetworkGetNetworkIdFromEntity(entity) or proof.model~=modelHash(model)
        or proof.bucket~=GetEntityRoutingBucket(entity) or (descriptor~=nil and (type(descriptor)~='table' or descriptor.transient))) then return false end
    if not caller or not plate or type(entity)~='number' or entity==0 or not DoesEntityExist(entity)
        or GetEntityType(entity)~=2 or modelHash(model)~=modelHash(GetEntityModel(entity)) then return false end
    local entityPlate=clean(GetVehicleNumberPlateText(entity))
    local display=clean(authorizedDisplayPlate) or plate
    if not entityPlate or (entityPlate:upper()~=plate:upper() and entityPlate~=display) then return false end
    local canonicalIdentity
    if not products[caller] then
        local fw=tostring(exports.zloma_core:GetFrameworkType()):upper()
        local db=(fw=='QBCORE' or fw=='QBOX') and 'player_vehicles' or 'owned_vehicles'
        local row=MySQL.single.await('SELECT * FROM `'..db..'` WHERE plate=? LIMIT 1',{plate})
        local props=row and row[db=='player_vehicles' and 'mods' or 'vehicle']
        if type(props)=='string' then local ok,value=pcall(json.decode,props);props=ok and value end
        if not row or clean(row.plate)~=plate or not (row.stored == false or tonumber(row.stored ~= nil and row.stored or row.state)==0)
            or type(props)~='table' or modelHash(props.model)~=modelHash(model)
            or created[entity]~=proof or not DoesEntityExist(entity)
            or proof.netId~=NetworkGetNetworkIdFromEntity(entity) or proof.model~=modelHash(GetEntityModel(entity))
            or proof.bucket~=GetEntityRoutingBucket(entity) or clean(GetVehicleNumberPlateText(entity))~=entityPlate then return false end
        canonicalIdentity=db..':'..tostring(row.id or row.plate)
    end
    -- Transient testdrive/delivery/duty identities belong to the exact entity,
    -- not a globally unique DB plate (two isolated testdrives may share text).
    local transient=type(descriptor)=='table' and descriptor.transient==true
    local existing
    if transient then existing=byEntity[entity] else existing=byPlate[plate] end
    if existing and existing.entity~=entity and actual(existing) then return false end
    local netId=NetworkGetNetworkIdFromEntity(entity)
    if not netId or netId<=0 then return false end
    if existing and existing.entity==entity and existing.transient==transient and actual(existing) then return true end
    local previous=byEntity[entity]
    if previous and byPlate[previous.plate]==previous then byPlate[previous.plate]=nil end
    if existing then byEntity[existing.entity]=nil end
    serial=serial+1
    local entry={entity=entity,netId=netId,model=modelHash(model),plate=plate,entityPlate=entityPlate,resource=caller,
        bucket=GetEntityRoutingBucket(entity),generation=epoch..':'..serial,revision=1,descriptor=descriptor,transient=transient,dbIdentity=canonicalIdentity}
    if not transient then byPlate[plate]=entry end
    byEntity[entity]=entry
    return true
end)
-- Resolvers are private server callbacks registered by the owning product.
-- They read current DB/access rules; a bag or physical plate never creates a binding.
exports('RegisterVehicleContextResolver',function(resolver)
    local caller=GetInvokingResource()
    -- FiveM deserializes cross-resource function references into callable tables.
    -- Accept that runtime representation only from the existing trusted products.
    local mt=type(resolver)=='table' and getmetatable(resolver)
    local callable=type(resolver)=='function' or (type(resolver)=='table'
        and type(rawget(resolver,'__cfx_functionReference'))=='string'
        and type(mt)=='table' and type(mt.__call)=='function')
    if not products[caller] or not callable then return false end
    resolvers[caller]=resolver;return true
end)
local function verified(src,netId,purpose)
    if type(netId)~='number' or netId%1~=0 or netId<=0 or type(purpose)~='string' or #purpose>64 then return nil,'invalid_request' end
    local entity=NetworkGetEntityFromNetworkId(netId)
    local entry=byEntity[entity]
    if not entry or entry.netId~=netId or not actual(entry) then return nil,'unverified_entity' end
    local Core=exports.zloma_core
    local identifier=Core:GetIdentifier(src)
    if not identifier or GetPlayerRoutingBucket(src)~=entry.bucket then return nil,'actor_or_bucket_mismatch' end
    local data, accessReason
    local resolver=resolvers[entry.resource]
    if not resolver and not entry.transient then resolver=resolvers.zloma_garages or resolvers.zloma_simplegarages end
    if resolver then
        data,accessReason=resolver(src,entry.plate,purpose,entry.descriptor)
    elseif entry.descriptor and entry.descriptor.transient then
        local d=entry.descriptor
        if d.identifier==identifier and (not d.expires or GetGameTimer()<=d.expires) then
            data={identity=d.identity,owner=identifier,access={relationship=d.kind},persistent=false}
        end
    else
        local fw=tostring(Core:GetFrameworkType()):upper()
        local db=(fw=='QBCORE' or fw=='QBOX') and 'player_vehicles' or 'owned_vehicles'
        local row=MySQL.single.await('SELECT * FROM `'..db..'` WHERE plate=? LIMIT 1',{entry.plate})
        local owner=row and (row.owner or row.citizenid)
        local driver=(purpose=='tuning' or purpose=='fitment') and GetPedInVehicleSeat(entity,-1)==GetPlayerPed(src)
        local rawProps=row and row[db=='player_vehicles' and 'mods' or 'vehicle']
        local props=rawProps
        if type(props)=='string' then local ok,value=pcall(json.decode,props);props=ok and value or nil end
        if row and type(props)=='table' and modelHash(props.model) and (owner==identifier or driver) and (row.stored == false or tonumber(row.stored ~= nil and row.stored or row.state)==0) then
            data={identity=db..':'..tostring(row.id or row.plate),owner=owner,version=rawProps,
                access={relationship=owner==identifier and 'owner' or 'driver'},persistent=true,model=props.model}
        end
    end
    -- DB reads may yield: re-check the captured generation and entity afterwards.
    if data and data.model and modelHash(data.model)~=entry.model then return nil,'canonical_model_changed' end
    if not data or not data.identity or not data.access then
        return nil,type(accessReason)=='string' and accessReason or 'access_not_confirmed'
    end
    if byEntity[entity]~=entry then return nil,'binding_generation_changed' end
    if not actual(entry) then return nil,'entity_identity_changed' end
    if Core:GetIdentifier(src)~=identifier then return nil,'actor_identity_changed' end
    if GetPlayerRoutingBucket(src)~=entry.bucket then return nil,'actor_bucket_changed' end
    if entry.dbIdentity and entry.dbIdentity~=data.identity then return nil,'db_identity_changed' end
    entry.dbIdentity=data.identity
    if entry.version~=data.version then entry.version=data.version;entry.revision=entry.revision+1 end
    if entry.owner~=data.owner then entry.owner=data.owner;entry.revision=entry.revision+1 end
    return {vehicleId=data.identity,dbIdentity=data.identity,recordId=data.identity,bindingId=entry.generation,generation=entry.generation,generationId=entry.generation,
        revision=entry.revision,entity=entity,netId=netId,model=entry.model,modelHash=entry.model,bucket=entry.bucket,routingBucket=entry.bucket,
        originalPlate=entry.plate,canonicalPlate=entry.plate,displayPlate=entry.entityPlate,
        owner=data.owner,ownerIdentifier=data.owner,ownerCharacterIdentity=data.owner,characterIdentity=identifier,requesterIdentifier=identifier,
        access=data.access,persistent=data.persistent~=false}
end
exports('GetVerifiedVehicleContext',verified)
exports('GetAuthorizedVehicleBinding',function(entity)
    local entry=byEntity[entity]
    if not GetInvokingResource() or not entry or not actual(entry) then return end
    return {entity=entity,netId=entry.netId,model=entry.model,bucket=entry.bucket,generation=entry.generation,
        revision=entry.revision,originalPlate=entry.plate,displayPlate=entry.entityPlate}
end)
exports('SetAuthorizedVehicleDisplayPlate',function(entity,generation,display)
    local caller=GetInvokingResource();local entry=byEntity[entity];display=clean(display)
    if not products[caller] or not entry or entry.generation~=generation or not actual(entry) or not display then return false end
    SetVehicleNumberPlateText(entity,display)
    entry.entityPlate=display;entry.revision=entry.revision+1
    return true
end)
exports('InvalidateAuthorizedVehicle',function(entity,generation)
    local entry=byEntity[entity]
    if not entry or (not products[GetInvokingResource()] and entry.resource~=GetInvokingResource()) or (generation and generation~=entry.generation) then return false end
    byEntity[entity]=nil;if byPlate[entry.plate]==entry then byPlate[entry.plate]=nil end
    return true
end)
exports('IsAuthorizedVehicle',function(entity,plate,model)
    local entry=byPlate[clean(plate)]
    return entry~=nil and entry.entity==entity and entry.model==modelHash(model) and actual(entry)
end)
exports('GetAuthorizedVehicleEntity',function(plate)
    local entry=byPlate[clean(plate)]
    return entry and actual(entry) and entry.entity or nil
end)
AddEventHandler('entityRemoved',function(entity)
    created[entity]=nil
    local entry=byEntity[entity]
    if not entry then return end
    byEntity[entity]=nil
    if byPlate[entry.plate]==entry then byPlate[entry.plate]=nil end
end)
AddEventHandler('onResourceStop',function(resource)
    resolvers[resource]=nil
    if resource~=GetCurrentResourceName() or type(SetConvar)~='function' then return end
    local snapshot={}
    for _,entry in pairs(byEntity) do if actual(entry) then snapshot[#snapshot+1]=entry end end
    local ok,raw=pcall(json.encode,snapshot)
    if ok then SetConvar(snapshotKey,raw) end
end)
