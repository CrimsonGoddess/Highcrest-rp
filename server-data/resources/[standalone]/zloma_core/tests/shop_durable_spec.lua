local checks=0
local function check(value,label) assert(value,label);checks=checks+1 end
local function copy(v) if type(v)~='table' then return v end;local t={};for k,x in pairs(v) do t[k]=copy(x) end;return t end
local codes,counter={},0
json={encode=function(v) counter=counter+1;local key='j'..counter;codes[key]=copy(v);return key end,decode=function(v) return copy(codes[v]) end}
local db={ops={},effects={},owned={},orders={},stock=2,balance=1000,logs=0,sales=0}
local wallets={customer=1000,worker=0};local receipts={};local receiptCalls=0
local actor='customer'
local core={GetIdentifier=function() return actor end,GetDurableMoneyCapabilities=function() return {bankReady=true,societyReady=true} end,
    GetAuthorizedVehicleEntity=function() return nil end}
local moneyFault,cursorFault,txFault,insertFault=false,false,false,false
local function money(_,key,identity,delta)
    if receipts[key] then check(receipts[key].identity==identity and receipts[key].delta==delta,'immutable participant identity');return {success=true,status='applied'} end
    if (wallets[identity] or 0)+delta<0 then return {success=false,reason='insufficient'} end
    wallets[identity]=(wallets[identity] or 0)+delta;receipts[key]={identity=identity,delta=delta};receiptCalls=receiptCalls+1
    if moneyFault then moneyFault=false;error('simulated lost money receipt acknowledgement') end
    return {success=true,status='applied'}
end
core.ApplyBankMoneyOnce=money;core.ApplySocietyMoneyOnce=money
exports={zloma_core=core}
function CreateThread() end
function GetPlayerName() return 'Test' end
function GetPlayers() return {} end
function HasBusinessAccess() return true end
function GeneratePlate() return 'CAR'..counter end
ShopCacheReady=true;ShopOrders={};ShopCache={[1]={id=1}}
ShopSecurity={spawnTickets={},integer=function(v,lo,hi) return type(v)=='number' and v%1==0 and v>=lo and v<=hi end,
    near=function() return true end,cleanupOrder=function() end,ticket=function()
        counter=counter+1;ShopSecurity.spawnTickets[counter]={};return counter
    end}
function RefreshShopCache() end
local adapter={IsReady=function() return true end,PlateExists=function() return false end,
    GetVehicleStorageContract=function() return {table='owned_vehicles',owner='owner',stored='stored'} end,
    BuildOwnedVehicleInsert=function(owner,plate,props,stored,garage,op)
        return 'INSERT INTO `owned_vehicles` (owner,plate,vehicle,stored,zloma_shop_operation) VALUES (?, ?, ?, ?, ?)',{owner,plate,json.encode(props),stored,op}
    end}
_G.ZlomaVSDBAdapter=adapter
local function findPurpose(purpose) for _,op in pairs(db.ops) do if op.purpose==purpose then return copy(op) end end end
MySQL={scalar={},single={},insert={},update={},query={},transaction={}}
MySQL.scalar.await=function(q,p)
    if q=='SELECT UUID()' then counter=counter+1;return 'op-'..counter end
    if q:find('SELECT status FROM zloma_vehicleshop_effects',1,true) then return db.effects[p[1]] and db.effects[p[1]].status end
    if q:find('reserved_plate=',1,true) then for _,op in pairs(db.ops) do if op.reserved_plate==p[1] then return op.id end end end
    if q:find('SELECT terminal_operation',1,true) then return db.orders[p[1]] and db.orders[p[1]].terminal_operation end
end
MySQL.single.await=function(q,p)
    if q:find('WHERE purpose=',1,true) then return findPurpose(p[1]) end
    if q:find('FROM zloma_vehicleshop_operations WHERE id=',1,true) then return copy(db.ops[p[1]]) end
    if q:find('FROM zloma_vehicleshop_orders WHERE origin_operation=',1,true) then for _,o in pairs(db.orders) do if o.origin_operation==p[1] then return copy(o) end end end
end
local function insert(q,p)
    if q:find('INSERT INTO zloma_vehicleshop_operations',1,true) then
        local op={id=p[1],kind=p[2],actor=p[3],payload=p[4],cursor=0,dispatch='pending'}
        if q:find("'prepared'",1,true) then op.status='prepared';op.expires=p[5];op.reserved_plate=p[6]
        else op.status='authorized';op.purpose=p[5];op.reserved_plate=p[6] end
        if op.purpose and findPurpose(op.purpose) then error('duplicate purpose') end
        db.ops[op.id]=op;return 1
    end
