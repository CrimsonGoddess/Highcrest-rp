Config = {}

Config.Debug = false

--SERVER SETTINGS
Config.InteractionType = "target"                                    -- target or textui or 3dtext | which type of interaction you want

Config.QuasarLockpickMinigame = false                               -- if you use lockpick resource from qusar set this to true

Config.Framework = "qbcore"                                          -- Framework | types: auto-detect, qbcore, ESX, standalone
Config.NewESX = true                                                 -- if you use esx 1.1 set this to false
Config.Target = "ox_target"                                          -- Target | types: auto-detect, qb-target, qtarget, ox_target
Config.Dispatch = { enabled = false, script = "linden_outlawalert" } -- cd_dispatch, linden_outlawalert, ps-disptach, core-dispatch
Config.NotificationType = "ox_lib"                                   -- Notifications | types: ESX, ox_lib, qbcore
Config.Progress = "ox_lib"                                           -- ProgressBars | types: progressBars, ox_lib, qbcore
Config.Clothing = "illenium-appearance"                                     -- Skin / Clothing | types: auto-detect, esx_skin, qb-clothing, fivem-appearance, ox_appearance, illenium-appearance
Config.TextUI = "ox_lib"                                             -- TextUIs | types: esx, ox_lib, luke
Config.Context = "ox_lib"                                            -- Context | types: ox_lib, qbcore
Config.Input = "ox_lib"                                              -- Input | types: ox_lib, qb-input
Config.TimeChange = false                                            -- for realistic interior night time, can cause error when you dont use correct time sync!
Config.TimeSync = "none"                                             -- Time Sync | types: cd_easytime, none, realtime
Config.PoliceJobs = { 'police', 'sheriff' }                          -- jobs for police counting
--PLAYER CONTROL
Config.Logs = { enabled = false, type = "webhook" }                   --Change webhook in  use webhook or ox_lib (datadog) Can be changed in server > sv_utils.lua
Config.DropPlayer = false                                            -- Drop (Kick) Player if tries to cheat!
Config.AnticheatBan = false                                          -- Change in server/sv_Utils.lua!!! WIll not work by default you need to add your custom trigger to ban player!

Config.QBdisablemarkedbills = { enabled = false, item = "black_money" } -- yourt item (if you dont use markedbills this is for you!)

Config.OnlyOne = false                                                 -- One warehouse per one player

Config.CCTV = "solo"           -- Camera | types: disabled, solo (Player can only access camera when he is alone in warehouse, will prevent invisible problem), multi (if multi then player will become invisble when in camera mode for players inside warehouse)

Config.ResetHousesAfterTime = true                     -- reset houses
Config.ResetTime = 120                                 -- in minutes

Config.Lockpick = { item = "lockpick", remove = true } -- item for lockpicking house

Config.Inventory = "ox"                       -- auto-detect, ox, quasar, chezza, qb

Config.ResellValue = 50 -- Player will get 50% back when selling already purchased warehouse

Config.LocatorTimeout = 30 -- Minutes

--BLIPS
Config.Blips = {
    Shop = { -- do not use same value twice (will result in overwriting of blip)
        BlipCoords = vec3(-697.9, 271.6, 82.11), -- Blip coords
        Sprite = 475, -- Blip Icon
        Display = 4, -- keep 4
        Scale = 0.9, -- Size of blip
        Colour = 69, -- colour
        Name = "Warehouses for sale" -- Blip name
    },
    Upgrades = {
        BlipCoords = vec3(-262.93, 202.72, 84.37),
        Sprite = 289,
        Display = 4,
        Scale = 0.8,
        Colour = 6,
        Name = "Upgrades for warehouses"
    },
    TechShop = {
        BlipCoords = vec3(132.06, -1510.09, 28.14),
        Sprite = 485,
        Display = 4,
        Scale = 0.8,
        Colour = 1,
        Name = "Illegal Tech Shop"
    },
}

