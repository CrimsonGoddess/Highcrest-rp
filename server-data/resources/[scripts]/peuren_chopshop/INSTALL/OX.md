1. Add this to ox_inventory/data/weapons.lua:

	['weapon_digiscanner'] = {
		label = 'Signal booster',
		weight = 600,
		throwable = false,
	},

2. Add these to ox_inventory/data/items.lua:

	['toolbox'] = {
		label = 'Toolbox',
		description = "Usefull for working on vehicles",
		weight = 500,
		stack = true
	},

	['bonnet'] = {
		label = 'Bonnet',
		description = "A bonnet from a vehicle",
		weight = 500,
		stack = true
	},

	['boot'] = {
		label = 'Trunk',
		description = "A trunk from a vehicle",
		weight = 500,
		stack = true
	},

	['door'] = {
		label = 'Door',
		description = "A door from a vehicle",
		weight = 500,
		stack = true
	},

	['engine'] = {
		label = 'Engine',
		description = "A engine from a vehicle",
		weight = 500,
		stack = true
	},

	['wheel'] = {
		label = 'Wheel',
		description = "A wheel from a vehicle",
		weight = 500,
		stack = true
	},