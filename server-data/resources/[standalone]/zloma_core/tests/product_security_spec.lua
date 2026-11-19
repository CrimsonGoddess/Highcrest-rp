local tests=0
local function check(value,label) assert(value,label); tests=tests+1 end
local callbacks,events,registeredExports={},{},{}
local function clone(v) if type(v)~='table' then return v end; local r={}; for k,x in pairs(v) do r[k]=clone(x) end; return r end
local encodings,serial={},0
json={encode=function(v) serial=serial+1; local id='json'..serial; encodings[id]=clone(v); return id end,decode=function(v) return clone(encodings[v] or {}) end}
local vector={__sub=function(a,b) return vector3(a.x-b.x,a.y-b.y,a.z-b.z) end,__len=function(a) return math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z) end}
function vector3(x,y,z) return setmetatable({x=x,y=y,z=z},vector) end
local now,pedVehicle,model,plate,bucket,position=2000,10,123,'CAR1',0,vector3(0,0,0)
local balance,debits,credits,persistence=1000000,0,0,0
local admin=false
local Core={GetPlayerJob=function() return {name='mechanic',grade=3} end,GetFrameworkType=function() return 'ESX' end,IsAdmin=function() return admin end,GetIdentifier=function(_,src) return 'owner'..src end,GetPlayerMoney=function() return balance end,GetSocietyMoney=function() return balance end,RemoveMoney=function(_,_,amount) if balance<amount then return false end; balance=balance-amount;debits=debits+1;return true end,RemoveSocietyMoney=function(_,_,amount) if balance<amount then return false end;balance=balance-amount;debits=debits+1;return true end,AddMoney=function(_,_,amount) balance=balance+amount;credits=credits+1;return true end,AddSocietyMoney=function(_,_,amount) balance=balance+amount;credits=credits+1;return true end,GetJobGrades=function() return {[0]={},[1]={},[3]={}} end}
exports=setmetatable({zloma_core=Core},{__call=function(_,name,fn) registeredExports[name]=fn end})
-- Current tuning module registers receipt useables during startup; these tests exercise tuning payments.
Core.CreateUseableItem=function() end
Core.GetVehicleCatalogue=function() return {class=7,weaponPolicyReviewed=true,mods={['11']={count=5,forbidden={['4']=true}}},wheels={['0']={front=10,rear=10}},extras={['1']=true},liveryCount=2,toggles={modTurbo=true,modXenon=true,modSmokeEnabled=true}} end
Core.RegisterAuthorizedVehicle=function() return true end
Core.GetVerifiedVehicleContext=function() return {generation='binding:1',originalPlate='CAR1',displayPlate='CAR1',persistent=true} end
function NetworkGetNetworkIdFromEntity(e) return e+100 end
function NetworkGetEntityFromNetworkId(n) return n-100 end
lib={callback={register=function(name,fn) callbacks[name]=fn end}}
function GetCurrentResourceName() return 'zloma_tuning' end
function GetResourceState() return 'missing' end
function GetPlayerPed(src) return src end
function GetVehiclePedIsIn() return pedVehicle end
function GetPedInVehicleSeat(entity) return entity==10 and 1 or 0 end
function DoesEntityExist(entity) return entity~=0 end
function GetEntityType() return 2 end
function GetEntityModel() return model end
function GetVehicleNumberPlateText() return plate end
function GetPlayerRoutingBucket() return bucket end
function GetEntityRoutingBucket() return bucket end
function GetEntityCoords() return position end
function GetEntityHeading() return 0 end
function GetGameTimer() return now end
function GetHashKey(name) return name=='adder' and 123 or name=='flatbed3' and 456 or 789 end
function IsPlayerAceAllowed() return admin end
function GetPlayerName() return 'Test' end
function GetConvar(_,default) return default end
function CreateThread() end
function RegisterNetEvent(name,fn) events[name]=fn end
function AddEventHandler(name,fn) events[name]=fn end
function locale(k) return k end
function L(k) return k end
local function loadProduct(p,f) assert(load(read_source(p,f),p..'/'..f))() end
Config={}
loadProduct('zloma_tuning','config/config_prices.lua')
Config.Command={Enabled=true,AdminOnly=true,FreeTuning=true}
Config.UseMarkers=true; Config.Zones={{coords=vector3(0,0,0),radius=3}}
Config.JobRestriction='mechanic'; Config.ChargeSettings={AccountType='society',SocietyName='mechanic'}
local row={vehicle=json.encode({plate='CAR1',model=123,modEngine=-1,engineHealth=700,fuelLevel=25})}
local updateResult=1
MySQL={single={await=function() return clone(row) end},update={await=function(_,values)
    if updateResult~=1 then return updateResult end
    row.vehicle=values[1]; persistence=persistence+1;return 1
end}}
function IsDuplicityVersion() return true end
Config.RequireJobDuty=false;Config.UseStaffDuty=false
loadProduct('zloma_tuning','shared/access.lua')
loadProduct('zloma_tuning','server/authority.lua')
loadProduct('zloma_tuning','server/server.lua')
local begin=callbacks['zloma_tuning:beginSession']
local save=callbacks['zloma_tuning:saveVehicleTuning']
check(begin(1,nil)==nil,'non-admin cannot request free command session')
position=vector3(50,0,0);check(begin(1,1)==nil,'outside workshop');position=vector3(0,0,0)
local s=begin(1,1);check(s and s.token,'legitimate workshop opens')
check(not save(1,s.token+1,{modEngine=2},{}).saved,'invalid token')
check(not save(1,s.token,{plate='OTHER',modEngine=2},{}).saved,'plate mismatch')
pedVehicle=11;check(not save(1,s.token,{modEngine=2},{}).saved,'vehicle mismatch');pedVehicle=10
check(not save(1,s.token,{modEngine=0/0},{}).saved,'NaN rejected')
check(not save(1,s.token,{modEngine=math.huge},{}).saved,'infinity rejected')
check(not save(1,s.token,{modEngine=999},{}).saved,'extreme index rejected')
check(not save(1,s.token,{modEngine=4},{}).saved,'forbidden model-specific mod rejected')
check(not save(1,s.token,{extras={['2']=0}},{}).saved,'non-existent model extra rejected')
check(not save(1,s.token,{modSpoilers=0},{}).saved,'absent model mod slot rejected even when count is zero')
check(not save(1,s.token,{wheels=2},{}).saved,'unknown model wheel catalogue rejected')
check(not save(1,s.token,{livery=2},{}).saved,'out-of-range model livery rejected')
balance=0;check(not save(1,s.token,{modEngine=2},{}).saved and persistence==0,'failed payment cannot persist')
balance=1000000
local result=save(1,s.token,{modEngine=2,engineHealth=1000,fuelLevel=100,owner='attacker'}, {})
check(result.saved and result.amount==32500,'server price from model catalogue, no client zero-price input')
local stored=json.decode(row.vehicle)
check(stored.engineHealth==700 and stored.fuelLevel==25 and stored.owner==nil and result.props.engineHealth==nil and result.props.fuelLevel==nil,'non-tuning persistence and live damage protected')
check(debits==1 and persistence==1,'one payment precedes one persistence')
check(not save(1,s.token,{modEngine=3},{}).saved and debits==1,'checkout replay rejected')
s=begin(1,1);updateResult=0
result=save(1,s.token,{modEngine=3},{})
check(not result.saved and credits==1,'CAS conflict refunds')
updateResult=1
s=begin(1,1);admin=true
local free=begin(1,nil);check(free and free.free,'authorized free command retained');admin=false
local adderPrice=Config.Prices.Vehicles.adder
Config.Prices.Vehicles.adder=nil
local classSession=begin(1,1)
check(callbacks['zloma_tuning:quoteSession'](1,classSession.token,{modEngine=1},{}).amount==30000,'trusted catalogue class pricing preserves original class price')
Config.Prices.Vehicles.adder=adderPrice
local trustedCatalogue=Core.GetVehicleCatalogue
Core.GetVehicleCatalogue=function() return nil end
local fallback=begin(1,1)
check(fallback and fallback.token,'missing catalogue preserves legitimate tuning')
check(not save(1,fallback.token,{modEngine=999},{}).saved,'bounded fallback rejects extreme mods')
local before=debits
local tuned=save(1,fallback.token,{modEngine=1},{})
check(tuned.saved and tuned.amount>0 and debits==before+1,'fallback still uses server price and payment before persistence')
check(not save(1,fallback.token,{modEngine=2},{}).saved,'fallback session cannot replay')
Core.GetVehicleCatalogue=trustedCatalogue
local originalRow=row;local proof=Core.GetVerifiedVehicleContext
Core.GetVerifiedVehicleContext=function() return nil end
check(begin(1,1)==nil,'unregistered clone cannot tune a persistent DB record')
row=nil
local npc=begin(1,1)
local writes=persistence
check(npc and save(1,npc.token,{modEngine=1},{}).saved and persistence==writes,'paid non-owned tuning preserves gameplay without adopting persistent identity')
row=originalRow;Core.GetVerifiedVehicleContext=proof



