return {
	-- Highcrest: mechanic workbench at Highcrest Motorworks (LS Customs Vinewood counter).
	-- Only the mechanic job can use it. Kits are made from metal scrap (recycling job, scrapyard).
	{
		name = 'mechanic_bench',
		groups = { mechanic = 0 },
		items = {
			{
				name = 'repairkit',
				ingredients = { metalscrap = 3 },
				duration = 6000,
				count = 1,
			},
			{
				name = 'advancedrepairkit',
				ingredients = { metalscrap = 6 },
				duration = 10000,
				count = 1,
			},
			{
				name = 'tirekit',
				ingredients = { metalscrap = 2 },
				duration = 4000,
				count = 1,
			},
			{
				name = 'car_paint',
				ingredients = { plastic = 1, metalscrap = 1 },
				duration = 3000,
				count = 2,
			},
			{
				name = 'cleaningkit',
				ingredients = { metalscrap = 1 },
				duration = 2000,
				count = 2,
			},
		},
		points = {
			vec3(-319.89, -119.89, 39.8),
		},
		zones = {
			{
				-- RFC LSC workbench (user's /vec4 feet height + bench top)
				coords = vec3(-319.89, -119.89, 39.8),
				size = vec3(2.0, 1.2, 1.2),
				distance = 1.5,
				rotation = 348.0,
				groups = { mechanic = 0 },
			},
		},
	},
}
