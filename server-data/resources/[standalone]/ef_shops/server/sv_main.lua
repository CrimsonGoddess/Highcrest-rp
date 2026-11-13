lib.versionCheck('jellyton69/ef-shops')
if not lib.checkDependency('qbx_core', '1.6.0') then error() end
if not lib.checkDependency('ox_lib', '3.0.0') then error() end
if not lib.checkDependency('ox_inventory', '2.20.0') then error() end

local config = require 'config.config'
local TriggerEventHooks = require '@qbx_core.modules.hooks'

local ox_inventory = exports.ox_inventory
local ITEMS = ox_inventory:Items()

local PRODUCTS = require 'config.shop_items' ---@type table<string, table<string, ShopItem>>
local LOCATIONS = require 'config.locations' ---@type type<string, ShopLocation>

ShopData = {}

---@class ShopData
---@field name string
---@field location string
---@field inventory OxItem[]
---@field groups table

---@param shopType string
---@param shopData table
local function registerShop(shopType, shopData)
	ShopData[shopType] = {}

	if shopData.coords then
		for locationId, locationData in pairs(shopData.coords) do
			local shop = {
				name = shopData.name,
				location = locationId,
				inventory = lib.table.deepclone(shopData.inventory),
				groups = shopData.groups,
				coords = locationData
			}

			ShopData[shopType][locationId] = shop
		end
	else
		local shop = {
			name = shopData.name,
			inventory = lib.table.deepclone(shopData.inventory),
			groups = shopData.groups
		}

		ShopData[shopType][1] = shop
	end
end

-- Builds one shop's stock from its product list. Calling it again restocks the shop (prices re-roll too).
---@param shopID string
local function buildShop(shopID)
	local shopData = LOCATIONS[shopID]

	if not shopData.shopItems or not PRODUCTS[shopData.shopItems] then
		lib.print.error("A valid product ID (" .. tostring(shopData.shopItems) .. ") for [" .. shopID .. "] was not found.")
		return
	end

	local shopProducts = {}
	for item, data in pairs(PRODUCTS[shopData.shopItems]) do
		shopProducts[#shopProducts + 1] = {
			id = tonumber(item),
			name = data.name,
			price = config.fluctuatePrices and (math.round(data.price * (math.random(80, 120) / 100))) or data.price or 0, -- Price fluctuation algorithm from ox_inventory https://github.com/overextended/ox_inventory/blob/e3a6b905a1b8bdbd3066d012522cf5993466d166/modules/shops/server.lua#L32
			license = data.license,
			metadata = data.metadata,
			count = data.defaultStock,
			jobs = data.jobs
		}
	end

	table.sort(shopProducts, function(a, b)
		return a.name < b.name
	end)

	registerShop(shopID, {
		name = shopData.Label,
		inventory = shopProducts,
		groups = shopData.groups,
		coords = shopData.coords
	})
end

lib.callback.register("EF-Shops:Server:OpenShop", function(source, shop_type, location)
	local shop = ShopData[shop_type][location]
	return shop.inventory
end)

local mapBySubfield = function(tbl, subfield)
	local mapped = {}
	for i = 1, #tbl do
		local item = tbl[i]
		mapped[item[subfield]] = item
	end
	return mapped
end

