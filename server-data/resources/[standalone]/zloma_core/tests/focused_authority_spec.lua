local count = 0
function L(key) return key end
local function check(v, label) assert(v, label); count = count + 1 end
local callbacks, events, exported, threads = {}, {}, {}, {}
local codes, serial = {}, 0
local function clone(t) if type(t) ~= 'table' then return t end local r = {}; for k,v in pairs(t) do r[k] = clone(v) end; return r end
json = {encode = function(t) serial=serial+1; local key='j'..serial; codes[key]=clone(t); return key end,
 decode = function(s) return clone(codes[s] or {}) end}
local mt = {__sub=function(a,b) return vector3(a.x-b.x,a.y-b.y,a.z-b.z) end,
 __len=function(v) return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z) end}
function vector3(x,y,z) return setmetatable({x=x,y=y,z=z},mt) end
local now, pos, bucket, entity, plate, model, ped, identifier = 0, vector3(0,0,0), 0, 10, 'CAR1', 123, 1, 'license:one'
local resource = 'zloma_hud'
function GetCurrentResourceName() return resource end
function GetResourceState(name) return name=='es_extended' and 'started' or 'missing' end
function GetPlayerPed() return ped end
function GetVehiclePedIsIn() return entity end
function GetPedInVehicleSeat() return ped end
function DoesEntityExist(e) return e==entity and e~=0 end
function GetEntityType() return 2 end
function GetEntityModel() return model end
function GetVehicleNumberPlateText() return plate end
function GetPlayerRoutingBucket() return bucket end
function GetEntityRoutingBucket() return bucket end
function NetworkGetNetworkIdFromEntity(e) return e+100 end
function NetworkGetEntityFromNetworkId(id) return id==entity+100 and entity or 0 end
function GetPlayerIdentifierByType() return identifier end
function GetEntityCoords() return pos end
function GetGameTimer() return now end
function GetVehicleType() return 'automobile' end
function GetHashKey() return 123 end
function GetPlayers() return {'1'} end
function RegisterNetEvent(n,f) events[n]=f end
function AddEventHandler(n,f) events[n]=f end
function CreateThread(f) threads[#threads+1]=coroutine.create(f) end
function Wait() coroutine.yield() end
local bag = {}
function Entity() return {state={set=function(_,k,v) bag[k]=v end}} end
lib = {callback={register=function(n,f) callbacks[n]=f end}}
exports = setmetatable({}, {__call=function(_,n,f) exported[n]=f end})
Config = {Framework='ESX',VehicleMileage={enabled=true},MileageConfig={autoRunSql=false,tables={ESX='owned_vehicles'},
 ignoredVehicleClasses={},security={maxKmPerMinute=8},unit='kilometers'}}
local record = {plate='CAR1',mileage=100,identity='owner1',properties=json.encode({model=123})}
local writes, sqlResult = 0, 1
MySQL = {single={await=function() return clone(record) end},update={await=function(_,v)
 if sqlResult~=1 or v[3]~=record.identity or v[4]~=record.mileage then return 0 end
 writes=writes+1; record.mileage=v[1]; return 1
end}}
assert(load(read_source('zloma_hud','server/mileage.lua')))()
local thread=threads[1]
local function tick(ms) now=ms; local ok,err=coroutine.resume(thread); assert(ok,err) end
tick(0); tick(1000)
check(callbacks['zloma_hud:server:getMileage'](1,'CAR1')==100,'driver reads canonical mileage')
source=1; events['zloma_hud:server:updateMileage']('CAR1',999999)
check(record.mileage==100 and writes==0,'arbitrary client mileage does not persist')
for i=2,6 do pos=vector3((i-1)*10,0,0); tick(i*1000) end
check(math.abs(record.mileage-100.05)<1e-7 and writes==1,'server accrues and persists without client reports')
check(math.abs(exported.getMileageByEntity(10)-100.05)<1e-7,'server export reads own session, not owner bag')
check(callbacks['zloma_hud:server:getMileage'](1,'OTHER')==0,'arbitrary plate query rejected')
pos=vector3(10000,0,0);tick(7000)
check(math.abs(exported.getMileageByEntity(10)-100.05)<1e-7,'teleport contributes no distance')
callbacks['zloma_hud:server:getMileage'](1,'CAR1'); callbacks['zloma_hud:server:getMileage'](1,'CAR1')
pos=vector3(10010,0,0);tick(8000)
check(math.abs(exported.getMileageByEntity(10)-100.06)<1e-7,'reads cannot reset observation baseline')
bucket=1;pos=vector3(50000,0,0);tick(9000)
check(math.abs(exported.getMileageByEntity(10)-100.06)<1e-7,'bucket switch flushes old distance and resets baseline')
pos=vector3(50010,0,0);tick(10000); identifier='license:replacement';pos=vector3(90000,0,0);tick(11000)
check(math.abs(exported.getMileageByEntity(10)-100.07)<1e-7,'reconnect identity resets baseline')
entity=11;pos=vector3(120000,0,0);tick(12000)
check(math.abs(exported.getMileageByEntity(11)-100.07)<1e-7,'entity switch cannot add bridging distance')
pos=vector3(120010,0,0);tick(16000)
check(math.abs(exported.getMileageByEntity(11)-100.07)<1e-7,'long observation gap adds no inferred distance')
record.identity='new-owner';pos=vector3(120020,0,0);tick(17000)
check(math.abs(record.mileage-100.07)<1e-7,'ownership change defeats stale CAS')
source=1; events.playerDropped()
check(math.abs(record.mileage-100.07)<1e-7,'disconnect cannot overwrite changed owner')

-- Store authority: execute the production wrapper, canonicalizer, CAS and cleanup.
resource='zloma_garages';entity=10;plate='CAR1';model=123;bucket=0;ped=1;pos=vector3(0,0,0);now=20000
local fuel, deleted, handlerCalls, mutate = 25, 0, 0, nil
local expectedFuel=25
local row={plate='CAR1',owner='owner1',stored=0,vehicle=json.encode({plate='CAR1',model=123,modEngine=2,engineHealth=600,bodyHealth=800,fuelLevel=25})}
local garage={type='public',park_location={x=0,y=0,z=0},store_radius=10}
local DB={GetColumn=function(k) return k end,GetTable=function() return 'owned_vehicles' end}
exports.zloma_core={GetIdentifier=function() return 'owner1' end,ReadAuthoritativeVehicleFuel=function() return fuel end,
 GetAuthorizedVehicleBinding=function() return {generation='g1',revision=1,originalPlate='CAR1'} end,
 GetVerifiedVehicleContext=function() return {originalPlate='CAR1',generation='g1'} end,InvalidateAuthorizedVehicle=function() return true end,
 GetPlayerJob=function() return {name='police',grade=2} end,IsAuthorizedVehicle=function(_,e,p,m) return e==10 and p=='CAR1' and m==123 end}
exports.zloma_garages={GetDB=function() return DB end,GetGarageById=function() return garage end}
Config.PoliceJobs={police=0}
function GetVehicleEngineHealth() return 1000 end
function GetVehicleBodyHealth() return 500 end
function GetVehicleDirtLevel() return 5 end
function DeleteEntity() deleted=deleted+1 end
MySQL.single.await=function() return clone(row) end
MySQL.update.await=function(q,v)
 check(q:find('AND `owner` = ?',1,true)~=nil and q:find('AND `vehicle` = ?',1,true)~=nil,'store SQL binds canonical DB identity')
 if sqlResult~=1 then return 0 end
 row.vehicle=v[1];row.stored=1;return 1
end
assert(load(read_source('zloma_garages','shared/vehicle_properties.lua')))()
assert(load(read_source('zloma_garages','server/vehicle/store_authority.lua')))()
GarageStoreAuthority.register('store','store',function(src,data)
 handlerCalls=handlerCalls+1
 check(data.props.modEngine==2 and data.props.fuelLevel==expectedFuel,'client mods and fuel cannot replace canonical values')
 check(data.props.engineHealth==600 and data.props.bodyHealth==500,'storage cannot heal durable condition')
 if mutate then mutate() end
 local ok=GarageStoreAuthority.commit(src,'UPDATE owned_vehicles SET vehicle=? WHERE plate=?',{json.encode(data.props),data.plate})
 if ok then GarageStoreAuthority.delete(src,10) end
 return {success=ok}
end)
local function request(extra)
 local d={netId=110,plate='CAR1',garage_id=1,props={model=999,modEngine=99,fuelLevel=100,engineHealth=1000},fuel=100}
 for k,v in pairs(extra or {}) do d[k]=v end
 return callbacks.store(1,d)
end
sqlResult=1
check(request().success and deleted==1,'legitimate store commits once and deletes captured entity')
check(not request().success and deleted==1,'stored record cannot be replayed')
row.stored=0;pos=vector3(100,0,0)
check(not request().success,'garage location mismatch blocked');pos=vector3(0,0,0)
check(not request({plate='OTHER'}).success,'arbitrary plate blocked')
check(not request({netId=111}).success,'arbitrary entity blocked')
model=999;check(not request().success,'actual model must match canonical record');model=123
fuel=nil;expectedFuel=100;check(request().success,'bounded fuel telemetry preserves store without authority reader');row.stored=0;deleted=1;expectedFuel=25;fuel=25
check(not request({fuel=0/0}).success,'nonfinite fuel telemetry rejected')
local originalProof=exports.zloma_core.IsAuthorizedVehicle
exports.zloma_core.IsAuthorizedVehicle=function() return false end
check(not request().success,'matching plate/model alone does not authorize an unregistered entity')
exports.zloma_core.IsAuthorizedVehicle=originalProof
sqlResult=0;check(not request().success and deleted==1,'DB conflict does not delete vehicle');sqlResult=1
mutate=function() entity=11 end
check(not request().success and deleted==1,'entity replacement during handler blocks commit and cleanup')
entity=10;mutate=nil
garage.type='private';garage.owners=json.encode({{identifier='owner1'}})
check(request().success,'legitimate structured private owner preserved')
-- Exercise the actual private registry rather than trusting a state marker.
local caller='zloma_garages'
function GetInvokingResource() return caller end
assert(load(read_source('zloma_core','server/vehicle_authority.lua')))()
check(not exported.IsAuthorizedVehicle(10,'CAR1',123),'unregistered entity rejected by production registry')
check(exported.RegisterAuthorizedVehicle(10,'CAR1',123),'trusted spawn binds exact entity')
check(exported.IsAuthorizedVehicle(10,'CAR1',123),'registered identity is recognized')
check(not exported.IsAuthorizedVehicle(11,'CAR1',123),'matching cloned plate cannot change target')
model=999;check(not exported.IsAuthorizedVehicle(10,'CAR1',123),'registered entity model replacement rejected');model=123
check(exported.RegisterVehicleContextResolver(function(src,p,purpose)
 if src~=1 then return end
 return {identity='owned_vehicles:CAR1',owner='owner1',model=123,access={relationship='owner'}}
end),'trusted resolver registered')
local ctx=exported.GetVerifiedVehicleContext(1,110,'store')
check(ctx and ctx.originalPlate=='CAR1' and ctx.entity==10 and ctx.dbIdentity=='owned_vehicles:CAR1','context resolves exact registered DB identity')
check(not exported.GetVerifiedVehicleContext(2,110,'store'),'unrelated requester rejected')
check(not exported.GetVerifiedVehicleContext(1,111,'store'),'unregistered netId rejected')
function SetVehicleNumberPlateText(_,v) plate=v end
check(exported.SetAuthorizedVehicleDisplayPlate(10,ctx.generation,'FAKE123'),'trusted fake plate transition')
local fake=exported.GetVerifiedVehicleContext(1,110,'store')
check(fake.originalPlate=='CAR1' and fake.displayPlate=='FAKE123' and fake.revision>ctx.revision,'fake display preserves canonical identity and increments revision')
check(not exported.SetAuthorizedVehicleDisplayPlate(10,'wrong-generation','OTHER'),'stale generation cannot change plate')
check(exported.SetAuthorizedVehicleDisplayPlate(10,ctx.generation,'CAR1'),'trusted removal restores canonical plate')
events.entityRemoved(10)
check(not exported.IsAuthorizedVehicle(10,'CAR1',123),'entity removal clears proof before netId reuse')
caller=nil;check(not exported.RegisterAuthorizedVehicle(10,'CAR1',123),'no invoking server integration cannot register proof')
print(('Focused authority: %d production-module mock checks passed'):format(count))
