CreateThread(function()
	local shells = {
		{
			nameTier = `rtx_shell_my_shell`,
			offset = vector4(1.700000, 0.900000, 0.470000, 180.00),
			label = 'My shell',
			inventory = { weight = 500000, slots = 40 }
		},
	}

	insertInteriors(shells)
end)
