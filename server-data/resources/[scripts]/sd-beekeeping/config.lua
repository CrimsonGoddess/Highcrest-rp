Beekeeping = {}

SD.Locale.LoadLocale('en') -- Load the locale language, if available. You can change 'en' to any other available language in the locales folder.

Beekeeping.DebugZones = false --- Enable debug for honey zones

Beekeeping.Max = { -- Max amount of houses/hives an individual player can have placed down at any time.    
    Hives = 5, -- Maximum
    Houses = 5, -- Maximum
}

Beekeeping.Interaction = 'target' -- 'target' = qb-target/qtarget/ox_target or 'textui' = cd_drawtextui/qb-core/ox_lib textui 
Beekeeping.InteractionDistance = 3.0 -- Interaction distance with hives and houses with target/textui.

-- This config does NOT retroactievely apply to houses/hives already placed down. It only applies to new ones placed down after the change.
Beekeeping.SpawnRange = 100 -- Spawn range for the hives/houses from the player. (Default: 100 meters)

Beekeeping.Saving = {
    Method = 'txadmin',  -- Options: 'txadmin', 'interval', 'resourceStop'
    Interval = 30      -- in minutes, used if SaveMethod is 'interval'
}

-- It's recommended to keep this as false for performance reasons, but if you're testing or making changes to the config, 
-- you can set it to true to reload the objects without needing to relog.
-- If true, requests objects from the server when the script starts or the client loads. 
-- If false, it requests objects when the player is loaded. (e.g. via QBCore:Client:OnPlayerLoaded or esx:playerLoaded)
Beekeeping.LoadOnStart = false -- true/false

-- Beekeeping Expiration Settings
-- The expiration logic controls the durability of hives and houses over time. (Durability starts at a 100)
-- With the current configuration, the durability of a hive/house decreases by 'DecayRate' every 'DecayInterval' minutes.
-- For example, if 'DecayRate' is 1 and 'DecayInterval' is 60 (minutes), then the durability will decrease by 1 every hour.
-- Adjust these values based on your gameplay needs and server balance considerations.
Beekeeping.Expiry = {
    EnableExpiration = true,   -- Enables or disables the expiration logic for hives/houses.
    DecaySettings = {
        -- Settings for 'hive' type.
        hive = {
            DecayRate = 1,       -- The amount by which durability decreases each time the decay interval elapses for hives.
            DecayInterval = 60,  -- Interval in minutes at which the durability decreases by the DecayRate for hives.
        },
        -- Settings for 'house' type.
        house = {
            DecayRate = 2,       -- The amount by which durability decreases each time the decay interval elapses for houses.
            DecayInterval = 120, -- Interval in minutes at which the durability decreases by the DecayRate for houses.
        }
    },
    RepairCostPerOne = 100,    -- The cost to restore one point of durability.
}

Beekeeping.LockAccess = true -- if enabled, lock access to the hive/house to the owner, and allow that owner to add 'collaborators' who will then also have access to the hive/house. If disabled, everyone can access it.
Beekeeping.RaycastingDistance = 10.0 -- Distance in meters that you are allowed to raycast when placing a hive/house.

-- This configuration limits the number of hives and houses a player can be added to as a collaborator.
-- It only applies to new additions and does NOT retroactively affect existing collaborations.
Beekeeping.LimitCollaborators = {
    Enable = false, -- Set to `true` to enable the collaborator limit, or `false` to disable it.
    Max = 5 -- The maximum number of hives/houses a player can collaborate on. Ignored if `Enable` is set to `false`.
}

