ESX INSTALL QUIDE

If u use ox_inventory please open install_OX.md and close this file!
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

ITEMS 

2. Add Item to your server
    Use this insert in your database or use esx_items.sql!

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('powder', 'Bag with powder', 1, 0, 1),
('hack_laptop', 'Hacking Laptop', 1, 0, 1),
('television', 'TV', 1, 0, 1),
('skull', 'Skull Art with diamonds', 1, 0, 1),
('watch', 'Watch', 1, 0, 1),
('toothpaste', 'Toothpaste', 1, 0, 1),
('soap', 'Soap', 1, 0, 1),
('shampoo', 'Shampoo', 1, 0, 1),
('romantic_book', 'Romantic book', 1, 0, 1),
('pencil', 'Pencil', 1, 0, 1),
('notepad', 'Notepad', 1, 0, 1),
('necklace', 'Necklace', 1, 0, 1),
('house_locator', 'House locator', 1, 0, 1),
('gold_watch', 'Gold watch', 1, 0, 1),
('gold_bracelet', 'Gold bracelet', 1, 0, 1),
('earings', 'Earings', 1, 0, 1),
('book', 'Book', 1, 0, 1),
('bracelet', 'Bracelet', 1, 0, 1),
('pogo', 'Art Piece', 1, 0, 1),
('toiletry', 'Toiletry', 1, 0, 1),
('sculpture', 'Sculpture', 1, 0, 1),
('hairdryer', 'Hairdryer', 1, 0, 1),
('j_phone', 'Phone', 1, 0, 1),
('coffemachine', 'Tape Player', 1, 0, 1),
('tapeplayer', 'Coffe machine', 1, 0, 1),
('bong', 'Bong', 1, 0, 1),
('boombox', 'Boombox', 1, 0, 1),
('console', 'Console', 1, 0, 1),
('dj_deck', 'DJ Deck', 1, 0, 1),
('shoebox', 'Shoe box', 1, 0, 1),
('fan', 'Fan', 1, 0, 1),
('radio_alarm', 'Radio', 1, 0, 1),
('flat_television', 'Flat TV', 1, 0, 1),
('monitor', 'Monitor', 1, 0, 1),
('npc_phone', 'Phone', 1, 0, 1),
('printer', 'Printer', 1, 0, 1),
('laptop', 'Laptop', 1, 0, 1),
('loot_bag', 'Duffle bag', 1, 0, 1),
('lockpick', 'Lockpick', 1, 0, 1);


3. Add Images to your inventory
    if your are using esx_inventory then 
    esx_inventoryhud > html > images
    Paste images from folder images to esx_inventoryhud > html > images

4. add ensure drc_houserobbery into your server.cfg (make sure to start it after ox_lib and your target system!)

5. Enjoy your new houserobbery script from DRC SCRIPTS!
