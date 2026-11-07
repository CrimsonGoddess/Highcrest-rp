-- Everything here runs on the server. Clients send ids and amounts, never permissions or balances.
local LEDGER_SIZE = 50

local offers = {}
local nextOfferId = 0
local busy = {}

local validPermissions = {}
for _, permission in ipairs(Config.permissions) do
    validPermissions[permission.id] = true
end

local function charName(player)
    local info = player.PlayerData.charinfo
    return ('%s %s'):format(info.firstname, info.lastname)
end

local function trimText(value)
    if type(value) ~= 'string' then return '' end
    return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

-- A whole, positive number of dollars within the limit, or nil.
local function cleanAmount(value)
    local amount = tonumber(value)
    if not amount or amount ~= amount or amount < 1 or amount > Config.maxTransaction then return nil end
    return math.floor(amount)
end

local function decodePermissions(raw)
    local ok, list = pcall(json.decode, raw or '[]')
    return ok and type(list) == 'table' and list or {}
end

local function loadMembership(businessId, citizenid)
    local row = MySQL.single.await([[
        SELECT s.id AS memberId, r.id AS rankId, r.name AS rankName, r.level, r.permissions
        FROM highcrest_empire_staff s
        JOIN highcrest_empire_ranks r ON r.id = s.rank_id
        WHERE s.business_id = ? AND s.citizenid = ?
    ]], { businessId, citizenid })
    if row then row.permissions = decodePermissions(row.permissions) end
    return row
end

local function isOwnerRank(membership)
    return membership.level >= Config.ownerLevel
end

local function can(membership, permission)
    if not membership then return false end
    if isOwnerRank(membership) then return true end
    for _, granted in ipairs(membership.permissions) do
        if granted == permission then return true end
    end
    return false
end

local function addLedger(businessId, entryType, amount, actor, note)
    local balance = MySQL.scalar.await('SELECT balance FROM highcrest_empire_businesses WHERE id = ?', { businessId }) or 0
    MySQL.insert.await('INSERT INTO highcrest_empire_ledger (business_id, type, amount, balance_after, actor, note) VALUES (?, ?, ?, ?, ?, ?)', {
        businessId, entryType, amount, balance, actor, note or '',
    })
end

-- Takes money only if the business has it. Two people withdrawing at once can't overdraw it,
-- because the database checks the balance and subtracts in the same step.
local function takeFromBusiness(businessId, amount)
    return MySQL.update.await('UPDATE highcrest_empire_businesses SET balance = balance - ? WHERE id = ? AND balance >= ?', { amount, businessId, amount }) == 1
end

local function addToBusiness(businessId, amount)
    return MySQL.update.await('UPDATE highcrest_empire_businesses SET balance = balance + ? WHERE id = ?', { amount, businessId }) == 1
end

-- Bank balances may go negative in Qbox, so spending has to be checked first.
local function takeFromBank(src, amount, reason)
    local bank = exports.qbx_core:GetMoney(src, 'bank')
    if type(bank) ~= 'number' or bank < amount then return false end
    return exports.qbx_core:RemoveMoney(src, 'bank', amount, reason) == true
end

local function notifyCitizen(citizenid, message)
    local player = exports.qbx_core:GetPlayerByCitizenId(citizenid)
    if player then TriggerClientEvent('highcrest_empire:client:notify', player.PlayerData.source, message) end
end

-- One money or staff action at a time per player, so double clicks can't run twice.
local function register(name, handler, readOnly)
    lib.callback.register('highcrest_empire:server:' .. name, function(source, data)
        local player = exports.qbx_core:GetPlayer(source)
        if not player then return nil end
        if readOnly then return handler(source, player, data) end
        if busy[source] then return { error = 'Still working on your last request.' } end

        busy[source] = true
        local ok, result = pcall(handler, source, player, data)
        busy[source] = nil

        if not ok then
            lib.print.error(('%s failed: %s'):format(name, result))
            return { error = 'Something went wrong. Nothing was charged.' }
        end
        return result
    end)
end

local function publicBusiness(row)
    return {
        id = row.id,
        name = row.name,
        type = row.type,
        typeLabel = Config.businessTypes[row.type] or 'Other',
        price = row.price,
        x = row.x,
        y = row.y,
    }