-- Boss security: validation and the lock surround the real handler, including yields.
loadProduct('zloma_bossmenu','server/security.lua')
check(not BossSecurity.grade('mechanic',2),'non-existent grade rejected')
check(BossSecurity.grade('mechanic',1),'existing grade accepted')
check(not BossSecurity.grade('mechanic',1.5),'fractional grade rejected')
local calls=0
BossSecurity.register('zloma_bossmenu:withdraw',function(src,value)
    calls=calls+1
    local nested=callbacks['zloma_bossmenu:withdraw'](src,value)
    check(nested==false,'concurrent mutation rejected before handler')
    return true
end)
check(callbacks['zloma_bossmenu:withdraw'](1,100)==true and calls==1,'legitimate mutation executes once')
check(callbacks['zloma_bossmenu:withdraw'](1,0/0)==false and calls==1,'NaN blocked before handler')
check(callbacks['zloma_bossmenu:withdraw'](1,'1e999')==false,'numeric-string infinity blocked')
local tooDeep={};local cursor=tooDeep;for i=1,10 do cursor.x={};cursor=cursor.x end
check(callbacks['zloma_bossmenu:withdraw'](1,tooDeep)==false,'deep payload rejected')

-- Shop test drive uses actual shop model membership and server return position.
ShopCache={[1]={coords={x=0,y=0,z=0},testdrive_coords={x=10,y=0,z=0},shop_open=true,vehicles={{spawn_name='adder',enabled=1,vehicle_type='car'}},label='Shop'}}
ActiveTestDrives={};ShopOrders={};Config.TestDrive={duration=15};Config.Business={towTruckModel='flatbed3'}
function SetRoutingBucketPopulationEnabled() end
function SetRoutingBucketEntityLockdownMode() end
function SetPlayerRoutingBucket(_,value) bucket=value end
function LogDebug() end
loadProduct('zloma_vehicleshop','server/security.lua')
loadProduct('zloma_vehicleshop','server/shop/testdrive.lua')
local start=callbacks['zloma_vehicleshop:startTestDrive']
check(not start(1,1,'tank',{},{}).success,'test-drive arbitrary model denied')
bucket=42
local drive=start(1,1,'adder',{}, {x=99999,y=99999,z=99999})
check(drive.success and drive.spawnTicket,'test drive server-issued ticket')
check(drive.returnCoords.x==0 and drive.returnCoords.y==0,'client return teleport rejected')
check(bucket==10001,'test drive dimension allocated')
check(not start(1,1,'adder',{},{}).success,'parallel test drive denied')
check(callbacks['zloma_vehicleshop:endTestDrive'](1).success and bucket==42,'original bucket restored')
local modelBefore=model
check(not callbacks['zloma_vehicleshop:redeemSpawn'](2,drive.spawnTicket).success,'ticket source bound')
check(not callbacks['zloma_vehicleshop:redeemSpawn'](1,999).success,'unknown spawn ticket denied')
Config.ServerControlledVehicles=false
local ticket=ShopSecurity.ticket(1,'adder','purchase',{x=0,y=0,z=0},{plate='CAR1'},'car')
check(callbacks['zloma_vehicleshop:redeemSpawn'](1,ticket).success,'authorized hybrid spawn retained')
check(not callbacks['zloma_vehicleshop:redeemSpawn'](1,ticket).success,'spawn ticket replay denied')
check(not callbacks['zloma_vehicleshop:bindSpawn'](1,ticket,0/0).success,'invalid entity target denied')
function HasBusinessAccess() return true end
ShopOrders[1]={[10]={status='pending',worker_identifier='owner1'}}
check(not ShopSecurity.completeDelivery(1,1,10),'pending order cannot be completed')
ShopOrders[1][10].status='in_progress'
check(not ShopSecurity.completeDelivery(1,1,10),'missing pickup cannot be completed')
ShopSecurity.delivery[10]={source=2,identifier='owner2',shop=1,tow=10,cargo=20,bucket=42,picked=0}
check(not ShopSecurity.completeDelivery(1,1,10),'other worker cannot complete')
-- Provider-side stash hook denies direct inventory calls that bypass the menu.
local hooks={}
exports.ox_inventory={registerHook=function(_,name,fn) hooks[name]=fn end}
function GetResourceState(name) return name=='ox_inventory' and 'started' or 'missing' end
events.onResourceStart('ox_inventory')
check(hooks.openInventory({source=1,inventoryId='player_stash_test'})==false,'direct stash bypass denied')
BossSecurity.grant(1,'player_stash_test')
check(hooks.openInventory({source=1,inventoryId='player_stash_test'})==true,'authorized stash grant accepted')
check(hooks.openInventory({source=2,inventoryId='player_stash_test'})==false,'stash grant source bound')
BossSecurity.removing.player_stash_test=true
check(hooks.openInventory({source=1,inventoryId='player_stash_test'})==false,'stash cannot open during pickup')
check(hooks.swapItems({fromInventory='player_stash_test',toInventory=1})==false,'stash move blocked during pickup')
BossSecurity.removing.player_stash_test=nil
now=now+5001
check(hooks.openInventory({source=1,inventoryId='player_stash_test'})==false,'stash grant expires')

