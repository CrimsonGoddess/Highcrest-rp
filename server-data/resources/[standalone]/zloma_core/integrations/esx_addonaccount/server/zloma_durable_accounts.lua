-- Load in esx_addonaccount before server/main.lua, together with the supplied
-- SQL-owned CreateAddonAccount replacement. Existing accounts are retained.
ZlomaAddonAccountStorage = {}
local S, ready = ZlomaAddonAccountStorage, false
local function finite(v) return type(v)=='number' and v==v and math.abs(v)<math.huge end
local function rowFor(name,owner)
    local query='SELECT id,money FROM addon_account_data WHERE account_name=? AND '
    local values={name}
    if owner==nil then query=query..'owner IS NULL';else query=query..'owner=?';values[2]=owner end
    local rows=MySQL.query.await(query..' LIMIT 2',values)
    if not rows or #rows~=1 then return end -- ambiguous shared account is not authority
    return rows[1]
end
function S.read(name,owner)
    if not ready then return end
    local row=rowFor(name,owner)
    return row and tonumber(row.money)
end
function S.change(name,owner,delta,absolute)
    if not ready or not finite(delta) or delta%1~=0 or math.abs(delta)>1000000000 then return false end
    local row=rowFor(name,owner)
    if not row then return false end
    local affected
    if absolute then
        if delta<0 then return false end
        affected=MySQL.update.await('UPDATE addon_account_data SET money=? WHERE id=?',{delta,row.id})
    else
        affected=MySQL.update.await('UPDATE addon_account_data SET money=money+? WHERE id=? AND money+?>=0',{delta,row.id,delta})
    end
    if affected~=1 then
        if not absolute or tonumber(row.money)~=delta then return false end
    end
    return S.read(name,owner)
end
local function applyOnce(id,name,delta)
    local caller=GetInvokingResource()
    if not ready or not caller or type(id)~='string' or #id<1 or #id>140 or not id:match('^[%w_:%-%.]+$')
        or type(name)~='string' or #name<1 or #name>100 or not name:match('^[%w_%-]+$')
        or not finite(delta) or delta%1~=0 or math.abs(delta)>1000000000 then
        return {success=false,reason='invalid_unready_society_operation'}
    end
    local row=rowFor(name,nil)
    if not row then return {success=false,reason='missing_or_ambiguous_society_account'} end
    local operation=caller..':'..id
    local tx=MySQL.transaction.await({
        {query=[[
            INSERT IGNORE INTO zloma_addonaccount_operations(operation_id,account_id,delta,status)
            VALUES (?,?,?,'pending')
        ]],values={operation,row.id,delta}},
        {query=[[
            UPDATE addon_account_data a JOIN zloma_addonaccount_operations o ON o.account_id=a.id
            SET a.money=a.money+o.delta,o.status='applied'
            WHERE o.operation_id=? AND o.account_id=? AND o.delta=? AND o.status='pending'
                AND a.money+o.delta>=0 AND a.owner IS NULL
        ]],values={operation,row.id,delta}}
    })
    if not tx then return {success=false,reason='society_transaction_failed'} end
    local receipt=MySQL.single.await('SELECT * FROM zloma_addonaccount_operations WHERE operation_id=? LIMIT 1',{operation})
    if not receipt or tonumber(receipt.account_id)~=tonumber(row.id) or tonumber(receipt.delta)~=delta then
        return {success=false,reason='society_operation_payload_conflict'}
    end
    if receipt.status~='applied' then return {success=false,status=receipt.status,reason='insufficient_society_balance'} end
    local account=GetSharedAccount(name)
    if account then
        local ok,err=pcall(account.refresh)
        if not ok then print('[esx_addonaccount] [WARNING] Applied receipt retained; cache refresh requires retry: '..tostring(err)) end
    end
    return {success=true,status='applied',operationId=operation}
end
exports('ApplySharedAccountMoneyOnce',applyOnce)
exports('HasDurableSharedAccountMoney',function() return ready end)
CreateThread(function()
    local source=LoadResourceFile(GetCurrentResourceName(),'server/classes/addonaccount.lua') or ''
    if not source:find('ZLOMA_SQL_OWNED_ACCOUNT',1,true) then
        print('[esx_addonaccount] [ERROR] Durable money requires the SQL-owned account class');return
    end
    local engine=MySQL.scalar.await("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='addon_account_data'")
    if engine~='InnoDB' then print('[esx_addonaccount] [ERROR] Durable money requires InnoDB addon_account_data');return end
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS zloma_addonaccount_operations (
            operation_id VARCHAR(200) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
            account_id INT NOT NULL,delta BIGINT NOT NULL,status VARCHAR(16) NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY(operation_id),KEY account_operation(account_id)
        ) ENGINE=InnoDB
    ]])
    local journalEngine=MySQL.scalar.await("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='zloma_addonaccount_operations'")
    if journalEngine~='InnoDB' then print('[esx_addonaccount] [ERROR] Durable society receipt journal requires InnoDB');return end
    ready=true
end)
