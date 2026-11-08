OX INSTALL QUIDE

ANTICHEAT {
    EXPLOSION USED 
    
    ID - 31
    NAME  -	EXP_TAG_TANKER

}

1. Download all dependencies!
    Dependencies:
    ox_lib | https://github.com/overextended/ox_lib/releases/latest
    es_extended / qb-core
    qtarget / qb-target
    ox_inventory / qb-inventory
	xsound (with emulator for interact sound) or interactsound

2. Add Images to your inventory
	ox_inventory > web > build > images
	Paste images from folder images to ox_inventory > web > build > img

3. Add Items to your inventory
	ox_inventory > data> items.lua

	['c4'] = {
		label = 'C4',
		weight = 10,
		stack = true,
		close = true,
	},
	['diamond'] = {
		label = 'Diamond',
		weight = 100,
		stack = true,
		close = true,
	},
	['gold'] = {
		label = 'Gold',
		weight = 100,
		stack = true,
		close = true,
	},


4. add ensure drc_truckrobbery into your server.cfg (make sure to start it after ox_lib and your target system!)

5. Enjoy your new Truck Robbery script from DRC SCRIPTS!