Beekeeping.Infection = {
    Enable = true,                           -- Whether to enable infection mechanics
    CheckInterval = 10,                       -- How often (in minutes) to run the infection update
    SeverityIncreaseInterval = 1,           -- How often (in minutes) for the severity of the infection to increase
    InfectionChance = 1,                     -- Chance (1 in X) that an uninfected hive becomes infected each check

    WorkerDeathChance = 20,                  -- Percentage chance that workers will die each infection check if infected
    WorkerDeathCountRange = {1, 3},          -- Minimum and maximum number of workers that can die when the event occurs
    QueenDeathBaseChance = 0,                -- Base percentage chance per severity level that the queen dies each check

    TreatmentEnabled = true,                 -- Whether players can treat and cure infected hives

    -- Severity levels fully define infection parameters
    SeverityLevels = {
        [1] = {
            WorkerDeathChance = 20,          -- Percentage chance workers die at severity 1
            WorkerDeathCountRange = {1, 3},  -- Range of workers that may die at severity 1
            QueenDeathChance = 0,            -- Percentage chance the queen dies at severity 1
            ProductionDelayMultiplier = 2.0, -- Production delay multiplier at severity 1
        },
        [2] = {
            WorkerDeathChance = 30,          -- Percentage chance workers die at severity 2
            WorkerDeathCountRange = {2, 4},  -- Range of workers that may die at severity 2
            QueenDeathChance = 5,            -- Percentage chance the queen dies at severity 2
            ProductionDelayMultiplier = 2.5, -- Production delay multiplier at severity 2
        },
        [3] = {
            WorkerDeathChance = 50,          -- Percentage chance workers die at severity 3
            WorkerDeathCountRange = {3, 6},  -- Range of workers that may die at severity 3
            QueenDeathChance = 10,           -- Percentage chance the queen dies at severity 3
            ProductionDelayMultiplier = 3.0, -- Production delay multiplier at severity 3
        }
        -- Add additional severity levels as needed
    },

    ShieldsEnabled = true,                    -- Whether players can purchase shields
    -- Protection Tiers: Define different levels of shield protection
    ProtectionTiers = {
        [1] = {
            localeKey = "hives.protection_tier_1",
            cost = 500,
            duration = 720 -- Duration in minutes (12 hours)
        },
        [2] = {
            localeKey = "hives.protection_tier_2",
            cost = 1000,
            duration = 1440 -- Duration in minutes (24 hours)
        },
        [3] = {
            localeKey = "hives.protection_tier_3",
            cost = 2000,
            duration = 2880 -- Duration in minutes (48 hours)
        }
    }
}

-- Aggression settings for hives and houses
Beekeeping.Aggression = {
    Enable = true, -- Toggle the aggression system

    DefaultLevel = 1, -- Starting aggression when created, this is more for testing purposes, you shouldn't modify this value.

    Levels = { -- Aggression tiers: name + damage
        [1] = { nameKey = "aggression.name_calm", damage = 0  },
        [2] = { nameKey = "aggression.name_alert", damage = 5  },
        [3] = { nameKey = "aggression.name_defensive", damage = 10 },
        [4] = { nameKey = "aggression.name_aggressive", damage = 20 },
    },

    SmokerReduceBy = 'all', -- Levels reduced per use of the smoker.
    -- You can also set this to a number so for ex. SmokerReduceBy = 1, which will reduce the aggression lvl by 1
    SmokerRemoveChance = 25, -- % chance for the smoker to break when using it.

    UpdateInterval = 120, -- Minutes between aggression rolls

    Chance = { -- Overall % chance to bump +1 to aggression level each interval
        Base           = 5, -- Flat base % chance
        PerWorker      = 0.1, -- +0.2% per worker bee
        PerSeverity    = 2, -- +2% per infection severity level
        FullHiveBonus  = 5, -- +5% if full of honey but still producing
        FullHouseBonus = 5, -- +% chance when a house is full of bees
        Max            = 90, -- Cap the chance at 90%
    },

    StingChance = {
        [1] = 0,    -- level 1 (calm) → 0% chance to sting
        [2] = 20,   -- level 2 (alert) → 20% chance to sting
        [3] = 50, -- level 3 (defensive) → 50% chance to sting
        [4] = 80,   -- level 4 (aggressive) → 80% chance to sting
    },

    ProtectiveClothing = {
        Enable = true,  -- Master switch: enable/disable all protective checks

        -- Matching logic:
        --   "any"           → pass if any single component or prop matches (Categories ignored)
        --   "all"           → require every listed component and every listed prop (Categories ignored)
        --   "category_any"  → require that you’re wearing something in at least one of the listed categories (Components/Props ignored)
        --   "category_all"  → require that you’re wearing something in every listed category (Components/Props ignored)
        Mode = "any",

        -- Category/ID List, this is what you can use for the "id" under props and components as well as the category section:
        -- face, masks, hair, torso, legs, bags, shoes, accessories, undershirt, armor, decals, jackets, hats, glasses, ears, watches, bracelets
        
        -- Exact body-component checks. (Used in "any" or "all" modes)
        -- Add/remove entries here when Mode = "any" or "all"
        Components = {
            Common = { -- Shared between Male and Female
                { id = "hats", drawable = 5  }, 
                -- You can add more or remove the above entry...
            },
            Male = {
                { id = "masks", drawable = 21 },  -- Torso (male-specific)
                -- You can add more or remove the above entry...
            },
            Female = {
                { id = "masks", drawable = 15 },  -- Torso (female-specific)
                -- You can add more or remove the above entry...
            },
        },

        -- Exact prop checks (hats, glasses, etc.). (Used in "any" or "all" modes)
        -- Add/remove entries here when Mode = "any" or "all"
        Props = {
            Common = { -- Shared between Male and Female
                { id = "hats", drawable = 14 },  -- Helmet
                -- You can add more or remove the above entry...
            },
            Male = {
                { id = "masks", drawable = 5  },  -- Glasses (male)
                -- You can add more or remove the above entry...
            },
            Female = {
                { id = "masks", drawable = 2  },  -- Glasses (female)
                -- You can add more or remove the above entry...
            },
        },

        -- Category requirements: if category_all must wear *something* in each named category, if category_any must wear at least have something in any of the listed category.
        -- Used only when Mode = "category_any" or Mode = "category_all"
        Categories = {
            "masks", "masks", -- add others as needed
        },
    },
}