-- Load the real stash handler to test pickup replay, full inventory and remote access.
Config.PlayerStashes={types={small={item='stashitem'}},pinLength=6};Config.Logging={};Config.Creator={allowedGroups={}}
local stash={stash_id='player_stash_test',owner_identifier='owner1',stash_type='small',stash_name='Test',location=json.encode({x=0,y=0,z=0}),access_mode='owner'}
local stashPresent=true
local placementItems=0
local canAdd=true
Core.CanReadStashItems=function() return true end
Core.GetStashItems=function() return {} end
Core.AddItem=function() if not canAdd then return false end;placementItems=placementItems+1;return true end
Core.Notify=function() end;Core.GetCharacterName=function() return 'Test' end
function LoadPlayerStashes() end
MySQL.single.await=function() return stashPresent and clone(stash) or nil end
MySQL.update.await=function() if not stashPresent then return 0 end;stashPresent=false;return 1 end
MySQL.insert={await=function() stashPresent=true;return 1 end}
loadProduct('zloma_bossmenu','server/stashes.lua')
local remove=callbacks['zloma_bossmenu:removePlayerStash']
canAdd=false;check(remove(1,'player_stash_test')==false and stashPresent and placementItems==0,'full inventory restores stash')
canAdd=true;check(remove(1,'player_stash_test')==true and not stashPresent and placementItems==1,'legitimate pickup once')
check(remove(1,'player_stash_test')==false and placementItems==1,'stash pickup replay cannot mint item')
stashPresent=true;position=vector3(100,0,0)
check(callbacks['zloma_bossmenu:openPlayerStash'](1,'player_stash_test')==false,'remote stash denied')
position=vector3(0,0,0)

