-- Highcrest mechanic orders. Customers design a build at a shop; mechanics quote labour on
-- their tablet, the customer approves, the mechanic fits the parts and the customer is charged.
-- Everything a client sends is checked here: changes against the catalogue, prices from the
-- config, ownership, job, duty and distance.

local catalogue = {}
for _, tab in ipairs(Config.catalogue) do
    for _, item in ipairs(tab.items) do catalogue[item.key] = item end
end

local colorSet, listSets, neonSet = {}, {}, {}
for _, c in ipairs(Config.colors) do colorSet[c[1]] = c[2] end
for name, list in pairs(Config.lists) do
    listSets[name] = {}
    for _, entry in ipairs(list) do listSets[name][entry[1]] = entry[2] end
end
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

local function partPrice(item, value)
    if item.kind == 'level' then
        local levels = Config.prices.levels[item.key]
        return levels[value + 2] or levels[#levels]
    end
    if item.key == 'modTurbo' then return value and Config.prices.turbo or 0 end
    if item.kind == 'toggle' and value == false then return 0 end
    if item.kind == 'color' then return Config.prices.color end
    return Config.prices.cosmetic
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

    local stored = storedVehicle(plate)
    if not stored or stored.citizenid ~= player.PlayerData.citizenid then
        return false, 'You can only order work on a car you own.'
    end
    local open = openOrderFor(plate)
    if open then
        return false, ('This car already has order #%d (%s). A mechanic will be with you.'):format(open.id, open.status)
    end
    return true
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
    local lines, clean, parts = {}, {}, 0
    for key, value in pairs(changes) do
        value = normalise(value)
        local item = catalogue[key]
        if item and validValue(item, value) and not sameValue(current[key], value) then
            clean[key] = value
            local price = partPrice(item, value)
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

-- Mechanic: order list for the tablet.
lib.callback.register('highcrest_mechanic:orders', function(source)
    if not isMechanic(getPlayer(source)) then return false end
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
        end
    end
    return { open = open, recent = recent, maxLabour = Config.maxLabour, cut = Config.mechanicCut }
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

-- Mechanic: start fitting the parts (must be at the car).
lib.callback.register('highcrest_mechanic:startWork', function(source, id, netId)
    local player = getPlayer(source)
    if not isMechanic(player) then return false, 'You must be an on-duty mechanic.' end
    local order = loadOrder(tonumber(id) or 0)
    if not order or not (order.status == 'approved' or order.status == 'in_progress' or order.status == 'unpaid') then
        return false, 'This order is not approved yet.'
    end
    if not vehicleNear(source, netId, order.plate, 8.0) then return false, ('Stand next to the car (%s).'):format(order.plate) end

    MySQL.update.await("UPDATE highcrest_mechanic_orders SET status = 'in_progress', mechanic = ?, mechanic_name = ? WHERE id = ?",
        { player.PlayerData.citizenid, fullName(player), order.id })
    return true, order.changes.lines or {}
end)

-- Mechanic: all parts fitted. Charge the customer, pay out, save the mods.
lib.callback.register('highcrest_mechanic:complete', function(source, id, netId)
    local player = getPlayer(source)
    if not isMechanic(player) then return false, 'You must be an on-duty mechanic.' end
    local order = loadOrder(tonumber(id) or 0)
    if not order or order.status ~= 'in_progress' or order.mechanic ~= player.PlayerData.citizenid then
        return false, 'This job is not yours to finish.'
    end
    if busy[order.id] then return false, 'Already finishing.' end
    if not vehicleNear(source, netId, order.plate, 8.0) then return false, 'Stand next to the car.' end

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
    for key, value in pairs(order.changes.values or {}) do props[key] = value end
    MySQL.update.await('UPDATE player_vehicles SET mods = ? WHERE plate = ?', { json.encode(props), order.plate })

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
    return true, order.changes.values or {}, cut
end)

-- Mechanic or customer: cancel an order that hasn't been finished.
lib.callback.register('highcrest_mechanic:cancel', function(source, id)
    local player = getPlayer(source)
    local order = loadOrder(tonumber(id) or 0)
    if not player or not order or order.status == 'done' or order.status == 'cancelled' then return false end
    if not isMechanic(player) and order.citizenid ~= player.PlayerData.citizenid then return false end
    setStatus(order.id, 'cancelled')
    local customer = sourceByCitizen(order.citizenid)
    if customer and customer ~= source then notify(customer, ('Order #%d was cancelled by the shop.'):format(order.id)) end
    return true
end)

AddEventHandler('playerDropped', function() busy[source] = nil end)
