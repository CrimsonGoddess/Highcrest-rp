-- Housing: realtors and admins list houses with /addhouse, and players buy or rent them in the app.
-- Each house is a qbx_properties property, so entering, stashes and keys work as before.
-- This file adds the address, photo, and separate sale and rent prices.
local propertiesConfig = require '@qbx_properties.config.shared'
local propertiesServerConfig = require '@qbx_properties.config.server'

local MAX_PHOTO_LENGTH = 3 * 1024 * 1024
local PHOTO_PREFIX = 'data:image/webp;base64,'
local MAX_DOOR_DISTANCE = 150.0   -- The realtor walks back to frame the photo, so allow some distance.

local shells = {}
for _, shell in ipairs(Config.housing.shells) do
    local hash = joaat(shell.model)
    if propertiesConfig.interiors[hash] then
        shells[shell.model] = { hash = hash, label = shell.label }
    else
        lib.print.warn(('Housing shell %s has no interior entry in qbx_properties/config/shared.lua and is skipped.'):format(shell.model))
    end
end

local pendingPhoto = {}
local capturingHouse = {}
local sendingHousePhoto = {}

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_housing_listings` (
            `property_id` INT NOT NULL,
            `address` VARCHAR(60) NOT NULL,
            `shell` VARCHAR(60) NOT NULL,
            `sale_price` INT NULL,
            `rent_price` INT NULL,
            `rent_hours` TINYINT NULL,
            `photo` MEDIUMTEXT NULL,
            `created_by` VARCHAR(50) NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`property_id`),
            FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

local function canManage(source)
    if IsPlayerAceAllowed(source, 'admin') then return true end
    local player = exports.qbx_core:GetPlayer(source)
    return player ~= nil and player.PlayerData.job.name == Config.housing.realtorJob
end

local function cleanPrice(value)
    value = tonumber(value)
    if not value then return nil end
    value = math.floor(value)
    if value < 1 or value > Config.housing.maxPrice then return false end
    return value
end

-- qbx_properties names stashes after the property, and only letters, numbers and spaces work there.
local function cleanAddress(value)
    if type(value) ~= 'string' then return nil end
    value = value:gsub('[^%w%s]', ''):gsub('%s+', ' '):gsub('^ ', ''):gsub(' $', '')
    if #value < 3 or #value > 60 then return nil end
    return value
end

-- qbx_properties only stores one price. Unowned houses show the sale price at the door when there
-- is one, otherwise the rent. This puts that back after a rental ends.
local function resetUnownedPrices()
    MySQL.update.await([[
        UPDATE properties p JOIN highcrest_housing_listings l ON l.property_id = p.id
        SET p.price = COALESCE(l.sale_price, l.rent_price),
            p.rent_interval = IF(l.sale_price IS NULL, l.rent_hours, NULL)
        WHERE p.owner IS NULL
    ]])
end

lib.addCommand('addhouse', {
    help = 'Add a house to the Housing app (realtors and admins)',
}, function(source)
    if not canManage(source) then
        return exports.qbx_core:Notify(source, 'Only realtors and admins can add houses.', 'error')
    end
    local options = {}
    for model, shell in pairs(shells) do options[#options + 1] = { model = model, label = shell.label, hash = shell.hash } end
    table.sort(options, function(a, b) return a.label < b.label end)
    if #options == 0 then
        return exports.qbx_core:Notify(source, 'No shells are set up. Add some to Config.housing.shells.', 'error')
    end
    pendingPhoto[source] = nil
    TriggerClientEvent('highcrest_phone:client:addHouse', source, options, Config.housing.defaultRentHours)
end)

lib.callback.register('highcrest_phone:server:housingPhoto', function(source)
    if not canManage(source) then return { error = 'Only realtors and admins can add houses.' } end
    if capturingHouse[source] then return { error = 'Still taking the last photo.' } end

    capturingHouse[source] = true
    local data = CapturePhoto(source)
    capturingHouse[source] = nil

    if type(data) ~= 'string' or #data > MAX_PHOTO_LENGTH or data:sub(1, #PHOTO_PREFIX) ~= PHOTO_PREFIX then
        return { error = 'The photo could not be taken. Try again.' }
    end
    pendingPhoto[source] = data
    return { ok = true }
end)

lib.callback.register('highcrest_phone:server:housingCreate', function(source, data)
    if not canManage(source) then return { error = 'Only realtors and admins can add houses.' } end
    if type(data) ~= 'table' or type(data.door) ~= 'table' then return { error = 'Something went wrong. Start again.' } end

    local photo = pendingPhoto[source]
    if not photo then return { error = 'Take a photo of the house first.' } end

    local shell = shells[data.shell]
    if not shell then return { error = 'Pick a shell from the list.' } end

    local address = cleanAddress(data.address)
    if not address then return { error = 'Enter an address of 3 to 60 letters and numbers.' } end

    local salePrice, rentPrice = cleanPrice(data.salePrice), cleanPrice(data.rentPrice)
    if salePrice == false or rentPrice == false then return { error = 'Prices must be between $1 and the maximum.' } end
    if not salePrice and not rentPrice then return { error = 'Set a sale price, a rent price, or both.' } end
    local rentHours = nil
    if rentPrice then
        rentHours = math.floor(tonumber(data.rentHours) or Config.housing.defaultRentHours)
        if rentHours < 1 or rentHours > 24 then return { error = 'Rent is taken every 1 to 24 hours.' } end
    end

    local door = vec3(tonumber(data.door.x) or 0, tonumber(data.door.y) or 0, tonumber(data.door.z) or 0)
    if #(GetEntityCoords(GetPlayerPed(source)) - door) > MAX_DOOR_DISTANCE then
        return { error = 'You moved too far from the front door. Start again.' }
    end

    if MySQL.scalar.await('SELECT 1 FROM properties WHERE property_name = ?', { address }) then
        return { error = 'A property with that address already exists.' }
    end

    local interior = propertiesConfig.interiors[shell.hash]
    local interactions = {
        { type = 'logout', coords = interior.logout },
        { type = 'clothing', coords = interior.clothing },
        { type = 'exit', coords = interior.exit },
    }
    local stashes = {
        { coords = interior.stash, slots = propertiesServerConfig.apartmentStash.slots, maxWeight = propertiesServerConfig.apartmentStash.maxWeight },
    }
    local doorJson = json.encode({ x = door.x, y = door.y, z = door.z })

    local id = MySQL.insert.await('INSERT INTO properties (coords, property_name, price, interior, interact_options, stash_options, rent_interval) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        doorJson, address, salePrice or rentPrice, shell.hash, json.encode(interactions), json.encode(stashes), (not salePrice) and rentHours or nil,
    })
    if not id then return { error = 'The house could not be saved.' } end

    local player = exports.qbx_core:GetPlayer(source)
    MySQL.insert.await('INSERT INTO highcrest_housing_listings (property_id, address, shell, sale_price, rent_price, rent_hours, photo, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        id, address, data.shell, salePrice, rentPrice, rentHours, photo, player and player.PlayerData.citizenid,
    })
    pendingPhoto[source] = nil

    -- Lets every client show the new front door straight away.
    TriggerClientEvent('qbx_properties:client:addProperty', -1, door)
    return { ok = true, address = address }
end)

lib.callback.register('highcrest_phone:server:housingGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end
    resetUnownedPrices()

    local rows = MySQL.query.await([[
        SELECT l.property_id AS id, l.address, l.shell, l.sale_price, l.rent_price, l.rent_hours, p.coords,
               l.photo IS NOT NULL AS has_photo
        FROM highcrest_housing_listings l JOIN properties p ON p.id = l.property_id
        WHERE p.owner IS NULL
        ORDER BY COALESCE(l.sale_price, l.rent_price)
    ]]) or {}

    local houses = {}
    for _, row in ipairs(rows) do
        local coords = json.decode(row.coords) or {}
        local shell = shells[row.shell]
        houses[#houses + 1] = {
            id = row.id,
            address = row.address,
            shellLabel = shell and shell.label or nil,
            salePrice = row.sale_price,
            rentPrice = row.rent_price,
            rentHours = row.rent_hours,
            hasPhoto = row.has_photo == 1 or row.has_photo == true,
            x = coords.x, y = coords.y,
        }
    end

    local owned = MySQL.query.await([[
        SELECT p.id, p.property_name AS address, p.rent_interval, p.price, p.coords
        FROM properties p WHERE p.owner = ? ORDER BY p.id
    ]], { player.PlayerData.citizenid }) or {}
    local mine = {}
    for _, row in ipairs(owned) do
        local coords = json.decode(row.coords) or {}
        mine[#mine + 1] = {
            id = row.id, address = row.address, renting = row.rent_interval ~= nil,
            rentPrice = row.rent_interval and row.price or nil, rentHours = row.rent_interval,
            x = coords.x, y = coords.y,
        }
    end

    return { houses = houses, mine = mine, canManage = canManage(source) }
end)

local function takeMoney(player, amount, reason)
    for _, account in ipairs({ 'cash', 'bank' }) do
        if player.PlayerData.money[account] >= amount and player.Functions.RemoveMoney(account, amount, reason) then
            return account
        end
    end
end

lib.callback.register('highcrest_phone:server:housingBuy', function(source, id)
    local player = GetPhoneOwner(source)
    id = tonumber(id)
    if not player or not id then return end
    if IsRateLimited(source, 'housingBuy', 2000) then return { error = 'Hold on a moment.' } end

    local listing = MySQL.single.await('SELECT l.address, l.sale_price FROM highcrest_housing_listings l JOIN properties p ON p.id = l.property_id WHERE l.property_id = ? AND p.owner IS NULL', { id })
    if not listing then return { error = 'That house is no longer available.' } end
    if not listing.sale_price then return { error = 'That house is only for rent.' } end

    local paidFrom = takeMoney(player, listing.sale_price, ('Purchased %s'):format(listing.address))
    if not paidFrom then return { error = ('You need %s in cash or bank.'):format(('$%d'):format(listing.sale_price)) } end

    local claimed = MySQL.update.await('UPDATE properties SET owner = ?, price = ?, rent_interval = NULL, keyholders = JSON_OBJECT() WHERE id = ? AND owner IS NULL', {
        player.PlayerData.citizenid, listing.sale_price, id,
    }) == 1
    if not claimed then
        player.Functions.AddMoney(paidFrom, listing.sale_price, 'house-purchase-refund')
        return { error = 'Someone else just got that house. You were not charged.' }
    end
    return { ok = true, message = ('You bought %s.'):format(listing.address) }
end)

lib.callback.register('highcrest_phone:server:housingRent', function(source, id)
    local player = GetPhoneOwner(source)
    id = tonumber(id)
    if not player or not id then return end
    if IsRateLimited(source, 'housingRent', 2000) then return { error = 'Hold on a moment.' } end

    local listing = MySQL.single.await('SELECT l.address, l.rent_price, l.rent_hours FROM highcrest_housing_listings l JOIN properties p ON p.id = l.property_id WHERE l.property_id = ? AND p.owner IS NULL', { id })
    if not listing then return { error = 'That house is no longer available.' } end
    if not listing.rent_price then return { error = 'That house is only for sale.' } end
    -- qbx_properties takes rent from the bank, starting with the first period right away.
    if player.PlayerData.money.bank < listing.rent_price then
        return { error = ('You need $%d in the bank for the first rent.'):format(listing.rent_price) }
    end

    local claimed = MySQL.update.await('UPDATE properties SET owner = ?, price = ?, rent_interval = ?, keyholders = JSON_OBJECT() WHERE id = ? AND owner IS NULL', {
        player.PlayerData.citizenid, listing.rent_price, listing.rent_hours, id,
    }) == 1
    if not claimed then return { error = 'Someone else just got that house.' } end

    exports.qbx_properties:StartRentThread(id)
    return { ok = true, message = ('You are renting %s for $%d every %dh.'):format(listing.address, listing.rent_price, listing.rent_hours) }
end)

-- Only unowned houses can be removed, so nobody loses a home they paid for.
lib.callback.register('highcrest_phone:server:housingRemove', function(source, id)
    id = tonumber(id)
    if not id or not canManage(source) then return { error = 'Only realtors and admins can remove houses.' } end
    local removed = MySQL.update.await('DELETE FROM properties WHERE id = ? AND owner IS NULL AND id IN (SELECT property_id FROM highcrest_housing_listings)', { id })
    if removed ~= 1 then return { error = 'That house is owned or no longer exists.' } end
    return { ok = true, message = 'House removed. It disappears from the map after a restart.' }
end)

-- House photos are large, so each one is sent as a latent event.
RegisterNetEvent('highcrest_phone:server:requestHousePhoto', function(id)
    local src = source
    id = tonumber(id)
    if not id or sendingHousePhoto[src] or not GetPhoneOwner(src) then return end
    sendingHousePhoto[src] = true
    local photo = MySQL.scalar.await('SELECT photo FROM highcrest_housing_listings WHERE property_id = ?', { id })
    TriggerLatentClientEvent('highcrest_phone:client:housePhoto', src, 1000000, id, photo)
    sendingHousePhoto[src] = nil
end)

AddEventHandler('playerDropped', function()
    pendingPhoto[source] = nil
    capturingHouse[source] = nil
    sendingHousePhoto[source] = nil
end)