-- Beekeeping Ped Settings
Beekeeping.Beekeeper = {
    Enable = true, -- If enabled, the beekeeper will spawn at the location below.
    Location = {
        {x = 426.05, y = 6478.9, z = 27.84, w = 234.9},
        -- Add more locations as needed (Will Randomize from available locations each script start)
    },
    Model = "a_m_m_farmer_01",
    Interaction = {
        Icon = "fas fa-circle",
        Distance = 3.0,
    },
    SpawnDistance = 50.0, -- Distance at which the ped spawns
    Scenario = "WORLD_HUMAN_STAND_IMPATIENT" -- Full list of scenarios @ https://pastebin.com/6mrYTdQv
}

-- Blip Creation for Beekeeper if the Beekeeper is enabled
Beekeeping.Blip = {
    Enable = true,  -- Set to false to disable blip creation
    Sprite = 106,    -- Sprite/Icon for the blip
    Display = 4,     -- Display type
    Scale = 0.7,     -- Scale of the blip
    Colour = 33,      -- Colour of the blip
    Name = "Beekeeper"  -- Name of the blip
}

-- These are the blips that are created (when toggled by the user) for Hives and Houses. If false no blips will appear and the user will not have the ability to toggle them.
Beekeeping.FacilityBlip = {
    Enable = true, -- true/false
    ["house"] = {
        sprite = 40,
        color = 10,
        scale = 0.6,
        label = "Bee House"
    },
    ["hive"] = {
        sprite = 40,
        color = 5,
        scale = 0.6,
        label = "Bee Hive"
    }
}

-- Beekeeping.ExclusionZones: Array of zones where hive/house placement is disabled.
-- Each zone is defined by a central point ('coords') and a 'radius'.
Beekeeping.ExclusionZones = {
    { coords = vector3(426.05, 6478.9, 27.84), radius = 100 }, -- Example Location (Default Beekeeper Location)
    -- Add more zones as needed
}

-- Define the honey zones
-- Each zone will have a 'name' and 'honeyType'
Beekeeping.HoneyZones = {
    Enable = true,
    { -- Mt Chiliad
        name = 'Chiliad Meadow',
        honeyType = 'chiliad',
        thickness = 750,
        points = {
            vec3(-52.06, 7790.08, 0.00),
            vec3(3248.96, 6337.81, 0.00),
            vec3(3791.22, 4888.10, 0.00),
            vec3(1315.75, 4216.83, 00.00),
            vec3(-231.41, 4086.02, 00.00),
            vec3(-2334.77, 5159.51, 00.00),
        },
    },
    { -- Green Hills
        name = 'Green Hills',
        honeyType = 'green_hills',
        thickness = 750,
        points = {
            vec3(-2334.77, 5159.51, 0.00),
            vec3(-3265.46, 3373.03, 0.00),
            vec3(-2421.15, -392.66, 0.00),
            vec3(-745.02, 936.11, 0.00),
            vec3(3393.98, -149.63, 0.00),
            vec3(3367.22, 2166.08, 0.00),
        },
    },
    { -- Alamo Grove
        name = 'Alamo Grove',
        honeyType = 'alamo',
        thickness = 750,
        points = {
            vec3(3367.22, 2166.08, 0.00),
            vec3(3791.22, 4888.10, 0.00),
            vec3(1315.75, 4216.83, 0.00),
            vec3(-231.41, 4086.02, 0.00),
        },
    },
    -- Add more zones as needed
}

