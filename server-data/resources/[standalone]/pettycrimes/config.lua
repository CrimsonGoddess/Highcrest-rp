Config = {}

-- Cooldowns (seconds)
Config.Cooldowns = {
    ParkingMeter = 10 * 60,
    Vending      = 10 * 60,
}

-- Police / Dispatch
Config.Police = {
    enabled = true,
    minCops = 0,                 -- set to your preference
    alertChance = 50,            -- %
    jobs = { 'police', 'bcso' },  -- jobs that receive ps-dispatch alert (MUST match job names)
}

-- Required items
Config.Items = {
    Lockpick = 'lockpick',
    Crowbar  = 'WEAPON_CROWBAR',
}

-- Optional item break chance (on failure)
Config.BreakChance = {
    LockpickFail = 0, -- %
    CrowbarFail  = 0,  -- %
}

-- Parking meter settings
Config.ParkingMeter = {
    cashMin = 100,
    cashMax = 250,
    skillcheck = { 'easy', 'easy', 'medium' },
    anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' },
    progressMs = 4500,
}

-- Vending machine settings
Config.Vending = {
    skillcheck = { 'easy', 'medium' },
    anim = { dict = 'missheistfbi3b_ig7', clip = 'lift_fibagent_loop' },
    progressMs = 5000,
    rewardCount = { min = 1, max = 3 },
    lootTable = {
        { item = 'crisps',     min = 1, max = 2, weight = 40 },
        { item = 'ecola',      min = 1, max = 2, weight = 35 },

    }
}

-- Target models
Config.Models = {
    ParkingMeters = {
        `prop_parknmeter_01`,
        `prop_parknmeter_02`,
    },
    VendingMachines = {
        `prop_vend_soda_01`,
        `prop_vend_soda_02`,
        `prop_vend_fridge01`,
        `prop_vend_water_01`,
        `prop_vend_coffe_01`,
        `prop_vend_snak_01`,
    }
}
