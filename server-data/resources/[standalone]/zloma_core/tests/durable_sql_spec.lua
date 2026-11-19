local checks=0
local function check(value,label) assert(value,label);checks=checks+1 end
json={encode=encode_json,decode=decode_json}
MySQL={transaction={await=sql_transaction}}
for _,kind in ipairs({'query','single','scalar','insert','update'}) do
    MySQL[kind]={await=function(q,p) return sql_execute(q,p,kind) end}
end
local function sql(q,p) return MySQL.query.await(q,p) end
sql([[CREATE TABLE users(identifier VARCHAR(100) PRIMARY KEY,accounts LONGTEXT NOT NULL,metadata LONGTEXT NOT NULL) ENGINE=InnoDB]])
sql([[INSERT INTO users VALUES ('owner1','{"bank":10000}','{}'),('worker','{"bank":0}','{}')]])
sql([[CREATE TABLE addon_account_data(id INT AUTO_INCREMENT PRIMARY KEY,account_name VARCHAR(100),owner VARCHAR(100),money INT NOT NULL) ENGINE=InnoDB]])
sql([[INSERT INTO addon_account_data(account_name,owner,money) VALUES ('society_dealer',NULL,1000)]])
sql([[CREATE TABLE owned_vehicles(owner VARCHAR(100),plate VARCHAR(32) UNIQUE,vehicle LONGTEXT,stored INT NOT NULL,type VARCHAR(16),garage_id INT NULL) ENGINE=InnoDB]])
sql([[CREATE TABLE zloma_vehicleshops(id INT PRIMARY KEY,custom_balance BIGINT NOT NULL DEFAULT 0,max_debt_limit BIGINT NOT NULL DEFAULT 0) ENGINE=InnoDB]])
sql([[INSERT INTO zloma_vehicleshops VALUES (1,1000,0)]])
sql([[CREATE TABLE zloma_vehicleshop_vehicles(id INT PRIMARY KEY,shop_id INT,enabled INT,in_showroom INT,stock INT,current_stock INT) ENGINE=InnoDB]])
sql([[INSERT INTO zloma_vehicleshop_vehicles VALUES (1,1,1,1,2,2)]])
sql([[CREATE TABLE zloma_vehicleshop_orders(id INT AUTO_INCREMENT PRIMARY KEY,shop_id INT,vehicle_id INT,spawn_name VARCHAR(64),ordered_by VARCHAR(100),placed_by_name VARCHAR(128),placed_by_grade INT,customer_identifier VARCHAR(100),customer_name VARCHAR(128),order_color_primary INT NULL,order_color_secondary INT NULL,is_customer_order INT,unit_cost BIGINT,quantity INT,paid_price BIGINT,status VARCHAR(24),origin_operation VARCHAR(64) UNIQUE,terminal_operation VARCHAR(64),financial_snapshot LONGTEXT,worker_identifier VARCHAR(100),worker_name VARCHAR(128),delivered_at DATETIME NULL,created_at DATETIME DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB]])
sql([[CREATE TABLE zloma_vehicleshop_transactions(id INT AUTO_INCREMENT PRIMARY KEY,shop_id INT,type VARCHAR(32),amount BIGINT,actor_identifier VARCHAR(100),actor_name VARCHAR(128),buyer_identifier VARCHAR(100),buyer_name VARCHAR(128),vehicle_spawn_name VARCHAR(64),notes VARCHAR(512)) ENGINE=InnoDB]])
sql([[CREATE TABLE zloma_vehicleshop_employees(shop_id INT,identifier VARCHAR(100),total_sales INT DEFAULT 0,total_revenue BIGINT DEFAULT 0,last_seen DATETIME NULL) ENGINE=InnoDB]])
sql([[INSERT INTO zloma_vehicleshop_employees(shop_id,identifier) VALUES (1,'owner1')]])
local resource,caller='es_extended',nil
local exported={};local delayed
function GetCurrentResourceName() return resource end
function GetInvokingResource() return caller end
function LoadResourceFile(_,file)
    if file=='server/functions.lua' then return 'ZLOMA_DURABLE_WALLET_SAVE_GUARD ZLOMA_DURABLE_WALLET_SAVE_GUARD' end
    if file=='server/classes/player.lua' then return 'ZLOMA_DURABLE_WALLET_READ_GUARD' end
    return 'ZLOMA_SQL_OWNED_ACCOUNT'
end
function Wait() coroutine.yield() end
function CreateThread(fn) if (resource=='zloma_vehicleshop' and ShopDurable) or resource=='zloma_banking' then delayed=fn else fn() end end
function SetTimeout() end
function AddEventHandler() end
function TriggerClientEvent() end
function TriggerEvent() end
function GetPlayers() return {} end
function GetPlayerName() return 'Test' end
function HasBusinessAccess() return true end
local actor='owner1'
local player={source=1,identifier='owner1',accounts={{name='bank',money=10000,index=1}},metadata={}}
player.getMeta=function(key) return player.metadata[key] end
player.triggerEvent=function() end
ESX={GetPlayerFromIdentifier=function(identifier) return identifier=='owner1' and player or nil end,
    GetExtendedPlayers=function() return {player} end}
local function dispatch(target,name,...)
    local oldResource,oldCaller=resource,caller;caller,resource=resource,target
    local result=table.pack(pcall(exported[target][name],...))
    resource,caller=oldResource,oldCaller
    if not result[1] then error(result[2]) end
    return table.unpack(result,2,result.n)
end
exports=setmetatable({}, {__call=function(_,name,fn) exported[resource]=exported[resource] or {};exported[resource][name]=fn end,
    __index=function(_,target) return setmetatable({}, {__index=function(_,name) return function(_,...) return dispatch(target,name,...) end end}) end})
local function loadProduct(product,file) assert(load(read_source(product,file),file))() end
loadProduct('zloma_core','integrations/esx_legacy_wallet/server/zloma_durable_wallet.lua')
resource='esx_addonaccount'
loadProduct('zloma_core','integrations/esx_addonaccount/server/classes/addonaccount.lua')
local account
function GetSharedAccount() return account end
loadProduct('zloma_core','integrations/esx_addonaccount/server/zloma_durable_accounts.lua')
account=CreateAddonAccount('society_dealer',nil,1000)
resource='zloma_core';ZlomaCore={DetectSociety=function() return 'esx_addonaccount' end}
exported.zloma_core={GetFrameworkType=function() return 'ESX' end,GetIdentifier=function() return actor end,
    GetAuthorizedVehicleEntity=function() return nil end}
loadProduct('zloma_core','server/durable_money.lua')
resource='zloma_vehicleshop'
function GetResourceState() return 'missing' end
function LogDebug() end
function joaat() return 123 end
ZlomaVSDBConfig={};ZlomaVSSchemaManager={Initialize=function() return {framework='ESX',table='owned_vehicles',config={columns={owner='owner',plate='plate',vehicle='vehicle',stored='stored',type='type'}}} end}
loadProduct('zloma_vehicleshop','server/db_adapter.lua')
local seq=0
function GeneratePlate() seq=seq+1;return 'TEST'..seq end
ShopCacheReady=true;ShopCache={[1]={id=1,coords={},custom_balance=1000}};ShopOrders={}
ShopSecurity={spawnTickets={},integer=function(v,lo,hi) return type(v)=='number' and v%1==0 and v>=lo and v<=hi end,
    near=function() return true end,cleanupOrder=function() end,ticket=function() seq=seq+1;ShopSecurity.spawnTickets[seq]={};return seq end}
function RefreshShopCache() ShopCache[1].custom_balance=MySQL.scalar.await('SELECT custom_balance FROM zloma_vehicleshops WHERE id=1') end
loadProduct('zloma_vehicleshop','server/durable_transactions.lua')
local thread=coroutine.create(delayed);local ok,err=coroutine.resume(thread);check(ok and ShopDurable.ready,'real journal/schema initialization: '..tostring(err))
local function purchase(plate)
    local props={plate=plate or ShopDurable.plate(),model='adder'}
    return ShopDurable.prepare(1,'purchase',{shopId=1,props=props,spawnName='adder',spawnCoords={},result={success=true,price=100,label='Adder'},steps={ShopDurable.bank('owner1',-100),{kind='purchase',shopId=1,vehicleId=1,owner='owner1',props=props,price=100,business=true}}}).operationId
end
local op=purchase();local result=ShopDurable.resume(1,'purchase',op)
check(result.success and result.spawnTicket,'purchase executes actual SQL and normal dispatch')
check(MySQL.scalar.await('SELECT current_stock FROM zloma_vehicleshop_vehicles WHERE id=1')==1,'stock decremented')
check(MySQL.scalar.await('SELECT COUNT(*) FROM owned_vehicles')==1 and player.accounts[1].money==9900,'ownership and wallet persisted')
check(ShopDurable.resume(1,'purchase',op).alreadyCompleted and player.accounts[1].money==9900,'actual SQL replay recognized')
check(MySQL.scalar.await('SELECT total_sales FROM zloma_vehicleshop_employees')==1,'employee statistics preserved once')
local stale=json.encode({bank=10000})
check(MySQL.update.await('UPDATE users SET accounts=? WHERE identifier=? AND zloma_wallet_revision<=?',{stale,'owner1',0})==0,'actual stale autosave rejected')
op=purchase();set_fault('commit',true);result=ShopDurable.resume(1,'purchase',op)
check(result.pending,'lost real transaction reply retained')
loadProduct('zloma_vehicleshop','server/durable_transactions.lua');ShopDurable.ready=true
set_fault('cursor',2);result=ShopDurable.resume(1,'purchase',op)
check(result.pending and MySQL.scalar.await('SELECT COUNT(*) FROM owned_vehicles')==2,'ownership committed before lost cursor')
loadProduct('zloma_vehicleshop','server/durable_transactions.lua');ShopDurable.ready=true
result=ShopDurable.resume(1,'purchase',op)
check(result.success and MySQL.scalar.await('SELECT COUNT(*) FROM owned_vehicles')==2 and player.accounts[1].money==9800,'real receipts recover without duplicate owned row or debit')
op=purchase();result=ShopDurable.resume(1,'purchase',op)
check(result.pending and MySQL.scalar.await('SELECT COUNT(*) FROM owned_vehicles')==2,'zero-row stock gate creates no ownership')
ShopDurable.resume(1,'purchase',op)
check(player.accounts[1].money==9800,'real compensation restores debit once')
ShopDurable.resume(1,'purchase',op);check(player.accounts[1].money==9800,'real refund replay')
sql('UPDATE zloma_vehicleshop_vehicles SET current_stock=1 WHERE id=1')
sql([[CREATE TRIGGER deny_owned BEFORE INSERT ON owned_vehicles FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='test insert failure']])
op=purchase();result=ShopDurable.resume(1,'purchase',op)
check(result.pending and MySQL.scalar.await('SELECT current_stock FROM zloma_vehicleshop_vehicles WHERE id=1')==1,'actual SQL error rolls reservation back')
ShopDurable.resume(1,'purchase',op);check(player.accounts[1].money==9800,'insert rejection compensated once')
sql('DROP TRIGGER deny_owned')
local order={shop_id=1,vehicle_id=1,spawn_name='adder',placed_by='owner1',quantity=3,unit_cost=20,paid_price=150,is_customer_order=true,customer_identifier='owner1',financial_shop={kind='society',identity='dealer',delta=90}}
op=ShopDurable.prepare(1,'customer_order',{shopId=1,order=order,result={success=true},steps={ShopDurable.bank('owner1',-150),order.financial_shop,{kind='order',order=order}}}).operationId
result=ShopDurable.resume(1,'customer_order',op);check(result.success and result.orderId,'customer order SQL accepts absent reserved plate and colors')
local stored=MySQL.single.await('SELECT * FROM zloma_vehicleshop_orders WHERE id=?',{result.orderId})
check(stored.quantity==3 and stored.paid_price==150 and stored.order_color_primary==nil,'persistent order fields and nullable colors retained')
order=ShopOrders[1][stored.id]
result=ShopDurable.settle(1,'cancel',order,{shopId=1,terminalOrder=stored.id,result={success=true},steps={{kind='society',identity='dealer',delta=-90,provider=order.financial_shop.provider},ShopDurable.bank('owner1',150,order.financial_bank),{kind='terminal',orderId=stored.id,status='cancelled'}}})
check(result.success and player.accounts[1].money==9800 and account.money==1000,'society cancellation and customer refund actual SQL')
check(ShopDurable.resumeSettlement(1,'cancel',stored.id,1).alreadyCompleted and account.money==1000,'cancel tombstone replay actual SQL')
local stockOrder={shop_id=1,vehicle_id=1,spawn_name='adder',placed_by='owner1',quantity=4,unit_cost=10,financial_shop={kind='society',identity='dealer',delta=-40}}
op=ShopDurable.prepare(1,'boss_order',{shopId=1,order=stockOrder,result={success=true},steps={stockOrder.financial_shop,{kind='order',order=stockOrder}}}).operationId
result=ShopDurable.resume(1,'boss_order',op);check(result.success and account.money==960,'procurement existing society SQL')
order=ShopOrders[1][result.orderId];actor='worker'
result=ShopDurable.settle(2,'delivery',order,{shopId=1,terminalOrder=order.id,result={success=true},steps={{kind='stock',shopId=1,vehicleId=1,business=true,delta=4},ShopDurable.bank('worker',20),{kind='terminal',orderId=order.id,status='delivered'}}})
check(result.success and MySQL.scalar.await('SELECT current_stock FROM zloma_vehicleshop_vehicles WHERE id=1')==5,'delivery stock actual SQL')
check(MySQL.scalar.await("SELECT JSON_UNQUOTE(JSON_EXTRACT(accounts,'$.bank')) FROM users WHERE identifier='worker'")=='20','offline reward actual wallet receipt')
ShopDurable.resumeSettlement(2,'delivery',order.id,1)
check(MySQL.scalar.await('SELECT current_stock FROM zloma_vehicleshop_vehicles WHERE id=1')==5,'delivery replay leaves stock unchanged')
resource='zloma_banking'
loadProduct('zloma_banking','server/durable_offline.lua')
thread=coroutine.create(delayed);ok,err=coroutine.resume(thread)
check(ok and ZlomaOfflineCredits.ready,'banking durable queue real SQL initialization: '..tostring(err))
set_fault('commit',true)
local credited,_,state=ZlomaOfflineCredits.credit('worker',5)
check(not credited and state=='pending','banking lost wallet receipt queued for recovery')
check(MySQL.scalar.await("SELECT JSON_UNQUOTE(JSON_EXTRACT(accounts,'$.bank')) FROM users WHERE identifier='worker'")=='25','offline bridge bank credit actually committed')
sql('UPDATE zloma_banking_offline_credits SET next_attempt=NOW()')
ok,err=coroutine.resume(thread);check(ok,'offline receipt worker recovery: '..tostring(err))
check(MySQL.scalar.await("SELECT COUNT(*) FROM zloma_banking_offline_credits WHERE status='applied'")==1
    and MySQL.scalar.await("SELECT JSON_UNQUOTE(JSON_EXTRACT(accounts,'$.bank')) FROM users WHERE identifier='worker'")=='25','offline receipt worker does not credit twice')

-- Real SQL journal with ordinary cached provider mutations, no receipt API prerequisite.
resource='zloma_vehicleshop';actor='owner1'
local core=exported.zloma_core
core.GetDurableMoneyCapabilities=function() return {bank='ESX',society='esx_addonaccount',bankReady=false,societyReady=false} end
core.GetPlayerFromIdentifier=function(identity) return identity=='owner1' and 1 or nil end
core.GetPlayerMoney=function() return player.accounts[1].money end
core.RemoveMoney=function(src,amount) if player.accounts[1].money<amount then return false end;player.accounts[1].money=player.accounts[1].money-amount;return true end
core.AddMoney=function(src,amount) player.accounts[1].money=player.accounts[1].money+amount;return true end
sql('UPDATE zloma_vehicleshop_vehicles SET current_stock=1 WHERE id=1')
local before=player.accounts[1].money
op=purchase();result=ShopDurable.resume(1,'purchase',op)
check(result.success and player.accounts[1].money==before-100,'ordinary provider succeeds through actual journal SQL')
check(MySQL.scalar.await('SELECT status FROM zloma_vehicleshop_effects WHERE id=?',{op..':1'})=='applied','ordinary claim recorded after acknowledged payment')
loadProduct('zloma_vehicleshop','server/durable_transactions.lua');ShopDurable.ready=true
check(ShopDurable.resume(1,'purchase',op).alreadyCompleted and player.accounts[1].money==before-100,'ordinary replay after module reload does not repeat payment')
op=purchase()
sql("INSERT INTO zloma_vehicleshop_effects(id,operation_id,status) VALUES (?,?,'runtime_started')",{op..':1',op})
result=ShopDurable.resume(1,'purchase',op)
check(result.pending and player.accounts[1].money==before-100,'interrupted ordinary claim stays quarantined with real SQL')
check(MySQL.scalar.await('SELECT COUNT(*) FROM owned_vehicles WHERE zloma_shop_operation=?',{op})==0,'uncertain payment cannot create ownership')
print('Production Lua + isolated MariaDB: '..checks..' checks passed; no FXServer runtime')
