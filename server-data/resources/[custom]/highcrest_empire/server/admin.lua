-- Admin commands for putting businesses on the market. Location comes from where the admin is standing.
local function reply(source, message)
    if source == 0 then
        print(message)
    else
        TriggerClientEvent('highcrest_empire:client:notify', source, message)
    end
end

local function typeList()
    local names = {}
    for name in pairs(Config.businessTypes) do names[#names + 1] = name end
    table.sort(names)
    return table.concat(names, ', ')
end

lib.addCommand('empirecreate', {
    help = 'List a new business for sale where you are standing',
    params = {
        { name = 'price', type = 'number', help = 'Price in dollars' },
        { name = 'type', type = 'string', help = 'Business type' },
        { name = 'name', type = 'longString', help = 'Business name' },
    },
    restricted = 'group.admin',
}, function(source, args)
    if source == 0 then return print('Run this in-game, where the business should be.') end

    local price = math.floor(args.price)
    if price < 0 or price > Config.maxTransaction then return reply(source, 'Enter a valid price.') end
    if not Config.businessTypes[args.type] then return reply(source, ('Types: %s'):format(typeList())) end

    local name = args.name and args.name:gsub('^%s+', ''):gsub('%s+$', '') or ''
    if #name < 1 or #name > 60 then return reply(source, 'Names can be up to 60 characters.') end

    local coords = GetEntityCoords(GetPlayerPed(source))
    local id = MySQL.insert.await('INSERT INTO highcrest_empire_businesses (name, type, price, x, y) VALUES (?, ?, ?, ?, ?)', {
        name, args.type, price, coords.x, coords.y,
    })
    CreateBusinessRanks(id)
    reply(source, ('Listed #%d %s for $%d.'):format(id, name, price))
end)

lib.addCommand('empirelist', {
    help = 'List every business and its id',
    restricted = 'group.admin',
}, function(source)
    local rows = MySQL.query.await('SELECT id, name, price, owner IS NOT NULL AS owned FROM highcrest_empire_businesses ORDER BY id') or {}
    if #rows == 0 then return reply(source, 'There are no businesses yet.') end
    for _, row in ipairs(rows) do
        reply(source, ('#%d %s, $%d, %s'):format(row.id, row.name, row.price, row.owned == 1 and 'owned' or 'for sale'))
    end
end)

lib.addCommand('empiregive', {
    help = 'Give a business that is for sale to a player, for free',
    params = {
        { name = 'id', type = 'number', help = 'Business id' },
        { name = 'player', type = 'playerId', help = 'Player id, or me' },
    },
    restricted = 'group.admin',
}, function(source, args)
    local player = exports.qbx_core:GetPlayer(args.player)
    if not player then return reply(source, 'That player has no character loaded.') end
    if GiveBusiness(math.floor(args.id), player) then
        reply(source, 'Business given.')
    else
        reply(source, 'That business does not exist or already has an owner.')
    end
end)

-- Only unowned businesses can be deleted, so no player loses money or property this way.
lib.addCommand('empiredelete', {
    help = 'Delete a business that is for sale',
    params = {
        { name = 'id', type = 'number', help = 'Business id' },
    },
    restricted = 'group.admin',
}, function(source, args)
    local removed = MySQL.update.await('DELETE FROM highcrest_empire_businesses WHERE id = ? AND owner IS NULL', { math.floor(args.id) })
    reply(source, removed == 1 and 'Business deleted.' or 'That business does not exist or has an owner.')
end)