Config.MoneyWash = {
    ReportChanceWhenEntering = 5, -- only if he has alarm
    NeedPoliceCount = 0,
    InsidePositions = {
        ["Exit"] = {
            coords = vector4(1137.99, -3199.13, -39.67, 0.83),
        },
    },
    HackDevice = {
        ["HackDevice"] = {
            Label = "Hack Alarm",
            NeedItem = true,
            Item = "hack_laptop",
            Coords = vec3(1139.22, -3199.26, -39.23)
        }
    },

    Camera = vector3(1135.27, -3193.56, -40.43),

    Manage = vector3(1129.56, -3193.44, -40.51),

    LaserChance = 100,
    Lasers = {
        ["laser_low1"] = {
            FromCoords = vector3(1139.94, -3193.02, -36.66),
            ToCoords =  {vector3(1130.47, -3198.2, -40.65), vector3(1126.56, -3194.85, -41.32)},
            Visible = true,
            chance = 30,
            spawned = false
        },
    },
    Stashes = {
        ["stash"] = {
            coords = vector3(1138.5, -3193.24, -40.35),
            label = "Stash",
            TargetIcon = "fas fa-warehouse",
            TargetLabel = "Stash",
            Slots = 20,
            Weight = 50000, -- 50 KG
            radius = 0.5,
        },
    },
    CloakRoom = {
        Main = { coords = vector3(1116.45, -3192.88, -40.07), radius = 0.5 },
    },
    Count = {
        ["count1"] = {
            pos = vector3(1120.01, -3198.48, -40.56),
            animation = vector3(1119.58, -3197.85, -40.39),
            Visible = true,
            chance = 30,
            spawned = false
        },
        ["count2"] = {
            pos = vector3(1117.93, -3197.23, -40.59),
            animation = vector3(1117.37, -3196.95, -40.39),
            Visible = false,
            chance = 100,
            spawned = false
        },
    },
    CountItems = {
        RequiredItems = { item = "dry_money", minimum = 2000, maximum = 50000 },
        AnimationDuration = 4000, -- Duration of animation
        PercentageLost = 91.5, -- % kept at this stage. Four stages at 91.5% leave players about 70%
        AddItems = { item = "money" },
    },
    Cut = {
        ["table1"] = {
            pos = vector3(1122.11, -3198.45, -40.53),
            animation = vector3(1122.29, -3197.84, -40.39),
            Visible = true,
            chance = 30,
            spawned = false
        },
    },
    CutItems = {
        -- required item can be changed in server / sv_utils.lua by default its working on markedbills/dirty_money function is called: CheckDirtyMoney
        RequiredItems = { minimum = 2000, maximum = 50000 },
        AnimationDuration = 4000, -- Duration of animation (cooldown for timeout)
        PercentageLost = 91.5, -- % kept at this stage. Four stages at 91.5% leave players about 70%
        AddItems = { item = "unmarked_money" },
    },
    Wash = {
        ["dryer1"] = {
            pos = vector3(1122.33, -3193.8, -40.39),
            animation = vector3(1122.42, -3194.77, -40.4),
            Visible = true,
            chance = 30,
            spawned = false
        },
        ["dryer2"] = {
            pos = vector3(1123.77, -3193.66, -40.34),
            animation = vector3(1123.93, -3194.8, -40.4),
            Visible = false,
            chance = 100,
            spawned = false
        },
        ["dryer3"] = {
            pos = vector3(1125.54, -3193.79, -40.32),
            animation = vector3(1125.47, -3194.82, -40.4),
            Visible = false,
            chance = 100,
            spawned = false
        },
        ["dryer4"] = {
            pos = vector3(1126.94, -3193.68, -40.33),
            animation = vector3(1127.11, -3194.59, -40.4),
            Visible = false,
            chance = 100,
            spawned = false
        },
    },
    WashItems = {
        RequiredItems = { item = "unmarked_money", minimum = 2000, maximum = 50000 },
        Cooldown = 0.033, -- seconds per dollar. About 5 minutes per $10,000 here, so wash plus dry takes about 10
        UpgradeReduction = 10, -- % of time to be reduced
        AnimationDuration = 4000, -- Duration of animation
        PercentageLost = 91.5, -- % kept at this stage. Four stages at 91.5% leave players about 70%
        AddItems = { item = "wet_money" },
    },
    Dry = {
        Load = { pos = vector3(1133.18, -3198.13, -39.82), },
        Start =  { pos = vector3(1132.36, -3197.61, -39.27), },
        Collect = { pos = vector3(1126.12, -3197.78, -39.95), },
    },
    UpgradedDry = {
        Load = { pos = vector3(1136.11, -3198.03, -39.91), },
        Start =  { pos = vector3(1135.35, -3197.63, -39.27), },
        Collect = { pos = vector3(1126.12, -3197.78, -39.95), },
    },
    DryItems = {
        RequiredItems = { item = "wet_money", minimum = 2000, maximum = 50000 },
        Cooldown = 0.033, -- seconds per dollar. About 5 minutes per $10,000 here, so wash plus dry takes about 10
        UpgradeReduction = 10, -- % of time to be reduced
        AnimationDuration = 4000, -- Duration of animation
        PercentageLost = 91.5, -- % kept at this stage. Four stages at 91.5% leave players about 70%
        AddItems = { item = "dry_money" },
    },
}

