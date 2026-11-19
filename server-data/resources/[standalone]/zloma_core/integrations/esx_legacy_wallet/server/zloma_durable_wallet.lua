-- Load INSIDE es_extended after server/functions.lua. Requires the save-version
-- guard supplied in this integration's patch; never install this file alone.
local ready, locks, uncertain = false, {}, {}
local recover
local function cachedBank(player)
    for _,account in ipairs(player.accounts or {}) do if account.name=='bank' then return account end end
end
function ZlomaWaitDurableWallet(identifier)
    while locks[identifier] do Wait(10) end
    if not uncertain[identifier] then return end
    locks[identifier]=true
    local ok,result=pcall(recover,identifier)
    locks[identifier]=nil
    if not ok or not result then error('Bank state requires durable wallet recovery') end
    uncertain[identifier]=nil
end
local function integer(v)
    return type(v)=='number' and v==v and math.abs(v)<math.huge and v%1==0
end
local function namespace(id)
    local caller=GetInvokingResource()
    if not caller or type(id)~='string' or #id<1 or #id>140 or not id:match('^[%w_:%-%.]+$') then return end
    return caller..':'..id
end
local function decode(value)
    local ok, result=pcall(json.decode,value or '{}')
    return ok and type(result)=='table' and result or nil
end
recover=function(identifier)
    local player=ESX.GetPlayerFromIdentifier(identifier)
    if not player then return true end
    local revision=tonumber(player.getMeta('zlomaWalletRevision')) or 0
    local row=MySQL.single.await('SELECT zloma_wallet_revision FROM users WHERE identifier=? LIMIT 1',{identifier})
    local current=row and tonumber(row.zloma_wallet_revision)
    if not current or current<revision then return false end
    if current==revision then return true end
    local delta=tonumber(MySQL.scalar.await([[
        SELECT COALESCE(SUM(delta),0) FROM zloma_wallet_operations
        WHERE identifier=? AND status='applied' AND applied_revision>? AND applied_revision<=?
    ]],{identifier,revision,current})) or 0
    -- Reconnect can replace the cached player while SQL yielded.
    if ESX.GetPlayerFromIdentifier(identifier)~=player then return false end
    local actualRevision=tonumber(player.getMeta('zlomaWalletRevision')) or 0
    if actualRevision~=revision then return false end
    local bank=cachedBank(player)
    if not bank or not player.metadata then return false end
    -- Update the private account and revision together BEFORE emitting any
    -- events. An event failure must not leave a replayable cached money delta.
    bank.money=bank.money+delta
    player.metadata.zlomaWalletRevision=current
    -- Publish after the lock is released; event consumers may read bank state.
    SetTimeout(0,function()
        if ESX.GetPlayerFromIdentifier(identifier)~=player then return end
        pcall(player.triggerEvent,'esx:setAccountMoney',cachedBank(player))
        pcall(player.triggerEvent,'esx:updatePlayerData','metadata',player.metadata)
        if delta~=0 then
            pcall(TriggerEvent,delta>0 and 'esx:addAccountMoney' or 'esx:removeAccountMoney',
                player.source,'bank',math.abs(delta),'durable wallet recovery')
        end
    end)
    return true