end

local function loadOverview(citizenid)
    local mine = MySQL.query.await([[
        SELECT b.id, b.name, b.type, r.name AS rankName, r.level
        FROM highcrest_empire_staff s
        JOIN highcrest_empire_businesses b ON b.id = s.business_id
        JOIN highcrest_empire_ranks r ON r.id = s.rank_id
        WHERE s.citizenid = ? ORDER BY r.level DESC, b.name
    ]], { citizenid }) or {}
    for _, row in ipairs(mine) do
        row.typeLabel = Config.businessTypes[row.type] or 'Other'
        row.isOwner = row.level >= Config.ownerLevel
    end

    local market = {}
    for _, row in ipairs(MySQL.query.await('SELECT id, name, type, price, x, y FROM highcrest_empire_businesses WHERE owner IS NULL ORDER BY price') or {}) do
        market[#market + 1] = publicBusiness(row)
    end

    local now = os.time()
    local myOffers = {}
    for id, offer in pairs(offers) do
        if offer.expires < now then
            offers[id] = nil
        elseif offer.citizenid == citizenid then
            myOffers[#myOffers + 1] = { id = id, businessName = offer.businessName, rankName = offer.rankName }
        end
    end

    return { mine = mine, market = market, offers = myOffers }
end

local function loadBusiness(businessId, citizenid)
    local business = MySQL.single.await('SELECT id, name, type, price, x, y, balance FROM highcrest_empire_businesses WHERE id = ?', { businessId })
    local membership = loadMembership(businessId, citizenid)
    if not business or not membership then return nil end

    local owner = isOwnerRank(membership)
    local allowed = {}
    for _, permission in ipairs(Config.permissions) do
        allowed[permission.id] = can(membership, permission.id)
    end

    local result = publicBusiness(business)
    result.rankName = membership.rankName
    result.isOwner = owner
    result.can = allowed
    result.sellPrice = math.floor(business.price * Config.sellBackShare)

    -- The balance is only sent to people who handle the money.
    if allowed.deposit or allowed.withdraw or allowed.pay or allowed.ledger then
        result.balance = tonumber(business.balance) or 0
    end

    local staff = MySQL.query.await([[
        SELECT s.id, s.name, s.citizenid = ? AS isMe, r.id AS rankId, r.name AS rankName, r.level
        FROM highcrest_empire_staff s
        JOIN highcrest_empire_ranks r ON r.id = s.rank_id
        WHERE s.business_id = ? ORDER BY r.level DESC, s.name
    ]], { citizenid, businessId }) or {}
    for _, member in ipairs(staff) do
        -- Decides which buttons to show. The server checks again when one is used.
        member.manageable = member.level < membership.level
    end
    result.staff = staff

    result.ranks = {}
    for _, rank in ipairs(MySQL.query.await('SELECT id, name, level, permissions FROM highcrest_empire_ranks WHERE business_id = ? ORDER BY level DESC', { businessId }) or {}) do
        result.ranks[#result.ranks + 1] = {
            id = rank.id,
            name = rank.name,
            level = rank.level,
            permissions = decodePermissions(rank.permissions),
            isOwnerRank = rank.level >= Config.ownerLevel,
        }
    end
    result.permissionList = Config.permissions

    if allowed.ledger then
        result.ledger = MySQL.query.await(([[
            SELECT type, amount, balance_after AS balanceAfter, actor, note, UNIX_TIMESTAMP(created_at) AS createdAt
            FROM highcrest_empire_ledger WHERE business_id = ? ORDER BY id DESC LIMIT %d
        ]]):format(LEDGER_SIZE), { businessId }) or {}
    end

    return result
end

register('overview', function(_, player)
    return loadOverview(player.PlayerData.citizenid)
end, true)

register('business', function(_, player, id)
    id = tonumber(id)
    return id and loadBusiness(id, player.PlayerData.citizenid) or { error = 'You do not work there.' }
end, true)

register('buy', function(source, player, value)
    local id = tonumber(value)
    local citizenid = player.PlayerData.citizenid
    local business = id and MySQL.single.await('SELECT id, name, price, owner FROM highcrest_empire_businesses WHERE id = ?', { id })
    if not business or business.owner then return { error = 'That business is no longer for sale.' } end

    local owned = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_empire_businesses WHERE owner = ?', { citizenid })
    if owned >= Config.maxOwnedBusinesses then
        return { error = ('You can only own %d businesses.'):format(Config.maxOwnedBusinesses) }
    end

    local ownerRank = MySQL.scalar.await('SELECT id FROM highcrest_empire_ranks WHERE business_id = ? AND level = ?', { id, Config.ownerLevel })
    if not ownerRank then return { error = 'That business is not set up correctly.' } end

    if not takeFromBank(source, business.price, ('empire-buy-%d'):format(id)) then
        return { error = ('You need %s in the bank.'):format(business.price) }
    end

    -- Only one buyer can win this update. Anyone else gets their money back.
    local claimed = MySQL.update.await('UPDATE highcrest_empire_businesses SET owner = ?, balance = 0 WHERE id = ? AND owner IS NULL', { citizenid, id }) == 1
    if not claimed then
        exports.qbx_core:AddMoney(source, 'bank', business.price, 'empire-buy-refund')
        return { error = 'Someone else just bought it. You were refunded.' }
    end

    -- A business can return to the market if its owner's character is deleted, so buyers start clean.
    MySQL.update.await('DELETE FROM highcrest_empire_staff WHERE business_id = ?', { id })
    MySQL.update.await('DELETE FROM highcrest_empire_ledger WHERE business_id = ?', { id })

    MySQL.update.await([[
        INSERT INTO highcrest_empire_staff (business_id, citizenid, name, rank_id) VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE rank_id = VALUES(rank_id), name = VALUES(name)
    ]], { id, citizenid, charName(player), ownerRank })
    addLedger(id, 'purchase', 0, charName(player), ('Bought for $%d'):format(business.price))

    TriggerEvent('highcrest_empire:businessPurchased', id, citizenid)
    return loadOverview(citizenid)
end)

-- Selling needs an empty account, so no money disappears with the business.
register('sell', function(source, player, value)
    local id = tonumber(value)
    local citizenid = player.PlayerData.citizenid
    local business = id and MySQL.single.await('SELECT price, owner, balance FROM highcrest_empire_businesses WHERE id = ?', { id })
    if not business or business.owner ~= citizenid then return { error = 'You do not own that business.' } end
    if tonumber(business.balance) ~= 0 then return { error = 'Withdraw the business balance before selling.' } end

    local released = MySQL.update.await('UPDATE highcrest_empire_businesses SET owner = NULL WHERE id = ? AND owner = ? AND balance = 0', { id, citizenid }) == 1
    if not released then return { error = 'That business could not be sold. Try again.' } end

    MySQL.update.await('DELETE FROM highcrest_empire_staff WHERE business_id = ?', { id })
    MySQL.update.await('DELETE FROM highcrest_empire_ledger WHERE business_id = ?', { id })
    exports.qbx_core:AddMoney(source, 'bank', math.floor(business.price * Config.sellBackShare), 'empire-sell')

    TriggerEvent('highcrest_empire:businessSold', id, citizenid)
    return loadOverview(citizenid)
end)

register('deposit', function(source, player, data)
    local id = type(data) == 'table' and tonumber(data.id)
    local amount = type(data) == 'table' and cleanAmount(data.amount)
    if not id or not amount then return { error = 'Enter a valid amount.' } end

    local citizenid = player.PlayerData.citizenid
    if not can(loadMembership(id, citizenid), 'deposit') then return { error = 'You are not allowed to do that.' } end
    if not takeFromBank(source, amount, ('empire-deposit-%d'):format(id)) then return { error = 'You do not have that much in the bank.' } end

    if not addToBusiness(id, amount) then
        exports.qbx_core:AddMoney(source, 'bank', amount, 'empire-deposit-refund')
        return { error = 'That deposit failed. You were refunded.' }
    end

    addLedger(id, 'deposit', amount, charName(player))
    return loadBusiness(id, citizenid)
end)

register('withdraw', function(source, player, data)
    local id = type(data) == 'table' and tonumber(data.id)
    local amount = type(data) == 'table' and cleanAmount(data.amount)
    if not id or not amount then return { error = 'Enter a valid amount.' } end

    local citizenid = player.PlayerData.citizenid
    if not can(loadMembership(id, citizenid), 'withdraw') then return { error = 'You are not allowed to do that.' } end
    if not takeFromBusiness(id, amount) then return { error = 'The business does not have that much.' } end

    if not exports.qbx_core:AddMoney(source, 'bank', amount, ('empire-withdraw-%d'):format(id)) then
        addToBusiness(id, amount)
        return { error = 'That withdrawal failed. The money was returned.' }
    end

    addLedger(id, 'withdraw', amount, charName(player))
    return loadBusiness(id, citizenid)
end)

-- Wages can reach staff who are offline.
register('pay', function(_, player, data)
    local id = type(data) == 'table' and tonumber(data.id)
    local memberId = type(data) == 'table' and tonumber(data.memberId)
    local amount = type(data) == 'table' and cleanAmount(data.amount)
    if not id or not memberId or not amount then return { error = 'Enter a valid amount.' } end

    local citizenid = player.PlayerData.citizenid
    if not can(loadMembership(id, citizenid), 'pay') then return { error = 'You are not allowed to do that.' } end

    local member = MySQL.single.await('SELECT citizenid, name FROM highcrest_empire_staff WHERE id = ? AND business_id = ?', { memberId, id })
    if not member then return { error = 'They no longer work here.' } end
    if not takeFromBusiness(id, amount) then return { error = 'The business does not have that much.' } end

    if not exports.qbx_core:AddMoney(member.citizenid, 'bank', amount, ('empire-pay-%d'):format(id)) then
        addToBusiness(id, amount)
        return { error = 'That payment failed. The money was returned.' }
    end

    addLedger(id, 'pay', amount, charName(player), ('To %s'):format(member.name))
    notifyCitizen(member.citizenid, ('You were paid $%d.'):format(amount))
    return loadBusiness(id, citizenid)
end)

-- Hiring is an offer the other player has to accept.
register('hire', function(_, player, data)
    local id = type(data) == 'table' and tonumber(data.id)
    if not id or type(data.number) ~= 'string' then return { error = 'Enter a phone number.' } end

    local citizenid = player.PlayerData.citizenid
    if not can(loadMembership(id, citizenid), 'hire') then return { error = 'You are not allowed to do that.' } end

    local target = exports.qbx_core:GetPlayerByPhone(trimText(data.number))
    if not target then return { error = 'That person is not in the city right now.' } end

    local targetCitizen = target.PlayerData.citizenid
    if loadMembership(id, targetCitizen) then return { error = 'They already work here.' } end

    local staffCount = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_empire_staff WHERE business_id = ?', { id })
    if staffCount >= Config.maxStaff then return { error = 'This business is at its staff limit.' } end

    for _, offer in pairs(offers) do
        if offer.businessId == id and offer.citizenid == targetCitizen and offer.expires >= os.time() then
            return { error = 'They already have an offer from you.' }
        end
    end

    local rank = MySQL.single.await('SELECT id, name FROM highcrest_empire_ranks WHERE business_id = ? ORDER BY level ASC LIMIT 1', { id })
    local businessName = MySQL.scalar.await('SELECT name FROM highcrest_empire_businesses WHERE id = ?', { id })
    if not rank or not businessName then return { error = 'That business is not set up correctly.' } end

    nextOfferId += 1
    offers[nextOfferId] = {
        businessId = id,
        businessName = businessName,
        citizenid = targetCitizen,
        name = charName(target),
        rankId = rank.id,
        rankName = rank.name,
        hiredBy = citizenid,
        expires = os.time() + Config.offerLifetimeSeconds,
    }
    notifyCitizen(targetCitizen, ('%s offered you a job. Open Empire on your phone to answer.'):format(businessName))

    local result = loadBusiness(id, citizenid)
    result.notice = ('Offer sent to %s.'):format(charName(target))
    return result
end)

register('respondOffer', function(_, player, data)
    local citizenid = player.PlayerData.citizenid
    local offerId = type(data) == 'table' and tonumber(data.id)
    local offer = offerId and offers[offerId]
    if not offer or offer.citizenid ~= citizenid or offer.expires < os.time() then
        offers[offerId or 0] = nil
        return { error = 'That offer has expired.' }
    end
    offers[offerId] = nil

    if data.accept == true then
        local staffCount = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_empire_staff WHERE business_id = ?', { offer.businessId })
        if staffCount >= Config.maxStaff then return { error = 'That business is now full.' } end

        MySQL.insert.await('INSERT IGNORE INTO highcrest_empire_staff (business_id, citizenid, name, rank_id) VALUES (?, ?, ?, ?)', {
            offer.businessId, citizenid, charName(player), offer.rankId,
        })
        notifyCitizen(offer.hiredBy, ('%s accepted your job offer.'):format(charName(player)))
        TriggerEvent('highcrest_empire:employeeHired', offer.businessId, citizenid)
    else
        notifyCitizen(offer.hiredBy, ('%s declined your job offer.'):format(charName(player)))
    end
    return loadOverview(citizenid)
end)

-- Staff can only be managed by someone of a higher rank.
local function loadManagedMember(id, memberId, membership)
    local member = MySQL.single.await([[
        SELECT s.citizenid, s.name, r.level
        FROM highcrest_empire_staff s
        JOIN highcrest_empire_ranks r ON r.id = s.rank_id
        WHERE s.id = ? AND s.business_id = ?
    ]], { memberId, id })
    if not member then return nil, 'They no longer work here.' end
    if member.level >= membership.level then return nil, 'You can only manage people below your rank.' end
    return member
end

register('fire', function(_, player, data)
    local id = type(data) == 'table' and tonumber(data.id)
    local memberId = type(data) == 'table' and tonumber(data.memberId)
    if not id or not memberId then return { error = 'That did not work.' } end

    local citizenid = player.PlayerData.citizenid
    local membership = loadMembership(id, citizenid)
    if not can(membership, 'fire') then return { error = 'You are not allowed to do that.' } end

    local member, problem = loadManagedMember(id, memberId, membership)
    if not member then return { error = problem } end

    MySQL.update.await('DELETE FROM highcrest_empire_staff WHERE id = ? AND business_id = ?', { memberId, id })
    notifyCitizen(member.citizenid, 'You were let go from your job.')
    addLedger(id, 'staff', 0, charName(player), ('Fired %s'):format(member.name))
    TriggerEvent('highcrest_empire:employeeFired', id, member.citizenid)
    return loadBusiness(id, citizenid)
end)

register('setRank', function(_, player, data)
    local id = type(data) == 'table' and tonumber(data.id)
    local memberId = type(data) == 'table' and tonumber(data.memberId)
    local rankId = type(data) == 'table' and tonumber(data.rankId)
    if not id or not memberId or not rankId then return { error = 'That did not work.' } end

    local citizenid = player.PlayerData.citizenid
    local membership = loadMembership(id, citizenid)
    if not can(membership, 'promote') then return { error = 'You are not allowed to do that.' } end

    local member, problem = loadManagedMember(id, memberId, membership)
    if not member then return { error = problem } end

    local rank = MySQL.single.await('SELECT name, level FROM highcrest_empire_ranks WHERE id = ? AND business_id = ?', { rankId, id })
    if not rank then return { error = 'That rank does not exist.' } end
    if rank.level >= membership.level then return { error = 'You can only give ranks below your own.' } end

    MySQL.update.await('UPDATE highcrest_empire_staff SET rank_id = ? WHERE id = ? AND business_id = ?', { rankId, memberId, id })
    notifyCitizen(member.citizenid, ('Your rank is now %s.'):format(rank.name))
    addLedger(id, 'staff', 0, charName(player), ('%s is now %s'):format(member.name, rank.name))
    return loadBusiness(id, citizenid)
end)

-- Only the owner can change what ranks are allowed to do. The Owner rank's powers can't be changed.
register('saveRank', function(_, player, data)
    local id = type(data) == 'table' and tonumber(data.id)
    local rankId = type(data) == 'table' and tonumber(data.rankId)
    if not id or not rankId then return { error = 'That did not work.' } end

    local citizenid = player.PlayerData.citizenid
    local membership = loadMembership(id, citizenid)
    if not membership or not isOwnerRank(membership) then return { error = 'Only the owner can change ranks.' } end

    local rank = MySQL.single.await('SELECT level FROM highcrest_empire_ranks WHERE id = ? AND business_id = ?', { rankId, id })
    if not rank then return { error = 'That rank does not exist.' } end

    local name = trimText(data.name)
    if #name < 1 or #name > 30 then return { error = 'Rank names can be up to 30 characters.' } end

    local permissions = {}
    if rank.level < Config.ownerLevel and type(data.permissions) == 'table' then
        for _, permission in ipairs(data.permissions) do
            if validPermissions[permission] then permissions[#permissions + 1] = permission end
        end
    end

    MySQL.update.await('UPDATE highcrest_empire_ranks SET name = ?, permissions = ? WHERE id = ? AND business_id = ?', {
        name, json.encode(permissions), rankId, id,
    })
    return loadBusiness(id, citizenid)
end)

register('leave', function(_, player, value)
    local id = tonumber(value)
    local citizenid = player.PlayerData.citizenid
    local membership = id and loadMembership(id, citizenid)
    if not membership then return { error = 'You do not work there.' } end
    if isOwnerRank(membership) then return { error = 'Owners sell the business instead of leaving.' } end

    MySQL.update.await('DELETE FROM highcrest_empire_staff WHERE business_id = ? AND citizenid = ?', { id, citizenid })
    return loadOverview(citizenid)
end)

AddEventHandler('playerDropped', function()
    busy[source] = nil
end)

-- For other Highcrest systems, such as Reputation and future business scripts.
exports('GetCitizenBusinesses', function(citizenid)
    return MySQL.query.await([[
        SELECT b.id, b.name, b.type, r.name AS rankName, r.level
        FROM highcrest_empire_staff s
        JOIN highcrest_empire_businesses b ON b.id = s.business_id
        JOIN highcrest_empire_ranks r ON r.id = s.rank_id
        WHERE s.citizenid = ?
    ]], { citizenid }) or {}
end)

exports('HasBusinessPermission', function(citizenid, businessId, permission)
    return can(loadMembership(businessId, citizenid), permission)
end)

-- Server scripts call this to pay revenue into a business, such as a sale at a future shop.
exports('AddBusinessRevenue', function(businessId, amount, note)
    local clean = cleanAmount(amount)
    if not clean or not addToBusiness(businessId, clean) then return false end
    addLedger(businessId, 'revenue', clean, 'System', note)
    return true
end)

CreateBusinessRanks = function(businessId)
    for _, rank in ipairs(Config.defaultRanks) do
        MySQL.insert.await('INSERT INTO highcrest_empire_ranks (business_id, name, level, permissions) VALUES (?, ?, ?, ?)', {
            businessId, rank.name, rank.level, json.encode(rank.permissions),
        })
    end
end

GiveBusiness = function(businessId, player)
    local citizenid = player.PlayerData.citizenid
    local ownerRank = MySQL.scalar.await('SELECT id FROM highcrest_empire_ranks WHERE business_id = ? AND level = ?', { businessId, Config.ownerLevel })
    if not ownerRank then return false end
    if MySQL.update.await('UPDATE highcrest_empire_businesses SET owner = ?, balance = 0 WHERE id = ? AND owner IS NULL', { citizenid, businessId }) ~= 1 then
        return false
    end
    MySQL.update.await('DELETE FROM highcrest_empire_staff WHERE business_id = ?', { businessId })
    MySQL.update.await('DELETE FROM highcrest_empire_ledger WHERE business_id = ?', { businessId })
    MySQL.update.await([[
        INSERT INTO highcrest_empire_staff (business_id, citizenid, name, rank_id) VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE rank_id = VALUES(rank_id), name = VALUES(name)
    ]], { businessId, citizenid, charName(player), ownerRank })
    addLedger(businessId, 'purchase', 0, 'Admin', ('Given to %s'):format(charName(player)))
    return true
end
