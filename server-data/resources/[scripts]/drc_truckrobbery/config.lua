Config = {}
Config.Locale = 'en'
Config.Debug = false
Config.Framework = 'qbcore'  --  'qbcore' or 'esx' /  auto-detect
Config.NewESX = true
Config.InteractionType = "target" -- target or textui or 3dtext | which type of interaction you want
Config.FrameworkTarget = 'ox_target' --qtarget or qb-target or ox_target / auto-detect
Config.Menu = 'ox_lib' -- qbcore / ox_lib
Config.Progress = 'ox_lib' -- qbcore / ox_lib
Config.TextUI = "ox_lib" -- TextUIs | types: esx, ox_lib, luke
Config.Context = 'ox_lib' -- qbcore / ox_lib
Config.Input = 'ox_lib' -- qbcore / ox_lib
Config.Clothing = 'illenium-appearance' -- esx_skin / fivem-appearance / illenium-appearance / qb-clothing
Config.PoliceJobs = { 'police', 'sheriff' }
Config.Dispatch = { enabled = true, script = "custom" } -- cd_dispatch, linden_outlawalert, ps-dispatch
Config.Logs = { enabled = false, type = "webhook" } --Change webhook in  use webhook or ox_lib (datadog) Can be changed in server > sv_utils.lua
Config.VehicleModel = `stockade` --vehicle spawn name

Config.Times = {
    HackTime = 20, -- How much seconds you have to hack 
    CoolDown = 60, -- In minutes. Applies only to the robbers, from when the robbery starts
    ActiveLock = 15, -- In minutes. Server-wide wait after any robbery starts, so two never overlap
    CountDown = 5 -- how much seconds it takes to explode c4
}


Config.C4 = {
    itemName = 'c4', -- Item name of the c4
    Chance = 20 -- Chance that c4 will not explode and have to be activated again
}

Config.Blip = {
    Pos = {1274.7621, -1721.0372, 54.6808},
    Sprite = 96,
    Display = 4,
    Scale = 1.0, 
    Colour = 3,
    ShortRange = true,
    Name = "Lester House",
    Enabled = false, -- Highcrest: no public blips for illegal places
}

Config.TruckBlip = {
    Truck = {
        Sprite = 477,
        Scale = 0.9,
        Colour = 29,
        Name = 'Security Truck'
    },
    TruckRadius = {
        Radius = 300.0,
        Name = 'TRUCK RADIUS',
        Scale = 1.5,
        Sprite = 477,
        Colour = 2
    }

}

Config.MissionStart = {
    StartMissionCoords = vec3(1274.46, -1720.49, 55.05), -- Where target 3dtext etc appear
    LeaveTeleportCoords = vec3(1274.78, -1720.97, 53.68), -- Where player spawns after completing minigame / failing
    CameraCoords = {x = 1276.4352, y = -1711.1195, z = 55.5042, rotX = 1.0, rotY = 0.0, rotZ = 85.8464, fov = 100.0}, -- Camera that will zoom on player 1
    PlayerTypeAnim = vec4(1272.2938, -1711.5671, 53.7715, 32.3324), -- Where player have the animation of typing
    VoiceTalk = true, -- Voice over after you successfully hack money truck location
    Cutscene = true, -- If you want cutscene to be turned on
    MaxTeamMembers = 2,  -- How many people can be in team recommended 2
    PoliceRequire = 2    -- How many on-duty police / sheriff must be on the server
}
Config.Offset = { x = 0.0, y = -3.5, z = 1.0 }

Config.TruckSpawn = {
    vec4(120.7979, -1057.4402, 29.1865, 133.6441),
    vec4(789.5583, -943.5524, 25.7265, 4.7960),
    vec4(-528.9175, -327.5963, 35.0376, 28.9772),
    vec4(-1263.7863, -646.8313, 26.8470, 25.3963)
}

Config.LootOdds = {
    diamonds = 30, -- Percentage chance for diamonds
    gold = 30,     -- Percentage chance for gold
    money = 40     -- Percentage chance for money
}

Config.Reward = {
    DirtyMoney = true,
    -- Paid per grab. Only the first MaxGrabs grabs per player pay, so a full trolley is worth about $10,000.
    MaxGrabs = 40,
    Money = {Min = 250, Max = 250},
    Gold = {Min = 1, Max = 1},
    Diamond = {Min = 1, Max = 1},
}


Config.Shop = {
    enabled = true,   
    Header = "Explosives dealer",
    Items = {
        { label = 'C4', item = 'c4', description = "Buy C4 for: $", price = 500, MinAmount = 1, MaxAmount = 2},
    },
    Ped = {
        model = `g_m_m_chicold_01`, 
        coords = vec4(236.67, -108.88, 72.35, 343.69), -- Highcrest: C4 dealer
        scenario = "WORLD_HUMAN_AA_SMOKE"
    },
    Blip = {
        Show = false, -- Highcrest: no blip; players find the dealer themselves
        RequireToAsk = true, -- if true he have to ask lester about location
        Name = 'Explosive Dealer',
        Sprite = 272,
        Scale = 1.0,
        Colour = 3,
    },
    Time = {
        enabled = true, -- If true then npc will appear only in this between this time
        time =  {
            from = 20,  -- from 8:00 PM
            to = 6     -- to 6:00 AM
        }
    }
}

Config.SellShop = {
    enabled = true,   
    EnabledSellAll = true,
    Header = "Sell",
    Items = {   
        { label = 'Diamond', item = 'diamond', description = "Sell diamonds for : $", price = 250, MinAmount = 1, MaxAmount = 20},
        { label = 'Gold', item = 'gold', description = "Sell gold for : $", price = 250, MinAmount = 1, MaxAmount = 20},
    },
    Ped = {
        model = `a_m_m_eastsa_01`, 
        coords = vec4(460.09, -1869.78, 24.98, 228.91), -- Highcrest: illegal dealer
        scenario = "WORLD_HUMAN_AA_COFFEE"
    },
    Blip = {
        Show = false, -- Highcrest: no blip; players find the buyer themselves
        Name = 'Illegal buyer',
        Sprite = 272,
        Scale = 1.0,
        Colour = 3,
    },
    Time = {
        enabled = false, -- If true then npc will appear only in this between this time
        time =  {
            from = 20,  -- from 8:00 PM
            to = 6     -- to 6:00 AM
        }
    }
}

