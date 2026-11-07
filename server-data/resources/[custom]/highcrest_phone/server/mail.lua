-- Mail: reads the player_mails table. Other scripts still send mail through npwd_qbx_mail for now.
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
