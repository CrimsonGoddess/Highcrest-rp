-- Highcrest mechanic orders. Customers design a build at a shop; mechanics quote labour on
-- their tablet, the customer approves, the mechanic fits the parts and the customer is charged.
-- Everything a client sends is checked here: changes against the catalogue, prices from the
-- config, ownership, job, duty and distance.

local catalogue = {}
for _, tab in ipairs(Config.catalogue) do
    for _, item in ipairs(tab.items) do
        item.tab = tab.id
        catalogue[item.key] = item
    end
end

local colorSet, listSets, neonSet, illegalSets, wildSet, finishSet = {}, {}, {}, {}, {}, {}
for _, c in ipairs(Config.colors) do colorSet[c[1]] = c[2] end
for name, list in pairs(Config.lists) do
    listSets[name], illegalSets[name] = {}, {}
    for _, entry in ipairs(list) do
        listSets[name][entry[1]] = entry[2]
        if entry[3] then illegalSets[name][entry[1]] = true end
    end
end
for _, w in ipairs(Config.wildPaints) do wildSet[table.concat(w[1], ',')] = w[2] end
for _, f in ipairs(Config.finishes) do finishSet[f[1]] = f[2] end

-- Progress of jobs being fitted in the bay: orderId -> { mechanic, fitted = { key = true }, readyAt }.
local work = {}
for _, n in ipairs(Config.neonColors) do neonSet[table.concat(n[1], ',')] = n[2] end

local busy = {}

local function trimPlate(plate)
    return type(plate) == 'string' and plate:gsub('^%s+', ''):gsub('%s+$', ''):upper() or nil
end

local function getPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

