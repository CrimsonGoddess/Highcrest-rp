local count=0
local function check(value,label) assert(value,label);count=count+1 end
local callbacks,events,threads,api={},{},{},{}
local resource,caller='zloma_core',nil
local values,serial={},0
json={encode=function(v) serial=serial+1;local key='j'..serial;values[key]=v;return key end,decode=function(v) return values[v] end}
local mt={__sub=function(a,b) return vector3(a.x-b.x,a.y-b.y,a.z-b.z) end,__len=function(v) return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z) end}
function vector3(x,y,z) return setmetatable({x=x,y=y,z=z},mt) end
local entity,plate,model,bucket,position=10,'CAR1',123,0,vector3(0,0,0)
function GetCurrentResourceName() return resource end
function GetInvokingResource() return caller end
function GetGameTimer() return 20000 end
function DoesEntityExist(e) return e==10 or e==11 end
function GetEntityType() return 2 end
function GetEntityModel() return model end
function GetHashKey() return 123 end
function GetVehicleNumberPlateText() return plate end
function SetVehicleNumberPlateText(_,v) plate=v end
function GetEntityRoutingBucket() return bucket end
function GetPlayerRoutingBucket() return 0 end
function GetPlayerPed(src) return src end
function GetPedInVehicleSeat() return 1 end
function GetEntityCoords(e) return e<=2 and vector3(0,0,0) or position end
function NetworkGetNetworkIdFromEntity(e) return e+100 end
function NetworkGetEntityFromNetworkId(n) return n-100 end
local rentalEnabled=false
function GetResourceState(name) return rentalEnabled and name=='zloma_rental' and 'started' or 'missing' end
function RegisterNetEvent(n,f) events[n]=f end
function AddEventHandler(n,f) events[n]=f end
function CreateThread(fn) threads[#threads+1]=fn end
local state={}
function Entity() return {state={set=function(_,k,v) state[k]=v end}} end
lib={callback={register=function(n,f) callbacks[n]=f end}}
local function dispatch(target,name,...)
    local oldResource,oldCaller=resource,caller;caller,resource=resource,target
    local result=table.pack(pcall(api[target][name],...))
    resource,caller=oldResource,oldCaller
    if not result[1] then error(result[2]) end
    return table.unpack(result,2,result.n)
end
exports=setmetatable({}, {__call=function(_,name,fn) api[resource]=api[resource] or {};api[resource][name]=fn end,
 __index=function(_,target) return setmetatable({}, {__index=function(_,name) return function(_,...) return dispatch(target,name,...) end end}) end})
local inventory,consumed,synced=2,0,0
api.zloma_core={GetIdentifier=function(src) return src==1 and 'owner1' or 'other' end,
 GetFrameworkType=function() return 'ESX' end,GetItemCount=function() return inventory end,RemoveItem=function() if inventory<1 then return false end;inventory=inventory-1;consumed=consumed+1;return true end,
 AddItem=function() inventory=inventory+1;return true end,GetPlayerJob=function() return {name='police',grade=2} end}
local row={id=5,plate='CAR1',owner='owner1',stored=0,vehicle=json.encode({plate='CAR1',model=123})}
local DB={GetTable=function() return 'owned_vehicles' end,GetColumn=function(k) return k end}
api.zloma_garages={GetDB=function() return DB end,UpdateTrackedFakePlate=function() end}
function ValidatePersonalAccess() return false end
function ValidateOrgAccess() return false end
Config={FakePlates={enabled=true,itemName='fake_plate',inventorySync={enabled=false},fuelSync={enabled=false}},PoliceJobs={police=0}}
local mapping
MySQL={single={await=function(q)
 if q:find('zloma_vehicle_display_plates',1,true) then return mapping end
 if q:find('zloma_rentals',1,true) then return {id=9,model='adder'} end
 return row
end},scalar={await=function() return nil end},query={await=function(q,p)
 if q:find('INSERT INTO zloma_vehicle_display_plates',1,true) then mapping={original_plate=p[1],display_plate=p[2],binding_generation=p[3],revision=p[4]} end
 return 1
end},update={await=function() mapping=nil;return 1 end}}
MySQL.transaction={await=function(tx)
    for _,q in ipairs(tx) do if q.query:find('DELETE',1,true) then MySQL.update.await(q.query,q.values) else MySQL.query.await(q.query,q.values) end end
    return true
end}
local function loadProduct(p,f) assert(load(read_source(p,f),p..'/'..f))() end
loadProduct('zloma_core','server/vehicle_authority.lua')
resource='zloma_garages'
loadProduct('zloma_garages','shared/vehicle_properties.lua')
loadProduct('zloma_garages','server/vehicle/context.lua')
FakePlates={GenerateRandomPlate=function() return 'FAKE123' end,GetStateBagKey=function() return 'fakePlate:original' end}
FakePlateInventory={OnApply=function() synced=synced+1 end,OnRemove=function() synced=synced+1 end}
loadProduct('zloma_garages','server/fake_plates.lua')
loadProduct('zloma_garages','server/vehicle/fake_plate_authority.lua')
threads[#threads]()
local change=callbacks['zloma_garages:fakePlates:change']
check(not change(1,110,'install').success,'unregistered matching model/plate cannot install')
check(exports.zloma_core:RegisterAuthorizedVehicle(10,'CAR1',123),'trusted creation binds')
check(not change(2,110,'install').success,'unrelated character cannot mutate identity')
check(not change(1,111,'install').success,'cloned plate cannot mutate canonical mapping')
position=vector3(50,0,0)
check(not change(1,110,'install').success,'remote actor cannot install');position=vector3(0,0,0)
bucket=1;check(not change(1,110,'install').success,'wrong bucket cannot install');bucket=0
local ctx=exports.zloma_core:GetVerifiedVehicleContext(1,110,'store')
check(ctx.dbIdentity=='owned_vehicles:5' and ctx.owner=='owner1','immutable DB identity and current owner returned')
local result=change(1,110,'install')
check(result.success and plate=='FAKE123' and consumed==1 and inventory==1,'legitimate install consumes one fixed item')
check(mapping.original_plate=='CAR1' and mapping.display_plate=='FAKE123','server canonical/display mapping persisted')
local fake=exports.zloma_core:GetVerifiedVehicleContext(1,110,'store')
check(fake.originalPlate=='CAR1' and fake.displayPlate=='FAKE123' and fake.revision>ctx.revision,'private context never adopts fake as canonical')
check(not change(1,110,'install').success and consumed==1,'install replay cannot consume or rename twice')
for _,name in ipairs({'store','clear','consumeItem','trackingUpdate'}) do events['zloma_garages:fakePlates:'..name](111,'VICTIM','EVIL') end
check(consumed==1 and synced==1 and plate=='FAKE123','legacy fragmented events cannot rename or spend')
check(change(1,110,'remove').success and plate=='CAR1' and not mapping,'legitimate removal restores DB/binding/display')
check(not change(1,110,'remove').success and synced==2,'remove replay has no provider side effects')
inventory=0;check(not change(1,110,'install').success and plate=='CAR1','missing item cannot grant fake plate')
row.owner='other'
check(not exports.zloma_core:GetVerifiedVehicleContext(1,110,'store'),'ownership change revokes old access')
local transferred=exports.zloma_core:GetVerifiedVehicleContext(2,110,'store')
check(transferred and transferred.owner=='other' and transferred.revision>fake.revision,'ownership transfer updates context revision')
row.id=6;check(not exports.zloma_core:GetVerifiedVehicleContext(2,110,'store'),'replaced DB record cannot inherit old binding')
events.entityRemoved(10)
check(not exports.zloma_core:GetVerifiedVehicleContext(2,110,'store'),'entity removal invalidates netId generation')

row.id=5;row.owner='owner1';plate='CAR1';rentalEnabled=true
api.zloma_rental={RegisterRentalEntity=function(src,e) return GetInvokingResource()=='zloma_garages' and src==1 and e==10 end}
resource='zloma_rental'
check(exports.zloma_garages:BindRentalVehicle(1,10,'CAR1'),'trusted initial rental creation registers through product hook')
local rented=exports.zloma_core:GetVerifiedVehicleContext(1,110,'store')
check(rented and rented.access.relationship=='rental' and rented.access.rentalId==9,'rental relationship and DB identity preserved')
resource='unknown_resource'
check(not exports.zloma_garages:BindRentalVehicle(1,11,'CAR1'),'unrelated resource cannot call rental lifecycle hook')

events.onResourceStop('zloma_garages')
check(exports.zloma_core:GetVerifiedVehicleContext(1,110,'store').owner=='owner1','default persistent DB resolver works for surviving purchase binding')
row.vehicle=json.encode({plate='CAR1',model=999})
check(not exports.zloma_core:GetVerifiedVehicleContext(1,110,'store'),'default resolver rejects replaced canonical model')
resource='zloma_vehicleshop';plate='TESTDRIVE'
check(exports.zloma_core:RegisterAuthorizedVehicle(10,'TESTDRIVE',123,nil,{transient=true,identifier='owner1',kind='testdrive',identity='shop:1'}),'first transient testdrive binds')
check(exports.zloma_core:RegisterAuthorizedVehicle(11,'TESTDRIVE',123,nil,{transient=true,identifier='other',kind='testdrive',identity='shop:2'}),'second same-plate testdrive remains usable')
local first=exports.zloma_core:GetVerifiedVehicleContext(1,110,'testdrive')
local second=exports.zloma_core:GetVerifiedVehicleContext(2,111,'testdrive')
check(first and second and first.generation~=second.generation and not first.persistent,'transient contexts have separate exact generations')
check(not exports.zloma_core:GetAuthorizedVehicleEntity('TESTDRIVE'),'transient text does not become persistent plate authority')
print('Final verified vehicle/fake plate contract: '..count..' production-module checks passed; no FXServer')