end
local function apply(id,identifier,delta)
    id=namespace(id)
    if not ready or not id or type(identifier)~='string' or #identifier<1 or #identifier>100
        or not integer(delta) or math.abs(delta)>1000000000 or locks[identifier] then
        return {success=false,reason='invalid_unready_or_busy_wallet_operation'}
    end
    locks[identifier]=true
    local ok,result=xpcall(function()
        if not recover(identifier) then return {success=false,reason='wallet_recovery_pending'} end
        uncertain[identifier]=nil
        local receipt=MySQL.single.await('SELECT * FROM zloma_wallet_operations WHERE operation_id=? LIMIT 1',{id})
        if receipt then
            if receipt.identifier~=identifier or tonumber(receipt.delta)~=delta then return {success=false,reason='operation_payload_conflict'} end
            if receipt.status=='applied' then return {success=true,status='applied',operationId=id} end
        end
        local row=MySQL.single.await('SELECT accounts,zloma_wallet_revision FROM users WHERE identifier=? LIMIT 1',{identifier})
        if not row then return {success=false,reason='wallet_identity_missing'} end
        local revision=tonumber(row.zloma_wallet_revision)
        local accounts=decode(row.accounts)
        if not integer(revision) or not accounts or not integer(tonumber(accounts.bank)) then return {success=false,reason='invalid_wallet_storage'} end
        local player=ESX.GetPlayerFromIdentifier(identifier)
        local balance=tonumber(accounts.bank)
        if player then
            if (tonumber(player.getMeta('zlomaWalletRevision')) or 0)~=revision then return {success=false,reason='wallet_revision_changed'} end
            local bank=cachedBank(player)
            if not bank then return {success=false,reason='wallet_cache_shape_unsupported'} end
            balance=bank.money
        end
        if not integer(balance) or balance+delta<0 then return {success=false,reason='insufficient_balance'} end
        uncertain[identifier]=true
        local tx=MySQL.transaction.await({
            {query=[[
                INSERT IGNORE INTO zloma_wallet_operations
                    (operation_id,identifier,delta,status,base_revision,balance_before)
                VALUES (?,?,?,'pending',?,?)
            ]],values={id,identifier,delta,revision,balance}},
            {query=[[
                UPDATE zloma_wallet_operations SET base_revision=?,balance_before=?
                WHERE operation_id=? AND identifier=? AND delta=? AND status='pending'
            ]],values={revision,balance,id,identifier,delta}},
            {query=[[
                UPDATE users u JOIN zloma_wallet_operations o ON o.identifier=u.identifier
                SET u.accounts=JSON_SET(u.accounts,'$.bank',o.balance_before+o.delta),
                    u.metadata=JSON_SET(COALESCE(NULLIF(u.metadata,''),'{}'),'$.zlomaWalletRevision',o.base_revision+1),
                    u.zloma_wallet_revision=o.base_revision+1,
                    o.applied_revision=o.base_revision+1,o.status='applied'
                WHERE o.operation_id=? AND o.identifier=? AND o.delta=? AND o.status='pending'
                    AND u.zloma_wallet_revision=o.base_revision AND o.balance_before+o.delta>=0
            ]],values={id,identifier,delta}}
        })
        if not tx then return {success=false,reason='wallet_transaction_failed'} end
        receipt=MySQL.single.await('SELECT * FROM zloma_wallet_operations WHERE operation_id=? LIMIT 1',{id})
        if not receipt or receipt.identifier~=identifier or tonumber(receipt.delta)~=delta or receipt.status~='applied' then
            return {success=false,reason='wallet_transaction_not_applied'}
        end
        -- Recovery applies a missing cached delta once. All stale ESX save
        -- snapshots are rejected by the mandatory monotonically versioned guard.
        if not recover(identifier) then return {success=true,status='applied',cachePending=true,operationId=id} end
        uncertain[identifier]=nil
        return {success=true,status='applied',operationId=id}
    end,debug.traceback)
    locks[identifier]=nil
    if not ok then print('[es_extended] [ERROR] Durable wallet operation: '..tostring(result)); return {success=false,reason='wallet_operation_exception'} end
    return result
end
exports('ApplyBankMoneyOnce',apply)
exports('HasDurableBankMoney',function() return ready end)
CreateThread(function()
    -- The patch makes every standard ESX SavePlayer/SavePlayers snapshot bind
    -- its cached revision. Merely adding a money journal would be insufficient.
    local source=LoadResourceFile(GetCurrentResourceName(),'server/functions.lua') or ''
    local _,guards=source:gsub('ZLOMA_DURABLE_WALLET_SAVE_GUARD','')
    if guards~=2 then print('[es_extended] [ERROR] Durable wallet requires BOTH player save guards'); return end
    local classes=LoadResourceFile(GetCurrentResourceName(),'server/classes/player.lua') or ''
    if not classes:find('ZLOMA_DURABLE_WALLET_READ_GUARD',1,true) then
        print('[es_extended] [ERROR] Durable wallet requires the bank read guard');return
    end
    local engine=MySQL.scalar.await("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users'")
    if engine~='InnoDB' then print('[es_extended] [ERROR] Durable wallet requires InnoDB users table');return end
    local column=MySQL.single.await("SHOW COLUMNS FROM users LIKE 'zloma_wallet_revision'")
    if not column then MySQL.query.await('ALTER TABLE users ADD COLUMN zloma_wallet_revision BIGINT UNSIGNED NOT NULL DEFAULT 0') end
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS zloma_wallet_operations (
            operation_id VARCHAR(200) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
            identifier VARCHAR(100) NOT NULL,delta BIGINT NOT NULL,status VARCHAR(16) NOT NULL,
            base_revision BIGINT UNSIGNED NOT NULL,balance_before BIGINT NOT NULL,
            applied_revision BIGINT UNSIGNED NULL,created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY(operation_id),KEY wallet_revision(identifier,applied_revision)
        ) ENGINE=InnoDB
    ]])
    local journalEngine=MySQL.scalar.await("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='zloma_wallet_operations'")
    if journalEngine~='InnoDB' then print('[es_extended] [ERROR] Durable wallet receipt journal requires InnoDB');return end
    ready=true
    for _,player in pairs(ESX.GetExtendedPlayers()) do
        if not locks[player.identifier] then
            uncertain[player.identifier]=true
            locks[player.identifier]=true
            local ok,result=pcall(recover,player.identifier)
            locks[player.identifier]=nil
            if ok and result then uncertain[player.identifier]=nil end
        end
    end
end)
AddEventHandler('esx:playerLoaded',function(_,player)
    if not ready or not player or not player.identifier then return end
    uncertain[player.identifier]=true
    if locks[player.identifier] then return end
    locks[player.identifier]=true
    local ok,result=pcall(recover,player.identifier)
    locks[player.identifier]=nil
    if ok and result then uncertain[player.identifier]=nil end
end)
