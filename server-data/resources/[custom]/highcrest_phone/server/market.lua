-- Marketplace: listings only. Buyers contact sellers by phone, and no money moves through the app.
local MAX_PRICE = 100000000
local MAX_LISTINGS_PER_CHARACTER = 10
local LISTING_DAYS = 30

MySQL.ready(function()
    Citizen.Await(PhotoTableReady)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_market_listings` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `phone` VARCHAR(15) NOT NULL,
            `title` VARCHAR(60) NOT NULL,
            `description` VARCHAR(500) NOT NULL,
            `price` INT NOT NULL,
            `photo_id` BIGINT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE,
            FOREIGN KEY (`photo_id`) REFERENCES `highcrest_phone_photos` (`id`) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.update.await(('DELETE FROM highcrest_market_listings WHERE created_at < NOW() - INTERVAL %d DAY'):format(LISTING_DAYS))
end)

local function loadListings(citizenid)
    return MySQL.query.await([[
        SELECT id, phone, title, description, price, photo_id AS photoId,
            UNIX_TIMESTAMP(created_at) AS createdAt, citizenid = ? AS mine
        FROM highcrest_market_listings ORDER BY id DESC LIMIT 100
    ]], { citizenid }) or {}
end

lib.callback.register('highcrest_phone:server:marketGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end
    return { listings = loadListings(player.PlayerData.citizenid) }
end)

lib.callback.register('highcrest_phone:server:marketCreate', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end
    if IsRateLimited(source, 'marketCreate', 10000) then return { error = 'Wait a few seconds before listing again.' } end

    local title = TrimText(data.title)
    local description = TrimText(data.description)
    local price = math.floor(tonumber(data.price) or -1)
    if #title < 1 or #title > 60 then return { error = 'Titles can be up to 60 characters.' } end
    if #description > 500 then return { error = 'Descriptions can be up to 500 characters.' } end
    if price < 0 or price > MAX_PRICE then return { error = 'Enter a valid price.' } end

    local citizenid = player.PlayerData.citizenid
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_market_listings WHERE citizenid = ?', { citizenid })
    if count >= MAX_LISTINGS_PER_CHARACTER then
        return { error = ('You can only have %d listings.'):format(MAX_LISTINGS_PER_CHARACTER) }
    end

    MySQL.insert.await('INSERT INTO highcrest_market_listings (citizenid, phone, title, description, price, photo_id) VALUES (?, ?, ?, ?, ?, ?)', {
        citizenid, player.PlayerData.charinfo.phone, title, description, price, CleanPhotoId(citizenid, data.photoId),
    })
    return { listings = loadListings(citizenid) }
end)

-- Sellers can delete their own listings. Admins can delete any listing.
lib.callback.register('highcrest_phone:server:marketDelete', function(source, value)
    local player = GetPhoneOwner(source)
    local id = tonumber(value)
    if not player or not id then return end

    local citizenid = player.PlayerData.citizenid
    if IsPlayerAceAllowed(source, 'admin') then
        MySQL.update.await('DELETE FROM highcrest_market_listings WHERE id = ?', { id })
    else
        MySQL.update.await('DELETE FROM highcrest_market_listings WHERE id = ? AND citizenid = ?', { id, citizenid })
    end
    return { listings = loadListings(citizenid) }
end)
