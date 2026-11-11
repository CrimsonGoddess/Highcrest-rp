Config = {}

Config.Groups = {
    enabled = true,--Enable or disable groups
}

Config.Keybinds = {
    placeBag = 73,--Keybind to place the bag on the ground
}

Config.TabletCommand = "tablet"--Tablet open command or just set it to false
Config.RequiredJob = false--Required job to access the gruppe6 job, Config.RequiredJob = "you job name here"

Config.Blips = {
    job_manager = {
        sprite = 374,--Blip icon id
        color = 11,--Blip color id
        scale = 1.0,--Blip scale
        label = "Gruppe 6 headquarters",--Blip label
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    Deliver = {
        sprite = 374,--Blip icon id
        color = 11,--Blip color id
        scale = 1.0,--Blip scale
        label = "Deliver location",--Blip label
        route = true,
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    Pickup = {
        sprite = 374,--Blip icon id
        color = 11,--Blip color id
        scale = 1.0,--Blip scale
        label = "Pick up location",--Blip label
        route = true,
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    }
}

Config.Center = {
    Orders = {--New order listings
        Pickup = { min = 0, sec = 10 },--Generate a new pickup job every min = x and sec = x
        Deliver = { min = 0, sec = 10 },--Generate a new deliver job every min = x and sec = x
    },

    peds = {
        job_manager = {
            model = 'cs_casey',--Dealers ped model, model names can be found @ https://docs.fivem.net/docs/game-references/ped-models/
            pos = vector3(-197.18, -831.43, 30.75), -- Highcrest: job start location (the script lowers peds by 1 m itself)--Dealers positions
            heading = 294.21,--Dealers heading
            animation = {--This controls dealer animation, if you don't want this, make it to: animation = false
                --Supported anim data format:
                    -- anim = ''
                    -- dict = ''
                    -- scenario = ''
                --Examples:
                    -- anim = 'missexile3'
                    -- dict = 'ex03_dingy_search_case_base_michael'
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            }
        },
        warehouse_manager = {
            model = 's_m_m_armoured_01',--Dealers ped model, model names can be found @ https://docs.fivem.net/docs/game-references/ped-models/
            pos = vector3(-20.54, -659.84, 33.48),--Dealers positions
            heading = 184.94,--Dealers heading
            animation = {--This controls dealer animation, if you don't want this, make it to: animation = false
                --Supported anim data format:
                    -- anim = ''
                    -- dict = ''
                    -- scenario = ''
                --Examples:
                    -- anim = 'missexile3'
                    -- dict = 'ex03_dingy_search_case_base_michael'
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            }
        },
    },

    Spawns = {
        vehicle = {
            { pos = vector3(-5.41, -670.47, 32.34), heading = 185.04 },
            { pos = vector3(-19.58, -671.1, 32.34), heading = 185.69 },
            { pos = vector3(-34.23, -673.33, 32.34),heading = 184.78 },
            { pos = vector3(-35.75, -700.61, 32.34), heading = 349.22 },
            { pos = vector3(-19.62, -705.79, 32.34), heading = 348.81 },
            { pos = vector3(-4.01, -711.43, 32.34),  heading = 347.5 },
        },

        package = {
            { pos = vector3(-439.43, -2787.75, 6.0), heading = 137.14 },
            { pos = vector3(-441.46, -2785.25, 6.0),  heading = 131.58 },
        }
    },
}

Config.Jobs = {
    ['atm'] = {
        label = 'ATM JOB',--job rank type label name 
        description = 'You will be collecting or delivering money to and from atms',
        group = true,--Does this job type support groups?
        cancelPenalty = 100,--This means how mucj xp will a player loose who cancels a taken job, to disable this, set it to cancelPenalty = false

        rewards = {--Rewards that the players get after finishing the job
            account = 'bank', --Account to send money to, cash or bank
            perBag = 500, --How much is paid for one single successfull pickup/delivery job
            groupMultiplier = true, --Multiply this number by the group count
            rankXp = 100 --Add rank xp after finished delivery
        },

        bag = {-- Money bag carrying
            item = 'money_bag',--If this has a set item name, it will give money bag as an item, to dissable this set item = false,
            model = 'xm_prop_x17_bag_01b',--Money bag model this is spawned only when you place it on the ground or in a vehicle
            disableSprint = false,
            disableJump = true,
            disableFight = false,      
            clothing = {--Bag clothing data
                --id is the clothing bag component id, drawable is the clothing item id and texture is the bags texture/color
                male = { id = 5, drawable = 45, texture = 0 },
                female = { id = 5, drawable = 45, texture = 0 }
            },
        },  

        vehicle = {--Don't touch this
            model = 'stockade',--Vehicle spawn name
            cargo = {
                areaSize = vec3(0.8, 3.0, 8.0),
                spacing = vec3(0.29, 0.60, 0.17),
                offsetPos = vec3(0.3, 3, 0.43),      
                trunkBones = {
                    -- [door id, rage is 0 - 5] = bone name
                    [2] = 'dside_r',
                    [3] = 'pside_r'
                }
            },
        }

        --- gruppe6 Nspeedo vehicle bag offsets
        -- vehicle = {--Don't touch this
        --     model = 'g6speedo',--Vehicle spawn name
        --     cargo = {
        --         areaSize = vec3(0.8, 3.0, 8.0),
        --         spacing = vec3(0.29, 0.60, 0.17),
        --         offsetPos = vec3(0.3, 2.3, -0.25),      
        --         trunkBones = {
        --             -- [door id, rage is 0 - 5] = bone name
        --             [2] = 'dside_r',
        --             [3] = 'pside_r'
        --         }
        --     },
        -- }
    },

    ['bank'] = {
        label = 'BANK JOB',--job rank type label name 
        description = 'You will be collecting or delivering money to and from banks',
        group = true,--Does this job type support groups?
        cancelPenalty = 100,--This means how mucj xp will a player loose who cancels a taken job, to disable this, set it to cancelPenalty = false 

        rewards = {--Rewards that the players get after finishing the job
            account = 'bank', --Account to send money to, cash or bank
            perBag = 1500, --How much is paid for one single successfull pickup/delivery job
            groupMultiplier = true, --Multiply this number by the group count
            rankXp = 100 --Add rank xp after finished delivery
        },

        bag = {-- Money bag carrying
            item = 'money_bag',--If this has a set item name, it will give money bag as an item, to dissable this set item = false,
            model = 'xm_prop_x17_bag_01b',--Money bag model this is spawned only when you place it on the ground or in a vehicle
            disableSprint = false,
            disableJump = true,
            disableFight = false,      
            clothing = {--Bag clothing data
                --id is the clothing bag component id, drawable is the clothing item id and texture is the bags texture/color
                male = { id = 5, drawable = 45, texture = 0 },
                female = { id = 5, drawable = 45, texture = 0 }
            },
        },

        vehicle = {--Don't touch this
            model = 'stockade',--Vehicle spawn name
            cargo = {
                areaSize = vec3(0.8, 3.0, 8.0),
                spacing = vec3(0.29, 0.60, 0.17),
                offsetPos = vec3(0.3, 3, 0.43),      
                trunkBones = {
                    -- [door id, rage is 0 - 5] = bone name
                    [2] = 'dside_r',
                    [3] = 'pside_r'
                }
            },
        }

        --- gruppe6 Nspeedo vehicle bag offsets
        -- vehicle = {--Don't touch this
        --     model = 'g6speedo',--Vehicle spawn name
        --     cargo = {
        --         areaSize = vec3(0.8, 3.0, 8.0),
        --         spacing = vec3(0.29, 0.60, 0.17),
        --         offsetPos = vec3(0.3, 2.3, -0.25),      
        --         trunkBones = {
        --             -- [door id, rage is 0 - 5] = bone name
        --             [2] = 'dside_r',
        --             [3] = 'pside_r'
        --         }
        --     },
        -- }
    },

    ['vault'] = {
        label = 'PACIFIC BANK JOB',--job rank type label name 
        description = 'You will be collecting or delivering money to and from Pacific bank',
        group = true,--Does this job type support groups?
        cancelPenalty = 100,--This means how mucj xp will a player loose who cancels a taken job, to disable this, set it to cancelPenalty = false

        rewards = {--Rewards that the players get after finishing the job
            account = 'bank', --Account to send money to, cash or bank
            perBag = 2500, --How much is paid for one single successfull pickup/delivery job
            groupMultiplier = true, --Multiply this number by the group count
            rankXp = 100 --Add rank xp after finished delivery
        },

        bag = {-- Money bag carrying
            item = 'money_bag',--If this has a set item name, it will give money bag as an item, to dissable this set item = false,
            model = 'xm_prop_x17_bag_01b',--Money bag model this is spawned only when you place it on the ground or in a vehicle
            disableSprint = false,
            disableJump = true,
            disableFight = false,      
            clothing = {--Bag clothing data
                --id is the clothing bag component id, drawable is the clothing item id and texture is the bags texture/color
                male = { id = 5, drawable = 45, texture = 0 },
                female = { id = 5, drawable = 45, texture = 0 }
            },
        },

        vehicle = {--Don't touch this
            model = 'stockade',--Vehicle spawn name
            cargo = {
                areaSize = vec3(0.8, 3.0, 8.0),
                spacing = vec3(0.29, 0.60, 0.17),
                offsetPos = vec3(0.3, 3, 0.43),      
                trunkBones = {
                    -- [door id, rage is 0 - 5] = bone name
                    [2] = 'dside_r',
                    [3] = 'pside_r'
                }
            },
        },

        --- gruppe6 Nspeedo vehicle bag offsets
        -- vehicle = {--Don't touch this
        --     model = 'g6speedo',--Vehicle spawn name
        --     cargo = {
        --         areaSize = vec3(0.8, 3.0, 8.0),
        --         spacing = vec3(0.29, 0.60, 0.17),
        --         offsetPos = vec3(0.3, 2.3, -0.25),      
        --         trunkBones = {
        --             -- [door id, rage is 0 - 5] = bone name
        --             [2] = 'dside_r',
        --             [3] = 'pside_r'
        --         }
        --     },
        -- }

        container = {
            model = 'prop_container_03_ld',
            color = 7,
            doors = {
                left = "prop_container_door_mb_l",
                right = "prop_container_door_mb_r", 
            }
        }
    }
}

Config.Ranks = {--Don't touch this
    Levels = {--Don't touch this
        [1] = {--Rank level id
            minXP = 0,--minimum needed xp to unlock this level
            job = 'atm'--When a player reaches this rank level he unlocks this job type
        },
        [2] = {--Rank level id
            minXP = 50,--minimum needed xp to unlock this level
            job = 'bank'--When a player reaches this rank level he unlocks this job type
        },
        [3] = {--Rank level id
            minXP = 1000,--minimum needed xp to unlock this level
            job = 'vault'--When a player reaches this rank level he unlocks this job type
        }
    }
}