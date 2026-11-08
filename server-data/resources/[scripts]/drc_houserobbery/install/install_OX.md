OX INSTALL QUIDE

1. Download all dependencies!
    Dependencies:
    ox_lib | https://github.com/overextended/ox_lib
    es_extended / qb-core
    qtarget / qb-target / ox_target
    lockpick | https://github.com/baguscodestudio/lockpick
	howdy-hackminigame | https://github.com/HiHowdy/howdy-hackminigame
	pd-safe |	https://github.com/VHall1/pd-safe
	mka-lasers | https://github.com/mkafrin/mka-lasers
	xsound (with emulator for interact sound) or interactsound

2. Add Images to your inventory
	ox_inventory > web > build > images
	Paste images from folder images to ox_inventory > web > build > img

3. Add Items to your inventory
	ox_inventory > data> items.lua

	['hack_laptop'] = {
		label = 'Hacking Laptop',
		description = "",
		weight = 20,
		stack = true
	},

	['loot_bag'] = {
		label = 'Duffle bag',
		description = "",
		weight = 50,
		stack = true
	},

	['laptop'] = {
		label = 'Laptop',
		description = "",
		weight = 100,
		stack = true
	},

	['printer'] = {
		label = 'Printer',
		description = "",
		weight = 190,
		stack = true
	},

	['npc_phone'] = {
		label = 'Phone',
		description = "",
		weight = 10,
		stack = true
	},

	['monitor'] = {
		label = 'Monitor',
		description = "",
		weight = 50,
		stack = true
	},

	['television'] = {
		label = 'TV',
		description = "",
		weight = 155,
		stack = true
	},

	['flat_television'] = {
		label = 'Flat TV',
		description = "",
		weight = 155,
		stack = true
	},

	['radio_alarm'] = {
		label = 'Radio',
		description = "",
		weight = 30,
		stack = true
	},

	['fan'] = {
		label = 'Fan',
		description = "",
		weight = 20,
		stack = true
	},

	['lockpick'] = {
		label = 'Lockpick',
		description = "Can lockpick any doors if you have enough skill!",
		weight = 165,
		stack = true
	},

	['shoebox'] = {
		label = 'Shoe box',
		description = "",
		weight = 45,
		stack = true
	},

	['dj_deck'] = {
		label = 'DJ Deck',
		description = "",
		weight = 95,
		stack = true
	},

	['console'] = {
		label = 'Console',
		description = "",
		weight = 55,
		stack = true
	},

	['boombox'] = {
		label = 'Boombox',
		description = "",
		weight = 85,
		stack = true
	},

	['bong'] = {
		label = 'Bong',
		description = "",
		weight = 25,
		stack = true
	},

	['coffemachine'] = {
		label = 'Coffe machine',
		description = "",
		weight = 55,
		stack = true
	},

	['tapeplayer'] = {
		label = 'Tape Player',
		description = "",
		weight = 55,
		stack = true
	},

	['hairdryer'] = {
		label = 'Hairdryer',
		description = "",
		weight = 55,
		stack = true
	},

	['j_phone'] = {
		label = 'Phone',
		description = "",
		weight = 55,
		stack = true
	},

	['sculpture'] = {
		label = 'Sculpture',
		description = "",
		weight = 55,
		stack = true
	},

	['toiletry'] = {
		label = 'Toiletry',
		description = "",
		weight = 10,
		stack = true
	},

	['pogo'] = {
		label = 'Art Piece',
		description = "Pogo Statue",
		weight = 155,
		stack = true
	},

	['powder'] = {
		label = 'Bag with powder',
		description = "Good for discovering lasers that are not visible",
		weight = 50,
		stack = true
	},

	['bracelet'] = {
		label = 'Bracelet',
		description = "",
		weight = 25,
		stack = true
	},

	['book'] = {
		label = 'Book',
		description = "",
		weight = 25,
		stack = true
	},

	['earings'] = {
		label = 'Earings',
		description = "",
		weight = 25,
		stack = true
	},

	['gold_bracelet'] = {
		label = 'Gold bracelet',
		description = "",
		weight = 45,
		stack = true
	},

	['gold_watch'] = {
		label = 'Gold watch',
		weight = 55,
		stack = true
	},

	['house_locator'] = {
		label = 'House locator',
		weight = 55,
		stack = true
	},

	['necklace'] = {
		label = 'Necklace',
		weight = 55,
		stack = true
	},

	['notepad'] = {
		label = 'Notepad',
		weight = 5,
		stack = true
	},

	['pencil'] = {
		label = 'Pencil',
		weight = 25,
		stack = true
	},

	['romantic_book'] = {
		label = 'Romantic book',
		weight = 25,
		stack = true
	},

	['shampoo'] = {
		label = 'Shampoo',
		weight = 25,
		stack = true
	},

	['soap'] = {
		label = 'Soap',
		weight = 25,
		stack = true
	},

	['toothpaste'] = {
		label = 'Toothpaste',
		weight = 15,
		stack = true
	},

	['watch'] = {
		label = 'Watch',
		weight = 35,
		stack = true
	},
		
	['skull'] = {
		label = 'Skull Art with diamonds',
		weight = 95,
		stack = true
	},

4. add ensure drc_houserobbery into your server.cfg (make sure to start it after ox_lib and your target system!)

5. Enjoy your new houserobbery script from DRC SCRIPTS!