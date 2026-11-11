return {
	-- Highcrest: mechanic workbench at Highcrest Motorworks (LS Customs Vinewood counter).
	-- Only the mechanic job can use it. Materials come from the recycling job and the scrapyard.
	{
		name = 'mechanic_bench',
		groups = { mechanic = 0 },
		items = {
			{
				name = 'repairkit',
				ingredients = { steel = 3, metalscrap = 4, plastic = 2 },
				duration = 6000,
				count = 1,
			},
			{
				name = 'advancedrepairkit',
				ingredients = { steel = 6, aluminum = 4, copper = 3, plastic = 3, rubber = 2 },
				duration = 10000,
				count = 1,
			},
			{
				name = 'tirekit',
				ingredients = { rubber = 4, metalscrap = 1 },
				duration = 4000,
				count = 1,
			},
			{
				name = 'cleaningkit',
				ingredients = { plastic = 1 },
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