Config.Warehouses = {
    ["Warehouse1"] = {
        Coords = vec3(1184.47, -3303.93, 7.02),
        TeleportExit = vec3(1183.77, -3303.93, 6.09),
        Camera = { 
            PropPos = vec3(1184.19, -3302.41, 9.22),
            PropRot = vec3(21.2, 10.49, -55.62), 
            pos = vec3(1183.29, -3302.4, 9.95), 
            rot = vec3(-50.0, 0.0, 168.64), 
            fov = 70.0 
        },
        label = "Warehouse #1",
        description = "Located on Buccaneer Way at the docks, ideal for marine logistics. ",
        image = 'https://i.imgur.com/77NQkgZ.png',
        MoneyWash = Config.MoneyWash,
        price = 30090,
    },
    ["Warehouse2"] = {
        Coords = vec3(328.53, -994.34, 29.32),
        TeleportExit = vec3(328.53, -994.34, 28.32),
        Camera = { 
            PropPos = vec3(324.02, -1005.918, 34.82),
            PropRot = vec3(0.00, -0.00, 131.48), 
            pos = vec3(324.48, -1004.9, 34.07), 
            rot = vec3(-50.0, 0.0, 337.78), 
            fov = 90.0 
        },
        label = "Warehouse #2",
        description = "Positioned on Atlee Street near the police station, it's secure and well-enclosed. ",
        image = 'https://i.imgur.com/r453ueX.png',
        MoneyWash = Config.MoneyWash,
        price = 25000,
    },
    ["Warehouse3"] = {
        Coords = vec3(448.65, -2761.5, 7.1),
        TeleportExit = vec3(448.65, -2761.5, 6.1),
        Camera = { 
            PropPos = vec3(449.693, -2760.644, 8.484),
            PropRot = vec3(5.58, 22.02, -94.96), 
            pos = vec3(449.14, -2760.46, 8.17), 
            rot = vec3(-40.0, 0.0, 142.8), 
            fov = 90.0 
        },
        label = "Warehouse #3",
        description = "Situated on Abattoir Avenue at the docks, perfect for marine trading. ",
        image = 'https://i.imgur.com/Y8kbRvn.png',
        MoneyWash = Config.MoneyWash,
        price = 22000,
    },
    ["Warehouse4"] = {
        Coords = vec3(128.02, -1577.6, 29.73),
        TeleportExit = vec3(128.02, -1577.6, 28.73),
        Camera = { 
            PropPos = vec3(124.795, -1575.1199, 34.0036),
            PropRot = vec3(152.851, 18.079, -70.957), 
            pos = vec3(125.62, -1575.29, 33.44), 
            rot = vec3(-40.0, 0.0, 246.33), 
            fov = 90.0 
        },
        label = "Warehouse #4",
        description = "Based in the town's center on Strawberry Avenue, easily accessible for local markets. ",
        image = 'https://i.imgur.com/Q0Di9zN.png',
        MoneyWash = Config.MoneyWash,
        price = 35000,
    },
    ["Warehouse5"] = {
        Coords = vec3(-29.01, -234.13, 45.29),
        TeleportExit = vec3(-29.01, -234.13, 44.29),
        Camera = { 
            PropPos = vec3(-10.07430076599121, -231.8565216064453, 52.82437896728515),
            PropRot = vec3(0.0, 0.0, -110.558), 
            pos = vec3(-11.63, -231.88, 52.87), 
            rot = vec3(-40.0, 0.0, 93.82), 
            fov = 90.0 
        },
        label = "Warehouse #5",
        description = "Resides on Occupation Avenue. ",
        image = 'https://i.imgur.com/8m1ZFXf.png',
        MoneyWash = Config.MoneyWash,
        price = 45000,
    },
    ["Warehouse6"] = {
        Coords = vec3(1133.14, -323.31, 67.15),
        TeleportExit = vec3(1133.14, -323.31, 66.15),
        Camera = { 
            PropPos = vec3(1142.6623, -322.3881, 70.976),
            PropRot = vec3(16.169, -5.779, -135.8634), 
            pos = vec3(1141.6, -321.92, 70.65), 
            rot = vec3(-40.0, 0.0, 91.83), 
            fov = 90.0 
        },
        label = "Warehouse #6",
        description = "Located on Bridge Street, near a gas station, convenient for transport businesses. ",
        image = 'https://i.imgur.com/j9iuz3V.png',
        MoneyWash = Config.MoneyWash,
        price = 38000,
    },
    ["Warehouse7"] = {
        Coords = vec3(1135.04, -789.22, 57.6),
        TeleportExit = vec3(1135.04, -789.22, 56.6),
        Camera = { 
            PropPos = vec3(1143.0631, -789.557, 60.5085),
            PropRot = vec3(0.0, 0.0, -102.337), 
            pos = vec3(1141.67, -789.55, 60.67), 
            rot = vec3(-40.0, 0.0, 115.76), 
            fov = 90.0 
        },
        label = "Warehouse #7",
        description = "Found on West Mirror Drive, behind a mechanic's workshop, ideal for automotive businesses. ",
        image = 'https://i.imgur.com/0JwWSsP.png',
        MoneyWash = Config.MoneyWash,
        price = 30000,
    },
    ["Warehouse8"] = {
        Coords = vec3(2476.14, 4087.35, 38.12),
        TeleportExit = vec3(2476.14, 4087.35, 37.12),
        Camera = { 
            PropPos = vec3(2473.9135, 4083.228, 40.6668),
            PropRot = vec3(8.639, 14.836, 102.745), 
            pos = vec3(2474.85, 4083.99, 40.48), 
            rot = vec3(-40.0, 0.0, 325.42), 
            fov = 90.0 
        },
        label = "Warehouse #8",
        description = " Located on East Joshua Road in Sandy Shores, suitable for businesses seeking quieter locations. ",
        image = 'https://i.imgur.com/FoYChng.png',
        MoneyWash = Config.MoneyWash,
        price = 20000,
    },
    ["Warehouse9"] = {
        Coords = vec3(-8.28, 6487.56, 31.51),
        TeleportExit = vec3(-8.28, 6487.56, 30.51),
        Camera = { 
            PropPos = vec3(-9.184, 6486.3789, 33.556),
            PropRot = vec3(27.295, -2.774, 112.105), 
            pos = vec3(-8.75, 6486.75, 33.29), 
            rot = vec3(-40.0, 0.0, 312.65), 
            fov = 90.0 
        },
        label = "Warehouse #9",
        description = "Positioned on Paleto Boulevard in Paleto Bay, offers a peaceful and scenic setting. ",
        image = 'https://i.imgur.com/9PsI8Mr.png',
        MoneyWash = Config.MoneyWash,
        price = 15000,
    },
    ["Warehouse10"] = {
        Coords = vec3(-91.43, 6514.7, 32.1),
        TeleportExit = vec3(-91.43, 6514.7, 31.1),
        Camera = { 
            PropPos = vec3(-9.184, 6486.3789, 33.556),
            PropRot = vec3(27.295, -2.774, 112.105), 
            pos = vec3(-8.75, 6486.75, 33.29), 
            rot = vec3(-40.0, 0.0, 312.65), 
            fov = 90.0 
        },
        label = "Warehouse #X",
        description = "Located on Procopio Drive in Paletobay, great for operations requiring a tranquil environment. ",
        image = 'https://i.imgur.com/BtRol6o.png',
        MoneyWash = Config.MoneyWash,
        price = 55000,
    },
}


