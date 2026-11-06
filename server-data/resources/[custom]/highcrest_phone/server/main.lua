local CAPTURE_TIMEOUT_MS = 20000
local MAX_PHOTO_LENGTH = 3 * 1024 * 1024
local PHOTO_PREFIX = 'data:image/webp;base64,'

local presetIds = {}
for _, wallpaper in ipairs(Config.wallpapers) do
    presetIds[wallpaper.id] = true
end

local lastPhotoAt = {}
local capturing = {}
local sendingPhoto = {}

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_phone_settings` (
            `citizenid` VARCHAR(50) NOT NULL,
            `case_color` CHAR(7) NOT NULL,
            `accent_color` CHAR(7) NOT NULL,
            `wallpaper` VARCHAR(40) NOT NULL,
            PRIMARY KEY (`citizenid`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_phone_photos` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `data` MEDIUMTEXT NOT NULL,
            `taken_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `citizen_photos` (`citizenid`, `id`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

-- Every request goes through this: the player must be in a character and carrying a phone.
local function getOwner(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    if exports.ox_inventory:Search(src, 'count', Config.phoneItem) < 1 then return end
    return player
end
GetPhoneOwner = getOwner

local function isColor(value)
    return type(value) == 'string' and value:match('^#%x%x%x%x%x%x$') ~= nil
end

local function ownsPhoto(citizenid, photoId)
    return MySQL.scalar.await('SELECT 1 FROM highcrest_phone_photos WHERE id = ? AND citizenid = ?', { photoId, citizenid }) ~= nil
end

local function isValidWallpaper(citizenid, value)
    if type(value) ~= 'string' then return false end
    local preset = value:match('^preset:([%w_]+)$')
    if preset then return presetIds[preset] == true end
    local photoId = tonumber(value:match('^photo:(%d+)$'))
    return photoId ~= nil and ownsPhoto(citizenid, photoId)
end

local function loadSettings(citizenid)
    local row = MySQL.single.await('SELECT case_color, accent_color, wallpaper FROM highcrest_phone_settings WHERE citizenid = ?', { citizenid })
    if not row then return lib.table.deepclone(Config.defaults) end
    return { caseColor = row.case_color, accentColor = row.accent_color, wallpaper = row.wallpaper }
end

local function listPhotos(citizenid)
    return MySQL.query.await(
        'SELECT id, UNIX_TIMESTAMP(taken_at) AS takenAt FROM highcrest_phone_photos WHERE citizenid = ? ORDER BY id DESC',
        { citizenid }
    ) or {}
end

lib.callback.register('highcrest_phone:server:getPhone', function(source)
    local player = getOwner(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    return {
        settings = loadSettings(citizenid),
        photos = listPhotos(citizenid),
        phoneNumber = player.PlayerData.charinfo.phone,
        contacts = ListContacts(citizenid),
        unreadMessages = CountUnreadMessages(player.PlayerData.charinfo.phone),
        swatches = Config.swatches,
        wallpapers = Config.wallpapers,
        maxPhotos = Config.maxPhotosPerCharacter,
    }
end)

lib.callback.register('highcrest_phone:server:saveSettings', function(source, data)
    local player = getOwner(source)
    if not player or type(data) ~= 'table' then return end

    local citizenid = player.PlayerData.citizenid
    if not isColor(data.caseColor) or not isColor(data.accentColor) or not isValidWallpaper(citizenid, data.wallpaper) then
        return
    end

    MySQL.update.await([[
        INSERT INTO highcrest_phone_settings (citizenid, case_color, accent_color, wallpaper) VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE case_color = VALUES(case_color), accent_color = VALUES(accent_color), wallpaper = VALUES(wallpaper)
    ]], { citizenid, data.caseColor, data.accentColor, data.wallpaper })

    return loadSettings(citizenid)
end)

local function capture(src)
    local result = promise.new()
    local settled = false
    local function settle(value)
        if settled then return end
        settled = true
        result:resolve(value)
    end

    SetTimeout(CAPTURE_TIMEOUT_MS, function() settle(nil) end)
    exports.screencapture:serverCapture(src, {
        encoding = 'webp',
        maxWidth = Config.photoMaxWidth,
        maxHeight = Config.photoMaxHeight,
    }, function(data) settle(data) end)

    return Citizen.Await(result)
end

-- The server takes the picture itself, so the client never supplies image data.
lib.callback.register('highcrest_phone:server:takePhoto', function(source)
    local player = getOwner(source)
    if not player then return { error = 'You need a phone.' } end
    if capturing[source] then return { error = 'Hold on, still saving your last photo.' } end

    local now = os.time()
    if lastPhotoAt[source] and now - lastPhotoAt[source] < Config.photoCooldownSeconds then
        return { error = 'Wait a moment before taking another photo.' }
    end

    local citizenid = player.PlayerData.citizenid
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_phone_photos WHERE citizenid = ?', { citizenid })
    if count >= Config.maxPhotosPerCharacter then
        return { error = ('Gallery full (%d photos). Delete some first.'):format(Config.maxPhotosPerCharacter) }
    end

    capturing[source] = true
    lastPhotoAt[source] = now
    local data = capture(source)
    capturing[source] = nil

    if type(data) ~= 'string' or #data > MAX_PHOTO_LENGTH or data:sub(1, #PHOTO_PREFIX) ~= PHOTO_PREFIX then
        return { error = 'The photo could not be saved.' }
    end

    local id = MySQL.insert.await('INSERT INTO highcrest_phone_photos (citizenid, data) VALUES (?, ?)', { citizenid, data })
    return { photo = { id = id, takenAt = os.time() } }
end)

lib.callback.register('highcrest_phone:server:deletePhoto', function(source, photoId)
    local player = getOwner(source)
    photoId = tonumber(photoId)
    if not player or not photoId then return end

    local citizenid = player.PlayerData.citizenid
    local removed = MySQL.update.await('DELETE FROM highcrest_phone_photos WHERE id = ? AND citizenid = ?', { photoId, citizenid })
    if removed < 1 then return end

    MySQL.update.await('UPDATE highcrest_phone_settings SET wallpaper = ? WHERE citizenid = ? AND wallpaper = ?', {
        Config.defaults.wallpaper, citizenid, ('photo:%d'):format(photoId),
    })

    return loadSettings(citizenid)
end)

-- Photos are large, so they're sent one at a time as a latent event to avoid stalling the player.
RegisterNetEvent('highcrest_phone:server:requestPhoto', function(photoId)
    local src = source
    photoId = tonumber(photoId)
    if not photoId or sendingPhoto[src] then return end

    local player = getOwner(src)
    if not player then return end

    sendingPhoto[src] = true
    local data = MySQL.scalar.await('SELECT data FROM highcrest_phone_photos WHERE id = ? AND citizenid = ?', { photoId, player.PlayerData.citizenid })
    TriggerLatentClientEvent('highcrest_phone:client:photo', src, 1000000, photoId, data)
    sendingPhoto[src] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastPhotoAt[src] = nil
    capturing[src] = nil
    sendingPhoto[src] = nil
end)
