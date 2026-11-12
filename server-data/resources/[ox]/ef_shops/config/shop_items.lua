---@class ShopItem
---@field id? number internal id number, do not set
---@field name? string item name as referenced in ox_inventory
---@field price number base price of the item
---@field defaultStock? integer the amount of items available in the shop by default
---@field category? string the category of the item in the shop (e.g. 'Snacks', 'Tools', 'Firearms', 'Ammunition', 'Drinks')
---@field license? string the license required to purchase the item
---@field jobs? table<string, number> map of group names to min grade required to access the shop
---@field metadata? table | string metadata for item

---@type table<string, table<string | number, ShopItem>>
local ITEMS = {
	normal = {
		burger = { price = 5, defaultStock = 50, category = 'Hot Food' },
		sandwich = { price = 5, defaultStock = 50, category = 'Hot Food' },
		hotdog = { price = 5, defaultStock = 50, category = 'Hot Food' },
		noodles = { price = 5, defaultStock = 50, category = 'Snacks' },
		phatc_rib = { price = 5, defaultStock = 50, category = 'Snacks' },
		phatc_bch = { price = 5, defaultStock = 50, category = 'Snacks' },
		ps_qs = { price = 5, defaultStock = 50, category = 'Snacks' },
		water = { price = 5, defaultStock = 50, category = 'Drinks' },
		milk = { price = 5, defaultStock = 50, category = 'Drinks' },
		sprunk = { price = 5, defaultStock = 50, category = 'Drinks' },
		ecola = { price = 5, defaultStock = 50, category = 'Drinks' },
		orangotang = { price = 5, defaultStock = 50, category = 'Drinks' },
		ejunk = { price = 5, defaultStock = 50, category = 'Drinks' },
		--Smoking Items
		redwoods = { price = 11, defaultStock = 50, category = 'Smoking' },
		vape = { price = 24, defaultStock = 50, category = 'Smoking' },
		cigar = { price = 24, defaultStock = 50, category = 'Smoking' },

		wallet = { price = 20, defaultStock = 50, category = 'Random' },
		bandage = { price = 10, defaultStock = 50, category = 'Random' },
		--backpack = { price = 65, defaultStock = 50, category = 'Random'},

	},
	bar = {
		stronzo_beer = { price = 25, defaultStock = 50, category = 'Single Bottle' },
		patriot_beer =  {price = 40, defaultStock = 50, category = 'Single Bottle' },
		dusche_beer = {price = 3, defaultStock = 50, category = 'Single Bottle' },
		rancho_beer =  {price = 25, defaultStock = 50, category = 'Single Bottle' },
		bb_bourgeoix =  {price = 3, defaultStock = 50, category = 'Boxes' },
		bb_cariaque = {price = 3, defaultStock = 50, category = 'Boxes' },
		cb_bleuterd =  {price = 3, defaultStock = 50, category = 'Boxes' },
		rb_ragga =  {price = 3, defaultStock = 50, category = 'Boxes' },
		tb_tequilya =  {price = 3, defaultStock = 50, category = 'Liquor' },
		vb_nogo = {price = 3, defaultStock = 50, category = 'Liquor' },
		wb_mount =  {price = 3, defaultStock = 50, category = 'Liquor' },
		gin =  {price = 3, defaultStock = 50, category = 'Liquor' },
		brandy =  {price = 3, defaultStock = 50, category = 'Liquor' },
		--champagne =  {price = 3, defaultStock = 50, category = 'Liquor' },
		irish_cream =  {price = 3, defaultStock = 50, category = 'Liquor' },
		absinthe =  {price = 3, defaultStock = 50, category = 'Liquor' },
		cider =  {price = 3, defaultStock = 50, category = 'Liquor' },
		tonic_water = {price = 3, defaultStock = 50, category = 'Liquor' },
		soda_water = {price = 3, defaultStock = 50, category = 'Liquor' },
		simple_syrup =  {price = 3, defaultStock = 50, category = 'Liquor' },
		grenadine =  {price = 3, defaultStock = 50, category = 'Liquor' },
		bitters =  {price = 3, defaultStock = 50, category = 'Liquor' },

	},
	hardware = {
		{ name = 'lockpick', price = 120, defaultStock = 50, category = 'Tools' },
		{ name = 'duct_tape', price = 30, defaultStock = 50, category = 'Tools' },
		{ name = 'cleaning_kit', price = 30, defaultStock = 50, category = 'Tools' },
		{ name = 'drill', price = 500, defaultStock = 50, category = 'Tools' },
		{ name = 'lockpick', price = 10, defaultStock = 50, category = 'Tools'  },
		{ name = 'spray', price = 150, defaultStock = 50, category = 'Tools'  }, -- Highcrest: rcore_spray
		{ name = 'spray_remover', price = 100, defaultStock = 50, category = 'Tools'  },
		{ name = 'toolbox', price = 250, defaultStock = 50, category = 'Tools'  }, -- Highcrest: peuren_chopshop
		}, locations = {
	},
	weapons = {
		{ name = 'WEAPON_KNIFE',      price = 80,   defaultStock = 250,        category = 'Point Defense' },
		{ name = 'WEAPON_BAT',        price = 45,   defaultStock = 250,        category = 'Point Defense' },
		{ name = 'WEAPON_PISTOL',     price = 2450, defaultStock = 5,          license = "weapon",        category = 'Firearms' },
		{ name = 'WEAPON_SNSPISTOL',  price = 1850, defaultStock = 5,          license = "weapon",        category = 'Firearms' },
		{ name = 'WEAPON_PISTOL_MK2',  price = 6050, defaultStock = 5,          license = "weapon",        category = 'Firearms' },
		--{ name = 'WEAPON_509',  price = 6850, defaultStock = 5,          license = "weapon",        category = 'Firearms' },
		--{ name = 'WEAPON_2011',  price = 8600, defaultStock = 5,          license = "weapon",        category = 'Firearms' },
		{ name = 'ammo-9',            price = 2,    defaultStock = 9500,       license = "weapon",        category = 'Ammunition' },
		{ name = 'ammo-45',           price = 3,    defaultStock = 5500,       license = "weapon",        category = 'Ammunition' },
		{ name = 'ammo-38',           price = 1,    defaultStock = 5500,       license = "weapon",        category = 'Ammunition' },
	},
	parts = {

-- Service Items

		{ name = 'mechanic_tablet',      price = 500,   defaultStock = 9500,        category = 'Service' },
        { name = 'engine_oil',      price = 11,   defaultStock = 9500,        category = 'Service' },
		{ name = 'tyre_replacement',        price = 180,   defaultStock = 9500,        category = 'Service' },
		{ name = 'clutch_replacement',     price = 120, defaultStock = 9500,          category = 'Service' },
		{ name = 'air_filter',  price = 30, defaultStock = 9500,          category = 'Service' },
		{ name = 'spark_plug',            price = 20,    defaultStock = 9500,       category = 'Service' },
		{ name = 'brakepad_replacement',           price = 80,    defaultStock = 5500,       category = 'Service' },
		{ name = 'suspension_parts',        price = 1200,   defaultStock = 9500,        category = 'Service' },
		{ name = 'ev_motor',     price = 2000, defaultStock = 9500,          category = 'Service' },
		{ name = 'ev_battery',  price = 1500, defaultStock = 9500,          category = 'Service' },
		{ name = 'ev_coolant',            price = 14,    defaultStock = 9500,       category = 'Service' },

--Tuning Items

		{ name = 'awd_drivetrain',           price = 4500,    defaultStock = 5500,       category = 'Tuning' },
		{ name = 'rwd_drivetrain',        price = 3900,   defaultStock = 9500,        category = 'Tuning' },
		{ name = 'fwd_drivetrain',     price = 1700, defaultStock = 9500,          category = 'Tuning' },
		{ name = 'slick_tyres',  price = 900, defaultStock = 9500,          category = 'Tuning' },
		{ name = 'offroad_tyres',            price = 700,    defaultStock = 9500,       category = 'Tuning' },
		{ name = 'drift_tuning_kit',           price = 400,    defaultStock = 5500,       category = 'Tuning' },
		{ name = 'ceramic_brakes',        price = 400,   defaultStock = 9500,        category = 'Tuning' },
		{ name = 'stancing_kit',     price = 500, defaultStock = 9500,          category = 'Tuning' },
		{ name = 'manual_gearbox',     price = 1000, defaultStock = 9500,          category = 'Tuning' },
        { name = 'performance_part',     price = 150, defaultStock = 9500,          category = 'Tuning' },

--Cosmetic Items

		{ name = 'lighting_controller',  price = 100, defaultStock = 9500,          category = 'Cosmetic' },
		{ name = 'cosmetic_part',            price = 25,    defaultStock = 9500,       category = 'Cosmetic' },
		{ name = 'respray_kit',           price = 85,    defaultStock = 5500,       category = 'Cosmetic' },
		{ name = 'vehicle_wheels',        price = 100,   defaultStock = 9500,        category = 'Cosmetic' },
		{ name = 'extras_kit',     price = 100, defaultStock = 9500,          category = 'Cosmetic' },
		{ name = 'repair_kit',  price = 15, defaultStock = 9500,          category = 'Cosmetic' },
	},
	electronics = {
		{ name = 'phone', price = 850 },
		{ name = 'radio', price = 240 },
		--{ name = 'truckingtablet', price = 1000 },
	},
}

local newFormatItems = {}
for category, categoryItems in pairs(ITEMS) do
	local newCategoryItems = {}

	for item, data in pairs(categoryItems) do
		if not data.name then
			data.name = tostring(item)
		end

		newCategoryItems[#newCategoryItems + 1] = data
	end

	table.sort(newCategoryItems, function(a, b)
		return a.name < b.name
	end)

	newFormatItems[category] = newCategoryItems
end

return newFormatItems