lib.callback.register("EF-Shops:Server:PurchaseItems", function(source, purchaseData)
	if not purchaseData then
		lib.print.warn(GetPlayerName(source) .. " may be attempting to exploit EF-Shops:Server:PurchaseItems.")
		return false
	end

	if not purchaseData.shop then
		lib.print.warn(GetPlayerName(source) .. " may be attempting to exploit EF-Shops:Server:PurchaseItems.")
		lib.print.warn(purchaseData)
		return false
	end

	local player = exports.qbx_core:GetPlayer(source)
	local shop = ShopData[purchaseData.shop.id][purchaseData.shop.location]
	local shopType = purchaseData.shop.id

	if not shop then
		lib.print.error("Invalid shop: " .. purchaseData.shop.id .. " called by: " .. GetPlayerName(source))
		return false
	end

	local shopData = LOCATIONS[purchaseData.shop.id]

	if shopData.jobs then
		if not shopData.jobs[player.PlayerData.job.name] then
			lib.print.error("Invalid job: " .. player.PlayerData.job.name .. " for shop: " .. purchaseData.shop.id .. " called by: " .. GetPlayerName(source))
			return
		end

		if shopData.jobs[player.PlayerData.job.name] > player.PlayerData.job.grade.level then
			lib.print.error("Invalid job grade: " .. player.PlayerData.job.grade.level .. " for shop: " .. purchaseData.shop.id .. " called by: " .. GetPlayerName(source))
			return
		end
	end

	local currency = purchaseData.currency
	local mappedCartItems = mapBySubfield(purchaseData.items, "id")
	local validCartItems = {} ---@type OxItem[]

	local totalPrice = 0
	for i = 1, #shop.inventory do
		local shopItem = shop.inventory[i]
		local itemData = ITEMS[shopItem.name]
		local mappedCartItem = mappedCartItems[shopItem.id]

		if mappedCartItem then
			if shopItem.license and player.PlayerData.metadata.licences[shopItem.license] ~= true then
				TriggerClientEvent('ox_lib:notify', source, { title = "You do not have the license to purchase this item (" .. shopItem.license .. ").", type = "error" })
				goto continue
			end

			if not exports.ox_inventory:CanCarryItem(source, shopItem.name, mappedCartItem.quantity) then
				TriggerClientEvent('ox_lib:notify', source, { title = "You cannot carry the requested quantity of " .. itemData.label .. "s.", type = "error" })
				goto continue
			end

			if shopItem.count and (mappedCartItem.quantity > shopItem.count) then
				TriggerClientEvent('ox_lib:notify', source, { title = "The requested amount of " .. itemData.label .. " is no longer in stock.", type = "error" })
				goto continue
			end

			if shopItem.jobs then
				if not shopItem.jobs[player.PlayerData.job.name] then
					TriggerClientEvent('ox_lib:notify', source, { title = "You do not have the required job to purchase " .. itemData.label .. ".", type = "error" })
					goto continue
				end
				if shopItem.jobs[player.PlayerData.job.name] > player.PlayerData.job.grade.level then
					TriggerClientEvent('ox_lib:notify', source, { title = "You do not have the required grade to purchase " .. itemData.label .. ".", type = "error" })
					goto continue
				end
			end

			local newIndex = #validCartItems + 1
			validCartItems[newIndex] = mappedCartItem
			validCartItems[newIndex].inventoryIndex = i

			totalPrice = totalPrice + (shopItem.price * mappedCartItem.quantity)
		end

		:: continue ::
	end

	local itemStrings = {}
	local itemMetadata = {}
	for i = 1, #validCartItems do
		local item = validCartItems[i]
		local itemData = ITEMS[item.name]
		itemStrings[#itemStrings + 1] = item.quantity .. "x " .. itemData.label
		itemMetadata[item.name] = item.quantity
	end
	local purchaseReason = table.concat(itemStrings, "; ")

	if currency == "cash" then
		if not player.Functions.RemoveMoney("cash", totalPrice, shopData.label .. ": " .. purchaseReason, { type = "purchase:goods", subtype = "convenience", shop = purchaseData.shop.id, items = itemMetadata }) and totalPrice > 0 then
			TriggerClientEvent('ox_lib:notify', source, { title = "You do not have enough cash for this transaction.", type = "error" })
			return false
		end
	else
		if not player.Functions.RemoveMoney("bank", totalPrice, shopData.label .. ": " .. purchaseReason, { type = "purchase:goods", subtype = "convenience", shop = purchaseData.shop.id, items = itemMetadata }) and totalPrice > 0 then
			TriggerClientEvent('ox_lib:notify', source, { title = "You do not have enough money in the bank for this transaction.", type = "error" })
			return false
		end
	end

	local dropItems = {}
	for i = 1, #validCartItems do
		local item = validCartItems[i]
		local itemData = ITEMS[item.name]
		local productData = PRODUCTS[shopData.shopItems][item.id]

		if not itemData then
			lib.print.error("Invalid item: " .. item.name .. " in shop: " .. shopType)
			goto continue
		end

		if not productData then
			lib.print.error("Invalid product: " .. item.name .. " in shop: " .. shopType)
			goto continue
		end

		local hookResponse = TriggerEventHooks('buyItem', {
			source = source,
			shopId = purchaseData.shop.id,
			shopLocation = purchaseData.shop.location,
			item = itemData,
			product = productData,
			currency = currency,
		})

		if hookResponse == false then
			goto continue
		end

		local success, response = ox_inventory:AddItem(source, item.name, item.quantity, productData.metadata)
		if success then
			if shop.inventory[item.inventoryIndex].count then
				shop.inventory[item.inventoryIndex].count = shop.inventory[item.inventoryIndex].count - item.quantity
			end

			TriggerEventHooks('itemPurchased', {
				source = source,
				shopId = purchaseData.shop.id,
				shopLocation = purchaseData.shop.location,
				items = response,
				product = shop.inventory[item.inventoryIndex],
				currency = currency,
			})
		else
			local itemPrice = item.quantity * shop.inventory[item.inventoryIndex].price
			if currency == "cash" then
				player.Functions.AddMoney("cash", itemPrice, "REFUND: " .. shopData.label .. ": " .. purchaseReason, { type = "refund", subtype = "convenience", shop = purchaseData.shop.id })
			else
				player.Functions.AddMoney("bank", itemPrice, "REFUND: " .. shopData.label .. ": " .. purchaseReason, { type = "refund", subtype = "convenience", shop = purchaseData.shop.id })
			end
		end

		:: continue ::
	end

	if #dropItems > 0 then
		exports.ox_inventory:CustomDrop('Shop Drop', dropItems, GetEntityCoords(GetPlayerPed(source)), #dropItems, 10000, GetPlayerRoutingBucket(source), `prop_cs_shopping_bag`)
	end

	return true
end)

-- Custom shops (see ef_shops_admin). Saved definitions are kept here so new clients can be sent them.
local CustomDefs = {}

local function syncClients()
	TriggerClientEvent('EF-Shops:Client:SyncCustom', -1, CustomDefs)
end

lib.callback.register('EF-Shops:Server:GetCustom', function()
	return CustomDefs
end)

-- Replaces every custom shop with this list.
exports('SetCustomShops', function(defs)
	EF_ClearCustomShops(LOCATIONS, PRODUCTS)
	for id in pairs(ShopData) do
		if EF_IsCustomShop(id) then ShopData[id] = nil end
	end

	CustomDefs = {}
	for _, def in ipairs(defs or {}) do
		CustomDefs[def.id] = def
		EF_ApplyCustomShop(def, LOCATIONS, PRODUCTS)
		buildShop(def.id)
	end
	syncClients()
end)

-- Adds or replaces one custom shop. Its stock is rebuilt (restocked).
exports('UpsertCustomShop', function(def)
	CustomDefs[def.id] = def
	EF_ApplyCustomShop(def, LOCATIONS, PRODUCTS)
	buildShop(def.id)
	syncClients()
end)

exports('RemoveCustomShop', function(id)
	CustomDefs[id], LOCATIONS[id], PRODUCTS[id], ShopData[id] = nil, nil, nil, nil
	syncClients()
end)

-- Restocks one shop (config or custom). Returns false if the shop does not exist.
exports('RestockShop', function(id)
	if not LOCATIONS[id] then return false end
	buildShop(id)
	return true
end)

-- Config shops, read-only, so the admin panel can copy them.
exports('GetConfigShops', function()
	local list = {}
	for id, loc in pairs(LOCATIONS) do
		if not EF_IsCustomShop(id) then
			local coords = {}
			for i, c in ipairs(loc.coords or {}) do
				coords[i] = { x = c.x, y = c.y, z = c.z, w = c.w }
			end
			list[#list + 1] = {
				id = id,
				label = loc.label,
				model = loc.model,
				coords = coords,
				blip = loc.blip,
				jobs = loc.jobs,
				target = loc.target,
				products = PRODUCTS[loc.shopItems] or {},
			}
		end
	end
	table.sort(list, function(a, b) return a.id < b.id end)
	return list
end)

AddEventHandler('onResourceStart', function(resource)
	if GetCurrentResourceName() ~= resource and "ox_inventory" ~= resource then return end

	for productType, productData in pairs(PRODUCTS) do
		for _, item in pairs(productData) do
			if not ITEMS[(string.find(item.name, "weapon_") and (item.name):upper()) or item.name] then
				lib.print.error("Invalid Item: ", item, "in product table:", productType, "^7")
				productData[item] = nil
			end
		end
	end

	for shopID in pairs(LOCATIONS) do
		buildShop(shopID)
	end
end)