-- Key bridge must consume a trusted grant or prove ownership, not just proximity.
local keysIssued=0
function NormalizePlate(p) return type(p)=='string' and p or nil end
function GetRealPlate() return plate end
function PlayerHasKey() return false end
function GiveKeyToPlayer() keysIssued=keysIssued+1;return true end
MySQL.single.await=function() return nil end
loadProduct('zloma_keys','server/authorization.lua')
local priorProof=Core.GetVerifiedVehicleContext
Core.GetVerifiedVehicleContext=function() return {persistent=false,access={relationship='delivery'}} end
check(HasAuthorizedVehicleUse(1,10),'verified delivery grants temporary driving access without an inventory key')
Core.GetVerifiedVehicleContext=function() return {persistent=true,access={relationship='owner'}} end
check(not HasAuthorizedVehicleUse(1,10),'persistent ownership does not become temporary mission permission')
Core.GetVerifiedVehicleContext=function() return nil end
check(not HasAuthorizedVehicleUse(1,10),'unverified entity has no mission driving permission')
Core.GetVerifiedVehicleContext=priorProof

check(not AuthorizeClientKey(1,'CAR1',10) and keysIssued==0,'nearby unowned vehicle cannot issue keys')
now=now+5001
check(registeredExports.AuthorizeKeyRequest(1,'CAR1',123),'trusted integration can grant')
check(AuthorizeClientKey(1,'CAR1',10) and keysIssued==1,'integration grant preserves garage key flow')
now=now+5001
check(not AuthorizeClientKey(1,'CAR1',10) and keysIssued==1,'key grant replay cannot mint item')
-- Hotwire completion requires a source-bound, timed server attempt.
function NetworkGetEntityFromNetworkId(id) return id == 10 and 10 or id == 20 and 20 or 0 end
function NetworkGetNetworkIdFromEntity(entity) return entity end
function GetVehicleDoorLockStatus() return 1 end
function GetEntityPopulationType() return 7 end
function GetPlayer() return {} end
function DebugPrint() end
local broadcasts=0
function TriggerClientEvent() broadcasts=broadcasts+1 end
Config.EnableHotwire=true; Config.HotwirePoliceAlert=false
loadProduct('zloma_keys','server/hotwire.lua')
Config.RandomCarKeys={enabled=true,onlyUnownedVehicles=false,chance=100}
check(not callbacks['zloma_keys:server:searchVehicleKeys'](1,10,'CAR1').found,'unapproved scripted vehicle cannot farm random keys')
check(registeredExports.AuthorizeVehicleKeySearch(10),'trusted scripted key-search vehicle integration retained')
local beforeSearch=keysIssued
check(callbacks['zloma_keys:server:searchVehicleKeys'](1,10,'CAR1').found and keysIssued==beforeSearch+1,'authorized key search preserves reward')
check(not callbacks['zloma_keys:server:searchVehicleKeys'](1,10,'CAR1').found and keysIssued==beforeSearch+1,'key search replay cannot mint item')
source=1
local finishHotwire=events['zloma_keys:server:hotwireVehicle']
finishHotwire(10,'CAR1',nil,nil,'invented')
check(not IsVehicleHotwired('CAR1'),'hotwire without attempt denied')
local hotwire=callbacks['zloma_keys:server:beginHotwire'](1,10,'CAR1')
check(type(hotwire)=='string','legitimate hotwire starts')
finishHotwire(10,'CAR1',nil,nil,hotwire)
check(not IsVehicleHotwired('CAR1'),'early hotwire completion denied')
now=now+1001;source=2;finishHotwire(10,'CAR1',nil,nil,hotwire)
check(not IsVehicleHotwired('CAR1'),'hotwire source mismatch denied')
source=1;finishHotwire(10,'CAR1',nil,nil,hotwire)
check(IsVehicleHotwired('CAR1'),'timed driver attempt completes')
local before=broadcasts;finishHotwire(10,'CAR1',nil,nil,hotwire)
check(broadcasts==before,'hotwire completion replay rejected')

