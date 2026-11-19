local checks=0
local function check(v,label) assert(v,label);checks=checks+1 end
local function copy(v) if type(v)~='table' then return v end local r={};for k,x in pairs(v) do r[k]=copy(x) end;return r end
local encodings,serial={},0
json={encode=function(v) serial=serial+1;local k='j'..serial;encodings[k]=copy(v);return k end,
 decode=function(v) return copy(encodings[v] or {}) end}
local resource,caller='es_extended','zloma_core'
local exported,events,deferred={},{},{}
function GetCurrentResourceName() return resource end
function GetInvokingResource() return caller end
function LoadResourceFile(_,file)
 if file=='server/functions.lua' then return 'ZLOMA_DURABLE_WALLET_SAVE_GUARD ZLOMA_DURABLE_WALLET_SAVE_GUARD' end
 if file=='server/classes/player.lua' then return 'ZLOMA_DURABLE_WALLET_READ_GUARD' end
 return 'ZLOMA_SQL_OWNED_ACCOUNT'
end
function CreateThread(f) f() end
function SetTimeout(_,f) deferred[#deferred+1]=f end
function AddEventHandler(n,f) events[n]=f end
function TriggerEvent() end
function TriggerClientEvent() end
function Wait() error('unexpected wallet read while participant lock is held') end
exports=setmetatable({}, {__call=function(_,name,f) exported[name]=f end})
local function notify() local queued=deferred;deferred={};for _,f in ipairs(queued) do f() end end
local db={identifier='owner1',accounts={bank=1000},metadata={},zloma_wallet_revision=0}
local receipts,crashAfterCommit={},false
local player={source=1,identifier='owner1',accounts={{name='bank',money=1000,index=1}},metadata={}}
player.getMeta=function(k) return player.metadata[k] end
player.triggerEvent=function() error('publication failure must not repeat money') end
ESX={GetPlayerFromIdentifier=function(id) return id=='owner1' and player or nil end,
 GetExtendedPlayers=function() return player and {player} or {} end}
local function bank() ZlomaWaitDurableWallet('owner1');return player.accounts[1].money end
MySQL={query={await=function() return {} end},scalar={await=function(q,v)
 if q:find('information_schema',1,true) then return 'InnoDB' end
 local total=0
 for _,r in pairs(receipts) do
  if r.identifier==v[1] and r.status=='applied' and r.applied_revision>v[2] and r.applied_revision<=v[3] then total=total+r.delta end
 end
 return total
end},single={await=function(q,v)
 if q:find('SHOW COLUMNS',1,true) then return {Field='zloma_wallet_revision'} end
 if q:find('FROM zloma_wallet_operations',1,true) then
  if crashAfterCommit=='read_receipt' then crashAfterCommit=false;error('simulated interruption after SQL commit') end
  return copy(receipts[v[1]])
 end
 if v and v[1]==db.identifier then return {accounts=json.encode(db.accounts),zloma_wallet_revision=db.zloma_wallet_revision} end
end},transaction={await=function(queries)
 local v=queries[1].values
 local id,identity,delta,revision,before=v[1],v[2],v[3],v[4],v[5]
 local r=receipts[id]
 if not r then r={identifier=identity,delta=delta,status='pending'};receipts[id]=r end
 if r.identifier==identity and r.delta==delta and r.status=='pending' then
  r.base_revision,r.balance_before=revision,before
  if db.identifier==identity and db.zloma_wallet_revision==revision and before+delta>=0 then
   db.accounts.bank=before+delta;db.zloma_wallet_revision=revision+1;db.metadata.zlomaWalletRevision=revision+1
   r.status,r.applied_revision='applied',revision+1
  end
 end
 if crashAfterCommit==true then crashAfterCommit='read_receipt' end
 return true
end}}
assert(load(read_source('zloma_core','integrations/esx_legacy_wallet/server/zloma_durable_wallet.lua')))()
local apply=exported.ApplyBankMoneyOnce
check(exported.HasDurableBankMoney(),'wallet requires schema and all save/read guards')
check(apply('purchase:1','owner1',-300).success and db.accounts.bank==700 and bank()==700,'bank debit commits with receipt and cache revision')
notify()
check(apply('purchase:1','owner1',-300).success and bank()==700,'bank debit replay is recognized')
check(not apply('purchase:1','owner1',-301).success and bank()==700,'wallet operation amount immutable')
check(not apply('purchase:1','other',-300).success and db.accounts.bank==700,'wallet identity immutable')
local function staleSave(balance,revision)
 if db.zloma_wallet_revision<=revision then db.accounts.bank=balance end
end
staleSave(1000,0)
check(db.accounts.bank==700,'mandatory save-version guard rejects stale framework snapshot')
check(not apply('purchase:2','owner1',-800).success and bank()==700,'insufficient funds do not debit')
check(not apply('nan','owner1',0/0).success,'wallet rejects non-finite delta')
crashAfterCommit=true
check(not apply('purchase:3','owner1',-200).success and db.accounts.bank==500,'interruption may occur after durable commit')
check(bank()==500,'next bank read recovers ambiguous receipt before spending')
check(apply('purchase:3','owner1',-200).success and bank()==500,'restart/retry recognizes committed debit')
notify()
check(apply('refund:1','owner1',300).success and bank()==800,'refund has distinct durable receipt')
check(apply('refund:1','owner1',300).success and bank()==800,'refund replay cannot mint money')
local online=player;player=nil
check(apply('reward:4','owner1',150).success and db.accounts.bank==950,'offline bank reward commits atomically')
player=online
player.accounts[1].money=db.accounts.bank;player.metadata=copy(db.metadata)
events['esx:playerLoaded'](1,player)
check(bank()==950 and apply('reward:4','owner1',150).success and bank()==950,'reconnect cannot apply offline reward twice')
caller=nil;check(not apply('untrusted','owner1',10).success,'wallet requires invoking server integration');caller='zloma_core'

-- Selected society ledger retains its existing account ID/name and SQL money.
resource='esx_addonaccount'
local society={id=42,money=1000};local societyReceipts={};local account
MySQL.query.await=function(q,v)
 if q:find('FROM addon_account_data',1,true) then return v[1]=='society_dealer' and {copy(society)} or {} end
 return {}
end
MySQL.scalar.await=function() return 'InnoDB' end
MySQL.single.await=function(_,v) return copy(societyReceipts[v[1]]) end
MySQL.update={await=function(q,v)
 if q:find('money=money+?',1,true) then
  if society.money+v[1]<0 then return 0 end;society.money=society.money+v[1]
 else society.money=v[1] end
 return 1
end}
MySQL.transaction.await=function(queries)
 local v=queries[1].values
 local r=societyReceipts[v[1]]
 if not r then r={account_id=v[2],delta=v[3],status='pending'};societyReceipts[v[1]]=r end
 if r.account_id==society.id and r.delta==v[3] and r.status=='pending' and society.money+r.delta>=0 then
  society.money=society.money+r.delta;r.status='applied'
 end
 return true
end
function GetSharedAccount() return account end
assert(load(read_source('zloma_core','integrations/esx_addonaccount/server/classes/addonaccount.lua')))()
assert(load(read_source('zloma_core','integrations/esx_addonaccount/server/zloma_durable_accounts.lua')))()
account=CreateAddonAccount('society_dealer',nil,1000)
local societyApply=exported.ApplySharedAccountMoneyOnce
check(societyApply('order:1','society_dealer',-400).success and society.money==600,'society debit and receipt apply together')
check(societyApply('order:1','society_dealer',-400).success and society.money==600,'society procurement replay is recognized')
check(not societyApply('order:1','society_dealer',-401).success and society.money==600,'society amount cannot change')
check(not societyApply('order:2','society_dealer',-700).success and society.money==600,'society receipt remains unapplied on insufficient balance')
check(societyApply('cancel:1','society_dealer',400).success and society.money==1000,'society compensation applied once')
check(societyApply('cancel:1','society_dealer',400).success and society.money==1000,'society compensation replay cannot mint money')
check(account.removeMoney(100) and society.money==900,'legacy remove uses SQL relative mutation')
check(account.addMoney(200) and society.money==1100,'legacy add uses SQL relative mutation')
account.money=999999;account.save()
check(society.money==1100 and account.money==1100,'stale cached save cannot overwrite durable society money')
check(not account.removeMoney(1200) and society.money==1100,'legacy debit cannot overdraw selected society ledger')
function TriggerClientEvent() error('simulated notification publication failure') end
check(account.addMoney(10) and society.money==1110,'notification failure cannot turn committed legacy credit into failed credit')
check(societyApply('order:3','society_dealer',-10).success and society.money==1100,'durable receipt survives notification failure')
print(('Durable money participants: %d production-module mock checks passed'):format(checks))
