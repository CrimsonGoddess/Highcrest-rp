-- Highcrest VIP. VIP belongs to the player's account (FiveM license), so it covers every character.
-- Other resources ask through exports: GetVip(source), HasPerk(source, perk), CanBuyVehicle(source, model).
-- The current tier is also on Player(source).state.vip for client-side checks.
--
-- Admin:   /givevip [id] [supporter|vip|elite] [days, 0 = permanent]   /removevip [id]   /vipinfo [id]
-- Tebex:   hcvip_grant {sid} vip 30     hcvip_remove {sid}     (console only; a license:... id works too)
-- Players: /vipplate [text]  (in the driver seat of a car they own)

local function trim(s) return (tostring(s or ''):gsub('^%s+', ''):gsub('%s+$', '')) end

local function licenseOf(source)
    return GetPlayerIdentifierByType(source, 'license')
end

local function tierInfo(tier)
    local t = Config.tiers[tier]
    if not t then return nil end
    return { tier = tier, label = t.label, rank = t.rank, colour = t.colour, plates = t.plates, perks = t.perks }
end

---------------------------------------------------------------------------
-- Loading and caching
---------------------------------------------------------------------------

local cache = {} -- source -> { tier, expires } or false

local function readRow(identifier)
    local row = MySQL.single.await(
        'SELECT tier, UNIX_TIMESTAMP(expires_at) AS expires FROM highcrest_vip WHERE identifier = ?', { identifier })
    if not row or not Config.tiers[row.tier] then return nil end
    if row.expires and row.expires <= os.time() then return nil end
    return { tier = row.tier, expires = row.expires }
end

local function refresh(source)
    local identifier = licenseOf(source)
    local vip = identifier and readRow(identifier) or nil
    cache[source] = vip or false
    local info = vip and tierInfo(vip.tier) or nil
    if info then info.expires = vip.expires end
    Player(source).state:set('vip', info, true)
    return vip
end

local function getVip(source)
    if cache[source] == nil then refresh(source) end
    local vip = cache[source]
    if vip and vip.expires and vip.expires <= os.time() then return refresh(source) end
    return vip or nil
end

local function rankOf(source)
    local vip = getVip(source)
    return vip and Config.tiers[vip.tier].rank or 0
end

local function hasPerk(source, perk)
    local vip = getVip(source)
    return vip ~= nil and Config.tiers[vip.tier].perks[perk] == true
end

exports('GetVip', function(source) local vip = getVip(source) return vip and tierInfo(vip.tier) or nil end)
exports('HasPerk', hasPerk)

AddEventHandler('playerJoining', function() refresh(source) end)
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function() refresh(source) end)
AddEventHandler('playerDropped', function() cache[source] = nil end)

CreateThread(function()
    Wait(2000)
    for _, id in ipairs(GetPlayers()) do refresh(tonumber(id)) end
    while true do
        Wait(10 * 60 * 1000) -- expire tiers while players are online
        for source, vip in pairs(cache) do
            if vip and vip.expires and vip.expires <= os.time() then
                refresh(source)
                TriggerClientEvent('ox_lib:notify', source, { title = 'VIP', description = 'Your VIP has ended. Thanks for supporting Highcrest!' })
            end
        end
    end
end)

---------------------------------------------------------------------------
-- Imports: VIP Collection and early access
---------------------------------------------------------------------------

local function parseDate(text)
    local y, m, d = tostring(text or ''):match('^(%d+)-(%d+)-(%d+)$')
    if not y then return nil end
    return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 0 })
end

-- Restrictions for the dealership menu (clients hide or tag these cars).
local function publishCars()
    local cars, now = {}, os.time()
    for _, model in ipairs(Config.collection) do cars[model] = { collection = true } end
    for model, date in pairs(Config.earlyAccess) do
        local opens = parseDate(date)
        if opens and opens > now and not cars[model] then cars[model] = { opens = date } end
    end
    GlobalState.hcVipCars = cars
end
CreateThread(function()
    while true do
        publishCars()
        Wait(30 * 60 * 1000)
    end
end)