end
MySQL.insert.await=insert
local function update(q,p)
    if q:find('INSERT IGNORE INTO zloma_vehicleshop_effects',1,true) then
        if db.effects[p[1]] then return 0 end
        db.effects[p[1]]={operation_id=p[2],status='runtime_started'};return 1
    end
    if q:find("SET status='applied'",1,true) then
        local e=db.effects[p[1]];if e and e.status=='runtime_started' then e.status='applied';return 1 end;return 0
    end

    if q:find('SET status=\'authorized\'',1,true) then db.ops[p[1]].status='authorized';return 1 end
    if q:find('SET `cursor`=?',1,true) then
        if cursorFault==true or cursorFault==p[1] then cursorFault=false;error('simulated process death before journal cursor') end
        local op=db.ops[p[2]];if op.cursor==p[3] and op.status=='authorized' then op.cursor=p[1];return 1 end;return 0
    end
    if q:find('SET status=\'done\'',1,true) then local op=db.ops[p[1]];if op.cursor==p[2] then op.status='done';return 1 end;return 0 end
    if q:find('SET status=\'failed\'',1,true) then db.ops[p[1]].status='failed';return 1 end
    if q:find('SET dispatch=\'issued\'',1,true) then local op=db.ops[p[1]];if op.dispatch~='pending' then return 0 end;op.dispatch='issued';return 1 end
    if q:find('LEFT JOIN zloma_vehicleshop_effects',1,true) then
        local op,e=db.ops[p[2]],db.effects[p[1]]
        if op.cursor==1 and (not e or e.status=='pending') and not db.owned[op.id] then op.status='refunding';if e then e.status='cancelled' end;return 1 end
        return 0
    end
    if q:find('SET `stored`=0',1,true) then db.owned[p[1]].stored=0;return 1 end
    return 0
