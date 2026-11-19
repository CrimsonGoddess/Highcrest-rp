
function L(key) return key end -- Locale lookup is supplied by the resource at runtime.
local count=0
local function check(v,label) assert(v,label);count=count+1 end
local resource,caller,api,events,threads,entities,row,online,identifier,bucket,engineHook,engineFailure,serial,values,createdCount
local mt={__sub=function(a,b) return vector3(a.x-b.x,a.y-b.y,a.z-b.z) end,__len=function(v) return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z) end}
function vector3(x,y,z) return setmetatable({x=x,y=y,z=z},mt) end
function GetCurrentResourceName() return resource end
function GetInvokingResource() return caller end
function GetGameTimer() return 10000 end
function GetHashKey() return 123 end
function GetPlayerName() return online and 'player' or nil end
function GetPlayerPed(src) return src end
function GetPlayerRoutingBucket() return bucket end
function DoesEntityExist(e) return e==1 or e==2 or entities[e]~=nil end
function GetEntityType(e) return entities[e] and 2 or 1 end
function GetEntityCoords(e) return entities[e] and entities[e].coords or vector3(0,0,0) end
function GetEntityRoutingBucket(e) return entities[e].bucket end
function SetEntityRoutingBucket(e,b) entities[e].bucket=b end
function GetEntityModel(e) return entities[e].model end
function GetVehicleNumberPlateText(e) return entities[e].plate end
function SetVehicleNumberPlateText(e,p) entities[e].plate=p end
function NetworkGetNetworkIdFromEntity(e) return entities[e] and e+1000 or 0 end
function NetworkGetEntityFromNetworkId(n) return entities[n-1000] and n-1000 or 0 end
function SetEntityOrphanMode() end
function GetPedInVehicleSeat() return 0 end
function GetResourceState(n) return n=='sd-phone' and 'started' or 'missing' end
function Entity() return {state={set=function() end}} end
function CreateThread(f) threads[#threads+1]=f end
function Wait() end
function AddEventHandler(n,f) events[n]=events[n] or {};table.insert(events[n],f) end
function DeleteEntity(e)
 entities[e]=nil
 for _,fn in ipairs(events.entityRemoved or {}) do fn(e) end
end
function CreateVehicleServerSetter(model,kind,x,y,z)
 createdCount=createdCount+1
 local e=createdCount+10;entities[e]={model=model,plate='EMPTY',bucket=0,coords=vector3(x,y,z)};return e
end
local function dispatch(target,name,...)
 local oldR,oldC=resource,caller;caller,resource=resource,target
 local result=table.pack(pcall(api[target][name],...));resource,caller=oldR,oldC
 if not result[1] then error(result[2]) end
 return table.unpack(result,2,result.n)
end
exports=setmetatable({}, {__call=function(_,n,f) api[resource][n]=f end,
 __index=function(_,t) return setmetatable({}, {__index=function(_,n) return function(_,...) return dispatch(t,n,...) end end}) end})
local function loadProduct(p,f) assert(load(read_source(p,f),p..'/'..f))() end
local function reset()
 resource,caller,api,events,threads,entities='zloma_core',nil,{zloma_core={},[product]={}},{},{},{}
 online,identifier,bucket,engineHook,engineFailure,serial,values,createdCount=true,'owner',0,nil,nil,0,{},0
 json={encode=function(v) serial=serial+1;values['j'..serial]=v;return 'j'..serial end,decode=function(v) return values[v] end}
 row={id=5,plate='CAR1',owner='owner',stored=1,vehicle=json.encode({model=123,plate='CAR1'})}
 api.zloma_core.GetIdentifier=function(src) return src==1 and identifier or 'other' end
 api.zloma_core.GetFrameworkType=function() return 'ESX' end
 local DB={GetTable=function() return 'owned_vehicles' end,GetColumn=function(k) return k end,GetVehicle=function() return row end}
 api[product].GetDB=function() return DB end
 api[product].OnVehicleSpawned=function() end
 api[product].RegisterActiveVehicle=function() end
 MySQL={single={await=function() return row end},update={await=function(q,p)
  if q:find('SET `stored` = 0',1,true) then
   if row.stored~=1 or row.plate~=p[1] or row.owner~=p[2] or row.vehicle~=p[3] or (p[4] and row.id~=p[4]) then return 0 end
   row.stored=0;return 1
  end
  if row.stored~=0 or row.plate~=p[1] or row.owner~=p[2] or row.vehicle~=p[3] or (p[4] and row.id~=p[4]) then return 0 end
  row.stored=1;return 1
 end}}
 lib={callback={register=function() end}}
 Config={SpawnVehiclesWithServerSetter=true,Valet={Callers={['sd-phone']=true},MaxDistance=225}}
 ZlomaVehiclePolicy={BindingCallers={['zloma_vehManagement']=true,['zloma_autopijaca']=true}}
 loadProduct('zloma_core','server/vehicle_authority.lua')
 resource=product
 loadProduct('zloma_garages','shared/vehicle_properties.lua')
loadProduct(product,'server/vehicle/context.lua')
 ZlomaServerSpawn={Spawn=function(opts)
   if engineHook then engineHook(opts) end
   if engineFailure then return nil,engineFailure end
   local e=CreateVehicleServerSetter(opts.props.model,'automobile',opts.point.x,opts.point.y,opts.point.z)
   SetEntityRoutingBucket(e,opts.bucket);SetVehicleNumberPlateText(e,opts.plate)
   return e,NetworkGetNetworkIdFromEntity(e)
 end}
 loadProduct(product,'server/vehicle/spawn.lua')
 resource='sd-phone'
end
local function request(id,extra,src)
 local q={sessionId=id or 'paid1',purpose='valet',destination={x=75,y=0,z=0,w=0},bucket=0,isValid=function() return true end}
 for k,v in pairs(extra or {}) do q[k]=v end
 return exports[product]:RetrieveVehicleForValet(src or 1,'CAR1',q)
end
reset()
local r=request()
check(r.success and row.stored==0 and r.context.access.relationship=='owner','stored owned checkout')
check(r.generation and r.dbIdentity=='owned_vehicles:5' and exports.zloma_core:GetAuthorizedVehicleBinding(r.entity).generation==r.generation,'binding exists before result')
check(exports.zloma_core:GetVerifiedVehicleContext(1,r.netId,'store').generation==r.generation,'verified context after result')
check(request().reason=='duplicate_session' and createdCount==1,'session replay no new entity')
check(request('paid2').reason=='not_stored_or_impounded' and createdCount==1,'second valet cannot checkout')
check(exports[product]:CancelValetRetrieval('paid1').reason=='already_ready' and row.stored==0,'published success cannot rollback')
check(not exports[product]:AcknowledgeValetHandoff('paid1','stale').success,'stale handoff generation')
local originalRead=MySQL.single.await
MySQL.single.await=function(q,p)
 local previous=resource;resource='sd-phone'
 check(not exports[product]:AcknowledgeValetHandoff('paid1',r.generation).success,'concurrent handoff claim rejected before DB yield')
 resource=previous;return originalRead(q,p)
end
check(exports[product]:AcknowledgeValetHandoff('paid1',r.generation).success,'exact handoff acknowledgment')
MySQL.single.await=originalRead
check(not exports[product]:AcknowledgeValetHandoff('paid1',r.generation).success,'handoff replay')
reset();check(request(nil,nil,2).reason=='not_owner' and row.stored==1,'wrong owner')
reset();row.stored=0;check(not request().success and createdCount==0,'not stored')
reset();row.stored=3;check(not request().success and createdCount==0,'impounded')
reset();resource='unrelated';check(request().reason=='caller_not_authorized','wrong caller')
reset();check(request(nil,{bucket=1}).reason=='wrong_bucket','wrong bucket')
reset();check(request(nil,{model=999}).reason=='unsupported_argument','client model injection rejected')
reset();check(request(nil,{destination={x=99999,y=0,z=0}}).reason=='destination_too_far','arbitrary destination rejected')
reset();check(request(nil,{destination={x=0/0,y=0,z=0}}).reason=='invalid_destination','nonfinite destination rejected')
reset();Config.SpawnVehiclesWithServerSetter=false;check(request().reason=='ServerSetter_required' and createdCount==0,'no hybrid fallback')
reset();engineFailure='creation_failed';check(request().outcome=='rolled_back' and row.stored==1,'create failure rollback')
reset();engineFailure='initialization_exhausted';check(request().outcome=='rolled_back' and row.stored==1,'init failure rollback')
reset();engineHook=function()
 local previous=resource;resource='sd-phone'
 check(request('parallel').reason=='checkout_busy','two valet concurrency');resource=previous
 check(not RequestVehicleSpawn(1,{plate='CAR1'}).success,'garage+valet concurrency')
 check(not exports.zloma_core:GetVerifiedVehicleContext(1,1011,'store'),'no context before binding')
end;check(request().success,'concurrent attempt preserves legitimate checkout')
reset();engineHook=function() online=false end;check(request().outcome=='rolled_back' and row.stored==1 and not next(entities),'disconnect cleans exact entity')
reset();engineHook=function() identifier='switched' end;check(request().outcome=='rolled_back' and row.stored==1,'character switch rollback')
reset();engineHook=function() bucket=1 end;check(request().outcome=='rolled_back' and row.stored==1,'bucket switch rollback')
reset();engineHook=function() local prev=resource;resource='sd-phone';exports[product]:CancelValetRetrieval('paid1');resource=prev end;check(request().outcome=='rolled_back' and row.stored==1,'cancel pending rollback')
reset();local valid=true;engineHook=function() valid=false end;check(request(nil,{isValid=function() return valid end}).outcome=='rolled_back','destination/session invalidation')
reset();engineHook=function() row.id=6 end;check(request().outcome=='quarantined' and row.stored==0,'replaced DB generation never restored')
reset();local initialUpdate=MySQL.update.await;MySQL.update.await=function(q,p) initialUpdate(q,p);return nil end
check(request().outcome=='quarantined' and row.stored==0,'missing SQL acknowledgment never claims no checkout')
reset();local update=MySQL.update.await;MySQL.update.await=function() error('provider outcome unknown') end
check(request().outcome=='quarantined' and createdCount==0,'unknown checkout outcome quarantined')
reset();engineHook=function() local old=resource;resource='sd-phone';local q=request('paid1');resource=old;check(q.reason=='duplicate_session','pending replay blocked') end
check(request().success,'pending replay leaves original checkout intact')
reset();engineHook=function()
 for _,fn in ipairs(events.onResourceStop or {}) do fn('sd-phone') end
end
check(request().outcome=='rolled_back' and row.stored==1,'caller resource stop cancels pending checkout')
reset();local replacement
api[product].OnVehicleSpawned=function()
 local old=11;DeleteEntity(old)
 replacement=CreateVehicleServerSetter(123,'automobile',75,0,0);SetVehicleNumberPlateText(replacement,'CAR1')
 exports.zloma_core:RegisterAuthorizedVehicle(replacement,'CAR1',123)
end
check(request().outcome=='quarantined' and entities[replacement] and row.stored==0,'replacement generation never deleted/restored')
reset();engineFailure='reservation_cancelled_or_requester_changed';engineHook=function() api.zloma_core.GetAuthorizedVehicleEntity=function() error('Core stopped') end end
check(request().outcome=='quarantined' and row.stored==0,'lost registry quarantines instead of guessing rollback')
-- Private server creation provenance and canonical DB validation for external callers.
for _,name in ipairs({'zloma_vehManagement','zloma_autopijaca'}) do
 reset();row.stored=0;resource=name
 local e=exports.zloma_core:CreateVehicleForAuthorizedBinding(123,'automobile',{x=0,y=0,z=0,w=0},0)
 SetVehicleNumberPlateText(e,'CAR1')
 check(exports.zloma_core:RegisterAuthorizedVehicle(e,'CAR1',123),'trusted '..name..' accepted')
 check(exports.zloma_core:GetVerifiedVehicleContext(1,e+1000,'store').dbIdentity=='owned_vehicles:5','external binding canonical DB context')
end
reset();row.stored=0;resource='unrelated';check(not exports.zloma_core:CreateVehicleForAuthorizedBinding(123,'automobile',{x=0,y=0,z=0},0),'unrelated creation denied')
resource='zloma_vehManagement';local e=CreateVehicleServerSetter(123,'automobile',0,0,0);SetVehicleNumberPlateText(e,'CAR1')
check(not exports.zloma_core:RegisterAuthorizedVehicle(e,'CAR1',123),'unrelated/client entity cannot be adopted even by configured caller')
reset();row.stored=0;resource='zloma_vehManagement';e=exports.zloma_core:CreateVehicleForAuthorizedBinding(123,'automobile',{x=0,y=0,z=0},0);SetVehicleNumberPlateText(e,'CAR1');resource='zloma_autopijaca'
check(not exports.zloma_core:RegisterAuthorizedVehicle(e,'CAR1',123),'another trusted caller cannot claim entity')
reset();row.stored=0;resource='zloma_vehManagement';e=exports.zloma_core:CreateVehicleForAuthorizedBinding(999,'automobile',{x=0,y=0,z=0},0);SetVehicleNumberPlateText(e,'CAR1')
check(not exports.zloma_core:RegisterAuthorizedVehicle(e,'CAR1',999),'external model must match DB canonical model')
reset();row.stored=0;resource='zloma_vehManagement';e=exports.zloma_core:CreateVehicleForAuthorizedBinding(123,'automobile',{x=0,y=0,z=0},0);SetVehicleNumberPlateText(e,'CAR1');DeleteEntity(e);entities[e]={model=123,plate='CAR1',bucket=0,coords=vector3(0,0,0)}
check(not exports.zloma_core:RegisterAuthorizedVehicle(e,'CAR1',123),'reused handle loses creation provenance')
print(product..': '..count..' focused production valet/caller-policy checks passed; no FXServer')
