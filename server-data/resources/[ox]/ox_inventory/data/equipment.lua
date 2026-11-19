-- Equipment slots shown beside the body in the inventory, and backpack storage.
-- Edit this file only; everything else reads from it. Restart ox_inventory after changes.

return {
	-- Order = slot order. Each slot is added after the normal player slots (inventory:slots convar).
	-- `items` lists which item names may sit in the slot.
	-- Removing or reordering slots later moves/loses whatever players have equipped, so add new ones at the end.
	slots = {
		{ name = 'phone', label = 'Phone', side = 'left', items = { 'phone' } },
		-- every backpack listed below is allowed here automatically
		{ name = 'backpack', label = 'Backpack', side = 'right', items = {} },
	},

	-- Backpacks: item name = storage. The item must also exist in data/items.lua.
	-- Add a backpack: one line here + the item in items.lua.
	backpacks = {
		backpack = { slots = 15, maxWeight = 20000 },
		-- duffelbag = { slots = 25, maxWeight = 40000 },
		-- hikingbag = { slots = 20, maxWeight = 30000, blacklist = { 'weapon_rpg' } },
	},
}
