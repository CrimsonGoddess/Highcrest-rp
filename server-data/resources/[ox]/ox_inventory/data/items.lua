return {
    ['testburger'] = {
        label = 'Test Burger',
        weight = 220,
        degrade = 60,
        client = {
            image = 'burger_chicken.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            export = 'ox_inventory_examples.testburger'
        },
        server = {
            export = 'ox_inventory_examples.testburger',
            test = 'what an amazingly delicious burger, amirite?'
        },
        buttons = {
            {
                label = 'Lick it',
                action = function(slot)
                    print('You licked the burger')
                end
            },
            {
                label = 'Squeeze it',
                action = function(slot)
                    print('You squeezed the burger :(')
                end
            },
            {
                label = 'What do you call a vegan burger?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('A misteak.')
                end
            },
            {
                label = 'What do frogs like to eat with their hamburgers?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('French flies.')
                end
            },
            {
                label = 'Why were the burger and fries running?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('Because they\'re fast food.')
                end
            }
        },
        consume = 0.3
    },

    ['bandage'] = {
        label = 'Bandage',
        weight = 115,
    },



    ['diving_gear'] = {
        label = 'Diving Gear',
        weight = 30000,
    },

    ['diving_fill'] = {
        label = 'Diving Tube',
        weight = 3000,
    },

    ['antipatharia_coral'] = {
        label = 'Antipatharia',
        weight = 1000,
    },

    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        weight = 1000,
    },

    ['jerry_can'] = {
        label = 'Jerrycan',
        weight = 3000,
    },

    ['nitrous'] = {
        label = 'Nitrous',
        weight = 1000,
    },

    ['wine'] = {
        label = 'Wine',
        weight = 500,
    },

    ['grape'] = {
        label = 'Grape',
        weight = 10,
    },

    ['grapejuice'] = {
        label = 'Grape Juice',
        weight = 200,
    },

    ['coffee'] = {
        label = 'Coffee',
        weight = 200,
    },

    ['vodka'] = {
        label = 'Vodka',
        weight = 500,
    },

    ['whiskey'] = {
        label = 'Whiskey',
        weight = 200,
    },

    ['beer'] = {
        label = 'Beer',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Walking Stick',
        weight = 1000,
    },


    ['binoculars'] = {
        label = 'Binoculars',
        weight = 800,
    },

    ['stickynote'] = {
        label = 'Sticky Note',
        weight = 0,
    },

    ['empty_evidence_bag'] = {
        label = 'Empty Evidence Bag',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Filled Evidence Bag',
        weight = 200,
    },

    ['harness'] = {
        label = 'Harness',
        weight = 200,
    },

    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 200,
    },

    ['c4'] = {
        label = 'C4',
        weight = 500,
        stack = true,
        close = true,
    },

    ['gold'] = {
        label = 'Gold Bar',
        weight = 1000,
        stack = true,
        close = true,
    },

    ['ems'] = {
        label = 'EMS Tablet',
        weight = 500,
        stack = false,
        close = true,
        consume = 0,
        client = { event = 'redutzu-ems:client:openEMS', image = 'redutzu_ems.png' },
        description = 'Medical records and dispatch for EMS',
    },

    -- drc_moneywash: dirty money goes unmarked, then wet, then dry, then clean.
    ['unmarked_money'] = {
        label = 'Unmarked Dirty Money',
        weight = 0,
        stack = true,
        close = true,
    },

    ['wet_money'] = {
        label = 'Wet Money',
        weight = 0,
        stack = true,
        close = true,
    },

    ['dry_money'] = {
        label = 'Dry Money',
        weight = 0,
        stack = true,
        close = true,
    },

    ['warehouse_locator'] = {
        label = 'Warehouse Locator',
        weight = 100,
        stack = true,
        close = true,
    },

    ['hack_laptop'] = {
        label = 'Hacking Laptop',
        weight = 2000,
        stack = true,
        close = true,
    },

    -- drc_houserobbery: tools and stolen goods
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

    -- peuren_chopshop: car parts and tools
    ['bonnet'] = { label = 'Car Bonnet', weight = 8000, stack = true, close = true },
    ['boot'] = { label = 'Car Trunk Lid', weight = 8000, stack = true, close = true },
    ['door'] = { label = 'Car Door', weight = 10000, stack = true, close = true },
    ['engine'] = { label = 'Car Engine', weight = 25000, stack = true, close = true },
    ['wheel'] = { label = 'Car Wheel', weight = 6000, stack = true, close = true },
    ['toolbox'] = { label = 'Toolbox', weight = 2000, stack = true, close = true, description = 'For taking cars apart.' },
    ['mechanic_tablet'] = { label = 'Mechanic Tablet', weight = 500, stack = false, close = true, description = 'Work orders for Highcrest Motorworks.', client = { image = 'tablet.png', export = 'highcrest_mechanic.openTablet' } }, -- Highcrest

    -- peuren_gruppe6: Gruppe Sechs cash runs
    ['money_bag'] = { label = 'Money Bag', weight = 250, stack = true, close = true, description = 'Gruppe Sechs money bag.' },

    -- sd-beekeeping
    ['bee-hive'] = { label = 'Bee Hive', weight = 1000, stack = true, close = true, server = { export = 'sd-beekeeping.useBee-hive' } }, -- Highcrest: placed by sd-beekeeping
    ['bee-house'] = { label = 'Bee House', weight = 1000, stack = true, close = true, server = { export = 'sd-beekeeping.useBee-house' } }, -- Highcrest: placed by sd-beekeeping
    ['bee-queen'] = { label = 'Bee Queen', weight = 100, stack = true, close = true },
    ['bee-worker'] = { label = 'Worker Bee', weight = 100, stack = true, close = true },
    ['bee-smoker'] = { label = 'Bee Smoker', weight = 1000, stack = true, close = true },
    ['thymol'] = { label = 'Thymol', weight = 500, stack = true, close = true },
    ['bee-wax'] = { label = 'Bee Wax', weight = 500, stack = true, close = true },
    ['bee-honey'] = { label = 'Bee Honey', weight = 1000, stack = true, close = true },
    ['chiliad-honey'] = { label = 'Chiliad Honey', weight = 1000, stack = true, close = true },
    ['green-hills-honey'] = { label = 'Green Hills Honey', weight = 1000, stack = true, close = true },
    ['alamo-honey'] = { label = 'Alamo Honey', weight = 1000, stack = true, close = true },

    -- lation_detecting: metal detecting
    ['blue_metaldetector'] = {
    label = 'Beginner\'s Beacon',
    weight = 475
    },

    ['green_metaldetector'] = {
    label = 'Lustrous Locator',
    weight = 475
    },

    ['red_metaldetector'] = {
    label = 'Treasure Trove Tracker',
    weight = 475
    },

    ['orange_metaldetector'] = {
    label = 'Goldseeker\'s Grail',
    weight = 475
    },

    ['black_metaldetector'] = {
    label = 'Archaeo Ace',
    weight = 475
    },

    ['md_shovel'] = {
    label = 'Shovel',
    weight = 55
    },

    ['md_bottlecap'] = {
    label = 'Bottle Cap',
    weight = 25
    },

    ['md_brokenjunk'] = {
    label = 'Broken Junk',
    weight = 25
    },

    ['md_crushedcan'] = {
    label = 'Crushed Can',
    weight = 25
    },

    ['md_lighter'] = {
    label = 'Lighter',
    weight = 25
    },

    ['md_metalcan'] = {
    label = 'Metal Can',
    weight = 25
    },

    ['md_nails'] = {
    label = 'Nails',
    weight = 25
    },

    ['md_needle'] = {
    label = 'Needle',
    weight = 25
    },

    ['md_nickle'] = {
    label = 'Nickle',
    weight = 25
    },

    ['md_nut'] = {
    label = 'Nut',
    weight = 25
    },

    ['md_oldshotgunshell'] = {
    label = 'Old Shotgun Shell',
    weight = 25
    },

    ['md_paperclip'] = {
    label = 'Paper Clip',
    weight = 25
    },

    ['md_pulltab'] = {
    label = 'Pull Tab',
    weight = 25
    },

    ['md_quarter'] = {
    label = 'Quarter',
    weight = 25
    },

    ['md_rustyball'] = {
    label = 'Rusty Ball',
    weight = 25
    },

    ['md_rustyironball'] = {
    label = 'Rusty Iron Ball',
    weight = 25
    },

    ['md_rustyjunk'] = {
    label = 'Rusty Junk',
    weight = 25
    },

    ['md_rustynails'] = {
    label = 'Rusty Nails',
    weight = 25
    },

    ['md_rustypliers'] = {
    label = 'Rusty Pliers',
    weight = 25
    },

    ['md_rustyring'] = {
    label = 'Rusty Ring',
    weight = 25
    },

    ['md_rustyscissors'] = {
    label = 'Rusty Scissors',
    weight = 25
    },

    ['md_rustyscrewdriver'] = {
    label = 'Rusty Screwdriver',
    weight = 25
    },

    ['md_rustyspring'] = {
    label = 'Rusty Spring',
    weight = 25
    },

    ['md_screw'] = {
    label = 'Screw',
    weight = 25
    },

    ['md_wheatpenny'] = {
    label = 'Wheat Penny',
    weight = 25
    },

    ['md_ancientcoin'] = {
    label = 'Ancient Coin',
    weight = 25
    },

    ['md_blackwatch'] = {
    label = 'Watch',
    weight = 25
    },

    ['md_coppernugget'] = {
    label = 'Copper Nugget',
    weight = 25
    },

    ['md_diamondearings'] = {
    label = 'Diamond Earings',
    weight = 25
    },

    ['md_diamondnecklace'] = {
    label = 'Diamond Necklace',
    weight = 25
    },

    ['md_diamondring'] = {
    label = 'Diamond Ring',
    weight = 25
    },

    ['md_earpod'] = {
    label = 'Ear Pod',
    weight = 25
    },

    ['md_golddollar'] = {
    label = 'Gold Dollar',
    weight = 25
    },

    ['md_goldearings'] = {
    label = 'Gold Earings',
    weight = 25
    },

    ['md_goldnecklace'] = {
    label = 'Gold Necklace',
    weight = 25
    },

    ['md_goldnugget'] = {
    label = 'Gold Nugget',
    weight = 25
    },

    ['md_goldounce'] = {
    label = '1oz Gold Bar',
    weight = 25
    },

    ['md_goldring'] = {
    label = 'Gold Ring',
    weight = 25
    },

    ['md_halfdollar'] = {
    label = 'Half Dollar',
    weight = 25
    },

    ['md_ironnugget'] = {
    label = 'Iron Nugget',
    weight = 25
    },

    ['md_platinumnugget'] = {
    label = 'Platinum Nugget',
    weight = 25
    },

    ['md_presidentialwatch'] = {
    label = 'Presidential Watch',
    weight = 25
    },

    ['md_relicrevolver'] = {
    label = 'Relic Revolver',
    weight = 25
    },

    ['md_silverdime'] = {
    label = 'Silver Dime',
    weight = 25
    },

    ['md_silverearings'] = {
    label = 'Silver Earings',
    weight = 25
    },

    ['md_silverounce'] = {
    label = '1oz Silver Bar',
    weight = 25
    },

    ['md_silverring'] = {
    label = 'Silver Ring',
    weight = 25
    },

    -- pickle_hunting
['hunting_horn'] = {
    label = 'Hunting Horn',
    weight = 1,
    stack = true,
    description = "Shows the nearest animals to you on the map."
},    

['animal_hide_1'] = {
    label = 'Animal Hide G1',
    weight = 100,
    stack = true,
    description = ""
},    

['animal_hide_2'] = {
    label = 'Animal Hide G2',
    weight = 100,
    stack = true,
    description = ""
},    

['animal_hide_3'] = {
    label = 'Animal Hide G3',
    weight = 100,
    stack = true,
    description = ""
},    

['animal_meat_1'] = {
    label = 'Animal Meat G1',
    weight = 1000,
    stack = true,
    description = ""
},    

['animal_meat_2'] = {
    label = 'Animal Meat G2',
    weight = 1000,
    stack = true,
    description = ""
},    