end
MySQL.update.await=update
MySQL.transaction.await=function(tx)
    local before=copy(db)
    local ok,err=pcall(function()
        for _,statement in ipairs(tx) do
            local q,p=statement.query,statement.values
            if q:find('INSERT INTO zloma_vehicleshop_operations',1,true) then insert(q,p)
            elseif q:find('SET terminal_operation=',1,true) then
                local o=db.orders[p[3]];if o and not o.terminal_operation and (o.status=='pending' or o.status=='in_transit') then o.terminal_operation=p[1];o.status=p[2] end
            elseif q:find('INSERT IGNORE INTO zloma_vehicleshop_effects',1,true) then
                if db.ops[p[2]].status=='authorized' and not db.effects[p[1]] then db.effects[p[1]]={operation_id=p[2],status='pending'} end
            elseif q:find('UPDATE zloma_vehicleshop_vehicles',1,true) and q:find("e.status='reserved'",1,true) then
                local e=db.effects[p[1]];if e and e.status=='pending' and db.stock>0 then db.stock=db.stock-1;e.status='reserved' end
            elseif q:find('INSERT INTO `owned_vehicles`',1,true) then
                local e=db.effects[p[#p-1]]
                if e and e.status==p[#p] then
                    if insertFault then insertFault=false;error('simulated ownership insert rejection') end
                    if db.owned[p[5]] then error('duplicate ownership') end
                    db.owned[p[5]]={owner=p[1],plate=p[2],stored=p[4]}
                end
            elseif q:find('UPDATE zloma_vehicleshop_effects e JOIN `owned_vehicles`',1,true) then
                local e=db.effects[p[1]];if e and db.owned[e.operation_id] then e.status='applied' end
            elseif q:find('SET s.custom_balance=',1,true) then
                local e=db.effects[p[1]]
                if e and ((q:find("e.status='reserved'",1,true) and e.status=='reserved') or e.status=='pending') and db.balance+p[2]>=0 then
                    db.balance=db.balance+p[2]
                    if q:find("e.status='applied'",1,true) then e.status='applied' end
                end
            elseif q:find('INSERT INTO zloma_vehicleshop_orders',1,true) then
                local e=db.effects[p[#p]]
                if e and e.status=='pending' then
                    local o=json.decode(p[#p-1]);o.id=100+#tx+counter;o.origin_operation=p[#p-2];o.status='pending';db.orders[o.id]=o
                end
            elseif q:find('JOIN zloma_vehicleshop_orders o ON o.origin_operation=',1,true) then
                local e=db.effects[p[1]]
                for _,o in pairs(db.orders) do if e and o.origin_operation==e.operation_id then e.status='applied' end end
            elseif q:find('SET v.current_stock=v.current_stock+',1,true) then
                local e=db.effects[p[1]];if e and e.status=='pending' then db.stock=db.stock+p[2];e.status='applied' end
            elseif q:find('SET o.status=',1,true) then
                local e,o=db.effects[p[1]],db.orders[p[4]]
                if e and o and e.status=='pending' and o.terminal_operation==p[5] then e.status='applied';o.status=p[2] end
            elseif q:find('INSERT INTO zloma_vehicleshop_transactions',1,true) then
                local e=db.effects[p[10]];if e and e.status=='pending' then db.logs=db.logs+1 end
            elseif q:find('UPDATE zloma_vehicleshop_employees',1,true) then
                local e=db.effects[p[1]];if e and e.status=='pending' then db.sales=db.sales+1 end
            elseif q:find('UPDATE zloma_vehicleshop_effects SET status=',1,true) then
                local e=db.effects[p[1]];if e and e.status=='pending' then e.status='applied' end
            end
        end
    end)
    if not ok then db=before;return false end
    if txFault then txFault=false;error('simulated transaction committed but response lost') end
    return true
end
local function reload() assert(load(read_source(),'durable_transactions.lua'))();ShopDurable.ready=true end
reload()
local function purchase()
    local plate=ShopDurable.plate();local props={model='adder',plate=plate}
    return ShopDurable.prepare(1,'purchase',{shopId=1,props=props,spawnName='adder',spawnCoords={},result={success=true,price=100},
        steps={ShopDurable.bank('customer',-100),{kind='purchase',shopId=1,vehicleId=1,owner='customer',props=props,price=100,business=true}}}).operationId
end
local op=purchase();check(wallets.customer==1000 and not db.owned[op],'prepared intent has no side effect')
actor='intruder';check(not ShopDurable.resume(2,'purchase',op).success,'foreign customer cannot authorize');actor='customer'
local r=ShopDurable.resume(1,'purchase',op)
check(r.success and r.spawnTicket and wallets.customer==900 and db.stock==1 and db.balance==1100,'purchase legitimate flow')
local count=receiptCalls;r=ShopDurable.resume(1,'purchase',op)
check(r.success and r.alreadyCompleted and not r.spawnTicket and receiptCalls==count and db.stock==1,'purchase replay has no second ticket/debit/stock/revenue')
check(db.logs==1 and db.sales==1,'business sales statistics and log survive replay once')
op=purchase();moneyFault=true;r=ShopDurable.resume(1,'purchase',op)
check(r.pending and wallets.customer==800 and not db.owned[op],'lost wallet acknowledgement retains saga')
reload();txFault=true;r=ShopDurable.resume(1,'purchase',op)
check(r.success and db.owned[op] and wallets.customer==800 and db.stock==0 and db.balance==1200,'restart recognizes wallet and committed ownership receipts')
db.stock=1;op=purchase();cursorFault=true;r=ShopDurable.resume(1,'purchase',op)
check(r.pending and wallets.customer==700,'cursor loss after money')
reload();cursorFault=2;r=ShopDurable.resume(1,'purchase',op)
check(r.pending and db.owned[op] and db.stock==0,'cursor loss after ownership transaction')
reload();r=ShopDurable.resume(1,'purchase',op)
check(r.success and db.stock==0 and wallets.customer==700 and db.balance==1300,'receipt replay does not duplicate SQL ownership or stock')
op=purchase();r=ShopDurable.resume(1,'purchase',op)
check(r.pending and db.ops[op].status=='refunding' and wallets.customer==600,'stock conflict enters durable compensation')
reload();r=ShopDurable.resume(1,'purchase',op);check(not r.success and wallets.customer==700,'refund once after restart')
reload();r=ShopDurable.resume(1,'purchase',op);check(wallets.customer==700 and r.alreadyCompleted,'refund replay terminal')
db.stock=1;op=purchase();insertFault=true;r=ShopDurable.resume(1,'purchase',op)
check(r.pending and db.stock==1 and not db.owned[op] and db.ops[op].status=='refunding','ownership failure rolls back stock and schedules refund')
ShopDurable.resume(1,'purchase',op);check(wallets.customer==700,'failed insert refunded')
local o={shop_id=1,vehicle_id=1,spawn_name='adder',placed_by='customer',quantity=3,unit_cost=20,paid_price=150,
    is_customer_order=true,customer_identifier='customer',financial_shop={kind='balance',shopId=1,delta=90}}
op=ShopDurable.prepare(1,'customer_order',{shopId=1,order=o,result={success=true},steps={ShopDurable.bank('customer',-150),o.financial_shop,{kind='order',order=o}}}).operationId
r=ShopDurable.resume(1,'customer_order',op);check(r.success and r.orderId,'customer order durably allocated database ID')
local saved=db.orders[r.orderId];check(saved.quantity==3 and saved.paid_price==150,'quantity and paid price survive restart')
saved.db_id=saved.id;saved.origin_operation=op
local beforeBalance=db.balance;local beforeWallet=wallets.customer
r=ShopDurable.settle(1,'cancel',saved,{shopId=1,terminalOrder=saved.id,result={success=true},steps={{kind='balance',shopId=1,delta=-90},ShopDurable.bank('customer',150),{kind='terminal',orderId=saved.id,status='cancelled'}}})
check(r.success and db.orders[saved.id].status=='cancelled' and db.balance==beforeBalance-90 and wallets.customer==beforeWallet+150,'cancel reverses original ledger and refunds offline identity')
reload();r=ShopDurable.resumeSettlement(1,'cancel',saved.id,1)
check(r.success and r.alreadyCompleted and wallets.customer==beforeWallet+150,'cancel tombstone recognizes replay after restart')
check(not ShopDurable.settle(1,'delivery',saved,{steps={},result={success=true}}).success,'cancelled order cannot also deliver')
local stockOrder={shop_id=1,vehicle_id=1,spawn_name='adder',placed_by='customer',quantity=4,unit_cost=10,paid_price=0,financial_shop={kind='society',identity='mechanic',delta=-40}}
wallets.mechanic=1000
op=ShopDurable.prepare(1,'boss_order',{shopId=1,order=stockOrder,result={success=true},steps={stockOrder.financial_shop,{kind='order',order=stockOrder}}}).operationId
r=ShopDurable.resume(1,'boss_order',op);check(r.success and wallets.mechanic==960,'stock order uses existing society participant')
saved=db.orders[r.orderId];saved.db_id=saved.id;saved.origin_operation=op;saved.status='in_transit'
actor='worker';local previousStock=db.stock;moneyFault=true
r=ShopDurable.settle(2,'delivery',saved,{shopId=1,terminalOrder=saved.id,result={success=true},steps={{kind='stock',business=true,shopId=1,vehicleId=1,delta=4},ShopDurable.bank('worker',20),{kind='terminal',orderId=saved.id,status='delivered'}}})
check(r.pending and db.stock==previousStock+4 and wallets.worker==20,'delivery interrupted after stock and reward receipt')
reload();r=ShopDurable.resumeSettlement(2,'delivery',saved.id,1)
check(r.success and db.stock==previousStock+4 and wallets.worker==20 and db.orders[saved.id].status=='delivered','delivery recovery does not duplicate stock or reward')
check(ShopDurable.resumeSettlement(2,'delivery',saved.id,1).alreadyCompleted,'delivery final replay recognized')

-- Ordinary ESX/addonaccount compatibility does not require durable APIs.
actor='customer';db.stock=2;wallets.customer=1000
core.GetDurableMoneyCapabilities=function() return {bank='ESX',society='esx_addonaccount',bankReady=false,societyReady=false} end
core.GetPlayerFromIdentifier=function(_,identity) return identity==actor and 1 or nil end
core.GetPlayerMoney=function() return wallets[actor] end
core.RemoveMoney=function(_,src,amount) if wallets[actor]<amount then return false end;wallets[actor]=wallets[actor]-amount;return true end
core.AddMoney=function(_,src,amount) wallets[actor]=wallets[actor]+amount;return true end
core.RemoveSocietyMoney=function(_,identity,amount) wallets[identity]=wallets[identity]-amount;return true end
core.AddSocietyMoney=function(_,identity,amount) wallets[identity]=(wallets[identity] or 0)+amount;return true end
op=purchase();check(op~=nil,'ordinary provider permits legitimate quote')
r=ShopDurable.resume(1,'purchase',op)
check(r.success and wallets.customer==900 and db.owned[op],'ordinary runtime payment precedes ownership')
check(ShopDurable.resume(1,'purchase',op).alreadyCompleted and wallets.customer==900,'ordinary purchase replay cannot debit or grant twice')
reload();check(ShopDurable.resume(1,'purchase',op).alreadyCompleted and wallets.customer==900,'completed ordinary receipt survives journal restart')
op=purchase();db.ops[op].status='authorized';db.effects[op..':1']={status='runtime_started',operation_id=op}
reload();r=ShopDurable.resume(1,'purchase',op)
check(r.pending and wallets.customer==900 and not db.owned[op],'interrupted ordinary money claim is quarantined, not retried or used as payment proof')
print('Durable shop: '..checks..' production-module fault checks passed (modeled SQL, no FXServer)')