local function fullName(player)
    local c = player.PlayerData.charinfo or {}
    return ('%s %s'):format(c.firstname or '', c.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function isMechanic(player)
    local job = player and player.PlayerData.job
    return job and job.name == Config.job and job.onduty == true
end

-- The shop boss (top grade of the mechanic job) sets the price list. Duty isn't needed.
local function isBoss(player)
    local job = player and player.PlayerData.job
    return job and job.name == Config.job and job.isboss == true
end

local function hasJob(player)
    local job = player and player.PlayerData.job
    return job and job.name == Config.job
end

local function firstShop()
    local ids = {}
    for id in pairs(Config.shops) do ids[#ids + 1] = id end
    table.sort(ids)
    return ids[1]
end

local function notify(source, text, kind)
    TriggerClientEvent('ox_lib:notify', source, { title = 'Mechanic', description = text, type = kind or 'inform', duration = 7000 })
end

local function sourceByCitizen(citizenid)
    local player = exports.qbx_core:GetPlayerByCitizenId(citizenid)
    return player and player.PlayerData.source or nil
end

local function notifyMechanics(text)
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if isMechanic(getPlayer(src)) then notify(src, text) end
    end
end

-- Numbers from the UI can arrive as 3.0 instead of 3, so whole floats count too.
local function isInteger(v, min, max)
    return type(v) == 'number' and v == math.floor(v) and v >= min and v <= max
end

-- Turn whole floats into integers so stored props stay clean.
local function normalise(value)
    if type(value) == 'number' then return math.tointeger(value) or value end
    if type(value) == 'table' then
        local out = {}
        for i, v in ipairs(value) do out[i] = normalise(v) end
        return out
    end
    return value
end

-- Is this a value the catalogue allows for this key?
local function validValue(item, value)
    local kind = item.kind
    if kind == 'mod' then return isInteger(value, -1, 100) end
    if kind == 'level' then
        local levels = Config.prices.levels[item.key]
        return levels and isInteger(value, -1, #levels - 2)
    end
    if kind == 'toggle' then return type(value) == 'boolean' end
    if kind == 'color' then return isInteger(value, 0, 255) and colorSet[value] ~= nil end
    if kind == 'paint' then
        if type(value) == 'number' then return isInteger(value, 0, 255) and colorSet[value] ~= nil end
        if type(value) ~= 'table' or #value ~= 4 then return false end
        for i = 1, 3 do if not isInteger(value[i], 0, 255) then return false end end
        return isInteger(value[4], 0, 5) and finishSet[value[4]] ~= nil
    end
    if kind == 'list' then return isInteger(value, -1, 255) and listSets[item.list][value] ~= nil end
    if kind == 'neon' then
        if type(value) ~= 'table' or #value ~= 4 then return false end
        for i = 1, 4 do if type(value[i]) ~= 'boolean' then return false end end
        return true
    end
    if kind == 'neoncolor' then
        if type(value) ~= 'table' or #value ~= 3 then return false end
        for i = 1, 3 do if not isInteger(value[i], 0, 255) then return false end end
        return neonSet[table.concat(value, ',')] ~= nil
    end
    return false
end

-- Shop price lists. The boss sets them on the tablet; anything missing uses the config.
local shopPrices = {}
local SCALAR_PRICES = { 'cosmetic', 'color', 'customPaint', 'illegalTint', 'turbo' }

local function defaultPrices()
    local p = { labourPerPart = Config.labourPerPart, levels = {} }
    for _, key in ipairs(SCALAR_PRICES) do p[key] = Config.prices[key] end
    for key, levels in pairs(Config.prices.levels) do
        p.levels[key] = {}
        for i, v in ipairs(levels) do p.levels[key][i] = v end
    end
    return p
end

local function pricesFor(shopId)
    return shopPrices[shopId] or defaultPrices()
end

-- Check a price list from the tablet (or the database). Out-of-range or missing values
-- are refused so a typo can't make a $1 engine.
local function cleanPrices(input)
    if type(input) ~= 'table' then return nil, 'Bad price list.' end
    local out = defaultPrices()
    local lo, hi = Config.priceLimits.min, Config.priceLimits.max
    local function bounded(value, standard, label)
        value = tonumber(value)
        if not value then return nil, ('%s needs a price.'):format(label) end
        value = math.floor(value + 0.5)
        local min, max = math.floor(standard * lo), math.floor(standard * hi)
        if value < min or value > max then return nil, ('%s must be between $%d and $%d.'):format(label, min, max) end
        return value
    end
    local labels = { cosmetic = 'Body part', color = 'Paint colour', customPaint = 'Custom paint', illegalTint = 'Pure Black tint', turbo = 'Turbo' }
    for _, key in ipairs(SCALAR_PRICES) do
        -- Price lists saved before a price existed just get the standard one.
        local v, err = bounded(input[key] == nil and Config.prices[key] or input[key], Config.prices[key], labels[key])
        if not v then return nil, err end
        out[key] = v
    end
    local labour = tonumber(input.labourPerPart)
    if not labour or labour < 0 or labour > Config.maxLabour then
        return nil, ('Labour per part must be between $0 and $%d.'):format(Config.maxLabour)
    end
    out.labourPerPart = math.floor(labour + 0.5)
    local levelsIn = type(input.levels) == 'table' and input.levels or {}
    for key, standard in pairs(Config.prices.levels) do
        local given = type(levelsIn[key]) == 'table' and levelsIn[key] or {}
        local label = catalogue[key] and catalogue[key].label or key
        out.levels[key][1] = 0 -- stock is always free
        for i = 2, #standard do
            local v, err = bounded(given[i], standard[i], ('%s level %d'):format(label, i - 1))
            if not v then return nil, err end
            out.levels[key][i] = v
        end
    end
    return out
end

MySQL.ready(function()
    local ok, rows = pcall(MySQL.query.await, 'SELECT shop, prices FROM highcrest_mechanic_prices')
    if not ok then return end
    for _, row in ipairs(rows or {}) do
        local clean = Config.shops[row.shop] and cleanPrices(json.decode(row.prices or '') or {})
        if clean then shopPrices[row.shop] = clean end
    end
end)

local function partPrice(item, value, prices)
    prices = prices or defaultPrices()
    if item.kind == 'level' then
        local levels = prices.levels[item.key]
        return levels[value + 2] or levels[#levels]
    end
    if item.key == 'modTurbo' then return value and prices.turbo or 0 end
    if item.kind == 'toggle' and value == false then return 0 end
    if item.kind == 'paint' then return type(value) == 'table' and (prices.customPaint or Config.prices.customPaint) or prices.color end
    if item.kind == 'color' then return prices.color end
    if item.kind == 'list' and illegalSets[item.list][value] then return prices.illegalTint or Config.prices.illegalTint end
    return prices.cosmetic
end

local function sameValue(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= 'table' then return a == b end
    if #a ~= #b then return false end
    for i = 1, #a do if a[i] ~= b[i] then return false end end
    return true
end

local function describe(item, value)
    if item.kind == 'level' then return value < 0 and 'Stock' or ('Level %d'):format(value + 1) end
    if item.kind == 'toggle' then return value and 'Fitted' or 'Removed' end
    if item.kind == 'color' then return colorSet[value] end
    if item.kind == 'paint' then
        if type(value) == 'number' then return colorSet[value] end
        return wildSet[table.concat(value, ',')]
            or ('Custom #%02X%02X%02X, %s'):format(value[1], value[2], value[3], finishSet[value[4]] or 'Gloss')
    end
    if item.kind == 'list' then return listSets[item.list][value] end
    if item.kind == 'neoncolor' then return neonSet[table.concat(value, ',')] end
    if item.kind == 'neon' then
        local on = 0
        for i = 1, 4 do if value[i] then on = on + 1 end end
        return on == 0 and 'Off' or (on == 4 and 'All sides' or ('%d sides'):format(on))
    end
    return value < 0 and 'Stock' or ('Option %d'):format(value + 1)
end

local function storedVehicle(plate)
    return MySQL.single.await('SELECT citizenid, vehicle, mods FROM player_vehicles WHERE plate = ?', { plate })
end

local function openOrderFor(plate)
    return MySQL.single.await(
        "SELECT id, status FROM highcrest_mechanic_orders WHERE plate = ? AND status NOT IN ('done', 'cancelled', 'declined') ORDER BY id DESC LIMIT 1",
        { plate })
end

local function loadOrder(id)
    local order = MySQL.single.await('SELECT * FROM highcrest_mechanic_orders WHERE id = ?', { id })
    if order then order.changes = json.decode(order.changes) or {} end
    return order
end

local function setStatus(id, status)
    MySQL.update.await('UPDATE highcrest_mechanic_orders SET status = ? WHERE id = ?', { status, id })
end

local function vehicleNear(source, netId, plate, range)
    local entity = NetworkGetEntityFromNetworkId(tonumber(netId) or 0)
    if entity == 0 or not DoesEntityExist(entity) then return nil end
    if trimPlate(GetVehicleNumberPlateText(entity)) ~= plate then return nil end
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - GetEntityCoords(entity)) > range then return nil end
    return entity
end

-- Customer: may this car be designed here?
lib.callback.register('highcrest_mechanic:canDesign', function(source, shopId, plate)
    local player = getPlayer(source)
    plate = trimPlate(plate)
    local shop = Config.shops[shopId]
    if not player or not shop or not plate then return false, 'Something went wrong.' end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - shop.bay.xyz) > shop.bayRadius + 3.0 then return false, 'Park in the design bay first.' end

    -- An on-duty mechanic bringing in a car with an order gets the work view.
    if isMechanic(player) then
        local open = openOrderFor(plate)
        if open then
            local order = loadOrder(open.id)
            if order.status == 'new' or order.status == 'quoted' or order.status == 'declined' then
                return false, ('Order #%d needs a quote the customer has approved first (tablet).'):format(order.id)
            end
            local progress = work[order.id]
            if progress and progress.mechanic ~= player.PlayerData.citizenid and order.status == 'in_progress' then
                return false, ('%s is already working on order #%d.'):format(order.mechanic_name or 'Another mechanic', order.id)
            end
            MySQL.update.await("UPDATE highcrest_mechanic_orders SET status = 'in_progress', mechanic = ?, mechanic_name = ? WHERE id = ?",
                { player.PlayerData.citizenid, fullName(player), order.id })
            work[order.id] = {
                mechanic = player.PlayerData.citizenid,
                fitted = progress and progress.mechanic == player.PlayerData.citizenid and progress.fitted or {},
                readyAt = 0,
            }
            local lines = {}
            for _, line in ipairs(order.changes.lines or {}) do
                local item = catalogue[line.key]
                lines[#lines + 1] = {
                    key = line.key, label = line.label, value = line.value, price = line.price,
                    tab = item and item.tab, seconds = (item and item.tab == 'performance') and Config.installSeconds.performance or Config.installSeconds.default,
                    raw = (order.changes.values or {})[line.key], fitted = work[order.id].fitted[line.key] == true,
                }
            end
            return true, nil, nil, {
                id = order.id, customer = order.customer, plate = order.plate, parts = order.parts, labour = order.labour,
                customerOnline = sourceByCitizen(order.citizenid) ~= nil, lines = lines,
            }
        end
    end

    local stored = storedVehicle(plate)
    if not stored or stored.citizenid ~= player.PlayerData.citizenid then
        return false, 'You can only order work on a car you own.'
    end
    local open = openOrderFor(plate)
    if open then
        return false, ('This car already has order #%d (%s). A mechanic will be with you.'):format(open.id, open.status)
    end
    return true, nil, pricesFor(shopId)
end)

-- Customer: submit a build.
lib.callback.register('highcrest_mechanic:submit', function(source, shopId, plate, model, changes)
    local player = getPlayer(source)
    plate = trimPlate(plate)
    local shop = Config.shops[shopId]
    if not player or not shop or not plate or type(changes) ~= 'table' then return false, 'Something went wrong.' end
    if busy[source] then return false, 'One moment.' end
    busy[source] = true

    local stored = storedVehicle(plate)
    if not stored or stored.citizenid ~= player.PlayerData.citizenid then
        busy[source] = nil
        return false, 'You can only order work on a car you own.'
    end
    if openOrderFor(plate) then
        busy[source] = nil
        return false, 'This car already has an open order.'
    end

    local current = json.decode(stored.mods or '{}') or {}
    local prices = pricesFor(shopId)
    local lines, clean, parts = {}, {}, 0
    for key, value in pairs(changes) do
        value = normalise(value)
        local item = catalogue[key]
        if item and validValue(item, value) and not sameValue(Config.fromProps(key, current), value) then
            clean[key] = value
            local price = partPrice(item, value, prices)
            parts = parts + price
            lines[#lines + 1] = { key = key, label = item.label, value = describe(item, value), price = price }
        end
    end
    if not next(clean) then
        busy[source] = nil
        return false, 'Nothing has changed.'
    end
    table.sort(lines, function(a, b) return a.label < b.label end)

    local id = MySQL.insert.await([[
        INSERT INTO highcrest_mechanic_orders (shop, citizenid, customer, plate, model, changes, parts, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'new')
    ]], { shopId, player.PlayerData.citizenid, fullName(player), plate, tostring(model or stored.vehicle or ''):sub(1, 60),
        json.encode({ values = clean, lines = lines }), parts })

    busy[source] = nil
    notifyMechanics(('New order #%d: %s, parts $%s. Check your tablet.'):format(id, plate, parts))
    return true, id, parts
end)

-- Mechanic: order list for the tablet. Off-duty mechanics see only the clock-in screen.
lib.callback.register('highcrest_mechanic:orders', function(source)
    local player = getPlayer(source)
    if not hasJob(player) then return false end
    if not isMechanic(player) then
        return { offDuty = true, open = {}, recent = {}, maxLabour = Config.maxLabour, cut = Config.mechanicCut, isBoss = isBoss(player) }
    end
    local open = MySQL.query.await(
        "SELECT * FROM highcrest_mechanic_orders WHERE status NOT IN ('done', 'cancelled') ORDER BY id DESC LIMIT 50") or {}
    local recent = MySQL.query.await(
        "SELECT * FROM highcrest_mechanic_orders WHERE status IN ('done', 'cancelled') ORDER BY updated_at DESC LIMIT 15") or {}
    for _, list in ipairs({ open, recent }) do
        for _, order in ipairs(list) do
            local data = json.decode(order.changes) or {}
            order.changes = nil
            order.lines = data.lines or {}
            order.shopLabel = Config.shops[order.shop] and Config.shops[order.shop].label or order.shop
            order.customerOnline = sourceByCitizen(order.citizenid) ~= nil
            order.suggestedLabour = math.min(Config.maxLabour, #order.lines * pricesFor(order.shop).labourPerPart)
        end
    end
    return { open = open, recent = recent, maxLabour = Config.maxLabour, cut = Config.mechanicCut, isBoss = isBoss(player) }
end)

-- Mechanic: clock in or out from the tablet.
lib.callback.register('highcrest_mechanic:setDuty', function(source, onDuty)
    local player = getPlayer(source)
    if not hasJob(player) then return false end
    player.Functions.SetJobDuty(onDuty == true)
    notify(source, onDuty and 'You clocked in. Orders will show on your tablet.' or 'You clocked out.', 'success')
    return true
end)

-- Boss: the shop's price list for the tablet's Prices tab.
local function priceSheet(shopId)
    local labels, order = {}, {}
    for _, tab in ipairs(Config.catalogue) do
        for _, item in ipairs(tab.items) do
            if Config.prices.levels[item.key] then
                order[#order + 1] = item.key
                labels[item.key] = item.label
            end
        end
    end
    return {
        shop = shopId, shopLabel = Config.shops[shopId].label,
        prices = pricesFor(shopId), defaults = defaultPrices(),
        levelLabels = labels, levelOrder = order,
        limits = Config.priceLimits, maxLabour = Config.maxLabour,
    }
end

lib.callback.register('highcrest_mechanic:prices', function(source, shopId)
    if not isBoss(getPlayer(source)) then return false end
    shopId = Config.shops[shopId] and shopId or firstShop()
    return priceSheet(shopId)
end)

-- Boss: save the price list (nil resets to the standard prices).
lib.callback.register('highcrest_mechanic:setPrices', function(source, shopId, input)
    local player = getPlayer(source)
    if not isBoss(player) then return false, 'Only the shop boss can change prices.' end
    if not Config.shops[shopId] then return false, 'Unknown shop.' end
    if input == nil then
        shopPrices[shopId] = nil
        MySQL.query.await('DELETE FROM highcrest_mechanic_prices WHERE shop = ?', { shopId })
        return true, 'Prices reset to standard.', priceSheet(shopId)
    end
    local clean, err = cleanPrices(input)
    if not clean then return false, err end
    shopPrices[shopId] = clean
    MySQL.query.await([[
        INSERT INTO highcrest_mechanic_prices (shop, prices, updated_by) VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE prices = VALUES(prices), updated_by = VALUES(updated_by)
    ]], { shopId, json.encode(clean), fullName(player) })
    return true, 'Prices saved. New designs use them right away.', priceSheet(shopId)
end)

-- Mechanic: send the customer a quote (parts + labour).
lib.callback.register('highcrest_mechanic:quote', function(source, id, labour)
    local player = getPlayer(source)
    if not isMechanic(player) then return false, 'You must be an on-duty mechanic.' end
    labour = math.floor(tonumber(labour) or -1)
    if labour < 0 or labour > Config.maxLabour then return false, ('Labour must be between $0 and $%d.'):format(Config.maxLabour) end

    local order = loadOrder(tonumber(id) or 0)
    if not order or not (order.status == 'new' or order.status == 'quoted' or order.status == 'declined') then
        return false, 'This order can no longer be quoted.'
    end

    MySQL.update.await("UPDATE highcrest_mechanic_orders SET labour = ?, mechanic = ?, mechanic_name = ?, status = 'quoted' WHERE id = ?",
        { labour, player.PlayerData.citizenid, fullName(player), order.id })

    local customer = sourceByCitizen(order.citizenid)
    if not customer then return true, 'Quote saved. The customer is not in the city; send it again when they are.' end
    TriggerClientEvent('highcrest_mechanic:client:quote', customer, {
        id = order.id, plate = order.plate, parts = order.parts, labour = labour,
        mechanic = fullName(player), lines = order.changes.lines or {},
    })
    return true, 'Quote sent to the customer.'
end)

-- Customer: approve or decline a quote.
RegisterNetEvent('highcrest_mechanic:server:respond', function(id, accept)
    local src = source
    local player = getPlayer(src)
    local order = loadOrder(tonumber(id) or 0)
    if not player or not order or order.citizenid ~= player.PlayerData.citizenid or order.status ~= 'quoted' then return end

    local mechanic = order.mechanic and sourceByCitizen(order.mechanic)
    if not accept then
        setStatus(order.id, 'declined')
        notify(src, ('You declined the quote for order #%d.'):format(order.id))
        if mechanic then notify(mechanic, ('Order #%d: the customer declined the quote.'):format(order.id), 'error') end
        return
    end

    local total = order.parts + order.labour
    local money = player.Functions.GetMoney('bank') + player.Functions.GetMoney('cash')
    if money < total then
        notify(src, ('You need $%d to approve this quote.'):format(total), 'error')
        return
    end
    setStatus(order.id, 'approved')
    notify(src, ('Quote approved. You will pay $%d when the work is done.'):format(total), 'success')
    if mechanic then notify(mechanic, ('Order #%d approved. Start work at the car.'):format(order.id), 'success') end
end)

-- Mechanic: fit one part in the bay. Each part takes its install time; the server keeps
-- count so a part can't be skipped by a modified client.
lib.callback.register('highcrest_mechanic:fitPart', function(source, id, key, netId, phase)
    local player = getPlayer(source)
    if not isMechanic(player) then return false, 'You must be an on-duty mechanic.' end
    local order = loadOrder(tonumber(id) or 0)
    local progress = order and work[order.id]
    if not order or order.status ~= 'in_progress' or not progress or progress.mechanic ~= player.PlayerData.citizenid then
        return false, 'Drive the car into the bay and press E to work on it.'
    end
    local values = order.changes.values or {}
    if values[key] == nil then return false, 'That part is not on this order.' end
    if not vehicleNear(source, netId, order.plate, 8.0) then return false, 'The car has to be in the bay.' end
    local item = catalogue[key]
    local seconds = (item and item.tab == 'performance') and Config.installSeconds.performance or Config.installSeconds.default

    if phase == 'start' then
        progress.current, progress.readyAt = key, GetGameTimer() + seconds * 1000 - 750
        return true, seconds
    end
    if progress.current ~= key or GetGameTimer() < progress.readyAt then return false, 'Too quick: finish fitting the part.' end
    progress.current = nil
    progress.fitted[key] = true
    return true, Config.toProps(key, values[key])
end)

-- Mechanic: all parts fitted. Charge the customer, pay out, save the mods.
lib.callback.register('highcrest_mechanic:complete', function(source, id, netId)
    local player = getPlayer(source)
    if not isMechanic(player) then return false, 'You must be an on-duty mechanic.' end
    local order = loadOrder(tonumber(id) or 0)
    if not order or not (order.status == 'in_progress' or order.status == 'unpaid') or order.mechanic ~= player.PlayerData.citizenid then
        return false, 'This job is not yours to finish.'
    end
    if busy[order.id] then return false, 'Already finishing.' end
    if not vehicleNear(source, netId, order.plate, 8.0) then return false, 'The car has to be in the bay.' end
    local progress = work[order.id]
    for key in pairs(order.changes.values or {}) do
        if not (progress and progress.mechanic == player.PlayerData.citizenid and progress.fitted[key]) then
            return false, 'Fit every part on the order first.'
        end
    end

    local customerSrc = sourceByCitizen(order.citizenid)
    local customer = customerSrc and getPlayer(customerSrc)
    if not customer then return false, 'The customer must be in the city to pay.' end

    busy[order.id] = true
    local total = order.parts + order.labour
    local paid = false
    if customer.Functions.GetMoney('bank') >= total then
        paid = customer.Functions.RemoveMoney('bank', total, ('Mechanic order #%d'):format(order.id))
    elseif customer.Functions.GetMoney('cash') >= total then
        paid = customer.Functions.RemoveMoney('cash', total, ('Mechanic order #%d'):format(order.id))
    end
    if not paid then
        setStatus(order.id, 'unpaid')
        busy[order.id] = nil
        notify(customerSrc, ('You could not pay $%d for order #%d. The parts stay at the shop.'):format(total, order.id), 'error')
        return false, 'The customer could not pay. The order is marked unpaid.'
    end

    -- Save the new mods onto the car's stored properties.
    local stored = storedVehicle(order.plate)
    local props = stored and json.decode(stored.mods or '{}') or {}
    local applied = {}
    for key, value in pairs(order.changes.values or {}) do
        for prop, v in pairs(Config.toProps(key, value)) do
            props[prop] = v
            applied[prop] = v
        end
    end
    MySQL.update.await('UPDATE player_vehicles SET mods = ? WHERE plate = ?', { json.encode(props), order.plate })
    work[order.id] = nil

    -- Pay out: parts and the shop's labour share to the business, the rest to the mechanic.
    local shop = Config.shops[order.shop]
    local cut = math.floor(order.labour * Config.mechanicCut)
    local shopShare = order.parts + (order.labour - cut)
    local business = shop and shop.business
    if business and GetResourceState('highcrest_empire') == 'started'
        and exports.highcrest_empire:AddBusinessRevenue(business, shopShare, ('Mechanic order #%d (%s)'):format(order.id, order.plate)) then
        player.Functions.AddMoney('bank', cut, ('Mechanic order #%d'):format(order.id))
    else
        -- No business set up yet: the mechanic gets the full labour fee; parts money pays the supplier.
        cut = order.labour
        player.Functions.AddMoney('bank', cut, ('Mechanic order #%d'):format(order.id))
    end

    setStatus(order.id, 'done')
    busy[order.id] = nil
    notify(customerSrc, ('Order #%d is finished. You paid $%d. Enjoy the ride!'):format(order.id, total), 'success')
    return true, applied, cut, total
end)

-- Mechanic or customer: cancel an order that hasn't been finished.
lib.callback.register('highcrest_mechanic:cancel', function(source, id)
    local player = getPlayer(source)
    local order = loadOrder(tonumber(id) or 0)
    if not player or not order or order.status == 'done' or order.status == 'cancelled' then return false end
    if not isMechanic(player) and order.citizenid ~= player.PlayerData.citizenid then return false end
    setStatus(order.id, 'cancelled')
    work[order.id] = nil
    local customer = sourceByCitizen(order.citizenid)
    if customer and customer ~= source then notify(customer, ('Order #%d was cancelled by the shop.'):format(order.id)) end
    return true
end)

AddEventHandler('playerDropped', function() busy[source] = nil end)
