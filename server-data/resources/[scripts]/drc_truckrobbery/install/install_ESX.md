ESX INSTALL QUIDE

ANTICHEAT {
    EXPLOSION USED 
    
    ID - 31
    NAME  -	EXP_TAG_TANKER

}


If u use ox_inventory please open install_OX.md and close this file!
1. Download all dependencies!
    Dependencies:
    ox_lib | https://github.com/overextended/ox_lib/releases/latest
    es_extended / qb-core
    qtarget / qb-target -- optional
    ox_inventory / qb-inventory
	xsound (with emulator for interact sound) or interactsound

ITEMS

2. Add Item to your server
    Use this insert in your database or use esx_items.sql!

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('c4', 'C4', 1, 0, 1),
('diamond', 'Diamond', 1, 0, 1),
('gold', 'Gold', 1, 0, 1);



3. Add Images to your inventory
    if your are using esx_inventory then 
    esx_inventoryhud > html > images
    Paste images from folder images to esx_inventoryhud > html > images

4. add ensure drc_truckrobbery into your server.cfg (make sure to start it after ox_lib and your target system!)

5. Enjoy your new Truck Robbery script from DRC SCRIPTS!
