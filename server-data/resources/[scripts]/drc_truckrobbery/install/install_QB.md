QBCORE INSTALL QUIDE

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
    qb-inventory > html > images
    Paste images from folder images to qb-inventory > html > images 

3. Add Items to your inventory and jobs
    qb-core > shared.lua

["c4"] = {
    ["name"] = "c4",
    ["label"] = "C4",
    ["weight"] = 150,
    ["type"] = "item",
    ["image"] = "c4.png",
    ["unique"] = false,
    ["useable"] = false,
    ["shouldClose"] = false,
    ["combinable"] = nil,
    ["description"] = ""
},

["diamond"] = {
    ["name"] = "diamond",
    ["label"] = "Diamond",
    ["weight"] = 150,
    ["type"] = "item",
    ["image"] = "diamond.png",
    ["unique"] = false,
    ["useable"] = false,
    ["shouldClose"] = false,
    ["combinable"] = nil,
    ["description"] = ""
},
["gold"] = {
    ["name"] = "gold",
    ["label"] = "Gold",
    ["weight"] = 150,
    ["type"] = "item",
    ["image"] = "gold.png",
    ["unique"] = false,
    ["useable"] = false,
    ["shouldClose"] = false,
    ["combinable"] = nil,
    ["description"] = ""
},


4. add ensure drc_truckrobbery into your server.cfg (make sure to start it after ox_lib and your target system!)

5. Enjoy your new Truck Robbery script from DRC SCRIPTS!