Beekeeping.HoneyTypes = {
    ['chiliad'] = { -- Mt Chiliad
        displayName = 'Chiliad Honey',
        item = 'chiliad-honey',
    },
    ['green_hills'] = { -- Green Hills
        displayName = 'Green Hills Honey',
        item = 'green-hills-honey',
    },
    ['alamo'] = { -- Alamo Grove (Sandy Shores)
        displayName = 'Alamo Honey',
        item = 'alamo-honey',
    },
    ['basic'] = { -- Default Honey
        displayName = 'Bee Honey',
        item = 'bee-honey',
    },
}

Beekeeping.Shop = {
    UseItemImages      = false,  -- if true, display SD.GetItemImage(product); otherwise use iconName
    ShowPricesOnTitles = true, -- if true, displays the price alongside the title. (labelKey)

    BuyItems = {
        {
            product  = "bee-house", -- internal identifier for the item (item name) (used in server events & SD.GetItemImage)
            price    = 1000, -- how much the player pays per unit
            labelKey = "beekeeper.buy_bee_house", -- locale key OR a literal string (string example: labelKey = "Buy Bee House" )
            descKey  = "beekeeper.purchase_bee_house_desc", -- locale key OR a literal string (string example: descKey = "Buy Bee House for $1000" )
            iconName = "home" -- fallback FA icon if UseItemImages = false
        },
        {
            product  = "bee-hive",
            price    = 1250,
            labelKey = "beekeeper.buy_bee_hive",
            descKey  = "beekeeper.purchase_bee_hive_desc",
            iconName = "fa-brands fa-hive"
        },
        {
            product  = "thymol",
            price    = 250,
            labelKey = "beekeeper.buy_thymol",
            descKey  = "beekeeper.purchase_thymol_desc",
            iconName = "fa-solid fa-leaf",
        },
        {
            product  = "bee-smoker",
            price    = 500,
            labelKey = "beekeeper.buy_smoker",
            descKey  = "beekeeper.buy_smoker_desc",
            iconName = "fa-solid fa-smog"
        },
        -- ←– To add a new buyable item, append:
        -- {
        --     product  = "your-new-item-key",
        --     price    = 1234,
        --     labelKey = "locale.or.direct.string.for.title",
        --     descKey  = "locale.or.direct.string.for.description",
        --     iconName = "fa-icon-name"
        -- },
    },

    SellItems = {
        {
            product      = "bee-wax",
            price        = 750,
            labelKey     = "beekeeper.sell_wax",
            descKey      = "beekeeper.sell_wax_desc",
            iconName     = "fa-brands fa-hive"
        },
        {
            product      = "chiliad-honey",
            price        = 750,
            labelKey     = "beekeeper.sell_honey",  -- locale expects {honey_name}
            descKey      = "beekeeper.sell_honey_desc", -- locale expects {honey_name}
            iconName     = "jar",
            formatParams = { honey_name = Beekeeping.HoneyTypes["chiliad"].displayName } -- provides honey_name for locale
        },
        {
            product      = "green-hills-honey",
            price        = 675,
            labelKey     = "beekeeper.sell_honey",
            descKey      = "beekeeper.sell_honey_desc",
            iconName     = "jar",
            formatParams = { honey_name = Beekeeping.HoneyTypes["green_hills"].displayName }
        },
        {
            product      = "alamo-honey",
            price        = 600,
            labelKey     = "beekeeper.sell_honey",
            descKey      = "beekeeper.sell_honey_desc",
            iconName     = "jar",
            formatParams = { honey_name = Beekeeping.HoneyTypes["alamo"].displayName }
        },
        {
            product      = "bee-honey",
            price        = 500,
            labelKey     = "beekeeper.sell_honey",
            descKey      = "beekeeper.sell_honey_desc",
            iconName     = "jar",
            formatParams = { honey_name = Beekeeping.HoneyTypes["basic"].displayName }
        }
        -- ←– To add another sellable item, append:
        -- {
        --     product      = "item-key",
        --     price        = <sell price>,
        --     labelKey     = "locale.or.direct.string.for.title",
        --     descKey      = "locale.or.direct.string.for.description",
        --     iconName     = "fa-icon-name",
        --     formatParams = { ... }   -- only if your locale needs parameters
        -- },
    }
}

