-- Mail: stores and reads the player_mails table.
local MAIL_LIMIT = 100

local approvedEvents = {}
for _, event in ipairs(Config.mailButtonEvents) do
    approvedEvents[event] = true
end

local function readButton(raw)
    if type(raw) ~= 'string' or raw == '' then return nil end
    local ok, button = pcall(json.decode, raw)
    if ok and type(button) == 'table' and approvedEvents[button.buttonEvent] then return button end
end

function CountUnreadMail(citizenid)
    return MySQL.scalar.await('SELECT COUNT(*) FROM player_mails WHERE citizenid = ? AND `read` = 0', { citizenid }) or 0
end

lib.callback.register('highcrest_phone:server:mailGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end

    local rows = MySQL.query.await(([[
        SELECT id, sender, subject, message, `read` AS isRead, UNIX_TIMESTAMP(`date`) AS sentAt, button
        FROM player_mails WHERE citizenid = ? ORDER BY id DESC LIMIT %d
    ]]):format(MAIL_LIMIT), { player.PlayerData.citizenid }) or {}

    -- Clients only learn that an action exists. What it does stays on the server until it's used.
    for _, row in ipairs(rows) do
        row.hasAction = readButton(row.button) ~= nil
        row.button = nil
    end
    return { mail = rows }
end)

lib.callback.register('highcrest_phone:server:mailRead', function(source, value)
    local player = GetPhoneOwner(source)
    local id = tonumber(value)
    if not player or not id then return end

    MySQL.update.await('UPDATE player_mails SET `read` = 1 WHERE id = ? AND citizenid = ?', { id, player.PlayerData.citizenid })
    return { unread = CountUnreadMail(player.PlayerData.citizenid) }
end)

lib.callback.register('highcrest_phone:server:mailDelete', function(source, value)
    local player = GetPhoneOwner(source)
    local id = tonumber(value)
    if not player or not id then return end

    MySQL.update.await('DELETE FROM player_mails WHERE id = ? AND citizenid = ?', { id, player.PlayerData.citizenid })
    return { unread = CountUnreadMail(player.PlayerData.citizenid) }
end)

-- Each action works once, and only for the owner's own mail and an approved event.
lib.callback.register('highcrest_phone:server:mailAction', function(source, value)
    local player = GetPhoneOwner(source)
    local id = tonumber(value)
    if not player or not id then return end

    local citizenid = player.PlayerData.citizenid
    local raw = MySQL.scalar.await('SELECT button FROM player_mails WHERE id = ? AND citizenid = ?', { id, citizenid })
    local button = readButton(raw)
    if not button then return { error = 'That action is no longer available.' } end

    MySQL.update.await('UPDATE player_mails SET button = NULL WHERE id = ? AND citizenid = ?', { id, citizenid })
    return { event = button.buttonEvent, data = button.buttonData }
end)

-- Delivery. Other scripts send mail through these qb-phone event names, so they don't need changing.
local MAX_SENDER_LENGTH = 50
local MAX_SUBJECT_LENGTH = 50
local MAX_MESSAGE_LENGTH = 2000
local SEND_COOLDOWN_MS = 1000

local function cutText(value, limit)
    local text = TrimText(value)
    return text:sub(1, limit)
end

local function deliverMail(citizenid, mail)
    if type(mail) ~= 'table' then return end

    -- A button only survives if it names an approved event.
    local button = type(mail.button) == 'table' and approvedEvents[mail.button.buttonEvent] and mail.button or nil
    local sender = cutText(mail.sender, MAX_SENDER_LENGTH)
    local subject = cutText(mail.subject, MAX_SUBJECT_LENGTH)

    MySQL.insert.await('INSERT INTO player_mails (citizenid, sender, subject, message, `read`, mailid, button) VALUES (?, ?, ?, ?, 0, ?, ?)', {
        citizenid, sender, subject, cutText(mail.message, MAX_MESSAGE_LENGTH),
        math.random(111111, 999999), button and json.encode(button) or nil,
    })

    local recipient = exports.qbx_core:GetPlayerByCitizenId(citizenid)
    if recipient then
        TriggerClientEvent('highcrest_phone:client:newMail', recipient.PlayerData.source, { sender = sender, subject = subject })
    end
end

-- Client scripts use this one, so it can only ever mail the player who triggered it.
RegisterNetEvent('qb-phone:server:sendNewMail', function(mail)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or IsRateLimited(src, 'sendMail', SEND_COOLDOWN_MS) then return end
    deliverMail(player.PlayerData.citizenid, mail)
end)

-- Server scripts only. It isn't a net event, so clients can't use it to mail other players.
AddEventHandler('qb-phone:server:sendNewMailToOffline', function(citizenid, mail)
    if type(citizenid) == 'string' then deliverMail(citizenid, mail) end
end)

lib.addCommand('testemail', { help = 'Send yourself a test email', restricted = 'group.admin' }, function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    deliverMail(player.PlayerData.citizenid, {
        sender = 'Highcrest RP',
        subject = 'Test email',
        message = 'This is a test of the mail system.',
    })
end)