--Shop
Config.UpgradeShop = {
    enabled = true,
    Header = "Upgrade shop",
    Items = {
        ["laundry"] = { enabled = true, label = 'Buy Laundry Setup for your warehouse', description =
        "Buy upgrade for your warehouse for: $", price = 8000, image = "https://i.imgur.com/VC2KQdv.png", icon = "sack-dollar" },
        ["alarm"] = { enabled = true, label = 'Security Alarm Upgrade', description =
        "Buy upgrade for your warehouse for: $", price = 2000, image = "https://i.imgur.com/Qy4shWi.png", icon = "eye" },
        ["laser"] = { enabled = true, label = 'Security Laser Upgrade', description =
        "Buy upgrade for your warehouse for: $", price = 3000, image = "https://i.imgur.com/HEASryA.png", icon = "server" },
        ["printer"] = { enabled = true, label = 'Faster and better dryer Upgrade (Laundry needed)', description =
        "Buy upgrade for your warehouse for: $", price = 4000, image = "https://i.imgur.com/Rluafl0.png", icon = "print" },
        ["washing"] = { enabled = true, label = 'Faster and better washing Upgrade (Laundry needed)', description =
        "Buy upgrade for your warehouse for: $", price = 5000, image = "https://i.imgur.com/ZPM33Ef.png", icon = "hands-bubbles" },
    },
    Ped = {
        model = `s_m_y_waretech_01`,
        coords = vec4(-262.93, 202.72, 84.37, 186.32),
        scenario = "WORLD_HUMAN_AA_SMOKE",
        renderdistance = 100
    },
}

