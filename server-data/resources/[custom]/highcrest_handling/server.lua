-- Highcrest handling: staff paste exported handling into a Discord channel; the server reads it,
-- saves it into handling.meta (replacing that car's old entry) and reacts ✅ or ❌.
-- New handling loads at the next server restart.
--
-- In the channel:
--   paste an export (text or the message.txt Discord makes)   -> add / replace that car
--   remove SULTAN                                               -> take SULTAN's tuning out
--
-- Entries are kept in entries.json on the server; handling.meta is rebuilt from it. Neither file
-- is in the repo, so uploading this resource never overwrites what staff have added.

local API = 'https://discord.com/api/v10'
local ENTRIES_FILE = 'entries.json'
local resource = GetCurrentResourceName()

local function token()
    local t = GetConvar('highcrest_discord_token', '')
    return t ~= '' and t or nil
end

local function headers()
    return { ['Authorization'] = 'Bot ' .. token(), ['Content-Type'] = 'application/json', ['User-Agent'] = 'HighcrestRP (fivem, 1.0)' }
end

local function request(method, url, body)
    local p = promise.new()
    PerformHttpRequest(url, function(status, response) p:resolve({ status = status, body = response }) end,
        method, body or '', headers())
    return Citizen.Await(p)
end

---------------------------------------------------------------------------
-- Entries and handling.meta
---------------------------------------------------------------------------

local function loadEntries()
    local raw = LoadResourceFile(resource, ENTRIES_FILE)
    return raw and json.decode(raw) or {}
end

local function writeMeta(entries)
    local names = {}
    for name in pairs(entries) do names[#names + 1] = name end
    table.sort(names)
    local parts = {
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<!-- Built by highcrest_handling from the Discord #handling channel. Do not edit by hand on the server;',
        '     post in the channel instead. Cars: ' .. (#names > 0 and table.concat(names, ', ') or 'none') .. ' -->',
        '<CHandlingDataMgr>',
        '  <HandlingData>',
    }
    for _, name in ipairs(names) do
        parts[#parts + 1] = ('    <!-- %s: by %s, %s -->'):format(name, entries[name].by or '?', entries[name].at or '?')
        parts[#parts + 1] = entries[name].xml
    end
    parts[#parts + 1] = '  </HandlingData>'
    parts[#parts + 1] = '</CHandlingDataMgr>'
    SaveResourceFile(resource, 'handling.meta', table.concat(parts, '\n') .. '\n', -1)
end

local function saveEntries(entries)
    SaveResourceFile(resource, ENTRIES_FILE, json.encode(entries, { indent = true }), -1)
    writeMeta(entries)
end

---------------------------------------------------------------------------
-- Parsing an export
---------------------------------------------------------------------------

-- Every top-level <Item type="CHandlingData"> ... </Item> block, nested items included.
local function handlingBlocks(text)
    local blocks = {}
    local pos = 1
    while true do
        local s = text:find('<Item%s+type="CHandlingData"%s*>', pos)
        if not s then break end
        local depth, cursor, finish = 0, s, nil
        while true do
            local a, b, tag = text:find('(</?Item[^>]*>)', cursor)
            if not a then break end
            if tag:sub(1, 2) == '</' then
                depth = depth - 1
            elseif tag:sub(-2) ~= '/>' then
                depth = depth + 1
            end
            cursor = b + 1
            if depth == 0 then finish = b break end
        end
        if not finish then break end
        blocks[#blocks + 1] = text:sub(s, finish)
        pos = finish + 1
    end
    return blocks
end

local REQUIRED = { 'fMass', 'fInitialDriveForce', 'fInitialDriveMaxFlatVel', 'fBrakeForce', 'fTractionCurveMax', 'fSuspensionForce' }

-- Check a block and return its car name, or nil and why not.
local function checkBlock(block)
    local name = block:match('<handlingName>%s*([%w_]+)%s*</handlingName>')
    if not name then return nil, 'no <handlingName>' end
    for _, key in ipairs(REQUIRED) do
        if not block:find('<' .. key .. '%s+value="%-?[%d%.]+"') then return nil, ('%s is missing %s'):format(name, key) end
    end
    if #block > 20000 then return nil, ('%s is too long'):format(name) end
    return name:upper()
end

-- Exports put empty <Item type="" /> lines in SubHandlingData, which GTA rejects; drop them.
local function tidy(block)
    block = block:gsub('\n%s*<Item%s+type=""%s*/>', '')
    block = block:gsub('<SubHandlingData>%s*</SubHandlingData>', '<SubHandlingData />')
    -- Indent consistently.
    local lines = {}
    for line in block:gmatch('[^\r\n]+') do
        local trimmed = line:match('^%s*(.-)%s*$')
        if trimmed ~= '' then lines[#lines + 1] = trimmed end
    end
    for i, line in ipairs(lines) do
        lines[i] = (i == 1 or i == #lines) and ('    ' .. line) or ('      ' .. line)
    end
    return table.concat(lines, '\n')
end

---------------------------------------------------------------------------
-- Reading the channel
---------------------------------------------------------------------------

local function react(messageId, ok)
    local emoji = ok and '%E2%9C%85' or '%E2%9D%8C'
    request('PUT', ('%s/channels/%s/messages/%s/reactions/%s/@me'):format(API, Config.channelId, messageId, emoji))
end

-- The message text plus any text files Discord made from a long paste.
local function messageText(message)
    local text = message.content or ''
    for _, file in ipairs(message.attachments or {}) do
        local name = (file.filename or ''):lower()
        if (name:find('%.txt$') or name:find('%.meta$') or name:find('%.xml$')) and (file.size or 0) < 200000 then
            local p = promise.new()
            PerformHttpRequest(file.url, function(status, body) p:resolve(status == 200 and body or '') end, 'GET', '', {})
            text = text .. '\n' .. Citizen.Await(p)
        end
    end
    return text
end

local function handleMessage(message, entries)
    local author = message.author or {}
    local who = Config.allowed[author.id]
    if not who or author.bot then return false end

    local text = messageText(message)
    local removeName = (message.content or ''):match('^%s*[Rr]emove%s+([%w_]+)%s*$')
    if removeName then
        removeName = removeName:upper()
        if entries[removeName] then
            entries[removeName] = nil
            print(('[highcrest_handling] %s removed %s'):format(who, removeName))
            react(message.id, true)
            return true
        end
        print(('[highcrest_handling] %s tried to remove %s, which has no tuning'):format(who, removeName))
        react(message.id, false)
        return false
    end

    local blocks = handlingBlocks(text)
    if #blocks == 0 then return false end -- just chat
    local changed, failed = false, false
    for _, block in ipairs(blocks) do
        local name, why = checkBlock(block)
        if name then
            entries[name] = { xml = tidy(block), by = who, at = os.date('%Y-%m-%d %H:%M') }
            print(('[highcrest_handling] %s set handling for %s'):format(who, name))
            changed = true
        else
            print(('[highcrest_handling] rejected a paste from %s: %s'):format(who, why))
            failed = true
        end
    end
    react(message.id, changed and not failed)
    return changed
end

local function checkChannel()
    if not token() then return end
    local last = GetResourceKvpString('lastMessage')
    local url = ('%s/channels/%s/messages?limit=50%s'):format(API, Config.channelId, last and ('&after=' .. last) or '')
    local res = request('GET', url)
    if res.status ~= 200 then
        if res.status == 403 or res.status == 401 then
            print(('[highcrest_handling] Discord said %s: the bot needs View Channel and Read Message History in the channel.'):format(res.status))
        end
        return
    end
    local messages = json.decode(res.body or '[]') or {}
    if #messages == 0 then return end
    -- Discord returns newest first.
    table.sort(messages, function(a, b) return #a.id < #b.id or (#a.id == #b.id and a.id < b.id) end)

    local entries = loadEntries()
    local changed = false
    for _, message in ipairs(messages) do
        local ok, result = pcall(handleMessage, message, entries)
        if ok and result then changed = true end
        if not ok then print('[highcrest_handling] error: ' .. tostring(result)) end
        SetResourceKvp('lastMessage', message.id)
    end
    if changed then
        saveEntries(entries)
        print('[highcrest_handling] handling.meta updated; it loads at the next restart.')
    end
end

CreateThread(function()
    if not LoadResourceFile(resource, 'handling.meta') then writeMeta(loadEntries()) end
    Wait(15000)
    while true do
        checkChannel()
        Wait(Config.checkEvery * 1000)
    end
end)

-- Console / admin: check the channel now instead of waiting.
lib.addCommand('handlingsync', { help = 'Read the Discord #handling channel now', restricted = 'group.admin' }, function(source)
    CreateThread(checkChannel)
    if source > 0 then TriggerClientEvent('ox_lib:notify', source, { description = 'Checking the handling channel…' }) end
end)