-- NPC carjack grant cannot be used to manufacture keys for an arbitrary entity.
Config.EnableCarjack=true;Config.CarjackStealTime=3000;Config.CarjackPoliceAlert=false
local npcDriver=true
function GetPedInVehicleSeat(entity) return entity==10 and (npcDriver and 20 or 1) or 0 end
function GetEntityType(entity) return entity==20 and 1 or 2 end
function GetPlayers() return {'1','2'} end
local population=1
function GetEntityPopulationType() return population end
function GetSelectedPedWeapon() return 999 end
loadProduct('zloma_keys','server/carjack.lua')
local beginJack=callbacks['zloma_keys:server:beginCarjack']
check(beginJack(1,10,'OTHER',20)==false,'carjack plate mismatch rejected')
population=7
check(beginJack(1,10,'CAR1',20)==false,'unapproved scripted NPC rejected')
check(registeredExports.AuthorizeCarjackNpc(10,20),'trusted scripted NPC integration retained')
local jack=beginJack(1,10,'CAR1',20)
check(type(jack)=='string','authorized carjack begins')
local keyCount=keysIssued
events['zloma_keys:server:carjackVehicle'](10,'CAR1',nil,nil,jack)
check(keysIssued==keyCount,'carjack early completion denied')
now=now+3001;npcDriver=false
events['zloma_keys:server:carjackVehicle'](10,'CAR1',nil,nil,jack)
check(keysIssued==keyCount+1,'carjack eligible completion issues one key')
events['zloma_keys:server:carjackVehicle'](10,'CAR1',nil,nil,jack)
check(keysIssued==keyCount+1,'carjack ticket replay rejected')
check(beginJack(1,10,'CAR1',20)==false,'claimed NPC cannot farm keys')

