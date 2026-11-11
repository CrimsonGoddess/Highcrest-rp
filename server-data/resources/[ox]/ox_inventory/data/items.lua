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

    ['burger'] = {
        label = 'Burger',
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ['sprunk'] = {
        label = 'Sprunk',
        weight = 350,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'You quenched your thirst with a sprunk'
        }
    },

    ['parachute'] = {
        label = 'Parachute',
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
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

    ['panties'] = {
        label = 'Knickers',
        weight = 10,
        consume = 0,
        client = {
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },

    ['lockpick'] = {
        label = 'Lockpick',
        weight = 160,
    },

    ['phone'] = {
        label = 'Phone',
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            add = function(total)
                if total > 0 then
                    pcall(function() return exports.npwd:setPhoneDisabled(false) end)
                end
            end,

            remove = function(total)
                if total < 1 then
                    pcall(function() return exports.npwd:setPhoneDisabled(true) end)
                end
            end
        }
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

    ['water'] = {
        label = 'Water',
        weight = 500,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'You drank some refreshing water'
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

    ['money'] = {
        label = 'Money',
    },

    ['black_money'] = {
        label = 'Dirty Money',
    },

    -- Dirty money from robberies and drug runs. Each stack's value is in its metadata (worth).
    ['markedbills'] = {
        label = 'Marked Bills',
        weight = 100,
        stack = false,
        close = true,
        description = 'Dirty money. Wash it before you can spend it.',
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
    },

    ['jammer'] = {
        label = 'Radio Jammer',
        weight = 10000,
        allowArmed = true,
    },

    ['radiocell'] = {
        label = 'AAA Cells',
        weight = 1000,
        stack = true,
        allowArmed = true,
    },

    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 500,
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
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repair Kit',
        weight = 4000,
    },

    ['diamond'] = {
        label = 'Diamond',
        weight = 1500,
    },

    ['diamond_ring'] = {
        label = 'Diamond Ring',
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

    ['10kgoldchain'] = {
        label = '10k Gold Chain',
        weight = 1500,
    },

    ['crack_baggy'] = {
        label = 'Crack Baggy',
        weight = 100,
    },

    ['cokebaggy'] = {
        label = 'Bag of Coke',
        weight = 100,
    },

    ['coke_brick'] = {
        label = 'Coke Brick',
        weight = 2000,
    },

    ['coke_small_brick'] = {
        label = 'Coke Package',
        weight = 1000,
    },

    ['xtcbaggy'] = {
        label = 'Bag of Ecstasy',
        weight = 100,
    },

    ['meth'] = {
        label = 'Methamphetamine',
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
        label = 'Aluminium',
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
        weight = 5000,
    },

    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
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

    ['sandwich'] = {
        label = 'Sandwich',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Walking Stick',
        weight = 1000,
    },

    ['lighter'] = {
        label = 'Lighter',
        weight = 200,
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
}
