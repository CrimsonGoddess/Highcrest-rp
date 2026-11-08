QBCORE INSTALL QUIDE

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
    qb-inventory > html > images
    Paste images from folder images to qb-inventory > html > images 

3. Add Items to your inventory
    qb-core > shared.lua
    ["powder"] 		 	 	 	 = {["name"] = "powder",           			["label"] = "Bag with powder",	 		["weight"] = 50, 		["type"] = "item", 		["image"] = "powder.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = "Good for discovering lasers that are not visible"},
    ["watch"] 		 	 	 	 = {["name"] = "watch",           			["label"] = "Watch",	 		["weight"] = 35, 		["type"] = "item", 		["image"] = "watch.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["toothpaste"] 		 	 	 	 = {["name"] = "toothpaste",           			["label"] = "Toothpaste",	 		["weight"] = 15, 		["type"] = "item", 		["image"] = "toothpaste.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["soap"] 		 	 	 	 = {["name"] = "soap",           			["label"] = "Soap",	 		["weight"] = 25, 		["type"] = "item", 		["image"] = "soap.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["shampoo"] 		 	 	 	 = {["name"] = "shampoo",           			["label"] = "Shampoo",	 		["weight"] = 25, 		["type"] = "item", 		["image"] = "shampoo.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["romantic_book"] 		 	 	 	 = {["name"] = "romantic_book",           			["label"] = "Romantic book",	 		["weight"] = 25, 		["type"] = "item", 		["image"] = "romantic_book.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["pencil"] 		 	 	 	 = {["name"] = "pencil",           			["label"] = "Pencil",	 		["weight"] = 25, 		["type"] = "item", 		["image"] = "pencil.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["notepad"] 		 	 	 	 = {["name"] = "notepad",           			["label"] = "Notepad",	 		["weight"] = 5, 		["type"] = "item", 		["image"] = "notepad.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["necklace"] 		 	 	 	 = {["name"] = "necklace",           			["label"] = "Necklace",	 		["weight"] = 55, 		["type"] = "item", 		["image"] = "necklace.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["house_locator"] 		 	 	 	 = {["name"] = "house_locator",           			["label"] = "House locator",	 		["weight"] = 55, 		["type"] = "item", 		["image"] = "house_locator.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["gold_watch"] 		 	 	 	 = {["name"] = "gold_watch",           			["label"] = "Gold watch",	 		["weight"] = 55, 		["type"] = "item", 		["image"] = "gold_watch.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["gold_bracelet"] 		 	 	 	 = {["name"] = "gold_bracelet",           			["label"] = "Gold bracelet",	 		["weight"] = 45, 		["type"] = "item", 		["image"] = "gold_bracelet.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["earings"] 		 	 	 	 = {["name"] = "earings",           			["label"] = "Earings",	 		["weight"] = 25, 		["type"] = "item", 		["image"] = "earings.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["book"] 		 	 	 	 = {["name"] = "book",           			["label"] = "Book",	 		["weight"] = 25, 		["type"] = "item", 		["image"] = "book.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["bracelet"] 		 	 	 	 = {["name"] = "bracelet",           			["label"] = "Bracelet",	 		["weight"] = 25, 		["type"] = "item", 		["image"] = "bracelet.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["sculpture"] 		 	 	 	 = {["name"] = "sculpture",           			["label"] = "Sculpture",	 		["weight"] = 55, 		["type"] = "item", 		["image"] = "sculpture.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["j_phone"] 		 	 	 	 = {["name"] = "j_phone",           			["label"] = "Phone",	 		["weight"] = 55, 		["type"] = "item", 		["image"] = "j_phone.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["hairdryer"] 		 	 	 	 = {["name"] = "hairdryer",           			["label"] = "Hairdryer",	 		["weight"] = 55, 		["type"] = "item", 		["image"] = "hairdryer.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["tapeplayer"] 		 	 	 	 = {["name"] = "tapeplayer",           			["label"] = "Tape Player",	 		["weight"] = 55, 		["type"] = "item", 		["image"] = "tapeplayer.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["coffemachine"] 		 	 	 	 = {["name"] = "coffemachine",           			["label"] = "Coffe machine",	 		["weight"] = 55, 		["type"] = "item", 		["image"] = "coffemachine.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["bong"] 		 	 	 	 = {["name"] = "bong",           			["label"] = "Bong",	 		["weight"] = 25, 		["type"] = "item", 		["image"] = "bong.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["boombox"] 		 	 	 	 = {["name"] = "boombox",           			["label"] = "Boombox",	 		["weight"] = 85, 		["type"] = "item", 		["image"] = "boombox.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["console"] 		 	 	 	 = {["name"] = "console",           			["label"] = "Console",	 		["weight"] = 85, 		["type"] = "item", 		["image"] = "console.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["dj_deck"] 		 	 	 	 = {["name"] = "dj_deck",           			["label"] = "DJ Deck",	 		["weight"] = 95, 		["type"] = "item", 		["image"] = "dj_deck.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["shoebox"] 		 	 	 	 = {["name"] = "shoebox",           			["label"] = "Shoe box",	 		["weight"] = 45, 		["type"] = "item", 		["image"] = "shoebox.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["fan"] 		 	 	 	 = {["name"] = "fan",           			["label"] = "Fan",	 		["weight"] = 20, 		["type"] = "item", 		["image"] = "fan.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["radio_alarm"] 		 	 	 	 = {["name"] = "radio_alarm",           			["label"] = "Radio",	 		["weight"] = 30, 		["type"] = "item", 		["image"] = "radio_alarm.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["flat_television"] 		 	 	 	 = {["name"] = "flat_television",           			["label"] = "Flat TV",	 		["weight"] = 155, 		["type"] = "item", 		["image"] = "flat_television.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["television"] 		 	 	 	 = {["name"] = "television",           			["label"] = "TV",	 		["weight"] = 155, 		["type"] = "item", 		["image"] = "television.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["monitor"] 		 	 	 	 = {["name"] = "monitor",           			["label"] = "Monitor",	 		["weight"] = 50, 		["type"] = "item", 		["image"] = "monitor.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["npc_phone"] 		 	 	 	 = {["name"] = "npc_phone",           			["label"] = "Phone",	 		["weight"] = 10, 		["type"] = "item", 		["image"] = "npc_phone.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["printer"] 		 	 	 	 = {["name"] = "printer",           			["label"] = "Printer",	 		["weight"] = 190, 		["type"] = "item", 		["image"] = "printer.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["laptop"] 		 	 	 	 = {["name"] = "laptop",           			["label"] = "Laptop",	 		["weight"] = 100, 		["type"] = "item", 		["image"] = "laptop.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["loot_bag"] 		 	 	 	 = {["name"] = "loot_bag",           			["label"] = "Duffle bag",	 		["weight"] = 50, 		["type"] = "item", 		["image"] = "loot_bag.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["hack_laptop"] 		 	 	 	 = {["name"] = "hack_laptop",           			["label"] = "Hacking Laptop",	 		["weight"] = 20, 		["type"] = "item", 		["image"] = "hack_laptop.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["toiletry"] 		 	 	 	 = {["name"] = "toiletry",           			["label"] = "Toiletry",	 		["weight"] = 10, 		["type"] = "item", 		["image"] = "toiletry.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["lockpick"] 		 	 	 	 = {["name"] = "lockpick",           			["label"] = "Lockpick",	 		["weight"] = 165, 		["type"] = "item", 		["image"] = "lockpick.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = "Can lockpick any doors if you have enough skill!"},
    ["skull"] 		 	 	 	 = {["name"] = "skull",           			["label"] = "Skull Art with diamonds",	 		["weight"] = 95, 		["type"] = "item", 		["image"] = "skull.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = ""},
    ["pogo"] 		 	 	 	 = {["name"] = "pogo",           			["label"] = "Art Piece",	 		["weight"] = 155, 		["type"] = "item", 		["image"] = "pogo.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = "Pogo Statue"},
    ["pogo"] 		 	 	 	 = {["name"] = "pogo",           			["label"] = "Art Piece",	 		["weight"] = 155, 		["type"] = "item", 		["image"] = "pogo.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil, ["description"] = "Pogo Statue"},


4. add ensure drc_houserobbery into your server.cfg (make sure to start it after ox_lib and your target system!)

5. Enjoy your new houserobbery script from DRC SCRIPTS!