--Shop
Config.Shop = {
    enabled = true,   
    Header = "Illegal Tech Shop",
    Items = {
        { label = 'Hacking laptop', item = 'hack_laptop', description = "Buy Laptop for: $", price = 500, 
        MinAmount = 1, MaxAmount = 2, image = "https://i.imgur.com/ne0omnr.png" },
        { label = 'Lockpick', item = 'lockpick', description = "Buy Lockpick for: $", price = 10, 
        MinAmount = 1, MaxAmount = 20, image = "https://i.imgur.com/wvqfHdS.png" },
        { label = 'Warehouse Locator', item = 'warehouse_locator', description = "Buy Locator for: $", price = 100, 
        MinAmount = 1, MaxAmount = 20, image = "https://i.imgur.com/gYNsh2y.png" },
    },
    Ped = {
        model = `s_m_y_waretech_01`, 
        coords = vec4(132.03, -1510.07, 28.14, 231.38), 
        scenario = "WORLD_HUMAN_AA_SMOKE",
        renderdistance = 100
    },
}

--SellShop
Config.WarehouseShop = {
    enabled = true,
    Ped = {
        model = `a_m_y_business_03`,
        coords = vec4(-697.9, 271.6, 82.11, 302.21),
        scenario = "WORLD_HUMAN_AA_COFFEE",
        renderdistance = 100
    },
}