Beekeeping.WorkerThreshold = 10  -- Number of additional workers needed for each multiplier level (eg. if you have 30, it'll be 1.4x Honey Production and so on.)
Beekeeping.Multipliers = {
    [1] = 1.2,  -- 1st level: 1.2x production
    [2] = 1.3,  -- 2nd level: 1.3x production
    [3] = 1.4,  -- 3rd level: 1.4x production
    [4] = 1.5,  -- 3rd level: 1.5x production
    [5] = 2.0,  -- 3rd level: 2x production
    -- Additional levels as needed
}

Beekeeping.House = {
    CaptureTime = 300, -- Time in seconds to capture a new bee
    QueenSpawnChance = 10, -- Chance in % to spawn a queen when capturing new bees
    BeesPerCapture = {2, 3}, -- Min and max bees to capture per capture or fix amount
    QueensPerCapture = 1, -- Min and max queens to capture per capture or fix amount
    MaxQueens = 5, -- Max queens per house
    MaxWorkers = 50, -- Max workers per house

    UseItemImages = true, -- Boolean to dictate if the menu should display fontawesome icons or the item images. If true, then it uses item images.
}

Beekeeping.Hives = {
    -- Honey
    HoneyTime = 600, -- Time in seconds to produce honey & wax
    HoneyPerTime = {1, 2}, -- Min and max honey to produce per time
    MaxHoney = 100, -- Max honey per hive
    -- Wax
    ChanceOfWax = 10, -- In percentage what are the chances to get wax on HoneyTime?
    WaxPerTime = {1, 2}, -- Min and max honey to produce per time
    MaxWax = 20, -- Max wax per hive
    -- Bees
    NeededQueens = 1, -- Amount of queens needed for the hive to work.
    NeededWorkers = 5, -- Amount of workers needed for the hive to work.
    MaxWorkers = 50, -- Max workers per hive

    UseItemImages = true, -- Boolean to dictate if the menu should display fontawesome icons or the item images. If true, then it uses item images.
}

Beekeeping.Items = {
    QueenItem = 'bee-queen',
    WorkerItem = 'bee-worker',
    HoneyItem = 'bee-honey',
    WaxItem = 'bee-wax',
    HiveItem = 'bee-hive',
    HouseItem = 'bee-house',
    TreatmentItem = 'thymol',
    SmokerItem = 'bee-smoker'
}

--[[
    For bzzz's props (free): https://bzzz.tebex.io/package/5696199
    For nopixel's props (paid): https://3dstore.nopixel.net/package/5622378
]]

-- 'native' are the props that come with the resource
Beekeeping.Type = 'native' -- 'native / 'bzzz' / 'nopixel' or 'custom'

if Beekeeping.Type == 'native' then
Beekeeping.Props = {
    bee_house = 'hp3d_beehive1',
    bee_hive = 'hp3d_beehive2',
}
elseif Beekeeping.Type == 'bzzz' then
Beekeeping.Props = {
    bee_house = 'bzzz_props_beehive_box_002',
    bee_hive = 'bzzz_props_beehive_box_001',
}
elseif Beekeeping.Type == 'nopixel' then
Beekeeping.Props = {
    bee_house = 'np_beehive',
    bee_hive = 'np_beehive02',
}
elseif Beekeeping.Type == 'custom' then
Beekeeping.Props = {
    bee_house = '',
    bee_hive = '',
}
end

Beekeeping.Grounds = { -- Acceptable materials for gound (grass, etc) [ DO NOT TOUCH IF YOU DON'T KNOW WHAT YOU ARE DOING. ]
    -2041329971, -- Leaves
    -461750719,  -- GrassLong
    1333033863,  -- Grass
    -1286696947, -- GrassShort
    1144315879,  -- ClayHard
    -1942898710, -- MudHard
    -1595148316, -- SandLoose
    -1885547121, -- DirtTrack
    -2041329971, -- Leaves
    -840216541,  -- Rock
    -700658213,  -- Soil
    -913351839,  -- Twigs
    1109728704,  -- MudDeep
    1635937914,  -- MudSoft
    2128369009,  -- GravelLarge
    951832588,   -- GravelSmall
    581794674,   -- Bushes
    510490462,   -- SandCompact
}