['animal_meat_3'] = {
    label = 'Animal Meat G3',
    weight = 1000,
    stack = true,
    description = ""
},    

    -- rcore_spray: graffiti
    ['spray'] = { label = 'Spray Paint', weight = 500, stack = true, close = true, description = 'Paint graffiti on walls.', server = { export = 'rcore_spray.spray' } },
    ['spray_remover'] = { label = 'Spray Remover', weight = 500, stack = true, close = true, description = 'Cleans graffiti off walls.', server = { export = 'rcore_spray.spray_remover' } },

    -- pug-cokebusiness
    ['cokelabnote'] = { label = 'Lab Note', weight = 100, stack = false, close = true, description = 'A note with some information on it...' },
    ["poster"] = { 
    label = "Poster",
    weight = 360, 
    description = 'Blank poster for you to put your artwork on' 
    },

    ['garbage'] = {
        label = 'Garbage',
    },

    ['paperbag'] = {
        label = 'Paper Bag',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['truckingtablet'] = {
    label = 'Trucking tablet',
    weight = 0,
    description = "There is an app on that",
    client = {
	export = 'kub_trucking.truckingtablet',
        }
    },

            --FUNNY ITEMS
    ['panties'] = {
        label = 'Panties',
        description = "Tag says 'property of egirl' ",
        weight = 10,
        consume = 0,
        client = {
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },


--------------------------------------------------
--BackPacks And Business Related Items
--------------------------------------------------

['backpack'] = {
        label = 'Standard Backpack',
        description = 'This holds your shit!',
        weight = 3000,
        client = {
        disable = { move = true, car = true, combat = true },    
        }
},








--------------------------------------------------
    ['phone'] = {
        label = 'Phone',
        description = "The newest edition of the LB Phone",
        weight = 190,
        stack = false,
        consume = 0,
    },

    ['mustard'] = {
        label = 'Mustard',
        weight = 500,
        client = {
            status = { hunger = 25000, thirst = 25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
            usetime = 2500,
            notification = 'You... drank mustard'
        }
    },

    ['armour'] = {
        label = 'Bulletproof Vest',
        weight = 3000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Clothing',
        consume = 0,
    },

    ['id_card'] = {
        label = 'Identification Card',
    },

    ['driver_license'] = {
        label = 'Drivers License',
    },

    ['weaponlicense'] = {
        label = 'Weapon License',
    },

    ['lawyerpass'] = {
        label = 'Lawyer Pass',
    },

    ['radio'] = {
        label = 'Radio',
        weight = 1000,
        allowArmed = true,
        consume = 0,
        client = {
            event = 'mm_radio:client:use'
        }
    },

    ['jammer'] = {
        label = 'Radio Jammer',
        weight = 10000,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'AAA Cells',
        weight = 1000,
        stack = true,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 500,
        durability = 10,
        stack = false
    },

    ['screwdriverset'] = {
        label = 'Screwdriver Set',
        weight = 500,
    },

    ['electronickit'] = {
        label = 'Electronic Kit',
        weight = 500,
    },

    ['cleaningkit'] = {
        label = 'Cleaning Kit',
        weight = 500,
    },

    ['repairkit'] = {
        label = 'Repair Kit',
        stack = false,
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repair Kit',
        weight = 4000,
    },

    ['diamond_ring'] = {
        label = 'Diamond',
        weight = 1500,
    },

    ['rolex'] = {
        label = 'Golden Watch',
        weight = 1500,
    },

    ['goldbar'] = {
        label = 'Gold Bar',
        weight = 1500,
    },

    ['goldchain'] = {
        label = 'Golden Chain',
        weight = 1500,
    },

    ['lighter'] = {
        label = 'Lighter',
        weight = 300,
    },

    ['crack_baggy'] = {
        label = 'Crack Baggy',
        weight = 100,
    },

    ['cokebaggy'] = {
        label = 'Bag of Coke',
        weight = 100,
    },

    ['coke_small_brick'] = {
        label = 'Coke Package',
        weight = 1000,
    },

    ['xtcbaggy'] = {
        label = 'Bag of Ecstasy',
        weight = 100,
    },

    ['oxy'] = {
        label = 'Oxycodone',
        weight = 100,
    },

    ['weed_ak47'] = {
        label = 'AK47 2g',
        weight = 200,
    },

    ['weed_ak47_seed'] = {
        label = 'AK47 Seed',
        weight = 1,
    },

    ['weed_skunk'] = {
        label = 'Skunk 2g',
        weight = 200,
    },

    ['weed_skunk_seed'] = {
        label = 'Skunk Seed',
        weight = 1,
    },

    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        weight = 200,
    },

    ['weed_amnesia_seed'] = {
        label = 'Amnesia Seed',
        weight = 1,
    },

    ['weed_og-kush'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_og-kush_seed'] = {
        label = 'OGKush Seed',
        weight = 1,
    },

    ['weed_white-widow'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_white-widow_seed'] = {
        label = 'White Widow Seed',
        weight = 1,
    },

    ['weed_purple-haze'] = {
        label = 'Purple Haze 2g',
        weight = 200,
    },

    ['weed_purple-haze_seed'] = {
        label = 'Purple Haze Seed',
        weight = 1,
    },

    ['weed_brick'] = {
        label = 'Weed Brick',
        weight = 2000,
    },

    ['weed_nutrition'] = {
        label = 'Plant Fertilizer',
        weight = 2000,
    },

    ['joint'] = {
        label = 'Joint',
        weight = 200,
    },

    ['rolling_paper'] = {
        label = 'Rolling Paper',
        weight = 0,
    },

    ['empty_weed_bag'] = {
        label = 'Empty Weed Bag',
        weight = 0,
    },

    ['firstaid'] = {
        label = 'First Aid',
        weight = 2500,
    },

    ['ifaks'] = {
        label = 'Individual First Aid Kit',
        weight = 2500,
    },

    ['painkillers'] = {
        label = 'Painkillers',
        weight = 400,
    },

    ['firework1'] = {
        label = '2Brothers',
        weight = 1000,
    },

    ['firework2'] = {
        label = 'Poppelers',
        weight = 1000,
    },

    ['firework3'] = {
        label = 'WipeOut',
        weight = 1000,
    },

    ['firework4'] = {
        label = 'Weeping Willow',
        weight = 1000,
    },

    ['steel'] = {
        label = 'Steel',
        weight = 100,
    },

    ['rubber'] = {
        label = 'Rubber',
        weight = 100,
    },

    ['metalscrap'] = {
        label = 'Metal Scrap',
        weight = 100,
    },

    ['iron'] = {
        label = 'Iron',
        weight = 100,
    },

    ['copper'] = {
        label = 'Copper',
        weight = 100,
    },

    ['aluminum'] = {
        label = 'Aluminum',
        weight = 100,
    },

    ['plastic'] = {
        label = 'Plastic',
        weight = 100,
    },

    ['glass'] = {
        label = 'Glass',
        weight = 100,
    },

    ['gatecrack'] = {
        label = 'Gatecrack',
        weight = 1000,
    },

    ['cryptostick'] = {
        label = 'Crypto Stick',
        weight = 100,
    },

    ['trojan_usb'] = {
        label = 'Trojan USB',
        weight = 100,
    },

    ['toaster'] = {
        label = 'Toaster',
        weight = 5000,
    },

    ['small_tv'] = {
        label = 'Small TV',
        weight = 100,
    },

    ['security_card_01'] = {
        label = 'Security Card A',
        weight = 100,
    },

    ['security_card_02'] = {
        label = 'Security Card B',
        weight = 100,
    },

    ['drill'] = {
        label = 'Drill',
        description = "My drilla!",
        weight = 5000,
        stack = false
    },

    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
    },

-- Bait
["bread"] = {
    label = "Bread",
    weight = 10,
    stack = true, -- assuming 'unique' is false means it should be stackable
    close = true,
    description = "Bread",
    client = {
        image = "bread.png",
    }
},
 
["earthworm"] = {
    label = "Earthworm",
    weight = 10,
    stack = true,
    close = true,
    description = "Earthworm",
    client = {
        image = "earthworm.png",
    }
},
 
["dough"] = {
    label = "Dough",
    weight = 10,
    stack = true,
    close = true,
    description = "Dough",
    client = {
        image = "dough.png",
    }
},
 
["grub"] = {
    label = "Grub",
    weight = 10,
    stack = true,
    close = true,
    description = "Grub",
    client = {
        image = "grub.png",
    }
},
 
["caddis_fly"] = {
    label = "Caddis Fly",
    weight = 10,
    stack = true,
    close = true,
    description = "Caddis Fly",
    client = {
        image = "caddis_fly.png",
    }
},
 
["cheese"] = {
    label = "Cheese",
    weight = 10,
    stack = true,
    close = true,
    description = "Cheese",
    client = {
        image = "cheese.png",
    }
},
 
["fly"] = {
    label = "Fly",
    weight = 10,
    stack = true,
    close = true,
    description = "Fly",
    client = {
        image = "fly.png",
    }
},
 
["dragonfly"] = {
    label = "Dragonfly",
    weight = 10,
    stack = true,
    close = true,
    description = "Dragonfly",
    client = {
        image = "dragonfly.png",
    }
},
 
["grasshoper"] = {
    label = "Grasshoper",
    weight = 10,
    stack = true,
    close = true,
    description = "Grasshoper",
    client = {
        image = "grasshoper.png",
    }
},
 
["shrimp"] = {
    label = "Shrimp",
    weight = 10,
    stack = true,
    close = true,
    description = "Shrimp",
    client = {
        image = "shrimp.png",
    }
},
 
["leech"] = {
    label = "Leech",
    weight = 10,
    stack = true,
    close = true,
    description = "Leech",
    client = {
        image = "leech.png",
    }
},
 
["snail"] = {
    label = "Snail",
    weight = 10,
    stack = true,
    close = true,
    description = "Snail",
    client = {
        image = "snail.png",
    }
},
 
["liver"] = {
    label = "Liver",
    weight = 10,
    stack = true,
    close = true,
    description = "Liver",
    client = {
        image = "liver.png",
    }
},
-- Lines
["express_fishing_super_line"] = {
    label = "Express Super Line 0.1mm",
    weight = 70,
    stack = true, -- assuming 'unique' is false means it should be stackable
    close = true,
    description = "Express Super Line 0.1mm",
    client = {
        image = "express_fishing_super_line.png",
    }
},
 
["syberia_indiana_green"] = {
    label = "Indiana Green 0.14mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Indiana Green 0.14mm",
    client = {
        image = "syberia_indiana_green.png",
    }
},
 
["syberia_indiana_white"] = {
    label = "Indiana White 0.18mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Indiana White 0.18mm",
    client = {
        image = "syberia_indiana_white.png",
    }
},
 
["simmons_mono_original"] = {
    label = "Simmons Original 0.25mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Simmons Original 0.25mm",
    client = {
        image = "simmons_mono_original.png",
    }
},
 
["simmons_mono_ss"] = {
    label = "Simmons SS 0.28mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Simmons SS 0.28mm",
    client = {
        image = "simmons_mono_ss.png",
    }
},
 
["syberia_indiana_green_2"] = {
    label = "Indiana Green 0.32mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Indiana Green 0.32mm",
    client = {
        image = "syberia_indiana_green_2.png",
    }
},
 
["syberia_indiana_white_2"] = {
    label = "Indiana White 0.36mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Indiana White 0.36mm",
    client = {
        image = "syberia_indiana_white_2.png",
    }
},
 
["snake_power_line_clr"] = {
    label = "Snake Power Line 0.41mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Snake Power Line 0.41mm",
    client = {
        image = "snake_power_line_clr.png",
    }
},
 
["simmons_mono_original_2"] = {
    label = "Simmons Original 0.48mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Simmons Original 0.48mm",
    client = {
        image = "simmons_mono_original_2.png",
    }
},
 
["simmons_mono_ss_2"] = {
    label = "Simmons SS 0.52mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Simmons SS 0.52mm",
    client = {
        image = "simmons_mono_ss_2.png",
    }
},
 
["snake_power_line_clr_2"] = {
    label = "Snake Power Line 0.65mm",
    weight = 70,
    stack = true,
    close = true,
    description = "Snake Power Line 0.65mm",
    client = {
        image = "snake_power_line_clr_2.png",
    }
},
 
["solid_hipower_nylon"] = {
    label = "HiPower Nylon 0.8mm",
    weight = 70,
    stack = true,
    close = true,
    description = "HiPower Nylon 0.8mm",
    client = {
        image = "solid_hipower_nylon.png",
    }
},
 
["solid_hipower_nylon_lime"] = {
    label = "HiPower Nylon L 0.85mm",
    weight = 70,
    stack = true,
    close = true,
    description = "HiPower Nylon L 0.85mm",
    client = {
        image = "solid_hipower_nylon_lime.png",
    }
},
 
["solid_hipower_nylon_orange"] = {
    label = "HiPower Nylon O 0.9mm",
    weight = 70,
    stack = true,
    close = true,
    description = "HiPower Nylon O 0.9mm",
    client = {
        image = "solid_hipower_nylon_orange.png",
    }
},
 
["solid_hipower_nylon_2"] = {
    label = "HiPower Nylon 1.05mm",
    weight = 70,
    stack = true,
    close = true,
    description = "HiPower Nylon 1.05mm",
    client = {
        image = "solid_hipower_nylon_2.png",
    }
},
 
["solid_hipower_nylon_lime_2"] = {
    label = "HiPower Nylon L 1.15mm",
    weight = 70,
    stack = true,
    close = true,
    description = "HiPower Nylon L 1.15mm",
    client = {
        image = "solid_hipower_nylon_lime_2.png",
    }
},
 
["solid_hipower_nylon_orange_2"] = {
    label = "HiPower Nylon O 1.25mm",
    weight = 70,
    stack = true,
    close = true,
    description = "HiPower Nylon O 1.25mm",
    client = {
        image = "solid_hipower_nylon_orange_2.png",
    }
},
-- Rods
["ufe_telerod_370"] = {
    label = "UFE Telerod 370",
    weight = 150,
    stack = false, -- assuming 'unique' is false means it should be stackable
    close = true,
    description = "UFE Telerod 370",
    client = {
        image = "ufe_telerod_370.png",
    }
},
 
["carptack_feeder_master_250"] = {
    label = "Carptack Feeder Master 250",
    weight = 150,
    stack = false,
    close = true,
    description = "Carptack Feeder Master 250",
    client = {
        image = "carptack_feeder_master_250.png",
    }
},
 
["sakura_tsubarea_tsa_552_xul"] = {
    label = "Sakura Tsubarea TSA 552 XUL",
    weight = 150,
    stack = false,
    close = true,
    description = "Sakura Tsubarea TSA 552 XUL",
    client = {
        image = "sakura_tsubarea_tsa_552_xul.png",
    }
},
 
["carpex_hybid_carp_270"] = {
    label = "Carpex Hybid Carp 270",
    weight = 150,
    stack = false,
    close = true,
    description = "Carpex Hybid Carp 270",
    client = {
        image = "carpex_hybid_carp_270.png",
    }
},
 
["ufe_float_x5_300"] = {
    label = "UFE Float X5 300",
    weight = 150,
    stack = false,
    close = true,
    description = "UFE Float X5 300",
    client = {
        image = "ufe_float_x5_300.png",
    }
},
 
["predatek_fast_perch_210"] = {
    label = "Predatek Fast Perch 210",
    weight = 150,
    stack = false,
    close = true,
    description = "Predatek Fast Perch 210",
    client = {
        image = "predatek_fast_perch_210.png",
    }
},
 
["sakura_ionizer_bass_insb_701_ml"] = {
    label = "Sakura Ionizer Bass INSB 701",
    weight = 150,
    stack = false,
    close = true,
    description = "Sakura Ionizer Bass INSB 701",
    client = {
        image = "sakura_ionizer_bass_insb_701_ml.png",
    }
},
 
["sakura_redbird_rds_602_l"] = {
    label = "Sakura Redbird RDS 602 L",
    weight = 150,
    stack = false,
    close = true,
    description = "Sakura Redbird RDS 602 L",
    client = {
        image = "sakura_redbird_rds_602_l.png",
    }
},
 
["carpex_cobalt_carp_360"] = {
    label = "Carpex Cobalt Carp 360",
    weight = 150,
    stack = false,
    close = true,
    description = "Carpex Cobalt Carp 360",
    client = {
        image = "carpex_cobalt_carp_360.png",
    }
},
 
["sakura_salt_sniper_salss_611_mj1"] = {
    label = "Sakura Salt Sniper SALSS 611",
    weight = 150,
    stack = false,
    close = true,
    description = "Sakura Salt Sniper SALSS 611",
    client = {
        image = "sakura_salt_sniper_salss_611_mj1.png",
    }
},
 
["sakura_speciz_spes_light_602_zander"] = {
    label = "Sakura Speciz Spes Light 602",
    weight = 150,
    stack = false,
    close = true,
    description = "Sakura Speciz Spes Light 602",
    client = {
        image = "sakura_speciz_spes_light_602_zander.png",
    }
},
 
["sakura_redbird_rds_662"] = {
    label = "Sakura Redbird RDS 662",
    weight = 150,
    stack = false,
    close = true,
    description = "Sakura Redbird RDS 662",
    client = {
        image = "sakura_redbird_rds_662.png",
    }
},
 
["sakura_salt_sniper_salss_902_h"] = {
    label = "Sakura Salt Sniper SALSS 902",
    weight = 150,
    stack = false,
    close = true,
    description = "Sakura Salt Sniper SALSS 902",
    client = {
        image = "sakura_salt_sniper_salss_902_h.png",
    }
},
 
["predatek_seahunter_230"] = {
    label = "Predatek Seahunter 230",
    weight = 150,
    stack = false,
    close = true,
    description = "Predatek Seahunter 230",
    client = {
        image = "predatek_seahunter_230.png",
    }
},
 
["sakura_shukan_shuc_661_lj"] = {
    label = "Sakura Shukan Shuc 661 LJ",
    weight = 150,
    stack = false,
    close = true,
    description = "Sakura Shukan Shuc 661 LJ",
    client = {
        image = "sakura_shukan_shuc_661_lj.png",
    }
},
 
["ufe_powercatch_270"] = {
    label = "UFE Powercatch 270",
    weight = 150,
    stack = false,
    close = true,
    description = "UFE Powercatch 270",
    client = {
        image = "ufe_powercatch_270.png",
    }
},
 
["predatek_pilk_200"] = {
    label = "Predatek Pilk 200",
    weight = 150,
    stack = false,
    close = true,
    description = "Predatek Pilk 200",
    client = {
        image = "predatek_pilk_200.png",
    }
},
 
["robinson_carbonic_nordic_pilk_300"] = {
    label = "Robinson Carbonic Nordic Pilk",
    weight = 150,
    stack = false,
    close = true,
    description = "Robinson Carbonic Nordic Pilk",
    client = {
        image = "robinson_carbonic_nordic_pilk_300.png",
    }
},
 
["carptack_bottom_cast_360"] = {
    label = "Carptack Bottom Cast 360",
    weight = 150,
    stack = false,
    close = true,
    description = "Carptack Bottom Cast 360",
    client = {
        image = "carptack_bottom_cast_360.png",
    }
},
 
["seax_salfighter_170"] = {
    label = "Seax Salfighter 170",
    weight = 150,
    stack = false,
    close = true,
    description = "Seax Salfighter 170",
    client = {
        image = "seax_salfighter_170.png",
    }
},
-- Reels
["ufe_canta_1000"] = {
    label = "UFE Canta 1000",
    weight = 100,
    stack = false,
    close = true,
    description = "UFE Canta 1000",
    client = {
        image = "ufe_canta_1000.png",
    }
},
 
["ufe_barracuda_2000bt"] = {
    label = "UFE Barracuda 2000BT",
    weight = 100,
    stack = false,
    close = true,
    description = "UFE Barracuda 2000BT",
    client = {
        image = "ufe_barracuda_2000bt.png",
    }
},
 
["sakura_alpax_4508"] = {
    label = "Sakura Alpax 4508",
    weight = 100,
    stack = false,
    close = true,
    description = "Sakura Alpax 4508",
    client = {
        image = "sakura_alpax_4508.png",
    }
},
 
["sakura_alpax_8508"] = {
    label = "Sakura Alpax 8508",
    weight = 100,
    stack = false,
    close = true,
    description = "Sakura Alpax 8508",
    client = {
        image = "sakura_alpax_8508.png",
    }
},
 
["ufe_belona_4000"] = {
    label = "UFE Belona 4000",
    weight = 100,
    stack = false,
    close = true,
    description = "UFE Belona 4000",
    client = {
        image = "ufe_belona_4000.png",
    }
},
 
["ufe_bigspin_8000b"] = {
    label = "UFE Bigspin 8000B",
    weight = 100,
    stack = false,
    close = true,
    description = "UFE Bigspin 8000B",
    client = {
        image = "ufe_bigspin_8000b.png",
    }
},
 
["ufe_batara_8000g"] = {
    label = "UFE Batara 8000G",
    weight = 100,
    stack = false,
    close = true,
    description = "UFE Batara 8000G",
    client = {
        image = "ufe_batara_8000g.png",
    }
},
 
["ufe_batara_1000r"] = {
    label = "UFE Batara 1000R",
    weight = 100,
    stack = false,
    close = true,
    description = "UFE Batara 1000R",
    client = {
        image = "ufe_batara_1000r.png",
    }
},
 
["robinson_big_runner_807qd"] = {
    label = "Robinson Big Runner 807QD",
    weight = 100,
    stack = false,
    close = true,
    description = "Robinson Big Runner 807QD",
    client = {
        image = "robinson_big_runner_807qd.png",
    }
},
 
["spooler_catchpro_4000fd"] = {
    label = "Spooler Catchpro 4000FD",
    weight = 100,
    stack = false,
    close = true,
    description = "Spooler Catchpro 4000FD",
    client = {
        image = "spooler_catchpro_4000fd.png",
    }
},
 
["ufe_opensea_8000_x"] = {
    label = "UFE Opensea 8000-X",
    weight = 100,
    stack = false,
    close = true,
    description = "UFE Opensea 8000-X",
    client = {
        image = "ufe_opensea_8000-x.png",
    }
},
 
["spooler_catchpro_8000fd"] = {
    label = "Spooler Catchpro 8000FD",
    weight = 100,
    stack = false,
    close = true,
    description = "Spooler Catchpro 8000FD",
    client = {
        image = "spooler_catchpro_8000fd.png",
    }
},
 
["spooler_catchpro_14000fd"] = {
    label = "Spooler Catchpro 14000FD",
    weight = 100,
    stack = false,
    close = true,
    description = "Spooler Catchpro 14000FD",
    client = {
        image = "spooler_catchpro_14000fd.png",
    }
},
-- Hooks
["ufa_bait_hook"] = {
    label = "UFA Bait",
    weight = 40,
    stack = true,
    close = true,
    description = "UFA Bait",
    client = {
        image = "ufa_bait_hook.png",
    }
},
 
["ufa_sproat_hook"] = {
    label = "UFA Sproat",
    weight = 40,
    stack = true,
    close = true,
    description = "UFA Sproat",
    client = {
        image = "ufa_sproat_hook.png",
    }
},
 
["captack_claw_xl_hook"] = {
    label = "Captack Claw XL",
    weight = 40,
    stack = true,
    close = true,
    description = "Captack Claw XL",
    client = {
        image = "captack_claw_xl_hook.png",
    }
},
 
["ufa_sproat_g_hook"] = {
    label = "UFA Sproat-G",
    weight = 40,
    stack = true,
    close = true,
    description = "UFA Sproat-G",
    client = {
        image = "ufa_sproat_g_hook.png",
    }
},
 
["carptack_carp_ss_hook"] = {
    label = "Carptack Carp S&S",
    weight = 40,
    stack = true,
    close = true,
    description = "Carptack Carp S&S",
    client = {
        image = "carptack_carp_ss_hook.png",
    }
},
 
["ufa_wide_gap_bl_hook"] = {
    label = "UFA Wide Gap BL",
    weight = 40,
    stack = true,
    close = true,
    description = "UFA Wide Gap BL",
    client = {
        image = "ufa_wide_gap_bl_hook.png",
    }
},
 
["ufa_aberdeen_hook"] = {
    label = "UFA Aberdeen",
    weight = 40,
    stack = true,
    close = true,
    description = "UFA Aberdeen",
    client = {
        image = "ufa_aberdeen_hook.png",
    }
},
 
["ufa_octopus_bl_hook"] = {
    label = "UFA Octopus BL",
    weight = 40,
    stack = true,
    close = true,
    description = "UFA Octopus BL",
    client = {
        image = "ufa_octopus_bl_hook.png",
    }
},
 
["ufa_livebait_hook"] = {
    label = "UFA Livebait",
    weight = 40,
    stack = true,
    close = true,
    description = "UFA Livebait",
    client = {
        image = "ufa_livebait_hook.png",
    }
},
 
["carptack_micro_barb_hook"] = {
    label = "Carptack Micro Barb",
    weight = 40,
    stack = true,
    close = true,
    description = "Carptack Micro Barb",
    client = {
        image = "carptack_micro_barb_hook.png",
    }
},
 
["carptack_carp_hook"] = {
    label = "Carptack Carp",
    weight = 40,
    stack = true,
    close = true,
    description = "Carptack Carp",
    client = {
        image = "carptack_carp_hook.png",
    }
},
 
["ufa_fusion_bl_hook"] = {
    label = "UFA Fusion BL",
    weight = 40,
    stack = true,
    close = true,
    description = "UFA Fusion BL",
    client = {
        image = "ufa_fusion_bl_hook.png",
    }
},
 
["predatek_octopus_hook"] = {
    label = "Predatek Octopus",
    weight = 40,
    stack = true,
    close = true,
    description = "Predatek Octopus",
    client = {
        image = "predatek_octopus_hook.png",
    }
},
 
["predatek_fusion_hook"] = {
    label = "Predatek Fusion",
    weight = 40,
    stack = true,
    close = true,
    description = "Predatek Fusion",
    client = {
        image = "predatek_fusion_hook.png",
    }
},
-- Scuba Shit
["scuba"] = {
    label = "Scuba gear",
    weight = 300,
    stack = false,
    close = true,
    description = "Scuba gear",
    client = {
        image = "scuba.png",
    }
},
-- Fish
 
["alligator_gar"] = {
    label = "Alligator Gar",
    weight = 550,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "An alligator gar fish.",
    client = {
        image = "alligator_gar.png",
    }
},
 
["amur_pike"] = {
    label = "Amur Pike",
    weight = 750,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "An Amur Pike fish.",
    client = {
        image = "amur_pike.png",
    }
},
 
["atlantic_cod"] = {
    label = "Atlantic Cod",
    weight = 300,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "An Atlantic Cod fish.",
    client = {
        image = "atlantic_cod.png",
    }
},
 
["fishing_gear"] = {
    label = "Fishing Gear",
    weight = 30,  -- Dropped a 0 from the weight
    stack = false,  -- Made non-stackable (unique item)
    close = true,  -- Equivalent to shouldClose
    description = "Essential gear for fishing.",
    client = {
        image = "fishing_gear.png",
    }
},
 
["aquarium_pass"] = {
    label = "Aquarium Pass",
    weight = 30,  -- Dropped a 0 from the weight
    stack = false,  -- Made non-stackable
    close = true,  -- Equivalent to shouldClose
    description = "Pass for entry to the aquarium.",
    client = {
        image = "aquarium_pass.png",
    }
},
 
["research_kit"] = {
    label = "Research Kit",
    weight = 30,  -- Dropped a 0 from the weight
    stack = false,  -- Made non-stackable
    close = true,  -- Equivalent to shouldClose
    description = "A kit useful for conducting field research.",
    client = {
        image = "research_kit.png",
    }
},
["special_boots"] = {
    label = "Special Boots",
    weight = 30,  -- Dropped a 0 from the weight
    stack = false,  -- Made non-stackable
    close = true,  -- Equivalent to shouldClose
    description = "Specially designed boots for rugged terrain.",
    client = {
        image = "special_boots.png",
    }
},
 
["museum_ticket"] = {
    label = "Museum Ticket",
    weight = 30,  -- Dropped a 0 from the weight
    stack = false,  -- Made non-stackable
    close = true,  -- Equivalent to shouldClose
    description = "Ticket for entry to the museum.",
    client = {
        image = "museum_ticket.png",
    }
},
 
["atlantic_salmon"] = {
    label = "Atlantic Salmon",
    weight = 500,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "An Atlantic Salmon fish.",
    client = {
        image = "atlantic_salmon.png",
    }
},
 
["barbel"] = {
    label = "Barbel",
    weight = 600,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Barbel fish.",
    client = {
        image = "barbel.png",
    }
},
 
["beluga_sturgeon"] = {
    label = "Beluga Sturgeon",
    weight = 264,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Beluga Sturgeon fish.",
    client = {
        image = "beluga_sturgeon.png",
    }
},
 
["black_grayling"] = {
    label = "Black Grayling",
    weight = 120,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Black Grayling fish.",
    client = {
        image = "black_grayling.png",
    }
},
 
["blacktip_reef_shark"] = {
    label = "Blacktip Reef Shark",
    weight = 1500,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Blacktip Reef Shark.",
    client = {
        image = "blacktip_reef_shark.png",
    }
},
 
["blue_marlin"] = {
    label = "Blue Marlin",
    weight = 200,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Blue Marlin fish.",
    client = {
        image = "blue_marlin.png",
    }
},
 
["bluefin_tuna"] = {
    label = "Bluefin Tuna",
    weight = 270,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Bluefin Tuna fish.",
    client = {
        image = "bluefin_tuna.png",
    }
},
 
["bluegill"] = {
    label = "Bluegill",
    weight = 120,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Bluegill fish.",
    client = {
        image = "bluegill.png",
    }
},
 
["brook_trout"] = {
    label = "Brook Trout",
    weight = 700,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Brook Trout fish.",
    client = {
        image = "brook_trout.png",
    }
},
 
["brown_trout"] = {
    label = "Brown Trout",
    weight = 230,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Brown Trout fish.",
    client = {
        image = "brown_trout.png",
    }
},
 
["bull_trout"] = {
    label = "Bull Trout",
    weight = 200,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Bull Trout fish.",
    client = {
        image = "bull_trout.png",
    }
},
 
["chub"] = {
    label = "Chub",
    weight = 150,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Chub fish.",
    client = {
        image = "chub.png",
    }
},
 
["chum_salmon"] = {
    label = "Chum Salmon",
    weight = 600,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Chum Salmon fish.",
    client = {
        image = "chum_salmon.png",
    }
},
 
["coho_salmon"] = {
    label = "Coho Salmon",
    weight = 500,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Coho Salmon fish.",
    client = {
        image = "coho_salmon.png",
    }
},
 
["common_bleak"] = {
    label = "Common Bleak",
    weight = 10,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Common Bleak fish.",
    client = {
        image = "common_bleak.png",
    }
},
 
["common_bream"] = {
    label = "Common Bream",
    weight = 400,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Common Bream fish.",
    client = {
        image = "common_bream.png",
    }
},
 
["common_carp"] = {
    label = "Common Carp",
    weight = 700,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Common Carp fish.",
    client = {
        image = "common_carp.png",
    }
},
["crucian_carp"] = {
    label = "Crucian Carp",
    weight = 140,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Crucian Carp fish.",
    client = {
        image = "crucian_carp.png",
    }
},
 
["european_bass"] = {
    label = "European Bass",
    weight = 250,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A European Bass fish.",
    client = {
        image = "european_bass.png",
    }
},
 
["european_eel"] = {
    label = "European Eel",
    weight = 300,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A European Eel fish.",
    client = {
        image = "european_eel.png",
    }
},
 
["european_flounder"] = {
    label = "European Flounder",
    weight = 170,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A European Flounder fish.",
    client = {
        image = "european_flounder.png",
    }
},
 
["european_perch"] = {
    label = "European Perch",
    weight = 500,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A European Perch fish.",
    client = {
        image = "european_perch.png",
    }
},
 
["european_sea_sturgeon"] = {
    label = "European Sea Sturgeon",
    weight = 2000,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A European Sea Sturgeon.",
    client = {
        image = "european_sea_sturgeon.png",
    }
},
 
["electric_eel"] = {
    label = "Electric Eel",
    weight = 1500,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "An Electric Eel.",
    client = {
        image = "electric_eel.png",
    }
},
 
["garfish"] = {
    label = "Garfish",
    weight = 50,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Garfish.",
    client = {
        image = "garfish.png",
    }
},
 
["giant_freshwater_stingray"] = {
    label = "Giant Freshwater Stingray",
    weight = 350,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Giant Freshwater Stingray.",
    client = {
        image = "giant_freshwater_stingray.png",
    }
},
 
["giant_grouper"] = {
    label = "Giant Grouper",
    weight = 260,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Giant Grouper fish.",
    client = {
        image = "giant_grouper.png",
    }
},
 
["giant_squid"] = {
    label = "Giant Squid",
    weight = 2000,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Giant Squid.",
    client = {
        image = "giant_squid.png",
    }
},
 
["giant_trevally"] = {
    label = "Giant Trevally",
    weight = 200,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Giant Trevally fish.",
    client = {
        image = "giant_trevally.png",
    }
},
 
["golden_trout"] = {
    label = "Golden Trout",
    weight = 40,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Golden Trout fish.",
    client = {
        image = "golden_trout.png",
    }
},
 
["grass_carp"] = {
    label = "Grass Carp",
    weight = 120,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Grass Carp fish.",
    client = {
        image = "grass_carp.png",
    }
},
 
["grass_pickerel"] = {
    label = "Grass Pickerel",
    weight = 90,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Grass Pickerel fish.",
    client = {
        image = "grass_pickerel.png",
    }
},
 
["grayling"] = {
    label = "Grayling",
    weight = 80,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Grayling fish.",
    client = {
        image = "grayling.png",
    }
},
 
["great_barracuda"] = {
    label = "Great Barracuda",
    weight = 900,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Great Barracuda fish.",
    client = {
        image = "great_barracuda.png",
    }
},
 
["grey_snapper"] = {
    label = "Grey Snapper",
    weight = 400,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Grey Snapper fish.",
    client = {
        image = "grey_snapper.png",
    }
},
 
["huchen"] = {
    label = "Huchen",
    weight = 1500,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Huchen fish.",
    client = {
        image = "huchen.png",
    }
},
 
["ide"] = {
    label = "Ide",
    weight = 100,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "An Ide fish.",
    client = {
        image = "ide.png",
    }
},
 
["indian_threadfish"] = {
    label = "Indian Threadfish",
    weight = 250,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "An Indian Threadfish.",
    client = {
        image = "indian_threadfish.png",
    }
},
 
["lake_sturgeon"] = {
    label = "Lake Sturgeon",
    weight = 1600,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Lake Sturgeon fish.",
    client = {
        image = "lake_sturgeon.png",
    }
},
 
["largemouth_bass"] = {
    label = "Largemouth Bass",
    weight = 100,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Largemouth Bass fish.",
    client = {
        image = "largemouth_bass.png",
    }
},
 
["mahi_mahi"] = {
    label = "Mahi-Mahi",
    weight = 1000,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Mahi-Mahi fish.",
    client = {
        image = "mahi_mahi.png",
    }
},
 
["malabar_grouper"] = {
    label = "Malabar Grouper",
    weight = 1500,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Malabar Grouper fish.",
    client = {
        image = "malabar_grouper.png",
    }
},
 
["mirror_carp"] = {
    label = "Mirror Carp",
    weight = 700,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Mirror Carp fish.",
    client = {
        image = "mirror_carp.png",
    }
},
 
["northern_pike"] = {
    label = "Northern Pike",
    weight = 500,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Northern Pike fish.",
    client = {
        image = "northern_pike.png",
    }
},
 
["pink_river_dolphin"] = {
    label = "Pink River Dolphin",
    weight = 1550,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Pink River Dolphin.",
    client = {
        image = "pink_river_dolphin.png",
    }
},
 
["pink_salmon"] = {
    label = "Pink Salmon",
    weight = 200,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Pink Salmon fish.",
    client = {
        image = "pink_salmon.png",
    }
},
 
["prussian_carp"] = {
    label = "Prussian Carp",
    weight = 90,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Prussian Carp fish.",
    client = {
        image = "prussian_carp.png",
    }
},
 
["pufferfish"] = {
    label = "Pufferfish",
    weight = 150,  -- Dropped a 0 from the weight
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Pufferfish.",
    client = {
        image = "pufferfish.png",
    }
},
 
["pumpkinseed"] = {
    label = "Pumpkinseed",
    weight = 40,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Pumpkinseed fish.",
    client = {
        image = "pumpkinseed.png",
    }
},
 
["rainbow_trout"] = {
    label = "Rainbow Trout",
    weight = 100,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Rainbow Trout fish.",
    client = {
        image = "rainbow_trout.png",
    }
},
 
["red_lionfish"] = {
    label = "Red Lionfish",
    weight = 100,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Red Lionfish.",
    client = {
        image = "red_lionfish.png",
    }
},
 
["redeye_piranha"] = {
    label = "Redeye Piranha",
    weight = 120,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Redeye Piranha.",
    client = {
        image = "redeye_piranha.png",
    }
},
 
["redfin_pickerel"] = {
    label = "Redfin Pickerel",
    weight = 40,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Redfin Pickerel fish.",
    client = {
        image = "redfin_pickerel.png",
    }
},
 
["roach"] = {
    label = "Roach",
    weight = 50,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Roach fish.",
    client = {
        image = "roach.png",
    }
},
 
["sea_trout"] = {
    label = "Sea Trout",
    weight = 200,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Sea Trout fish.",
    client = {
        image = "sea_trout.png",
    }
},
 
["silver_carp"] = {
    label = "Silver Carp",
    weight = 1000,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Silver Carp fish.",
    client = {
        image = "silver_carp.png",
    }
},
 
["skeleton"] = {
    label = "Skeleton",
    weight = 10,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Skeleton.",
    client = {
        image = "skeleton.png",
    }
},
 
["smallmouth_bass"] = {
    label = "Smallmouth Bass",
    weight = 150,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Smallmouth Bass fish.",
    client = {
        image = "smallmouth_bass.png",
    }
},
 
["sockeye_salmon"] = {
    label = "Sockeye Salmon",
    weight = 300,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Sockeye Salmon fish.",
    client = {
        image = "sockeye_salmon.png",
    }
},
 
["south_sea_pearl_oyster"] = {
    label = "South Sea Pearl Oyster",
    weight = 10,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A South Sea Pearl Oyster.",
    client = {
        image = "south_sea_pearl_oyster.png",
    }
},
 
["tench"] = {
    label = "Tench",
    weight = 250,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Tench fish.",
    client = {
        image = "tench.png",
    }
},
 
["tiger_shark"] = {
    label = "Tiger Shark",
    weight = 5500,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Tiger Shark.",
    client = {
        image = "tiger_shark.png",
    }
},
 
["wels_catfish"] = {
    label = "Wels Catfish",
    weight = 400,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Wels Catfish fish.",
    client = {
        image = "wels_catfish.png",
    }
},
 
["white_sturgeon"] = {
    label = "White Sturgeon",
    weight = 800,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A White Sturgeon fish.",
    client = {
        image = "white_sturgeon.png",
    }
},
 
["yellow_perch"] = {
    label = "Yellow Perch",
    weight = 40,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Yellow Perch fish.",
    client = {
        image = "yellow_perch.png",
    }
},
 
["yellowfin_tuna"] = {
    label = "Yellowfin Tuna",
    weight = 900,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Yellowfin Tuna fish.",
    client = {
        image = "yellowfin_tuna.png",
    }
},
 
["yellowtail_barracuda"] = {
    label = "Yellowtail Barracuda",
    weight = 110,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Yellowtail Barracuda.",
    client = {
        image = "yellowtail_barracuda.png",
    }
},
 
["zander"] = {
    label = "Zander",
    weight = 200,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A Zander fish.",
    client = {
        image = "zander.png",
    }
},
 
["paddlefish"] = {
    label = "Paddle Fish",
    weight = 1000,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A rare and illegal Paddle Fish.",
    client = {
        image = "paddlefish.png",
    }
},
 
["sawfish"] = {
    label = "Saw Fish",
    weight = 1000,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A rare and illegal Saw Fish.",
    client = {
        image = "sawfish.png",
    }
},
 
["eel"] = {
    label = "Eel",
    weight = 1000,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A rare and illegal Eel.",
    client = {
        image = "eel.png",
    }
},
 
["hammerheadshark"] = {
    label = "Hammer Head Shark",
    weight = 2500,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A rare and illegal Hammer Head Shark.",
    client = {
        image = "hammerheadshark.png",
    }
},
 
["seaturtle"] = {
    label = "Sea Turtle",
    weight = 2500,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A rare and illegal Sea Turtle.",
    client = {
        image = "seaturtle.png",
    }
},
 
["leopardshark"] = {
    label = "Leopard Shark",
    weight = 2500,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A rare and illegal Leopard Shark.",
    client = {
        image = "leopardshark.png",
    }
},
 
["blueshark"] = {
    label = "Blue Shark",
    weight = 4000,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A legendary and illegal Blue Shark.",
    client = {
        image = "blueshark.png",
    }
},
 
["greatwhiteshark"] = {
    label = "Great White Shark",
    weight = 10000,  -- Converted weight to OxInventory format
    stack = true,  -- Made stackable
    close = true,  -- Equivalent to shouldClose
    description = "A mythic and illegal Great White Shark.",
    client = {
        image = "greatwhiteshark.png",
    }
},
 
-- Diving Items
["ancient_artifact"] = {
    label = "Ancient Artifact",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "An Ancient Artifact!",
    client = {
        image = "ancient_artifact.png",
    }
},
["antique_compass"] = {
    label = "Antique Compass",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "An Antique Compass.",
    client = {
        image = "antique_compass.png",
    }
},
["enchanted_jewel"] = {
    label = "Enchanted Jewel",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "An Enchanted Jewel.",
    client = {
        image = "enchanted_jewel.png",
    }
},
["luxury_watch"] = {
    label = "Luxury Watch",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "An Expensive Watch.",
    client = {
        image = "luxury_watch.png",
    }
},
["meteorite_ore"] = {
    label = "Meteorite Ore",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "Meteorite Ore.",
    client = {
        image = "meteorite_ore.png",
    }
},
["mystic_crystal"] = {
    label = "Mystic Crystal",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "A Mystic Crystal.",
    client = {
        image = "mystic_crystal.png",
    }
},
["phantom_amulet"] = {
    label = "Phantom Amulet",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "A Phantom Amulet.",
    client = {
        image = "phantom_amulet.png",
    }
},
["precious_pearls"] = {
    label = "Precious Pearls",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "Handfull of Precious Pearls.",
    client = {
        image = "precious_pearls.png",
    }
},
["rare_spices"] = {
    label = "Rare Spices",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "Collection of Rare Spices.",
    client = {
        image = "rare_spices.png",
    }
},
["spy_gadget"] = {
    label = "Spy Gadget",
    weight = 1000,  
    stack = true,  
    close = true,  
    description = "A Spy Gadget.",
    client = {
        image = "spy_gadget.png",
    }
},

    -- FOOD: General

    ['sandwich'] = { -- A simple sandwich for a simple day
        label = 'Sandwich',
        weight = 350,
        stack = true,
        close = true,
        description = "A simple sandwich for a simple day",
        client = {
            status = { hunger = 200000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'prop_sandwich_01', 
            pos = vec3(0.05, -0.02, -0.03), rot = vec3(150.0, 340.0, 170.0) },
            usetime = 7500,
        },
    },

    ['burger'] = { -- A test hamburger that you can eat
        label = 'Hamburger',
        weight = 350,
        stack = true,
        close = true,
        description = "A test hamburger that you can eat",
        client = {
            status = { hunger = 230000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'prop_cs_burger_01', 
            pos = vec3(0.05, -0.02, -0.03), rot = vec3(150.0, 340.0, 170.0) },
            usetime = 7500,
        },
    },

    ['burger_chs'] = { -- A test hamburger that you can eat
        label = 'Cheese Burger',
        weight = 350,
        stack = true,
        close = true,
        description = "A test hamburger that you can eat, with cheese",
        client = {
            status = { hunger = 230000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'prop_cs_burger_01', 
            pos = vec3(0.05, -0.02, -0.03), rot = vec3(150.0, 340.0, 170.0) },
            usetime = 7500,
        },
    },

    ['burger_chsbcn'] = { -- A test hamburger that you can eat
        label = 'Cheese Burger',
        weight = 350,
        stack = true,
        close = true,
        description = "A test hamburger that you can eat, with cheese & bacon",
        client = {
            status = { hunger = 230000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'prop_cs_burger_01', 
            pos = vec3(0.05, -0.02, -0.03), rot = vec3(150.0, 340.0, 170.0) },
            usetime = 7500,
        },
    },

    ['hotdog'] = { -- A test hamburger that you can eat
        label = 'Hotdog',
        weight = 350,
        stack = true,
        close = true,
        description = "Not made with real dogs or meat",
        client = {
            status = { hunger = 230000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'prop_cs_hotdog_01', 
            pos = vec3(0.06, -0.01, -0.03), rot = vec3(60.0, -90.0, 0.0) },
            usetime = 7500,
        },
    },

    ['noodles'] = { -- Fuck those baked shits are good af
        label = 'Thai Noodles',
        weight = 350,
        stack = true,
        close = true,
        description = "นี่คือบะหมี่",
        client = {
            status = { hunger = 160000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_ret_fh_noodle', 
            pos = vec3(-0.03, 0.01, 0.05), 
            rot = vec3(0.0, 0.0, -40.0) },
            usetime = 7500,
        },
    },

    ['fr_fries'] = { -- A test hamburger that you can eat
        label = 'French Fries',
        weight = 350,
        stack = true,
        close = true,
        description = "Rib flavored chips, made with real wood chips",
        client = {
            status = { hunger = 120000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_food_chips', 
            pos = vec3(-0.01, 0.0, -0.02), rot = vec3(0.0, 0.0, -45.0) },
            usetime = 5000,
        },
    },


    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- FOOD: Pizzas


    ['pizza_pep'] = { -- A simple sandwich for a simple day
        label = 'Peperoni Pizza',
        weight = 350,
        stack = true,
        close = true,
        description = "Who put cheese on my pepperoni",
        client = {
            status = { hunger = 200000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'knjgh_pizzaslice5', 
            pos = vec3(0.0500, -0.0300, -0.0700), 
            rot = vec3(300.0, -10.0, 160.0),
            bone = 60309 },
            usetime = 7500,
        },
    },

    ['pizza_chs'] = { -- A simple sandwich for a simple day
        label = 'Cheese Pizza',
        weight = 350,
        stack = true,
        close = true,
        description = "Is it enough cheese? No",
        client = {
            status = { hunger = 200000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'knjgh_pizzaslice4', 
            pos = vec3(0.0500, -0.0300, -0.0700), 
            rot = vec3(300.0, -10.0, 160.0),
            bone = 60309 },
            usetime = 7500,
        },
    },

    ['pizza_msh'] = { -- A simple sandwich for a simple day
        label = 'Mushroom Pizza',
        weight = 350,
        stack = true,
        close = true,
        description = "Fungi on my pizza? Who thought of this?",
        client = {
            status = { hunger = 200000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'knjgh_pizzaslice3', 
            pos = vec3(0.0500, -0.0300, -0.0700), 
            rot = vec3(300.0, -10.0, 160.0),
            bone = 60309 },
            usetime = 7500,
        },
    },

    ['pizza_mgt'] = { -- A simple sandwich for a simple day
        label = 'Margherita Pizza',
        weight = 350,
        stack = true,
        close = true,
        description = "I know, I thought it was alcohol pizza too",
        client = {
            status = { hunger = 200000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'knjgh_pizzaslice2', 
            pos = vec3(0.0500, -0.0300, -0.0700), 
            rot = vec3(300.0, -10.0, 160.0),
            bone = 60309 },
            usetime = 7500,
        },
    },

    ['pizza_dmt'] = { -- A simple sandwich for a simple day
        label = 'Double Meat Pizza',
        weight = 350,
        stack = true,
        close = true,
        description = "When one meat isn't enough and 3 is weird",
        client = {
            status = { hunger = 200000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'knjgh_pizzaslice1', 
            pos = vec3(0.0500, -0.0300, -0.0700), 
            rot = vec3(300.0, -10.0, 160.0),
            bone = 60309 },
            usetime = 7500,
        },
    },


    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- FOOD: Snacks


    ['phatc_rib'] = { -- A skeletons favorite snack
        label = 'Phat Chips: Ribs',
        weight = 350,
        stack = true,
        close = true,
        description = "Rib flavored chips, made with real wood chips",
        client = {
            status = { hunger = 120000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'ng_proc_food_chips01b', 
            pos = vec3(0.0, 0.08, 0.05), rot = vec3(90.0, 0.0, -45.0) },
            usetime = 5000,
        },
    },

    ['phatc_bch'] = { -- Biggie Cheese
        label = 'Phat Chips: Big Cheese',
        weight = 350,
        stack = true,
        close = true,
        description = "Cheese flavored chips, made with real rats",
        client = {
            status = { hunger = 120000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'ng_proc_food_chips01a', 
            pos = vec3(0.0, 0.08, 0.05), rot = vec3(90.0, 0.0, -45.0) },
            usetime = 5000,
        },
    },

    ['ps_qs'] = { -- is that candy
        label = 'P\'s & Q\'s',
        weight = 350,
        stack = true,
        close = true,
        description = "Candy make your tongue go brrrr",
        client = {
            status = { hunger = 650000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_candy_pqs', 
            pos = vec3(0.0, 0.02, 0.05), rot = vec3(90.0, 0.0, -45.0) },
            usetime = 5000,
        },
    },

    ['apple'] = { -- Apple good
        label = 'Apple',
        weight = 350,
        stack = true,
        close = true,
        description = "Yes, from the trees comes deez apples",
        client = {
            status = { hunger = 90000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'sf_prop_sf_apple_01a', 
            pos = vec3(0.03, -0.02, -0.03), rot = vec3(300.0, 340.0, 170.0) },
            usetime = 3000,
        },
    },

    ['banana'] = { -- banana good
        label = 'Banana',
        weight = 350,
        stack = true,
        close = true,
        description = "b a n a n a n a n a n a",
        client = {
            status = { hunger = 90000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'v_res_tre_banana', 
            pos = vec3(0.05, -0.02, 0.01), rot = vec3(270.0, 90.0, 0.0) },
            usetime = 3000,
        },
    },
    

    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- FOOD: Deserts

    ['donut_chc'] = { -- Fuck those baked shits are good af
        label = 'Chocolate Donut',
        weight = 350,
        stack = true,
        close = true,
        description = "Mmmmm, refrence",
        client = {
            status = { hunger = 150000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_foodpack_donut002', 
            bone = 18905,
            pos = vec3(0.13, 0.050, 0.020), 
            rot = vec3(-50.0, 100.0, 270.0) },
            usetime = 7500,
        },
    },

    ['donut_sby'] = { -- Fuck those baked shits are good af
        label = 'Strawberry Donut',
        weight = 350,
        stack = true,
        close = true,
        description = "Mmmmm, refrence",
        client = {
            status = { hunger = 150000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_foodpack_donut001', 
            bone = 18905,
            pos = vec3(0.13, 0.050, 0.020), 
            rot = vec3(-50.0, 100.0, 270.0) },
            usetime = 7500,
        },
    },

    ['smore'] = { -- Fuck those baked shits are good af
        label = 'Smore',
        weight = 350,
        stack = true,
        close = true,
        description = "Mmmmm, refrence",
        client = {
            status = { hunger = 90000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_food_dessert_a', 
            bone = 18905,
            pos = vec3(0.15, 0.03, 0.03), 
            rot = vec3(-42.0, -36.0, 0.0) },
            usetime = 7500,
        },
    },

    ['icecream_chr'] = { -- brain cold go brrrrr
        label = 'Cherry Ice Cream',
        weight = 350,
        stack = true,
        close = true,
        description = "Why yes, your brain is freezing",
        client = {
            status = { hunger = 50000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_cherry', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },

    ['icecream_chc'] = { -- brain cold go brrrrr
        label = 'Chocolate Ice Cream',
        weight = 350,
        stack = true,
        close = true,
        description = "Why yes, your brain is freezing",
        client = {
            status = { hunger = 50000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_chocolate', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },

    ['icecream_lmn'] = { -- brain cold go brrrrr
        label = 'Lemon Ice Cream',
        weight = 350,
        stack = true,
        close = true,
        description = "Why yes, your brain is freezing",
        client = {
            status = { hunger = 50000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_lemon', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },

    ['icecream_pso'] = { -- brain cold go brrrrr
        label = 'Pistachio Ice Cream',
        weight = 350,
        stack = true,
        close = true,
        description = "Why yes, your brain is freezing",
        client = {
            status = { hunger = 50000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_pistachio', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },

    ['icecream_rpy'] = { -- brain cold go brrrrr
        label = 'Raspberry Ice Cream',
        weight = 350,
        stack = true,
        close = true,
        description = "Why yes, your brain is freezing",
        client = {
            status = { hunger = 50000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_raspberry', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },

    ['icecream_ckd'] = { -- brain cold go brrrrr
        label = 'Cookie Dough Ice Cream',
        weight = 350,
        stack = true,
        close = true,
        description = "Why yes, your brain is freezing",
        client = {
            status = { hunger = 50000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_stracciatella', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },

    ['icecream_sby'] = { -- brain cold go brrrrr
        label = 'Strawberry Ice Cream',
        weight = 350,
        stack = true,
        close = true,
        description = "Why yes, your brain is freezing",
        client = {
            status = { hunger = 50000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_strawberry', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },

    ['icecream_vna'] = { -- brain cold go brrrrr
        label = 'Vanilla Ice Cream',
        weight = 350,
        stack = true,
        close = true,
        description = "Why yes, your brain is freezing",
        client = {
            status = { hunger = 50000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_walnut', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },








    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- DRINKS: General

    ['water'] = { -- Carbonized syrup is good for the soul
        label = 'Water Bottle',
        weight = 350,
        stack = true,
        close = true,
        description = "If you think you need more, you do",
        client = {
            status = { thirst = 300000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'vw_prop_casino_water_bottle_01a', 
            pos = vec3(0.008, 0.0, -0.05), rot = vec3(0.0, 0.0, -40.0) },
            usetime = 7500,
        },
    },

    ['milk'] = { -- milky milky milky
        label = 'Milk Carton',
        weight = 350,
        stack = true,
        close = true,
        description = "Milky mliky mliky I love milky mommy!",
        client = {
            status = { thirst = 300000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_res_tt_milk', 
            bone = 18905,
            pos = vec3(0.10, 0.008, 0.070), 
            rot = vec3(240.0, -60.0, 0.0) },
            usetime = 7500,
        },
    },


    -- COFFEES


    ['coffee_black'] = { -- Carbonized syrup is good for the soul
        label = 'Black Coffee',
        weight = 350,
        stack = true,
        close = true,
        description = "As black as the color wheel lets it be",
        client = {
            status = { thirst = 220000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'ng_proc_coffee_01a', 
            pos = vec3(0.008, 0.0, -0.05), rot = vec3(0.0, 0.0, -40.0) },
            usetime = 7500,
        },
    },

    ['coffee_mocha'] = { -- Carbonized syrup is good for the soul
        label = 'Mocha',
        weight = 350,
        stack = true,
        close = true,
        description = "What even is a mocha",
        client = {
            status = { thirst = 220000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'ng_proc_coffee_01a', 
            pos = vec3(0.008, 0.0, -0.05), rot = vec3(0.0, 0.0, -40.0) },
            usetime = 7500,
        },
    },

    ['coffee_cpcno'] = { -- Carbonized syrup is good for the soul
        label = 'Cappuccino',
        weight = 350,
        stack = true,
        close = true,
        description = "That might wake you up a smidge",
        client = {
            status = { thirst = 220000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'ng_proc_coffee_01a', 
            pos = vec3(0.008, 0.0, -0.05), rot = vec3(0.0, 0.0, -40.0) },
            usetime = 7500,
        },
    },

    ['coffee_amrcno'] = { -- Carbonized syrup is good for the soul
        label = 'Americano',
        weight = 350,
        stack = true,
        close = true,
        description = "American coffee, with an o",
        client = {
            status = { thirst = 220000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'ng_proc_coffee_01a', 
            pos = vec3(0.008, 0.0, -0.05), rot = vec3(0.0, 0.0, -40.0) },
            usetime = 7500,
        },
    },


    -- SODAS


    ['ecola'] = { -- Carbonized syrup is good for the soul
        label = 'eCola',
        weight = 350,
        stack = true,
        close = true,
        description = "Hey, there is soda in my cocaine",
        client = {
            status = { thirst = 160000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_ecola_can', 
            pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 130.0) },
            usetime = 5000,
        },
    },

    ['sprunk'] = { -- Carbonized syrup is good for the soul
        label = 'Sprunk',
        weight = 350,
        stack = true,
        close = true,
        description = "It tastes like water punched you in the throat",
        client = {
            status = { thirst = 160000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'ng_proc_sodacan_01b', 
            pos = vec3(0.005, -0.001, 0.08), rot = vec3(0.0, 0.0, 160.0) },
            usetime = 5000,
        },
    },

    ['orangotang'] = { -- Carbonized syrup is good for the soul
        label = 'Orang-o-tang',
        weight = 350,
        stack = true,
        close = true,
        description = "I didn't even know people wanted this",
        client = {
            status = { thirst = 160000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_orang_can_01', 
            pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 130.0) },
            usetime = 5000,
        },
    },

    ['ejunk'] = { -- Drinking too much of this wont kill you. I think.
        label = 'Junk Energy',
        weight = 350,
        stack = true,
        close = true,
        description = "Drinking too much of this wont kill you. I think.",
        client = {
            status = { thirst = 160000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'sf_prop_sf_can_01a', 
            pos = vec3(0.025, 0.010, 0.05), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 5000,
        },
    },










    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- ALCOHOL: Beers
    ['rancho_beer'] = { -- Good ol imported beer from mexico
        label = 'Cerbesa Barracho',
        weight = 290,
        stack = true,
        close = true,
        description = "Good ol imported beer from mexico",
        client = {
            status = { drunk = 90000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_beer_bottle', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['dusche_beer'] = { -- Good ol imported beer from germany
        label = 'Dusche Beer',
        weight = 290,
        stack = true,
        close = true,
        description = "Good ol imported beer from germany",
        client = {
            status = { drunk = 90000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_beerdusche', 
            pos = vec3(0.01, -0.01, -0.12), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 7500,
        },
    },

    ['stronzo_beer'] = { -- Good ol imported beer from italy
        label = 'Stronzo Beer',
        weight = 290,
        stack = true,
        close = true,
        description = "Good ol imported beer from italy",
        client = {
            status = { drunk = 90000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_beer_stz', 
            pos = vec3(0.01, -0.02, -0.15), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 7500,
        },
    },

    ['patriot_beer'] = { -- Good ol homemade beer from the brewery
        label = 'Patriot Beer',
        weight = 290,
        stack = true,
        close = true,
        description = "Good ol homemade beer from the brewery",
        client = {
            status = { drunk = 90000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_beer_patriot', 
            pos = vec3(0.01, -0.02, -0.15), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 7500,
        },
    },

    -- ALCOHOL: Bottles
    ['bb_bourgeoix'] = { -- Good ol imported beer from mexico
        label = 'Bottle of Bourgeoix Cognac',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 180000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_bottle_cognac', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['bb_cariaque'] = { -- Good ol imported beer from mexico
        label = 'Bottle of Cariaque Bourbon',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 180000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_bottle_brandy', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['cb_bleuterd'] = { -- Good ol imported beer from mexico
        label = 'Bottle of Bleuter\'d Champagne',
        weight = 290,
        stack = true,
        close = true,
        description = "For those fancy events",
        client = {
            status = { drunk = 180000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_champ_01b', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['rb_ragga'] = { -- Good ol imported beer from mexico
        label = 'Bottle of Ragga Rum',
        weight = 290,
        stack = true,
        close = true,
        description = "A pirates drink for me",
        client = {
            status = { drunk = 180000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_rum_bottle', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['tb_tequilya'] = { -- Good ol imported beer from mexico
        label = 'Bottle of Tequilya Tequila',
        weight = 290,
        stack = true,
        close = true,
        description = "For extra kick, add snake venom",
        client = {
            status = { drunk = 180000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_tequila_bottle', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['vb_nogo'] = { -- Good ol imported beer from mexico
        label = 'Bottle of Nogo Vodka',
        weight = 290,
        stack = true,
        close = true,
        description = "Chilled like the mountains of Siberia",
        client = {
            status = { drunk = 180000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_vodka_bottle', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['wb_mount'] = { -- Good ol imported beer from mexico
        label = 'Bottle of Mount Whiskey',
        weight = 290,
        stack = true,
        close = true,
        description = "The cowboy's choice for getting plastered",
        client = {
            status = { drunk = 180000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_cs_whiskey_bottle', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['wb_richards'] = { -- Good ol imported beer from mexico
        label = 'Bottle of Richard\'s Whiskey',
        weight = 290,
        stack = true,
        close = true,
        description = "For the refined taste buds you so clearly have",
        client = {
            status = { drunk = 180000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'prop_bottle_richard', 
            pos = vec3(0.02, -0.01, -0.14), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    -- ALCOHOL: Glasses
    ['bg_bourgeiox'] = { -- Good ol imported beer from mexico
        label = 'Glass of Bourgeoix Cognac',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_drink_whisky', 
            pos = vec3(0.16, -0.02, -0.06), 
            rot = vec3(270.00, 0.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['bg_cariaque'] = { -- Good ol imported beer from mexico
        label = 'Glass of Cariaque Bourbon',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_drink_whisky', 
            pos = vec3(0.16, -0.02, -0.06), 
            rot = vec3(270.00, 0.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['bs_bourgeiox'] = { -- Good ol imported beer from mexico
        label = 'Shot of Bourgeoix Cognac',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'p_cs_shot_glass_2_s', 
            pos = vec3(0.02, -0.01, 0.08), 
            rot = vec3(1.0, 5.0, -182.5) },
            usetime = 2000,
        },
    },

    ['bs_cariaque'] = { -- Good ol imported beer from mexico
        label = 'Shot of Cariaque Bourbon',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'p_cs_shot_glass_2_s', 
            pos = vec3(0.02, -0.01, 0.08), 
            rot = vec3(1.0, 5.0, -182.5) },
            usetime = 2000,
        },
    },

    ['cg_bleuterd'] = { -- Good ol imported beer from mexico
        label = 'Glass of Bleuter\'d Champagne',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_drink_champ', 
            pos = vec3(0.16, -0.19, -0.06), 
            rot = vec3(270.00, 0.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['tg_martini'] = { -- Good ol imported beer from mexico
        label = 'Martini',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_tequila', 
            pos = vec3(0.16, -0.12, -0.06), 
            rot = vec3(280.00, 90.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['tg_sunrise'] = { -- Good ol imported beer from mexico
        label = 'Tequilya Sunrise',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_tequsunrise', 
            pos = vec3(0.16, -0.1, -0.05), 
            rot = vec3(270.00, 0.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['tg_tequilya'] = { -- Good ol imported beer from mexico
        label = 'Glass of Tequilya',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_drink_whisky', 
            pos = vec3(0.16, -0.02, -0.06), 
            rot = vec3(270.00, 0.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['ts_tequilya'] = { -- Good ol imported beer from mexico
        label = 'Shot of Tequilya',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'p_cs_shot_glass_2_s', 
            pos = vec3(0.02, -0.01, 0.08), 
            rot = vec3(1.0, 5.0, -182.5) },
            usetime = 2000,
        },
    },

    ['vg_nogo'] = { -- Good ol imported beer from mexico
        label = 'Glass of Nogo Vodka',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_drink_whisky', 
            pos = vec3(0.16, -0.02, -0.06), 
            rot = vec3(270.00, 0.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['vs_nogo'] = { -- Good ol imported beer from mexico
        label = 'Shot of Nogo Vodka',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'p_cs_shot_glass_2_s', 
            pos = vec3(0.02, -0.01, 0.08), 
            rot = vec3(1.0, 5.0, -182.5) },
            usetime = 2000,
        },
    },

    ['wg_mount'] = { -- Good ol imported beer from mexico
        label = 'Glass of Mount Whiskey',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_drink_whisky', 
            pos = vec3(0.16, -0.02, -0.06), 
            rot = vec3(270.00, 0.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['wg_richards'] = { -- Good ol imported beer from mexico
        label = 'Glass of Richard\'s Whiskey',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_c' },
            prop = { model = 'prop_drink_whisky', 
            pos = vec3(0.16, -0.02, -0.06), 
            rot = vec3(270.00, 0.00, 0.00),
            bone = 57005},
            usetime = 12000,
        },
    },

    ['ws_mount'] = { -- Good ol imported beer from mexico
        label = 'Shot of Mount Whiskey',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'p_cs_shot_glass_2_s', 
            pos = vec3(0.02, -0.01, 0.08), 
            rot = vec3(1.0, 5.0, -182.5) },
            usetime = 2000,
        },
    },

    ['ws_richards'] = { -- Good ol imported beer from mexico
        label = 'Shot of Richard\'s Whiskey',
        weight = 290,
        stack = true,
        close = true,
        description = "Like whiskey, but more ouch",
        client = {
            status = { drunk = 10000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'p_cs_shot_glass_2_s', 
            pos = vec3(0.02, -0.01, 0.08), 
            rot = vec3(1.0, 5.0, -182.5) },
            usetime = 2000,
        },
    },
    







    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- USABLES: Beer crates
    ['box_rancho_beer'] = { -- idea: Player uses item to show badge prop
        label = 'Case of Rancho Beer',
        weight = 3500,
        --consume = 0,
        description = "Oh boy I love beer",
        client = {
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 
            clip = 'machinic_loop_mechandplayer', flag = 3 },
            prop = { model = 'v_ind_cfbox2', -- need badge props repo
            pos = vec3(-0.05, 0.8, -0.25), 
            rot = vec3(0.00, 0.00, 0.00), 
            bone = 56604 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_dusche_beer'] = { -- idea: Player uses item to show badge prop
        label = 'Case of Dusche Beer',
        weight = 3500,
        --consume = 0,
        description = "Oh boy I love beer",
        client = {
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 
            clip = 'machinic_loop_mechandplayer', flag = 3 },
            prop = { model = 'v_ind_cfbox2', -- need badge props repo
            pos = vec3(-0.05, 0.8, -0.25), 
            rot = vec3(0.00, 0.00, 0.00), 
            bone = 56604 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_stronzo_beer'] = { -- idea: Player uses item to show badge prop
        label = 'Case of Stronzo Beer',
        weight = 3500,
        --consume = 0,
        description = "Oh boy I love beer",
        client = {
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 
            clip = 'machinic_loop_mechandplayer', flag = 3 },
            prop = { model = 'v_ind_cfbox2', -- need badge props repo
            pos = vec3(-0.05, 0.8, -0.25), 
            rot = vec3(0.00, 0.00, 0.00), 
            bone = 56604 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_patriot_beer'] = { -- idea: Player uses item to show badge prop
        label = 'Case of Patriot Beer',
        weight = 3500,
        --consume = 0,
        description = "Oh boy I love beer",
        client = {
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 
            clip = 'machinic_loop_mechandplayer', flag = 3 },
            prop = { model = 'v_ind_cfbox2', -- need badge props repo
            pos = vec3(-0.05, 0.8, -0.25), 
            rot = vec3(0.00, 0.00, 0.00), 
            bone = 56604 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- USABLES: Pizza boxes
    ['box_pizza_chs'] = { -- idea: Player uses item to show badge prop
        label = 'Box of Cheese Pizza',
        weight = 3500,
        --consume = 0,
        description = "A box of cheesy goodness, my guy",
        client = {
            anim = { dict = 'anim@heists@box_carry@', clip = 'idle', flag = 49 },
            prop = { model = 'bzzz_pizzahut_box_a', -- need badge props repo
            pos = vec3(0.010, -0.100, -0.159), 
            rot = vec3(20.000, 0.000, 0.000), 
            bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_pizza_pep'] = { -- idea: Player uses item to show badge prop
        label = 'Box of Pepperoni Pizza',
        weight = 3500,
        --consume = 0,
        description = "A box of cheesy goodness, my guy",
        client = {
            anim = { dict = 'anim@heists@box_carry@', clip = 'idle', flag = 49 },
            prop = { model = 'bzzz_pizzahut_box_a', -- need badge props repo
            pos = vec3(0.010, -0.100, -0.159), 
            rot = vec3(20.000, 0.000, 0.000), 
            bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_pizza_msh'] = { -- idea: Player uses item to show badge prop
        label = 'Box of Mushroom Pizza',
        weight = 3500,
        --consume = 0,
        description = "A box of cheesy goodness, my guy",
        client = {
            anim = { dict = 'anim@heists@box_carry@', clip = 'idle', flag = 49 },
            prop = { model = 'bzzz_pizzahut_box_a', -- need badge props repo
            pos = vec3(0.010, -0.100, -0.159), 
            rot = vec3(20.000, 0.000, 0.000), 
            bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_pizza_mgt'] = { -- idea: Player uses item to show badge prop
        label = 'Box of Margherita Pizza',
        weight = 3500,
        --consume = 0,
        description = "A box of cheesy goodness, my guy",
        client = {
            anim = { dict = 'anim@heists@box_carry@', clip = 'idle', flag = 49 },
            prop = { model = 'bzzz_pizzahut_box_a', -- need badge props repo
            pos = vec3(0.010, -0.100, -0.159), 
            rot = vec3(20.000, 0.000, 0.000), 
            bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_pizza_dmt'] = { -- idea: Player uses item to show badge prop
        label = 'Box of Double Meat Pizza',
        weight = 3500,
        --consume = 0,
        description = "A box of cheesy goodness, my guy",
        client = {
            anim = { dict = 'anim@heists@box_carry@', clip = 'idle', flag = 49 },
            prop = { model = 'bzzz_pizzahut_box_a', -- need badge props repo
            pos = vec3(0.010, -0.100, -0.159), 
            rot = vec3(20.000, 0.000, 0.000), 
            bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },


    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- USABLES: Ammo cases
    ['box_ammo_rifle1'] = { -- idea: Player uses item to show badge prop
        label = 'Ammo Case: 5.56x45 (x120)',
        weight = 5,
        --consume = 0,
        description = "A case of stuff to make problems go away",
        client = {
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 
            clip = 'machinic_loop_mechandplayer', flag = 3 },
            prop = { model = 'prop_box_ammo02a', -- need badge props repo
            pos = vec3(0.0, 0.7, -0.40), 
            rot = vec3(0.00, 0.00, 90.00), 
            bone = 56604  },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_ammo_rifle2'] = { -- idea: Player uses item to show badge prop
        label = 'Ammo Case: 7.62x39 (x120)',
        weight = 5,
        --consume = 0,
        description = "A case of stuff to make problems go away",
        client = {
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 
            clip = 'machinic_loop_mechandplayer', flag = 3 },
            prop = { model = 'prop_box_ammo02a', -- need badge props repo
            pos = vec3(0.0, 0.7, -0.40), 
            rot = vec3(0.00, 0.00, 90.00), 
            bone = 56604  },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_ammo_shotgun'] = { -- idea: Player uses item to show badge prop
        label = 'Ammo Case: 12 Gauge (x60)',
        weight = 5,
        --consume = 0,
        description = "A case of stuff to make problems go away",
        client = {
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 
            clip = 'machinic_loop_mechandplayer', flag = 3 },
            prop = { model = 'prop_box_ammo02a', -- need badge props repo
            pos = vec3(0.0, 0.7, -0.40), 
            rot = vec3(0.00, 0.00, 90.00), 
            bone = 56604  },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['box_ammo_sniper'] = { -- idea: Player uses item to show badge prop
        label = 'Ammo Case: 7.62x51 (x30)',
        weight = 5,
        --consume = 0,
        description = "A case of stuff to make problems go away",
        client = {
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 
            clip = 'machinic_loop_mechandplayer', flag = 3 },
            prop = { model = 'prop_box_ammo02a', -- need badge props repo
            pos = vec3(0.0, 0.7, -0.40), 
            rot = vec3(0.00, 0.00, 90.00), 
            bone = 56604  },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },









    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- USABLE: Items
    ['dingus'] = { -- idea: Player uses item to show badge prop
        label = 'Dingus',
        weight = 6969,
        consume = 0,
        description = "Oh man, what a dingus, just Look at em",
        client = {
            anim = { dict = 'paper_1_rcm_alt1-8', clip = 'player_one_dual-8', flag = 49 },
            prop = { model = 'dingus', -- need badge props repo
            pos = vec3(0.13, 0.023, -0.04), rot = vec3(-90.0, -180.0, 300.0), bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },


-- Wallets

    ['wallet'] = { -- Use to hold licenses
        label = 'Wallet',
        weight = 115,
        description = "If you lose this, you're gonna be sorry",
        client = {
            anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
            prop = { model = 'prop_rolled_sock_02', 
            pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
            disable = { move = true, car = true, combat = true },
            usetime = 2500,
        }
    },











--

    ['cigarette'] = { -- social item that causes slight damage to health
        label = 'Cigarettes',
        weight = 115,
        description = "These probably aren't good for you, but fuck it",
        client = {
            anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c', flag = 49 },
            prop = { model = 'ng_proc_cigarette01a', 
            pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422 },
            disable = { move = false, car = false, combat = true },
            usetime = 16000,
        }
    },

    -- TESTING Cigarettes script
    ['redwoods'] = {
        label = 'Redwoods',
        weight = 50,
        stack = false,
        close = true,
        description = 'Pack of Original Red Wood Killer Cigarettes',
        consume = 0,
        durablity = 5, 
        client = {
            status = { stress = -100000 },
            anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c', flag = 49 },
            prop = { model = 'ng_proc_cigarette01a', 
            pos = { x = 0.00, y = 0.0, z = -0.00}, 
            rot = { x = 0.0, y = 0.0, z = 0.0}, 
            bone = 28422 },
            usetime = 15000,
        },
        buttons = {
            {
                label = 'Remove Cigarette',
                action = function(slot)
                    TriggerServerEvent('gr8_stuff:item:removeCig', slot, {indent=true})
                end
            },
        }
    },

    ['cigar'] = { -- social item that causes slight damage to health
        label = 'Cigar',
        weight = 115,
        description = "These REALLY aren't good for you, but fuck it",
        client = {
            anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c', flag = 49 },
            prop = { model = 'ng_proc_cigar01a', 
            pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 180.0, 0.0), bone = 28422 },
            disable = { move = false, car = false, combat = true },
            usetime = 15000,
        }
    },

    -- If you are below the mpchristmas3 update, change the prop to 'ba_prop_battle_vape_01'
    ['vape'] = { -- social item that causes slight damage to health
        label = 'Vape',
        weight = 115,
        description = "Vape-nash bruh, tastes like dissapointment",
        consume = 0,
        durability = 1,
        client = {
            anim = { dict = 'amb@world_human_smoking@male@male_b@base', clip = 'base', flag = 49 },
            prop = { model = 'xm3_prop_xm3_vape_01a',
            pos = vec3(-0.02, -0.02, 0.02), rot = vec3(70.0, 110.0, 10.0), bone = 28422 },

            disable = { move = false, car = false, combat = false },
            usetime = 7000,
        }
    },

	['bulletproofvest'] = {
		label = 'NIJ+ Level IV Plates',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500,
			export = 'pnt_bulletProofVest.bulletproofvest',
		},
	},

	['mediumbulletproofvest'] = {
		label = 'NIJ Level IIIA Plates',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500,
			export = 'pnt_bulletProofVest.mediumbulletproofvest',
		},
	},

	['lowbulletproofvest'] = {
		label = 'NIJ Level IIA PLates',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500,
			export = 'pnt_bulletProofVest.lowbulletproofvest',
		},
	},




    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- DRUGS: Weed
    ['weed_sativa'] = { -- idea: use for player to hype up
        label = '3oz Amnesia Haze',
        consume = 0.267,
        weight = 15,
        description = "Oh man, what a dingus, just Look at em",
        client = {
            anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c', flag = 49 },
            prop = { model = 'bzzz_cigarpack_cig003', 
            pos = vec3(-0.01, 0.0, 0.0), rot = vec3(0.0, 180.0, 0.0), bone = 28422 },
            disable = { move = false, car = false, combat = true },
            usetime = 16000,
        }
    },

    ['weed_indica'] = { -- idea: use for player to relax
        label = '3oz Afghan Kush',
        consume = 0.267,
        weight = 15,
        description = "Oh man, what a dingus, just Look at em",
        client = {
            anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c', flag = 49 },
            prop = { model = 'bzzz_cigarpack_cig003', 
            pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422 },
            disable = { move = false, car = false, combat = true },
            usetime = 16000,
        }
    },

    ['weed_hybrid'] = { -- idea: higher end weed
        label = '3oz White Widow',
        consume = 0.267,
        weight = 15,
        description = "Oh man, what a dingus, just Look at em",
        client = {
            anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c', flag = 49 },
            prop = { model = 'bzzz_cigarpack_cig003', 
            pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422 },
            disable = { move = false, car = false, combat = true },
            usetime = 16000,
        }
    },










    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- BADGES: Police
    ['badge_fib'] = { -- idea: Player uses item to show badge prop
        label = 'FIB Badge',
        weight = 444,
        consume = 0,
        description = "For official use by FIB Agents only",
        client = {
            anim = { dict = 'paper_1_rcm_alt1-8', clip = 'player_one_dual-8', flag = 49 },
            prop = { model = 'prop_fibb_badge', -- need badge props repo
            pos = vec3(0.13, 0.023, -0.04), rot = vec3(-90.0, -180.0, 300.0), bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['badge_bcso'] = { -- idea: Player uses item to show badge prop
        label = 'BCSO Badge',
        weight = 444,
        consume = 0,
        description = "For official use by FIB Agents only",
        client = {
            anim = { dict = 'paper_1_rcm_alt1-8', clip = 'player_one_dual-8', flag = 49 },
            prop = { model = 'prop_bcso_badge', -- need badge props repo
            pos = vec3(0.13, 0.023, -0.04), rot = vec3(-90.0, -180.0, 300.0), bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['badge_lssd'] = { -- idea: Player uses item to show badge prop
        label = 'LSSD Badge',
        weight = 444,
        consume = 0,
        description = "For official use by FIB Agents only",
        client = {
            anim = { dict = 'paper_1_rcm_alt1-8', clip = 'player_one_dual-8', flag = 49 },
            prop = { model = 'prop_lssd_badge', -- need badge props repo
            pos = vec3(0.13, 0.023, -0.04), rot = vec3(-90.0, -180.0, 300.0), bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },

    ['badge_lspd'] = { -- idea: Player uses item to show badge prop
        label = 'LSPD Badge',
        weight = 444,
        consume = 0,
        description = "For official use by FIB Agents only",
        client = {
            anim = { dict = 'paper_1_rcm_alt1-8', clip = 'player_one_dual-8', flag = 49 },
            prop = { model = 'prop_lspd_badge', -- need badge props repo
            pos = vec3(0.13, 0.023, -0.04), rot = vec3(-90.0, -180.0, 300.0), bone = 28422 },
            disable = { move = false, car = false, combat = false },
            usetime = 5000,
        }
    },









    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- MRE: Meal Ready to Eat
    ['mre_1'] = { 
        label = 'MRE-001',
        weight = 3500,
        stack = false,
        close = false,
        description = "Contains: Meal, Side, Bread, Dessert",
    },

    ['mre_2'] = { 
        label = 'MRE-002',
        weight = 3500,
        stack = false,
        close = false,
        description = "Contains: Meal, Side, Bread, Dessert",
    },

    ['mre_3'] = { 
        label = 'MRE-003',
        weight = 3500,
        stack = false,
        close = false,
        description = "Contains: Meal, Side, Bread, Dessert",
    },

    ['mre_4'] = { 
        label = 'MRE-004',
        weight = 3500,
        stack = false,
        close = false,
        description = "Contains: Meal, Side, Bread, Dessert",
    },

    ['mre_5'] = { 
        label = 'MRE-005',
        weight = 3500,
        stack = false,
        close = false,
        description = "Contains: Meal, Side, Bread, Dessert",
    },

    -- Main meals
    ['mre_chilimac'] = { 
        label = 'MRE - Chili Mac',
        weight = 1250,
        stack = true,
        close = true,
        description = "Meal-ready-to-eat",
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_res_fa_tincorn', 
            pos = vec3(-0.01, -0.01, 0.01), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['mre_beefstew'] = { 
        label = 'MRE - Beef Stew',
        weight = 1250,
        stack = true,
        close = true,
        description = "Meal-ready-to-eat",
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_res_fa_tincorn', 
            pos = vec3(-0.01, -0.01, 0.01), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['mre_chkenchilada'] = { 
        label = 'MRE - Chkn Enchiladas',
        weight = 1250,
        stack = true,
        close = true,
        description = "Meal-ready-to-eat",
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_res_fa_tincorn', 
            pos = vec3(-0.01, -0.01, 0.01), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['mre_veggieomelet'] = { 
        label = 'MRE - Veggie Omelet',
        weight = 1250,
        stack = true,
        close = true,
        description = "Meal-ready-to-eat",
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_res_fa_tincorn', 
            pos = vec3(-0.01, -0.01, 0.01), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['mre_chknking'] = { 
        label = 'MRE - Chicken-a-la-king',
        weight = 1250,
        stack = true,
        close = true,
        description = "Meal-ready-to-eat",
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_res_fa_tincorn', 
            pos = vec3(-0.01, -0.01, 0.01), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    -- Supp. food
    ['mre_tmsoup'] = { 
        label = 'MRE Tom. soup',
        weight = 1250,
        stack = true,
        close = true,
        description = "Standard military side soup",
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_res_fa_tintomsoup', 
            pos = vec3(-0.01, -0.01, 0.01), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['mre_corn'] = { 
        label = 'MRE Canned Corn',
        weight = 1250,
        stack = true,
        close = true,
        description = "Standard military side dish",
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'v_res_fa_tincorn', 
            pos = vec3(-0.01, -0.01, 0.01), rot = vec3(1.0, 5.0, -182.5) },
            usetime = 7500,
        },
    },

    ['mre_bread'] = { 
        label = 'MRE Bread',
        weight = 1250,
        stack = true,
        close = true,
        description = "Standard military bread",
        client = {
            status = { hunger = 250000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'v_res_fa_bread03', 
            bone = 18905,
            pos = vec3(0.14, 0.03, 0.01), 
            rot = vec3(85.0, 70.0, -203.0) },
            usetime = 7500,
        },
    },
    


--------------------------------------------------------------------------------
---
---MT-RESTURANTS
---
--------------------------------------------------------------------------------
["restaurant_food"] = {
    label = "Restaurant food",
    weight = 0,
    stack = true,
    close = true,
    client = {
        export = 'mt-restaurants.useFoodItem'
    }
},
["restaurant_box"] = {
    label = "Restaurant Box",
    weight = 0,
    stack = true,
    close = true,
    client = {
        export = 'mt-restaurants.useBoxItem'
    }
},
["restaurant_menu"] = {
    label = "Restaurant Menu",
    weight = 0,
    stack = true,
    close = true,
    client = {
        export = 'mt-restaurants.openMenu'
    }
},
--PROTEIN--
['ground_beef'] = { 
    label = 'Ground Beef', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Ground Beef', 
},
['steak'] = { 
    label = 'Steak', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Steak', 
},
['chicken_breast'] = { 
    label = 'Chicken Breast', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chicken Breast', 
},
['bacon'] = { 
    label = 'Bacon', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Bacon', 
},
['egg'] = { 
    label = 'Egg', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Egg', 
},
['tofu_block'] = { 
    label = 'Tofu Block', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tofu Block', 
},
['tofu_slices'] = { 
    label = 'Tofu Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tofu Slices', 
},
['sausage_link'] = { 
    label = 'Sausage Link', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Sausage Link', 
},
['lamb_chop'] = { 
    label = 'Lamb Chop', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Lamb Chop', 
},
['duck_breast'] = { 
    label = 'Duck Breast', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Duck Breast', 
},
['prawn'] = { 
    label = 'Shrimp', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Shrimp', 
},
['beans'] = { 
    label = 'Beans', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Beans', 
},
['lentils'] = { 
    label = 'Lentils', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Lentils', 
},
['pepperoni'] = { 
    label = 'Pepperoni', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pepperoni', 
},
['pepperoni_slices'] = { 
    label = 'Pepperoni Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pepperoni Slices', 
},
['italian_sausage'] = { 
    label = 'Italian Sausage', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Italian Sausage', 
},
['anchovies'] = { 
    label = 'Anchovies', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Anchovies', 
},
['prosciutto'] = { 
    label = 'Prosciutto', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Prosciutto', 
},
['chicken_wings'] = { 
    label = 'Chicken Wings', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chicken Wings', 
},
['pork_chop'] = { 
    label = 'Pork Chop', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pork Chop', 
},
['almonds'] = {
    label = 'Almonds',
    weight = 10,
    stack = true,
    close = true,
    description = 'Almonds',
},
['chopped_almonds'] = {
    label = 'Chopped Almonds',
    weight = 10,
    stack = true,
    close = true,
    description = 'Chopped Almonds',
},
['peanuts'] = {
    label = 'Peanuts',
    weight = 10,
    stack = true,
    close = true,
    description = 'Peanuts',
},
['chopped_peanuts'] = {
    label = 'Chopped Peanuts',
    weight = 10,
    stack = true,
    close = true,
    description = 'Chopped Peanuts',
},
['walnuts'] = {
    label = 'Walnuts',
    weight = 10,
    stack = true,
    close = true,
    description = 'Walnuts',
},
['chopped_walnuts'] = {
    label = 'Chopped Walnuts',
    weight = 10,
    stack = true,
    close = true,
    description = 'Chopped Walnuts',
},
['pecans'] = {
    label = 'Pecans',
    weight = 10,
    stack = true,
    close = true,
    description = 'Pecans',
},
['chopped_pecans'] = {
    label = 'Chopped Pecans',
    weight = 10,
    stack = true,
    close = true,
    description = 'Chopped Pecans',
},
['tuna'] = {
    label = 'Tuna',
    weight = 10,
    stack = true,
    close = true,
    description = 'Tuna',
},
['chopped_tuna'] = {
    label = 'Tuna Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Tuna Filet',
},
['salmon'] = {
    label = 'Salmon',
    weight = 10,
    stack = true,
    close = true,
    description = 'Salmon',
},
['chopped_salmon'] = {
    label = 'Salmon Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Salmon Filet',
},
['mackarel'] = {
    label = 'Mackarel',
    weight = 10,
    stack = true,
    close = true,
    description = 'Mackarel',
},
['chopped_mackarel'] = {
    label = 'Mackarel Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Mackarel Filet',
},
['eel_freshwater'] = {
    label = 'Freshwater Eel',
    weight = 10,
    stack = true,
    close = true,
    description = 'Freshwater Eel',
},
['eel_saltwater'] = {
    label = 'Saltwater Eel',
    weight = 10,
    stack = true,
    close = true,
    description = 'Saltwater Eel',
},
['sardine'] = {
    label = 'Sardine',
    weight = 10,
    stack = true,
    close = true,
    description = 'Sardine',
},
['scallop'] = {
    label = 'Scallop',
    weight = 10,
    stack = true,
    close = true,
    description = 'Scallop',
},
['squid'] = {
    label = 'Squid',
    weight = 10,
    stack = true,
    close = true,
    description = 'Squid',
},
['octopus'] = {
    label = 'Octopus',
    weight = 10,
    stack = true,
    close = true,
    description = 'Octopus',
},
['cod'] = {
    label = 'Cod',
    weight = 10,
    stack = true,
    close = true,
    description = 'Cod',
},
['chopped_cod'] = {
    label = 'Cod Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Cod Filet',
},
['tilapia'] = {
    label = 'Tilapia',
    weight = 10,
    stack = true,
    close = true,
    description = 'Tilapia',
},
['chopped_tilapia'] = {
    label = 'Tilapia Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Tilapia Filet',
},
['catfish'] = {
    label = 'Catfish',
    weight = 10,
    stack = true,
    close = true,
    description = 'Catfish',
},
['chopped_catfish'] = {
    label = 'Catfish Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Catfish Filet',
},
['trout'] = {
    label = 'Trout',
    weight = 10,
    stack = true,
    close = true,
    description = 'Trout',
},
['chopped_trout'] = {
    label = 'Trout Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Trout Filet',
},
['halibut'] = {
    label = 'Halibut',
    weight = 10,
    stack = true,
    close = true,
    description = 'Halibut',
},
['chopped_halibut'] = {
    label = 'Halibut Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Halibut Filet',
},
['red_snapper'] = {
    label = 'Red Snapper',
    weight = 10,
    stack = true,
    close = true,
    description = 'Red Snapper',
},
['chopped_red_snapper'] = {
    label = 'Red Snapper Filet',
    weight = 10,
    stack = true,
    close = true,
    description = 'Red Snapper Filet',
},
['imitation_crab'] = {
    label = 'Imitation Crab',
    weight = 10,
    stack = true,
    close = true,
    description = 'Imitation Crab',
},
['crab'] = {
    label = 'Crab',
    weight = 10,
    stack = true,
    close = true,
    description = 'Crab',
},
['lobster'] = {
    label = 'Lobster',
    weight = 10,
    stack = true,
    close = true,
    description = 'Lobster',
},
['oyster'] = {
    label = 'Oyster',
    weight = 10,
    stack = true,
    close = true,
    description = 'Oyster',
},
['clam'] = {
    label = 'Clam',
    weight = 10,
    stack = true,
    close = true,
    description = 'Clam',
},
['mussel'] = {
    label = 'Mussel',
    weight = 10,
    stack = true,
    close = true,
    description = 'Mussel',
},
['crawfish'] = {
    label = 'Crawfish',
    weight = 10,
    stack = true,
    close = true,
    description = 'Crawfish',
},
['bonito_flakes'] = {
    label = 'Bonito Flakes',
    weight = 10,
    stack = true,
    close = true,
    description = 'Bonito Flakes',
},
['caviar'] = {
    label = 'Caviar',
    weight = 10,
    stack = true,
    close = true,
    description = 'Caviar',
},
['flying_fish_roe'] = {
    label = 'Flying Fish Roe',
    weight = 10,
    stack = true,
    close = true,
    description = 'Flying Fish Roe',
},
['salmon_roe'] = {
    label = 'Salmon Roe',
    weight = 10,
    stack = true,
    close = true,
    description = 'Salmon Roe',
},


--VEGETABLES--
['potato'] = { 
    label = 'Potato', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Potato', 
},
['potato_slices'] = { 
    label = 'Potato Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Potato Slices', 
},
['corn'] = { 
    label = 'Corn', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Corn', 
},
['carrot'] = { 
    label = 'Carrot', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Carrot', 
},
['carrot_slices'] = { 
    label = 'Carrot Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Carrot Slices', 
},
['onion'] = { 
    label = 'Onion', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Onion', 
},
['onion_slices'] = { 
    label = 'Onion Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Onion Slices', 
},
['lettuce'] = { 
    label = 'Lettuce', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Lettuce', 
},
['chopped_lettuce'] = { 
    label = 'Chopped Lettuce', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Lettuce', 
},
['bell_pepper'] = { 
    label = 'Bell Pepper', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Bell Pepper', 
},
['bell_pepper_slices'] = { 
    label = 'Bell Pepper Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Bell Pepper Slices', 
},
['spinach'] = { 
    label = 'Spinach', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Spinach', 
},
['chopped_spinach'] = { 
    label = 'Chopped Spinach', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Spinach', 
},
['mushroom'] = { 
    label = 'Mushroom', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mushroom', 
},
['mushroom_slices'] = { 
    label = 'Mushroom Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mushroom Slices', 
},
['broccoli'] = { 
    label = 'Broccoli', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Broccoli', 
},
['chopped_broccoli'] = { 
    label = 'Chopped Broccoli', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Broccoli', 
},
['sweet_potato'] = { 
    label = 'Sweet Potato', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Sweet Potato', 
},
['sweet_potato_slices'] = { 
    label = 'Sweet Potato Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Sweet Potato Slices', 
},
['zucchini'] = { 
    label = 'Zucchini', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Zucchini', 
},
['zucchini_slices'] = { 
    label = 'Zucchini Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Zucchini Slices', 
},
['cabbage'] = { 
    label = 'Cabbage', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cabbage', 
},
['chopped_cabbage'] = { 
    label = 'Chopped Cabbage', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Cabbage', 
},
['beetroot'] = { 
    label = 'Beetroot', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Beetroot', 
},
['beetroot_slices'] = { 
    label = 'Beetroot Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Beetroot Slices', 
},
['cucumber'] = { 
    label = 'Cucumber', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cucumber', 
},
['cucumber_slices'] = { 
    label = 'Cucumber Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cucumber Slices', 
},
['eggplant'] = { 
    label = 'Eggplant', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Eggplant', 
},
['eggplant_slices'] = { 
    label = 'Eggplant Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Eggplant Slices', 
},
['kale'] = { 
    label = 'Kale', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Kale', 
},
['chopped_kale'] = { 
    label = 'Chopped Kale', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Kale', 
},
['cauliflower'] = { 
    label = 'Cauliflower', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cauliflower', 
},
['chopped_cauliflower'] = { 
    label = 'Chopped Cauliflower', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Cauliflower', 
},
['asparagus'] = { 
    label = 'Asparagus', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Asparagus', 
},
['brussels_sprouts'] = { 
    label = 'Brussels Sprouts', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Brussels Sprouts', 
},
['chopped_brussels_sprouts'] = { 
    label = 'Chopped Brussels Sprouts', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Brussels Sprouts', 
},
['butternut_squash'] = { 
    label = 'Butternut Squash', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Butternut Squash', 
},
['chopped_butternut_squash'] = { 
    label = 'Chopped Butternut Squash', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Butternut Squash', 
},
['turnip'] = { 
    label = 'Turnip', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Turnip', 
},
['turnip_slices'] = { 
    label = 'Turnip Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Turnip Slices', 
},
['radish'] = { 
    label = 'Radish', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Radish', 
},
['radish_slices'] = { 
    label = 'Radish Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Radish Slices', 
},
['leek'] = { 
    label = 'Leek', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Leek', 
},
['cut_leek'] = { 
    label = 'Cut Leek', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cut Leek', 
},
['okra'] = { 
    label = 'Okra', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Okra', 
},
['garlic'] = { 
    label = 'Garlic', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Garlic', 
},
['chopped_garlic'] = { 
    label = 'Chopped Garlic', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Garlic', 
},
['ginger'] = { 
    label = 'Ginger', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Ginger', 
},
['chopped_ginger'] = { 
    label = 'Chopped Ginger', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Ginger', 
},
['black_olives'] = { 
    label = 'Black Olives', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Black Olives', 
},
['green_olives'] = { 
    label = 'Green Olives', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Green Olives', 
},
['artichoke_hearts'] = { 
    label = 'Artichoke Hearts', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Artichoke Hearts', 
},
['chopped_artichoke_hearts'] = { 
    label = 'Chopped Artichoke Hearts', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chopped Artichoke Hearts', 
},
['sun_dried_tomatoes'] = { 
    label = 'Sun Dried Tomatoes', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Sun Dried Tomatoes', 
},
['roasted_red_peppers'] = { 
    label = 'Roasted Red Peppers', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Roasted Red Peppers', 
},
['jalapenos'] = { 
    label = 'Jalapenos', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Jalapenos', 
},
['jalapeno_slices'] = { 
    label = 'Jalapeno Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Jalapeno Slices', 
},
['pickles'] = { 
    label = 'Pickles', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pickles', 
},
['pickle_slices'] = { 
    label = 'Pickle Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pickle Slices', 
},
['green_onions'] = {
    label = 'Green Onions',
    weight = 10,
    stack = true,
    close = true,
    description = 'Green Onions',
},

['chopped_green_onions'] = {
    label = 'Chopped Green Onions',
    weight = 10,
    stack = true,
    close = true,
    description = 'Chopped Green Onions',
},

['bok_choy'] = {
    label = 'Bok Choy',
    weight = 10,
    stack = true,
    close = true,
    description = 'Bok Choy',
},

['chopped_bok_choy'] = {
    label = 'Chopped Bok Choy',
    weight = 10,
    stack = true,
    close = true,
    description = 'Chopped Bok Choy',
},

['napa_cabbage'] = {
    label = 'Napa Cabbage',
    weight = 10,
    stack = true,
    close = true,
    description = 'Napa Cabbage',
},

['chopped_napa_cabbage'] = {
    label = 'Chopped Napa Cabbage',
    weight = 10,
    stack = true,
    close = true,
    description = 'Chopped Napa Cabbage',
},


--FRUITS--
['tomato'] = { 
    label = 'Tomato', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tomato', 
},
['tomato_slices'] = { 
    label = 'Tomato Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tomato Slices', 
},
['apple_slices'] = { 
    label = 'Apple Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Apple Slices', 
},
['banana_slices'] = { 
    label = 'Banana Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Banana Slices', 
},
['orange'] = { 
    label = 'Orange', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Orange', 
},
['orange_slices'] = { 
    label = 'Orange Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Orange Slices', 
},
['watermelon'] = { 
    label = 'Watermelon', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Watermelon', 
},
['watermelon_slice'] = { 
    label = 'Watermelon Slice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Watermelon Slice', 
},
['grapes'] = { 
    label = 'Grapes', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Grapes', 
},
['pineapple'] = { 
    label = 'Pineapple', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pineapple', 
},
['pineapple_slices'] = { 
    label = 'Pineapple Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pineapple Slices', 
},
['kiwi'] = { 
    label = 'Kiwi', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Kiwi', 
},
['kiwi_slices'] = { 
    label = 'Kiwi Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Kiwi Slices', 
},
['pear'] = { 
    label = 'Pear', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pear', 
},
['pear_slices'] = { 
    label = 'Pear Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pear Slices', 
},
['mango'] = { 
    label = 'Mango', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mango', 
},
['mango_slices'] = { 
    label = 'Mango Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mango Slices', 
},
['papaya'] = { 
    label = 'Papaya', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Papaya', 
},
['papaya_slices'] = { 
    label = 'Papaya Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Papaya Slices', 
},
['avocado'] = { 
    label = 'Avocado', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Avocado', 
},
['avocado_slices'] = { 
    label = 'Avocado Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Avocado Slices', 
},
['peach'] = { 
    label = 'Peach', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Peach', 
},
['peach_slices'] = { 
    label = 'Peach Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Peach Slices', 
},
['cherry'] = { 
    label = 'Cherry', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cherry', 
},
['cranberry'] = { 
    label = 'Cranberry', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cranberry', 
},
['plum'] = { 
    label = 'Plum', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Plum', 
},
['plum_slices'] = { 
    label = 'Plum Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Plum Slices', 
},
['blueberry'] = { 
    label = 'Blueberry', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Blueberry', 
},
['raspberry'] = { 
    label = 'Raspberry', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Raspberry', 
},
['cantaloupe'] = { 
    label = 'Cantaloupe', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cantaloupe', 
},
['cantaloupe_slices'] = { 
    label = 'Cantaloupe Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cantaloupe Slices', 
},

['strawberry'] = {
    label = 'Strawberry',
    weight = 10,
    stack = true,
    close = true,
    description = 'Strawberry',
},

['strawberry_slices'] = {
    label = 'Strawberry Slices',
    weight = 10,
    stack = true,
    close = true,
    description = 'Strawberry Slices',
},

--GRAINS--
['bread_loaf'] = { 
    label = 'Bread', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Bread', 
},
['bread_slice'] = { 
    label = 'Bread Slice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Bread Slice', 
},
['rice'] = { 
    label = 'Rice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Rice', 
},
['oats'] = { 
    label = 'Oats', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Oats', 
},
['flour'] = { 
    label = 'Flour', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Flour', 
},
['tortilla'] = { 
    label = 'Tortilla', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tortilla', 
},
['quinoa'] = { 
    label = 'Quinoa', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Quinoa', 
},
['barley'] = { 
    label = 'Barley', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Barley', 
},
['couscous'] = { 
    label = 'Couscous', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Couscous', 
},
['pita_bread'] = { 
    label = 'Pita Bread', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pita Bread', 
},
['instant_ramen'] = { 
    label = 'Instant Ramen', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Instant Ramen', 
},
['granola'] = { 
    label = 'Granola', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Granola', 
},
['spaghetti'] = { 
    label = 'Spaghetti', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Spaghetti', 
},
['penne'] = { 
    label = 'Penne', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Penne', 
},
['fettuccine'] = { 
    label = 'Fettuccine', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Fettuccine', 
},
['ziti'] = { 
    label = 'Ziti', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Ziti', 
},
['lasagna_noodles'] = { 
    label = 'Lasagna Noodles', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Lasagna Noodles', 
},
['farfalle'] = { 
    label = 'Farfalle', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Farfalle', 
},
['wonton_skins'] = {
    label = 'Wonton Skins',
    weight = 10,
    stack = true,
    close = true,
    description = 'Wonton Skins',
},

['wonton_single'] = {
    label = 'Wonton Single',
    weight = 10,
    stack = true,
    close = true,
    description = 'Wonton Single',
},

['panko'] = {
    label = 'Panko',
    weight = 10,
    stack = true,
    close = true,
    description = 'Panko',
},

--JUICE--
['lemon'] = { 
    label = 'Lemon', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Lemon', 
},
['lemon_juice'] = { 
    label = 'Lemon Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Lemon Juice', 
},
['lime'] = { 
    label = 'Lime', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Lime', 
},
['lime_juice'] = { 
    label = 'Lime Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Lime Juice', 
},
['orange_juice'] = { 
    label = 'Orange Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Orange Juice', 
},
['cranberry_juice'] = { 
    label = 'Cranberry Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cranberry Juice', 
},
['pineapple_juice'] = { 
    label = 'Pineapple Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pineapple Juice', 
},
['tomato_juice'] = { 
    label = 'Tomato Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tomato Juice', 
},
['watermelon_juice'] = { 
    label = 'Watermelon Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Watermelon Juice', 
},
['grape_juice'] = { 
    label = 'Grape Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Grape Juice', 
},
['mango_juice'] = { 
    label = 'Mango Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mango Juice', 
},
['peach_juice'] = { 
    label = 'Peach Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Peach Juice', 
},
['cherry_juice'] = { 
    label = 'Cherry Juice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cherry Juice', 
},
['strawberry_juice'] = {
    label = 'Strawberry Juice',
    weight = 10,
    stack = true,
    close = true,
    description = 'Strawberry Juice',
},

--BEVERAGE STUFF--
['boba_pearls'] = { 
    label = 'Boba Pearls', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Boba Pearls', 
},
['matcha_powder'] = { 
    label = 'Matcha Powder', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Matcha Powder', 
},
['coffee_beans'] = { 
    label = 'Coffee Beans', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Coffee Beans', 
},
['black_tea_leaves'] = { 
    label = 'Black Tea Leaves', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Black Tea Leaves', 
},
['green_tea_leaves'] = { 
    label = 'Green Tea Leaves', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Green Tea Leaves', 
},
['chai_spice'] = { 
    label = 'Chai Spice', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chai Spice', 
},
['cocoa_mix'] = { 
    label = 'Cocoa Mix', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cocoa Mix', 
},
['syrup_vanilla'] = { 
    label = 'Syrup Vanilla', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Syrup Vanilla', 
},
['syrup_caramel'] = { 
    label = 'Syrup Caramel', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Syrup Caramel', 
},
['syrup_hazelnut'] = { 
    label = 'Syrup Hazelnut', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Syrup Hazelnut', 
},
['carbonated_water'] = { 
    label = 'Carbonated Water', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Carbonated Water', 
},
['dried_hibiscus'] = {
    label = 'Dried Hibiscus',
    weight = 10,
    stack = true,
    close = true,
    description = 'Dried Hibiscus',
},
['popping_boba'] = {
    label = 'Popping Boba',
    weight = 10,
    stack = true,
    close = true,
    description = 'Popping Boba',
},

--DAIRY--
['butter'] = { 
    label = 'Butter', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Butter', 
},
['yogurt'] = { 
    label = 'Yogurt', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Yogurt', 
},
['cream'] = { 
    label = 'Cream', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cream', 
},
['almond_milk'] = { 
    label = 'Almond Milk', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Almond Milk', 
},
['coconut_milk'] = { 
    label = 'Coconut Milk', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Coconut Milk', 
},
['parmesan'] = { 
    label = 'Parmesan', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Parmesan', 
},
['ice_cream'] = { 
    label = 'Ice Cream', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Ice Cream', 
},
['oat_milk'] = { 
    label = 'Oat Milk', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Oat Milk', 
},
['mozzarella_cheese'] = { 
    label = 'Mozzarella Cheese', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mozzarella Cheese', 
},
['mozzarella_cheese_slices'] = { 
    label = 'Mozzarella Cheese Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mozzarella Cheese Slices', 
},
['ricotta'] = { 
    label = 'Ricotta', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Ricotta', 
},
['mascarpone'] = { 
    label = 'Mascarpone', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mascarpone', 
},
['cheddar_cheese'] = { 
    label = 'Cheddar Cheese', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cheddar Cheese', 
},
['cheddar_cheese_slices'] = { 
    label = 'Cheddar Cheese Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cheddar Cheese Slices', 
},
['american_cheese'] = { 
    label = 'American Cheese', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'American Cheese', 
},
['american_cheese_slices'] = { 
    label = 'American Cheese Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'American Cheese Slices', 
},
['swiss_cheese'] = { 
    label = 'Swiss Cheese', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Swiss Cheese', 
},
['swiss_cheese_slices'] = { 
    label = 'Swiss Cheese Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Swiss Cheese Slices', 
},
['gouda_cheese'] = { 
    label = 'Gouda Cheese', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Gouda Cheese', 
},
['gouda_cheese_slices'] = { 
    label = 'Gouda Cheese Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Gouda Cheese Slices', 
},
['provolone_cheese'] = { 
    label = 'Provolone Cheese', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Provolone Cheese', 
},
['provolone_cheese_slices'] = { 
    label = 'Provolone Cheese Slices', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Provolone Cheese Slices', 
},
['feta_cheese'] = { 
    label = 'Feta Cheese', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Feta Cheese', 
},
['feta_cheese_slices'] = { 
    label = 'Feta Cheese Crumbles', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Feta Cheese Crumbles', 
},
['goat_cheese'] = { 
    label = 'Goat Cheese', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Goat Cheese', 
},
['sour_cream'] = { 
    label = 'Sour Cream', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Sour Cream', 
},


--CONDIMENTS--
['sugar'] = { 
    label = 'Sugar', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Sugar', 
},
['cooking_oil'] = { 
    label = 'Cooking Oil', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cooking Oil', 
},
['honey'] = { 
    label = 'Honey', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Honey', 
},
['vinegar'] = { 
    label = 'Vinegar', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Vinegar', 
},
['soy_sauce'] = { 
    label = 'Soy Sauce', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Soy Sauce', 
},
['broth_base'] = { 
    label = 'Broth Base', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Broth Base', 
},
['fruit_jam'] = { 
    label = 'Fruit Jam', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Fruit Jam', 
},
['chocolate_bar'] = { 
    label = 'Chocolate Bar', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chocolate Bar', 
},
['peanut_butter'] = { 
    label = 'Peanut Butter', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Peanut Butter', 
},
['maple_syrup'] = { 
    label = 'Maple Syrup', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Maple Syrup', 
},
['mayonnaise'] = { 
    label = 'Mayonnaise', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mayonnaise', 
},
['mustard_ingredient'] = { 
    label = 'Mustard', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mustard', 
},
['ketchup'] = { 
    label = 'Ketchup', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Ketchup', 
},
['kimchi'] = { 
    label = 'Kimchi', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Kimchi', 
},
['miso_paste'] = { 
    label = 'Miso Paste', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Miso Paste', 
},
['nori_sheet'] = { 
    label = 'Nori Sheet', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Nori Sheet', 
},
['wasabi'] = { 
    label = 'Wasabi', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Wasabi', 
},
['sriracha'] = { 
    label = 'Sriracha', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Sriracha', 
},
['caesar_dressing'] = { 
    label = 'Caesar Dressing', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Caesar Dressing', 
},
['vinaigrette'] = { 
    label = 'Vinaigrette', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Vinaigrette', 
},
['tartar_sauce'] = { 
    label = 'Tartar Sauce', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tartar Sauce', 
},
['hummus'] = { 
    label = 'Hummus', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Hummus', 
},
['pesto'] = { 
    label = 'Pesto', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Pesto', 
},
['hoisin_sauce'] = { 
    label = 'Hoisin Sauce', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Hoisin Sauce', 
},
['teriyaki_sauce'] = { 
    label = 'Teriyaki Sauce', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Teriyaki Sauce', 
},
['all_purpose_flour'] = { 
    label = 'All Purpose Flour', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'All Purpose Flour', 
},
['brown_sugar'] = { 
    label = 'Brown Sugar', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Brown Sugar', 
},
['baking_powder'] = { 
    label = 'Baking Powder', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Baking Powder', 
},
['shortening'] = { 
    label = 'Shortening', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Shortening', 
},
['vanilla_extract'] = { 
    label = 'Vanilla Extract', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Vanilla Extract', 
},
['yeast'] = { 
    label = 'Yeast', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Yeast', 
},
['cornstarch'] = { 
    label = 'Cornstarch', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cornstarch', 
},
['molasses'] = { 
    label = 'Molasses', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Molasses', 
},
['evaporated_milk'] = { 
    label = 'Evaporated Milk', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Evaporated Milk', 
},
['sweetened_condensed_milk'] = { 
    label = 'Sweetened Condensed Milk', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Sweetened Condensed Milk', 
},
['tomato_sauce'] = { 
    label = 'Tomato Sauce', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tomato Sauce', 
},
['olive_oil'] = { 
    label = 'Olive Oil', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Olive Oil', 
},
['balsamic_vinegar'] = { 
    label = 'Balsamic Vinegar', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Balsamic Vinegar', 
},
['cocoa_powder'] = { 
    label = 'Cocoa Powder', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cocoa Powder', 
},
['barbecue_sauce'] = { 
    label = 'Barbecue Sauce', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Barbecue Sauce', 
},
['ranch_dressing'] = { 
    label = 'Ranch Dressing', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Ranch Dressing', 
},

['sesame_seeds'] = {
    label = 'Sesame Seeds',
    weight = 10,
    stack = true,
    close = true,
    description = 'Sesame Seeds',
},

['gochujang'] = {
    label = 'Gochujang',
    weight = 10,
    stack = true,
    close = true,
    description = 'Gochujang',
},
['tajin'] = {
    label = 'Tajin',
    weight = 10,
    stack = true,
    close = true,
    description = 'Tajin',
},
['chamoy'] = {
    label = 'Chamoy',
    weight = 10,
    stack = true,
    close = true,
    description = 'Chamoy',
},

--HERBS SPICES--
['salt'] = { 
    label = 'Salt', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Salt', 
},
['thyme'] = { 
    label = 'Thyme', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Thyme', 
},
['rosemary'] = { 
    label = 'Rosemary', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Rosemary', 
},
['parsley'] = { 
    label = 'Parsley', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Parsley', 
},
['cilantro'] = { 
    label = 'Cilantro', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cilantro', 
},
['dill'] = { 
    label = 'Dill', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Dill', 
},
['mint'] = { 
    label = 'Mint', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Mint', 
},
['black_pepper'] = { 
    label = 'Black Pepper', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Black Pepper', 
},
['cinnamon'] = { 
    label = 'Cinnamon', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cinnamon', 
},
['nutmeg'] = { 
    label = 'Nutmeg', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Nutmeg', 
},
['turmeric'] = { 
    label = 'Turmeric', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Turmeric', 
},
['paprika'] = { 
    label = 'Paprika', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Paprika', 
},
['cumin'] = { 
    label = 'Cumin', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cumin', 
},
['chili_powder'] = { 
    label = 'Chili Powder', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Chili Powder', 
},
['basil'] = { 
    label = 'Basil', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Basil', 
},
['oregano'] = { 
    label = 'Oregano', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Oregano', 
},


--ALCOHOL--
['gin'] = { 
    label = 'Gin', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Gin', 
},
['brandy'] = { 
    label = 'Brandy', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Brandy', 
},
['red_wine'] = { 
    label = 'Red Wine', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Red Wine', 
},
['white_wine'] = { 
    label = 'White Wine', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'White Wine', 
},
['irish_cream'] = { 
    label = 'Irish Cream', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Irish Cream', 
},
['absinthe'] = { 
    label = 'Absinthe', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Absinthe', 
},
['cider'] = { 
    label = 'Cider', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Cider', 
},


--MIXERS--
['tonic_water'] = { 
    label = 'Tonic Water', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Tonic Water', 
},
['soda_water'] = { 
    label = 'Soda Water', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Soda Water', 
},
['simple_syrup'] = { 
    label = 'Simple Syrup', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Simple Syrup', 
},
['grenadine'] = { 
    label = 'Grenadine', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Grenadine', 
},
['bitters'] = { 
    label = 'Bitters', 
    weight = 10, 
    stack = true,
    close = true,
    description = 'Bitters', 
},


------------------------------------------------------------------
---
---                           LUNAR DRUGS
---
------------------------------------------------------------------
---

['ammonia'] = {
    label = 'Ammonia',
    weight = 500,
    stack = true,
},

['sodium_benzoate'] = {
    label = 'Sodium benzoate',
    weight = 750,
    stack = true,
},

['meth_tray'] = {
    label = 'Meth tray',
    weight = 1000,
    stack = true,
},


['meth_bag'] = {
    label = 'Meth bag',
    weight = 50,
    stack = true,
    description = "1 Gram of Meth Bagged"
},

['plastic_bag'] = {
    label = 'Plastic bag',
    weight = 40,
    stack = true,
},

['meth_syringe'] = {
    label = 'Meth syringe',
    weight = 75,
    stack = true,
},

-- Cocaine related items
['coke_seed'] = {
    label = 'Cocaine seed',
    weight = 10,
    stack = true,
},

['coke_leaf'] = {
    label = 'Cocaine leaf',
    weight = 50,
    stack = true,
},

['coke_paste'] = {
    label = 'Cocaine paste',
    weight = 150,
    stack = true,
},

['coke'] = {
    label = 'Cocaine',
    weight = 1,
    stack = true,
    description = "1 Gram of Cocaine"
},

['coke_bag'] = {
    label = 'Cocaine bag',
    weight = 50,
    stack = true,
    description = "1 Gram of Cocaine Bagged"
},


['coke_doll'] = {
    label = 'Cocaine doll',
    weight = 500,
    stack = true,
},

-- Weed related items
['weed_seed'] = {
    label = 'Weed seed',
    weight = 5,
    stack = true,
},

['weed_pot'] = {
    label = 'Flower Pot',
    weight = 500,
    stack = true,
},

['trowel'] = {
    label = 'Trowel',
    weight = 150,
    stack = true,
},

['weed_bud'] = {
    label = 'Weed bud',
    weight = 25,
    stack = true,
},

['clean_weed_bud'] = {
    label = 'Clean weed bud',
    weight = 20,
    stack = true,
    description = "1 Gram of Weed"
},

['cookie_dough'] = {
    label = 'Cookie dough',
    weight = 200,
    stack = true
},

['weed_cookie'] = {
    label = 'Weed cookie',
    weight = 50,
    stack = true
},

['weed_bag'] = {
    label = 'Weed bag',
    weight = 50,
    stack = true,
    description = "1 Gram of Weed Bagged"
},

['weed_joint'] = {
    label = 'Weed joint',
    weight = 15,
    stack = true,
},

['weed_papers'] = {
    label = 'Weed papers',
    weight = 5,
    stack = true,
},

-- Heroin related items
['poppy_seeds'] = {
    label = 'Poppy seeds',
    weight = 5,
    stack = true,
},

['poppy_plant'] = {
    label = 'Poppy plant',
    weight = 100,
    stack = true,
},

['opium'] = {
    label = 'Opium',
    weight = 1,
    stack = true,
},

['heroin'] = {
    label = 'Heroin',
    weight = 1,
    stack = true,
},

['heroin_bag'] = {
    label = 'Heroin bag',
    weight = 50,
    stack = true,
},

['heroin_syringe'] = {
    label = 'Heroin syringe',
    weight = 75,
    stack = true,
},

['syringe'] = {
    label = 'Syringe',
    weight = 25,
    stack = true,
},

-- LSD related items
['ergot_fungus'] = {
    label = 'Ergot fungus',
    weight = 50,
    stack = true,
},

['generic_leaf'] = {
    label = 'Leaf',
    weight = 20,
    stack = true,
},

['lsd_liquid'] = {
    label = 'LSD liquid',
    weight = 25,
    stack = true,
},

['lsd'] = {
    label = 'LSD',
    weight = 1,
    stack = true,
},

['art_papers'] = {
    label = 'Art papers',
    weight = 5,
    stack = true,
},

-- Ecstasy related items
['safrole_oil'] = {
    label = 'Safrole oil',
    weight = 300,
    stack = true,
},

['ecstasy_crystals'] = {
    label = 'Ecstasy crystals',
    weight = 1,
    stack = true,
},

['ecstasy_pill'] = {
    label = 'Ecstasy pill',
    weight = 15,
    stack = true,
},

-- Mushroom related items
['mushrooms'] = {
    label = 'Mushrooms',
    weight = 1,
    stack = true,
},

['mushroom_powder'] = {
    label = 'Mushroom powder',
    weight = 1,
    stack = true,
},

['chocolate_chips'] = {
    label = 'Chocolate chips',
    weight = 30,
    stack = true,
},

['mushroom_chocolate'] = {
    label = 'Mushroom chocolate',
    weight = 45,
    stack = true,
},

-- Ketamine related items
['anesthetic'] = {
    label = 'anesthetic',
    weight = 200,
    stack = true,
},

['ketamine'] = {
    label = 'Ketamine',
    weight = 1,
    stack = true,
},

['ketamine_bag'] = {
    label = 'Ketamine bag',
    weight = 50,
    stack = true,
},

-- Crack related items
['baking_soda'] = {
    label = 'Baking soda',
    weight = 100,
    stack = true,
},

['crack'] = {
    label = 'Crack',
    weight = 1,
    stack = true,
},

['crack_bag'] = {
    label = 'Crack bag',
    weight = 50,
    stack = true,
},

['crack_pipe'] = {
    label = 'Crack pipe',
    weight = 150,
    stack = true,
},

['crack_syringe'] = {
    label = 'Crack syringe',
    weight = 75,
    stack = true,
},

['pipe'] = {
    label = 'Pipe',
    weight = 100,
    stack = true,
},

-- Fentanyl related items
['npp_chemical'] = {
    label = 'NPP chemical',
    weight = 300,
    stack = true,
},

['aniline_solution'] = {
    label = 'Aniline solution',
    weight = 250,
    stack = true,
},

['fentanyl'] = {
    label = 'Fentanyl',
    weight = 1,
    stack = true,
},

['fentanyl_bag'] = {
    label = 'Fentanyl bag',
    weight = 25,
    stack = true,
    description = "1 Gram of Fenty"
},

['meth_table'] = {
    label = 'Meth table',
    weight = 2250,
    stack = false
},

['coke_table'] = {
    label = 'Coke table',
    weight = 2250,
    stack = false
},

['weed_table'] = {
    label = 'Weed table',
    weight = 2250,
    stack = false
},

['chem_table'] = {
    label = 'Chemistry table',
    weight = 2250,
    stack = false
},

['burner_phone'] = {
    label = 'Burner phone',
    weight = 200,
    stack = true
},

['light1'] = {
    label = 'Portable Lamp',
    weight = 2000,
    stack = true
},

['light2'] = {
    label = 'Portable Lamp',
    weight = 2000,
    stack = true
},

['fertilizer'] = {
    label = 'Fertilizer',
    weight = 250,
    stack = true
},

['water_can'] = {
    label = 'Watering can',
    weight = 250,
    stack = true
},


    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- TICKETS: mba events
    ['mbaticket_lux'] = { 
        label = 'MBA Ticket: Luxury',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "VIP lounge with a kitchen and bar",
    },

    ['mbaticket_dlx'] = { 
        label = 'MBA Ticket: Delux',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "Sit in the upper area for a better view",
    },

    ['mbaticket_std'] = { 
        label = 'MBA Ticket: Standard',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "Standard seating close to the arena",
        
    },

    







    ----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------- 
    -- TICKETS: fleeca heist update
    ['bag_blackmoney'] = { 
        label = 'MBA Ticket: Luxury',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "VIP lounge with a kitchen and bar",
    },

    ['drill_thermal'] = { 
        label = 'MBA Ticket: Delux',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "Sit in the upper area for a better view",
    },

    ['hackingtablet'] = { 
        label = 'Tablet',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "Not for your ipad kid unc, this hacks shit!", 
    },

    ['scard_fleeca'] = { 
        label = 'MBA Ticket: Luxury',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "VIP lounge with a kitchen and bar",
    },

    ['cig_69brand'] = { 
        label = 'MBA Ticket: Delux',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "Sit in the upper area for a better view",
    },

    ['cig_redwood'] = { 
        label = 'MBA Ticket: Standard',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "Standard seating close to the arena", 
    },

    ['cig_debonaire'] = { 
        label = 'MBA Ticket: Standard',
        weight = 500,
        stack = false,
        degrade = 2,
        consume = 1,
        description = "Standard seating close to the arena", 
    },


    ['zipties'] = {
        label = 'Zipties',
        weight = 200,
        stack = false
    },
    ['bolt_cutters'] = {
        label = 'Bolt Cutters',
        weight = 200,
        stack = false
    },

    -- Lunar Heist Gear
    ['blue_keycard'] = {
    label = 'Blue Keycard',
    weight = 100,
    stack = false
},

['purple_keycard'] = {
    label = 'Purple Keycard',
    weight = 100,
    stack = false
},

['hack_usb'] = {
    label = 'Phantom USB',
    weight = 100,
    stack = false
},

['hack_card'] = {
    label = 'Spoofing Card',
    weight = 100,
    stack = false
},

['coins'] = {
    label = 'Coins',
    weight = 10,
},

['painting'] = {
    label = 'Painting',
    weight = 100,
},

['bomb_c4'] = {
    label = 'C4 Explosive',
    weight = 3000,
},

['angle_grinder'] = {
    label = 'Angle Grinder',
    weight = 1500,
},

['contracts_tablet'] = {
    label = 'Contract Tablet',
    stack = false,
    weight = 400,
},

['classified_docs'] = {
    label = 'Classified Documents',
    weight = 100,
},

['diamond_necklace'] = {
    label = 'Diamond Necklace',
    weight = 100,
},

['diamonds_box'] = {
    label = 'Diamonds Box',
    weight = 200,
},

['luxurious_watch'] = {
    label = 'Luxurious Watch',
    weight = 200,
},

['rare_coins'] = {
    label = 'Rare Coins',
    weight = 500,
},

['golden_coins'] = {
    label = 'Stolen Golden Coins',
    weight = 1,
    description = "Large coins pressed with the seal of San Andreas. Possibly chocolate.", 
},

['pooper_note'] = {
    label = 'Discarded Note',
    weight = 10,
    description = "galileo-sisyphus+light the way-dignity+coliseum-white spray-slip n slide+prison-ethical", 
},


['gold_bar'] = {
    label = 'Gold Bar',
    weight = 500,
},

["large_drill"] = {
    label = "Large Drill",
    weight = 12500,
    stack = true,
    close = true,
},

['casino_keycard'] = {
    label = 'Casino Keycard',
    weight = 100,
    stack = false
},

["small_drill"] = {
    label = "Small Drill",
    weight = 2000,
    stack = true,
    close = true,
},

['explosives'] = {
    label = 'Explosives',
    weight = 3000,
},

['tv'] = {
    label = 'Television',
    weight = 12500,
    stack = true,
},

['microwave'] = {
    label = 'Microwave',
    weight = 7500,
    stack = true,
},


['flat_tv'] = {
    label = 'Flat Screen TV',
    weight = 12500,
    stack = true,
},

['old_tv'] = {
    label = 'Old TV',
    weight = 12500,
    stack = true,
},



['keyboard'] = {
    label = 'Keyboard',
    weight = 500,
    stack = true,
},



['pink_diamond'] = {
    label = 'Pink Diamond',
    weight = 100,
},

['rare_tequila'] = {
    label = 'Rare Tequila',
    weight = 300,
},

['plasma_cutter'] = {
    label = 'Plasma cutter',
    weight = 1000,
    stack = true,
},

    -- Jim-Recycle Items
    recyclablematerial = {
        name = "recyclablematerial",
        label = "Recycle Box",
        weight = 100,
        client = {
          image = "recyclablematerial.png",
        }
    },
    bottle = {
        name = "bottle",
        label = "Empty Bottle",
        weight = 10,
        client = {
          image = "bottle.png",
        }
    },
  -- Servicing Items
  ["engine_oil"] = {
    label = "Engine Oil",
    weight = 1000,
  },
  ["tyre_replacement"] = {
    label = "Tyre Replacement",
    weight = 1000,
  },
  ["clutch_replacement"] = {
    label = "Clutch Replacement",
    weight = 1000,
  },
  ["air_filter"] = {
    label = "Air Filter",
    weight = 100,
  },
  ["spark_plug"] = {
    label = "Spark Plug",
    weight = 1000,
  },
  ["brakepad_replacement"] = {
    label = "Brakepad Replacement",
    weight = 1000,
  },
  ["suspension_parts"] = {
    label = "Suspension Parts",
    weight = 1000,
  },
  -- Engine Items
  ["i4_engine"] = {
    label = "I4 Engine",
    weight = 1000,
  },
  ["v6_engine"] = {
    label = "V6 Engine",
    weight = 1000,
  },
  ["v8_engine"] = {
    label = "V8 Engine",
    weight = 1000,
  },
  ["v12_engine"] = {
    label = "V12 Engine",
    weight = 1000,
  },
  ["turbocharger"] = {
    label = "Turbocharger",
    weight = 1000,
  },
  -- Electric Engines
  ["ev_motor"] = {
    label = "EV Motor",
    weight = 1000,
  },
  ["ev_battery"] = {
    label = "EV Battery",
    weight = 1000,
  },
  ["ev_coolant"] = {
    label = "EV Coolant",
    weight = 1000,
  },
  -- Drivetrain Items
  ["awd_drivetrain"] = {
    label = "AWD Drivetrain",
    weight = 1000,
  },
  ["rwd_drivetrain"] = {
    label = "RWD Drivetrain",
    weight = 1000,
  },
  ["fwd_drivetrain"] = {
    label = "FWD Drivetrain",
    weight = 1000,
  },
  -- Tuning Items
  ["slick_tyres"] = {
    label = "Slick Tyres",
    weight = 1000,
  },
  ["semi_slick_tyres"] = {
    label = "Semi Slick Tyres",
    weight = 1000,
  },
  ["offroad_tyres"] = {
    label = "Offroad Tyres",
    weight = 1000,
  },
  ["drift_tuning_kit"] = {
    label = "Drift Tuning Kit",
    weight = 1000,
  },
  ["ceramic_brakes"] = {
    label = "Ceramic Brakes",
    weight = 1000,
  },
  -- Cosmetic Items
  ["lighting_controller"] = {
    label = "Lighting Controller",
    weight = 100,
    client = {
      event = "jg-mechanic:client:show-lighting-controller",
    }
  },
  ["stancing_kit"] = {
    label = "Stancer Kit",
    weight = 100,
    client = {
      event = "jg-mechanic:client:show-stancer-kit",
    }
  },
  ["cosmetic_part"] = {
    label = "Cosmetic Parts",
    weight = 100,
  },
  ["respray_kit"] = {
    label = "Respray Kit",
    weight = 1000,
  },
  ["vehicle_wheels"] = {
    label = "Vehicle Wheels Set",
    weight = 1000,
  },
  ["tyre_smoke_kit"] = {
    label = "Tyre Smoke Kit",
    weight = 1000,
  },
  ["bulletproof_tyres"] = {
    label = "Bulletproof Tyres",
    weight = 1000,
  },
  ["extras_kit"] = {
    label = "Extras Kit",
    weight = 1000,
  },
  -- Nitrous & Cleaning Items
  ["nitrous_bottle"] = {
    label = "Nitrous Bottle",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:use-nitrous-bottle",
    }
  },
  ["empty_nitrous_bottle"] = {
    label = "Empty Nitrous Bottle",
    weight = 1000,
  },
  ["nitrous_install_kit"] = {
    label = "Nitrous Install Kit",
    weight = 1000,
  },
  ["cleaning_kit"] = {
    label = "Cleaning Kit",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:clean-vehicle",
    }
  },
  ["repair_kit"] = {
    label = "Repair Kit",
    weight = 1000,
    stack = false,
    client = {
      event = "jg-mechanic:client:repair-vehicle",
    }
  },
  ["duct_tape"] = {
    label = "Duct Tape",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:use-duct-tape",
    }
  },
  -- Performance Item
  ["performance_part"] = {
    label = "Performance Parts",
    weight = 1000,
  },
  -- Mechanic Tablet Item
  -- Gearbox
  ["manual_gearbox"] = {
    label = "Manual Gearbox",
    weight = 1000,
  },
    can = {
        name = "can",
        label = "Empty Can",
        weight = 10,
        client = {
          image = "can.png",
        }
    },

-- Licenses

  ["fishinglicense"] = {
    label = "Fishing License",
    weight = 500,
  },

  ["huntinglicense"] = {
    label = "Fishing License",
    weight = 500,
  },

--Keys

    ['contractkey'] = { 
        label = 'Key',
        weight = 300,
        consume = 0,
        description = "Inscribed with a tablet image on it",
    },

    -- Items the server already used, put back after the items list was replaced (2026-11-12)
    ['parachute'] = {
        label = 'Parachute',
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['lockpick'] = {
        label = 'Lockpick',
        weight = 160,
        durability = 10,
        stack = false
    },

    ['money'] = {
        label = 'Money',
    },

    ['black_money'] = {
        label = 'Dirty Money',
    },

    ['markedbills'] = {
        label = 'Marked Bills',
        weight = 100,
        stack = false,
        close = true,
        description = 'Dirty money. Wash it before you can spend it.',
    },

    ['tirekit'] = {
        label = 'Tyre Kit',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Patches and a pump to fix a burst tyre.',
        client = { image = 'tirerepairkit.png' },
        server = { export = 'vehiclehandler.tirekit' },
    },

    ['car_paint'] = {
        label = 'Automotive Paint',
        weight = 800,
        stack = true,
        close = true,
        description = 'Car paint for the mechanic shop. Paint jobs use it.',
        client = { image = 'spray.png' },
    },

    ['diamond'] = {
        label = 'Diamond',
        weight = 1500,
    },

    ['10kgoldchain'] = {
        label = '10k Gold Chain',
        weight = 1500,
    },

    ['coke_brick'] = {
        label = 'Coke Brick',
        weight = 2000,
    },

    ['meth'] = {
        label = 'Methamphetamine',
        weight = 100,
    },

}