-- Stance runs the actual persistence event, not a duplicate validator.
Framework={GetPlayer=function() return {} end,GetIdentifier=function() return 'owner1' end,GetJob=function() return 'mechanic' end}
Config.FitmentZones={{coords=vector3(0,0,0),radius=3}}
local wheelWrites=0
MySQL.update.await=function() wheelWrites=wheelWrites+1;return 1 end
function Entity() return {state={set=function() end}} end
loadProduct('zloma_stance','server/server.lua')
local fit={stance={front=.05},camber={front=.02}}
local absolute={off_fl=.8,off_fr=-.8,off_rl=.8,off_rr=-.8,cam_fl=.02,cam_fr=.02,cam_rl=.02,cam_rr=.02}
local apply=events['zloma_stance:applyFitment']
source=1;apply(10,'OTHER',fit,absolute,1)
check(wheelWrites==0,'stance plate mismatch denied')
fit.stance.front=math.huge;apply(10,'CAR1',fit,absolute,1)
check(wheelWrites==0,'stance infinity denied')
fit.stance.front=.05;absolute.off_fl=100;apply(10,'CAR1',fit,absolute,1)
check(wheelWrites==0,'stance extreme offset denied')
absolute.off_fl=.8;position=vector3(100,0,0);apply(10,'CAR1',fit,absolute,1)
check(wheelWrites==0,'stance remote station denied')
position=vector3(0,0,0);apply(10,'CAR1',fit,absolute,1)
check(wheelWrites==1,'stance eligible fitment persists once')
apply(10,'CAR1',fit,absolute,1)
check(wheelWrites==1,'stance rapid replay throttled')

-- Antibump has no authority events; verify the event-driven client behavior.
loadProduct('zloma_vehicleshop','server/security_environment.lua')
local function environment(serverCreated, lockdown, stateStrict, filter)
    return ShopSecurityEnvironment.evaluate({serverCreated=serverCreated,lockdown=lockdown,stateStrict=stateStrict,filter=filter})
end
local profile,lines=environment(true,'strict',true,2)
check(profile=='RECOMMENDED' and not table.concat(lines):find('%[WARNING%]'),'recommended shop matrix has no warning')
check(environment(true,'inactive',true,2)=='SECURITY ADVISORY','inactive global lockdown advisory, server authority retained')
check(environment(true,'relaxed',true,2)=='SECURITY ADVISORY','relaxed is not strict')
check(environment(false,'strict',true,2)=='INCOMPATIBLE / ERROR','hybrid strict is actual incompatibility')
check(environment(false,'inactive',true,2)=='COMPATIBILITY MODE','hybrid inactive has no configuration error')
check(environment(true,'strict',false,2)=='SECURITY ADVISORY','optional state hardening is advisory')
check(environment(true,'strict',true,4)=='RECOMMENDED','filter four is not automatically an error')
check(environment(true,'strict',true,0)=='SECURITY ADVISORY','disabled control filtering advisory')
-- Real purchase validation/quote handler. Durable execution/crash boundaries
-- run against the production journal in shop_durable_spec.lua.
local purchaseVehicle={id=10,shop_id=1,enabled=1,spawn_name='adder',price=50000,stock=1,vehicle_type='car'}
local purchaseRows,insertOk,reserveOk=0,true,true
local adapter={IsReady=function() return true end,GetShopVehicle=function() return clone(purchaseVehicle) end,
    PlateExists=function() return false end,
    DecrementStock=function() if not reserveOk or purchaseVehicle.stock<=0 then return false end;purchaseVehicle.stock=purchaseVehicle.stock-1;return true end,
    RestoreStock=function() purchaseVehicle.stock=purchaseVehicle.stock+1 end,
    InsertOwnedVehicle=function() if not insertOk then return false end;purchaseRows=purchaseRows+1;return true end}