local function canBuyVehicle(source, model)
    local car = (GlobalState.hcVipCars or {})[model]
    if not car then return true end
    if car.collection then
        if hasPerk(source, 'collection') then return true end
        return false, 'That car is in the VIP Collection.'
    end
    if car.opens then
        if hasPerk(source, 'earlyAccess') then return true end
        return false, ('That car is VIP early access until %s.'):format(car.opens)
    end
    return true
end
exports('CanBuyVehicle', canBuyVehicle)

---------------------------------------------------------------------------
-- Granting and removing
---------------------------------------------------------------------------

local function resolveTarget(arg)
    local id = tonumber(arg)
    if id and GetPlayerName(id) then return licenseOf(id), id end
    if type(arg) == 'string' and arg:match('^license:') then
        for _, p in ipairs(GetPlayers()) do
            if licenseOf(tonumber(p)) == arg then return arg, tonumber(p) end
        end
        return arg, nil
    end
end

local function grant(identifier, tier, days, by)
    if not identifier or not Config.tiers[tier] then return false end
    days = tonumber(days) or 30
    local current = readRow(identifier)
    local expires
    if days > 0 then
        -- Renewing the same tier adds the days on to what's left.
        local from = (current and current.tier == tier and current.expires) or os.time()
        expires = os.date('%Y-%m-%d %H:%M:%S', from + days * 86400)
    end
    MySQL.query.await([[
        INSERT INTO highcrest_vip (identifier, tier, expires_at, updated_by) VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE tier = VALUES(tier), expires_at = VALUES(expires_at), updated_by = VALUES(updated_by)
    ]], { identifier, tier, expires, by })
    return true, expires
end

local function revoke(identifier)
    if not identifier then return false end
    MySQL.query.await('DELETE FROM highcrest_vip WHERE identifier = ?', { identifier })
    return true
end

local function announce(target, text)
    if target then
        refresh(target)
        TriggerClientEvent('ox_lib:notify', target, { title = 'VIP', description = text, type = 'success', duration = 9000 })
    end
end

lib.addCommand('givevip', {
    help = 'Give a player VIP',
    restricted = 'group.admin',
    params = {
        { name = 'target', type = 'playerId', help = 'Server ID' },
        { name = 'tier', type = 'string', help = 'supporter, vip or elite' },
        { name = 'days', type = 'number', help = 'Days (0 = permanent)', optional = true },
    },
}, function(source, args)
    local tier = tostring(args.tier):lower()
    local identifier = licenseOf(args.target)
    local ok, expires = grant(identifier, tier, args.days or 30, GetPlayerName(source) or 'console')
    if not ok then
        return TriggerClientEvent('ox_lib:notify', source, { description = 'Tier must be supporter, vip or elite.', type = 'error' })
    end
    announce(args.target, ('You are now %s%s. Thank you!'):format(Config.tiers[tier].label, expires and (' until ' .. expires:sub(1, 10)) or ''))
    TriggerClientEvent('ox_lib:notify', source, { description = ('Gave %s %s.'):format(GetPlayerName(args.target), Config.tiers[tier].label), type = 'success' })
end)

lib.addCommand('removevip', {
    help = 'Remove a player\'s VIP',
    restricted = 'group.admin',
    params = { { name = 'target', type = 'playerId', help = 'Server ID' } },
}, function(source, args)
    revoke(licenseOf(args.target))
    refresh(args.target)
    TriggerClientEvent('ox_lib:notify', source, { description = ('Removed VIP from %s.'):format(GetPlayerName(args.target)), type = 'success' })
end)

lib.addCommand('vipinfo', {
    help = 'Show a player\'s VIP tier (yours if no ID)',
    params = { { name = 'target', type = 'playerId', help = 'Server ID (admins)', optional = true } },
}, function(source, args)
    local target = source
    if args.target and args.target ~= source then
        if not IsPlayerAceAllowed(source, 'admin') then return end
        target = args.target
    end
    local vip = getVip(target)
    local text = vip and ('%s%s'):format(Config.tiers[vip.tier].label, vip.expires and (' until ' .. os.date('%Y-%m-%d', vip.expires)) or ' (permanent)') or 'No VIP'
    TriggerClientEvent('ox_lib:notify', source, { title = 'VIP', description = text })
end)

