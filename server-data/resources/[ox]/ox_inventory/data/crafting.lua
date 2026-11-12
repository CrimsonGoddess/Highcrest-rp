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
			vec3(-345.374969, -130.687088, 39.009613),
		},
		zones = {
			{
				coords = vec3(-346.1, -130.45, 39.0),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 70.0,
				groups = { mechanic = 0 },
			},
		},
	},
}
