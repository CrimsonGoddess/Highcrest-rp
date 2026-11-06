local MAX_MESSAGE_LENGTH = 500
local CONVERSATION_LIMIT = 100
local SEND_COOLDOWN_MS = 800

local lastSentAt = {}

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_phone_messages` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `sender_number` VARCHAR(15) NOT NULL,
            `recipient_number` VARCHAR(15) NOT NULL,
            `body` VARCHAR(500) NOT NULL,
            `sent_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `read_at` TIMESTAMP NULL DEFAULT NULL,
            PRIMARY KEY (`id`),
            KEY `by_sender` (`sender_number`, `id`),
            KEY `by_recipient` (`recipient_number`, `read_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

function NumberExists(number)
    return MySQL.scalar.await("SELECT 1 FROM players WHERE JSON_VALUE(charinfo, '$.phone') = ? LIMIT 1", { number }) ~= nil
end

function CountUnreadMessages(number)
    return MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_phone_messages WHERE recipient_number = ? AND read_at IS NULL', { number }) or 0
end

lib.callback.register('highcrest_phone:server:listConversations', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end

    local mine = player.PlayerData.charinfo.phone
    local rows = MySQL.query.await([[
        SELECT l.other, m.body, UNIX_TIMESTAMP(m.sent_at) AS sentAt, c.name,
            (SELECT COUNT(*) FROM highcrest_phone_messages u
                WHERE u.recipient_number = ? AND u.sender_number = l.other AND u.read_at IS NULL) AS unread
        FROM (
            SELECT IF(sender_number = ?, recipient_number, sender_number) AS other, MAX(id) AS last_id
            FROM highcrest_phone_messages
            WHERE sender_number = ? OR recipient_number = ?
            GROUP BY other
        ) l
        JOIN highcrest_phone_messages m ON m.id = l.last_id
        LEFT JOIN highcrest_phone_contacts c ON c.citizenid = ? AND c.number = l.other
        ORDER BY m.id DESC
    ]], { mine, mine, mine, mine, player.PlayerData.citizenid })

    return rows or {}
end)

lib.callback.register('highcrest_phone:server:getConversation', function(source, other)
    local player = GetPhoneOwner(source)
    other = CleanPhoneNumber(other)
    if not player or not other then return end

    local mine = player.PlayerData.charinfo.phone
    local rows = MySQL.query.await([[
        SELECT id, body, UNIX_TIMESTAMP(sent_at) AS sentAt, sender_number = ? AS mine FROM (
            SELECT * FROM highcrest_phone_messages
            WHERE (sender_number = ? AND recipient_number = ?) OR (sender_number = ? AND recipient_number = ?)
            ORDER BY id DESC LIMIT ?
        ) recent ORDER BY id
    ]], { mine, mine, other, other, mine, CONVERSATION_LIMIT })

    MySQL.update.await('UPDATE highcrest_phone_messages SET read_at = NOW() WHERE recipient_number = ? AND sender_number = ? AND read_at IS NULL', { mine, other })

    return {
        name = GetContactName(player.PlayerData.citizenid, other),
        messages = rows or {},
    }
end)

lib.callback.register('highcrest_phone:server:sendMessage', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' or type(data.body) ~= 'string' then return end

    local now = GetGameTimer()
    if lastSentAt[source] and now - lastSentAt[source] < SEND_COOLDOWN_MS then
        return { error = 'Slow down a little.' }
    end

    local mine = player.PlayerData.charinfo.phone
    local other = CleanPhoneNumber(data.number)
    local body = data.body:gsub('^%s+', ''):gsub('%s+$', '')
    if not other or #body < 1 or #body > MAX_MESSAGE_LENGTH then return { error = 'That message could not be sent.' } end
    if other == mine then return { error = 'You cannot text yourself.' } end
    if not NumberExists(other) then return { error = 'That number is not in service.' } end

    lastSentAt[source] = now
    local id = MySQL.insert.await('INSERT INTO highcrest_phone_messages (sender_number, recipient_number, body) VALUES (?, ?, ?)', { mine, other, body })
    local sentAt = os.time()

    local target = exports.qbx_core:GetPlayerByPhone(other)
    if target then
        TriggerClientEvent('highcrest_phone:client:message', target.PlayerData.source, {
            id = id,
            from = mine,
            name = GetContactName(target.PlayerData.citizenid, mine),
            body = body,
            sentAt = sentAt,
        })
    end

    return { message = { id = id, body = body, sentAt = sentAt, mine = 1 } }
end)

AddEventHandler('playerDropped', function()
    lastSentAt[source] = nil
end)