-- Tebex runs these from the server console when someone buys or their subscription ends.
RegisterCommand('hcvip_grant', function(source, args)
    if source ~= 0 then return end
    local identifier, target = resolveTarget(args[1])
    local tier = tostring(args[2] or ''):lower()
    local ok, expires = grant(identifier, tier, args[3] or 30, 'tebex')
    print(('[highcrest_vip] grant %s %s %s: %s'):format(tostring(args[1]), tier, tostring(args[3] or 30), ok and 'ok' or 'FAILED'))
    if ok then announce(target, ('Thanks for your purchase! You are now %s%s.'):format(Config.tiers[tier].label, expires and (' until ' .. expires:sub(1, 10)) or '')) end
end, true)

RegisterCommand('hcvip_remove', function(source, args)
    if source ~= 0 then return end
    local identifier, target = resolveTarget(args[1])
    local ok = revoke(identifier)
    print(('[highcrest_vip] remove %s: %s'):format(tostring(args[1]), ok and 'ok' or 'FAILED'))
    if target then refresh(target) end
end, true)

---------------------------------------------------------------------------
-- Custom plates
---------------------------------------------------------------------------

lib.addCommand('vipplate', {
    help = 'VIP: give the car you are driving a custom plate',
    params = { { name = 'text', type = 'longString', help = '1-8 letters, numbers or spaces' } },
}, function(source, args)
    local function say(text, kind) TriggerClientEvent('ox_lib:notify', source, { title = 'Custom plate', description = text, type = kind or 'error' }) end
    local vip = getVip(source)
    local allowance = vip and Config.tiers[vip.tier].plates or 0
    if allowance <= 0 then return say('Custom plates are a VIP perk.') end

    local newPlate = trim(args.text):upper()
    if #newPlate < Config.plateLength.min or #newPlate > Config.plateLength.max or not newPlate:match('^[A-Z0-9 ]+$') then
        return say(('Plates are %d to %d letters, numbers or spaces.'):format(Config.plateLength.min, Config.plateLength.max))
    end

    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then return say('Sit in the driver seat of your car.') end
    local oldPlate = trim(GetVehicleNumberPlateText(vehicle)):upper()
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    local owned = MySQL.single.await('SELECT id, mods FROM player_vehicles WHERE plate = ? AND citizenid = ?', { oldPlate, player.PlayerData.citizenid })
    if not owned then return say('You can only change the plate on a car you own.') end
    if newPlate == oldPlate then return say('That is already the plate.') end
    if MySQL.scalar.await('SELECT 1 FROM player_vehicles WHERE plate = ?', { newPlate }) then return say('That plate is taken.') end

    local identifier = licenseOf(source)
    local reusing = MySQL.scalar.await('SELECT 1 FROM highcrest_vip_plates WHERE plate = ? AND identifier = ?', { oldPlate, identifier })
    if not reusing then
        -- Count custom plates still on cars (selling or scrapping a car frees its slot).
        local used = MySQL.scalar.await([[
            SELECT COUNT(*) FROM highcrest_vip_plates p JOIN player_vehicles v ON v.plate = p.plate WHERE p.identifier = ?
        ]], { identifier }) or 0
        if used >= allowance then
            return say(('Your tier allows %d custom plate%s; change one of those instead.'):format(allowance, allowance == 1 and '' or 's'))
        end
    end

    local mods = json.decode(owned.mods or '{}') or {}
    mods.plate = newPlate
    MySQL.update.await('UPDATE player_vehicles SET plate = ?, mods = ? WHERE id = ?', { newPlate, json.encode(mods), owned.id })
    if reusing then
        MySQL.update.await('UPDATE highcrest_vip_plates SET plate = ? WHERE plate = ?', { newPlate, oldPlate })
    else
        MySQL.insert.await('INSERT INTO highcrest_vip_plates (plate, identifier, old_plate) VALUES (?, ?, ?)', { newPlate, identifier, oldPlate })
    end
    SetVehicleNumberPlateText(vehicle, newPlate)
    if GetResourceState('ox_inventory') == 'started' then pcall(exports.ox_inventory.UpdateVehicle, exports.ox_inventory, oldPlate, newPlate) end
    say(('Your plate is now %s.'):format(newPlate), 'success')
end)
