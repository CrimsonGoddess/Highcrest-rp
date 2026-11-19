local checks=0
local function check(value,label) assert(value,label);checks=checks+1 end
local queue,receipts={},{}
local balance,uuid,fault,available=500,0,false,true
local core={GetDurableMoneyCapabilities=function() return {bank='ESX',bankReady=available} end,
    ApplyBankMoneyOnce=function(_,key,identity,amount,provider)
        check(identity=='offline' and provider=='ESX','original participant and identity bound')
        if not receipts[key] then balance=balance+amount;receipts[key]=true end
        if fault then fault=false;error('simulated lost applied receipt reply') end
        return {success=true,status='applied'}
    end}
exports={zloma_core=core,es_extended={HasDurableBankMoney=function() return available end}}
local thread
function CreateThread(fn) thread=fn end
function Wait() coroutine.yield() end
function GetFrameworkType() return 'ESX' end
local sqlWrites=0
MySQL={query={await=function(q)
    if q:find('SELECT *',1,true) then local rows={};for _,row in pairs(queue) do if row.status=='pending' then rows[#rows+1]=row end end;return rows end
    return {}
end},scalar={await=function(q)
    if q=='SELECT UUID()' then uuid=uuid+1;return 'credit-'..uuid end
    if q:find('ENGINE',1,true) then return 'InnoDB' end
    return balance
end},insert={await=function(_,p) queue[p[1]]={operation_id=p[1],identifier=p[2],amount=p[3],provider=p[4],status='pending'};return 1 end},
update={await=function(q,p) if q:find('next_attempt',1,true) then return 1 end;if q:find('offline_credits',1,true) then queue[p[1]].status='applied';return 1 end;sqlWrites=sqlWrites+1;return 1 end}}
assert(load(read_source('server/durable_offline.lua')))()
check(select(3,ZlomaOfflineCredits.credit('offline',100))=='rejected','unready queue rejects before storing intent')
local worker=coroutine.create(thread);check(coroutine.resume(worker),'queue initialization')
local ok,money=ZlomaOfflineCredits.credit('offline',100)
check(ok and money==600 and queue['credit-1'].status=='applied','offline payout uses receipt and existing MAIN balance')
fault=true;local result,_,state=ZlomaOfflineCredits.credit('offline',50)
check(result==nil and state=='pending' and balance==650 and queue['credit-2'].status=='pending','ambiguous applied credit remains pending, not refunded')
check(coroutine.resume(worker),'periodic receipt recovery')
check(balance==650 and queue['credit-2'].status=='applied','recovery acknowledges applied credit without crediting twice')
available=false
check(select(3,ZlomaOfflineCredits.credit('offline',20))=='rejected','installed unready wallet cannot fall back to SQL')
assert(load(read_source('server/utils.lua')))()
check(not UpdatePlayerAccount('offline',0/0),'offline NaN rejected')
check(select(3,UpdatePlayerAccount('offline',20))=='rejected' and sqlWrites==0,'banking compatibility helper respects readiness')
check(not UpdatePlayerAccount('offline',1.5),'selected integer money policy')
print('Banking durable compatibility: '..checks..' production-module checks passed')
