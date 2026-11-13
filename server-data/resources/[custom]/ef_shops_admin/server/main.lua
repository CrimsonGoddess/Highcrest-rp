-- ef_shops_admin server: saved custom shops, admin checks, audit log, and the bridge into ef_shops.
-- Saved shops live in ef_shops_custom (highcrest_sql/sql/019). ef_shops never reads the table itself;
-- this resource pushes the enabled shops into it through its exports.

local ACE = 'admin' -- same ACE the other Highcrest admin tools use

local Cache = {} -- id -> saved shop definition (enabled and disabled)

local function allowed(src)
	return IsPlayerAceAllowed(src, ACE)
end

local function actorOf(src)
	return GetPlayerName(src) or 'console'
end

local function efRunning()
	return GetResourceState('ef_shops') == 'started'
end

-- Config-style model: digits are already a hash, names are hashed.
local function modelHash(name)
	return tonumber(name) or GetHashKey(name)
end

local function toEfShops(def)
	local model
	if def.models then
		model = {}
		for i, name in ipairs(def.models) do
			model[i] = modelHash(name)
		end
	end

	return {
		id = def.id,
		label = def.label,
		model = model,
		coords = def.coords,
		blip = def.blip,
		target = def.target,
		jobs = def.jobs,
		products = def.products,
	}
end

local function pushOne(id)
	if not efRunning() then return end
	local def = Cache[id]
	if def and def.enabled then
		exports.ef_shops:UpsertCustomShop(toEfShops(def))
	else
		exports.ef_shops:RemoveCustomShop(id)
	end
end

local function pushAll()
	if not efRunning() then return end
	local list = {}
	for _, def in pairs(Cache) do
		if def.enabled then list[#list + 1] = toEfShops(def) end
	end
	exports.ef_shops:SetCustomShops(list)
end

local function log(actor, action, shopId, detail)
	MySQL.insert.await('INSERT INTO ef_shops_admin_log (actor, action, shop_id, detail) VALUES (?, ?, ?, ?)',
		{ actor, action, shopId, detail and tostring(detail):sub(1, 500) })
end

local function loadCache()
	local rows = MySQL.query.await('SELECT id, data FROM ef_shops_custom')
	if not rows then error('ef_shops_custom could not be read') end

	Cache = {}
	for _, row in ipairs(rows) do
		local def = json.decode(row.data)
		if def then Cache[row.id] = def end -- saved only after validation, so no re-check here
	end
end

local function itemCatalog()
	local list = {}
	for name, item in pairs(exports.ox_inventory:Items()) do
		list[#list + 1] = {
			name = name,
			label = item.label or name,
			weight = item.weight,
			image = (item.client and item.client.image) or ('nui://ox_inventory/web/images/' .. name .. '.png'),
		}
	end
	table.sort(list, function(a, b) return a.label < b.label end)
	return list
end

local function shopList()
	local list = {}
	for _, def in pairs(Cache) do list[#list + 1] = def end
	table.sort(list, function(a, b) return a.label < b.label end)
	return list
end

local Actions = {}

-- Everything the panel needs to start.
Actions.bootstrap = function(src)
	local config = {}
	if efRunning() then
		local ok, list = pcall(function() return exports.ef_shops:GetConfigShops() end)
		if ok and list then config = list end
	end

	return {
		shops = shopList(),
		config = config,
		items = itemCatalog(),
		actor = actorOf(src),
		efRunning = efRunning(),
	}
end

Actions.save = function(src, data)
	local def, err = ShopValidate(data.shop, exports.ox_inventory:Items())
	if not def then return nil, err end

	local existing = Cache[def.id]
	if data.isNew and existing then return nil, 'That ID is already in use. Pick another.' end
	if not data.isNew and not existing then return nil, 'That shop was deleted. Reload the panel.' end

	local actor = actorOf(src)
	MySQL.query.await(
		'INSERT INTO ef_shops_custom (id, data, updated_by) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data), updated_by = VALUES(updated_by)',
		{ def.id, json.encode(def), actor })

	Cache[def.id] = def
	pushOne(def.id)
	log(actor, data.isNew and 'create' or 'update', def.id, def.label)
	return def
end

Actions.delete = function(src, data)
	local def = Cache[data.id]
	if not def then return nil, 'Shop not found.' end

	MySQL.query.await('DELETE FROM ef_shops_custom WHERE id = ?', { data.id })
	Cache[data.id] = nil
	pushOne(data.id)
	log(actorOf(src), 'delete', data.id, def.label)
	return true
end

Actions.restock = function(src, data)
	local def = Cache[data.id]
	if not def or not def.enabled then return nil, 'Enable the shop before restocking it.' end
	if not efRunning() then return nil, 'ef_shops is not running.' end

	exports.ef_shops:RestockShop(data.id)
	log(actorOf(src), 'restock', data.id)
	return true
end

-- Where the admin stands, for "add location from my position".
Actions.position = function(src)
	local ped = GetPlayerPed(src)
	local c = GetEntityCoords(ped)
	return { x = c.x, y = c.y, z = c.z, w = GetEntityHeading(ped) }
end

Actions.teleport = function(src, data)
	local x, y, z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
	if not (x and y and z) then return nil, 'Bad coordinates.' end

	SetEntityCoords(GetPlayerPed(src), x, y, z, false, false, false, false)
	return true
end

Actions.log = function()
	return MySQL.query.await('SELECT actor, action, shop_id, detail, created_at FROM ef_shops_admin_log ORDER BY id DESC LIMIT 100')
end

lib.callback.register('ef_shops_admin:canOpen', function(src)
	return allowed(src)
end)

lib.callback.register('ef_shops_admin:call', function(src, action, data)
	if not allowed(src) then return { ok = false, error = 'You do not have permission to manage shops.' } end

	local fn = Actions[action]
	if not fn then return { ok = false, error = 'Unknown action.' } end

	local ok, result, err = pcall(fn, src, type(data) == 'table' and data or {})
	if not ok then
		lib.print.error(('ef_shops_admin: action %s failed: %s'):format(action, tostring(result)))
		return { ok = false, error = 'Server error. See the server console.' }
	end
	if result == nil then return { ok = false, error = err or 'Request failed.' } end

	return { ok = true, data = result }
end)

-- highcrest_sql creates the tables. It may finish after this resource starts, so retry until it has.
CreateThread(function()
	while not pcall(loadCache) do
		Wait(2000)
	end
	pushAll()
end)

-- ef_shops was restarted and forgot the custom shops, so send them again.
AddEventHandler('onResourceStart', function(resource)
	if resource == 'ef_shops' then pushAll() end
end)