_G.ZlomaVSDBAdapter=adapter
function FormatMoney(value) return tostring(value) end
function GeneratePlate() return 'NEWCAR' end
function RefreshShopCache() end
function DiscordLogPurchase() end
function LogError() end
local preparedPayload
ShopDurable={plate=function() return 'NEWCAR' end,bank=function(identity,delta) return {kind='bank',identity=identity,delta=delta} end,
    prepare=function(_,kind,payload) preparedPayload=payload;return {prepared=true,operationId='quote-id',success=false} end,
    resume=function(_,kind,id) return {success=id=='quote-id',alreadyCompleted=true} end}
ShopCache[1].spawn_pos={x=0,y=0,z=0};ShopCache[1].business_mode=false
local originalThread=CreateThread
function CreateThread(fn) fn() end -- only this file's adapter-ready initialization
loadProduct('zloma_vehicleshop','server/shop/purchase.lua')
CreateThread=originalThread
local purchase=callbacks['zloma_vehicleshop:purchaseVehicle']
balance=0
check(not purchase(1,1,10,0,0).success and purchaseRows==0,'shop failed payment cannot create ownership')
balance=1000000
local cash=balance
check(purchase(1,1,10,0,0).prepared and balance==cash and purchaseRows==0,'quote has no bank or ownership side effect')
check(preparedPayload.steps[1].delta==-50000 and preparedPayload.result.price==50000,'server immutable purchase price')
check(preparedPayload.steps[2].kind=='purchase' and preparedPayload.props.plate=='NEWCAR','stock and ownership are one durable participant')
check(purchase(1,1,10,0,0,'quote-id').alreadyCompleted and purchaseRows==0,'operation retry routed before stock validation')
check(not purchase(1,1,10,0/0,0).success,'shop NaN color rejected')

-- HUD bags are outputs, not authority for stress persistence.
function GetCurrentResourceName() return 'zloma_hud' end
Config.StressSystem={enabled=true,useCustomStress=false}
Config.StressConfig={items={tablets={},boxes={}},persistence={enabled=false},admin={},gain={}}
function RegisterCommand() end
local playerState={stress=99}
playerState.set=function(_,key,value) playerState[key]=value end
function Player() return {state=playerState} end
loadProduct('zloma_hud','server/state_bags.lua')
loadProduct('zloma_hud','server/stress.lua')
registeredExports.setStress(1,40)
playerState.stress=0
check(registeredExports.getStress(1)==40,'client-authored stress bag cannot alter authoritative stress')
source=1;pedVehicle=0;events['zloma_hud:server:setSeatbelt'](true)
check(ZlomaHudSeatbelts[1]==nil,'seatbelt on foot denied')
pedVehicle=10;events['zloma_hud:server:setSeatbelt'](true)
check(ZlomaHudSeatbelts[1]==true,'vehicle seatbelt intent retained')

function GetCurrentResourceName() return 'zloma_antibump' end
Config={Debug=false,ReapplyDelayMs=500,IgnoredVehicles={}}
function GetEntityArchetypeName() return 'adder' end
function IsThisModelACar() return true end
local handlingWrites,entry=0,nil
function SetVehicleHandlingInt() handlingWrites=handlingWrites+1 end
lib.onCache=function(_,fn) entry=fn end
loadProduct('zloma_antibump','client.lua')
entry(10);entry(10)
check(handlingWrites==1,'antibump duplicate entry throttled')
now=now+501;entry(10)
check(handlingWrites==2,'antibump re-entry applies after cooldown')
Config.IgnoredVehicles.adder=true;entry(11)
check(handlingWrites==2,'antibump ignored vehicle unchanged')
print(('Product security: %d production-handler mock checks passed'):format(tests))
