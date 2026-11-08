local MAX_CONTACTS = 200

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_phone_contacts` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `name` VARCHAR(40) NOT NULL,
            `number` VARCHAR(15) NOT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `citizen_number` (`citizenid`, `number`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

function CleanPhoneNumber(value)
    if type(value) ~= 'string' and type(value) ~= 'number' then return end
    local number = tostring(value):gsub('[%s%-%(%)]', '')
    if number:match('^%d+$') and #number >= 3 and #number <= 15 then return number end
end

function ListContacts(citizenid)
    return MySQL.query.await('SELECT id, name, number FROM highcrest_phone_contacts WHERE citizenid = ? ORDER BY name', { citizenid }) or {}
end

-- The name this character saved for a number, if any.
function GetContactName(citizenid, number)
    return MySQL.scalar.await('SELECT name FROM highcrest_phone_contacts WHERE citizenid = ? AND number = ?', { citizenid, number })
end

lib.callback.register('highcrest_phone:server:saveContact', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' or type(data.name) ~= 'string' then return end

    local citizenid = player.PlayerData.citizenid
    local name = data.name:gsub('^%s+', ''):gsub('%s+$', '')
    local number = CleanPhoneNumber(data.number)
    if #name < 1 or #name > 40 or not number then return { error = 'Enter a name and a valid number.' } end

    local id = tonumber(data.id)
    if not id and #ListContacts(citizenid) >= MAX_CONTACTS then
        return { error = 'Your contact list is full.' }
    end

    local ok = pcall(function()
        if id then
            MySQL.update.await('UPDATE highcrest_phone_contacts SET name = ?, number = ? WHERE id = ? AND citizenid = ?', { name, number, id, citizenid })
        else
            MySQL.insert.await('INSERT INTO highcrest_phone_contacts (citizenid, name, number) VALUES (?, ?, ?)', { citizenid, name, number })
        end
    end)
    if not ok then return { error = 'You already have a contact with that number.' } end

    return { contacts = ListContacts(citizenid) }
end)

lib.callback.register('highcrest_phone:server:deleteContact', function(source, id)
    local player = GetPhoneOwner(source)
    id = tonumber(id)
    if not player or not id then return end

    local citizenid = player.PlayerData.citizenid
    MySQL.update.await('DELETE FROM highcrest_phone_contacts WHERE id = ? AND citizenid = ?', { id, citizenid })
    return { contacts = ListContacts(citizenid) }
end)

-- Share number: sends this character's number as a contact card to someone standing close by.
local SHARE_MAX_DISTANCE = 5.0

lib.callback.register('highcrest_phone:server:shareNumber', function(source, target)
    local player = GetPhoneOwner(source)
    target = tonumber(target)
    if not player or not target or target == source then return end
    if IsRateLimited(source, 'shareNumber', 3000) then return { error = 'Wait a moment before sharing again.' } end

    local receiver = GetPhoneOwner(target)
    if not receiver then return { error = 'They do not have a phone on them.' } end

    local mine, theirs = GetPlayerPed(source), GetPlayerPed(target)
    if mine == 0 or theirs == 0 or #(GetEntityCoords(mine) - GetEntityCoords(theirs)) > SHARE_MAX_DISTANCE then
        return { error = 'They need to be standing next to you.' }
    end

    local charinfo = player.PlayerData.charinfo
    TriggerClientEvent('highcrest_phone:client:numberShared', target, {
        name = ('%s %s'):format(charinfo.firstname, charinfo.lastname),
        number = charinfo.phone,
    })
    return { ok = true }
end)
