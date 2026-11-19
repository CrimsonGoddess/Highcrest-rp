Config = {}

-- Framework mode:
-- "auto" tries qbx_core -> qb-core -> standalone
Config.Framework = "auto"

-- Require aiming with a firearm
Config.RequireGunAim = true

-- Max distance to rob the NPC while aiming
Config.MaxRobDistance = 3.0

-- Robbery duration (seconds)
Config.RobTime = 8

-- Player cooldown between robbery attempts (seconds)
Config.PlayerCooldown = 10

-- Chance behavior (0.0 - 1.0)
Config.ChanceComply = 0.65
Config.ChanceRun    = 0.20
Config.ChanceFight  = 0.15
-- NOTE: Make sure these add up to 1.0 (or close). The script will still work if they don't, but balance will be off.

-- Prevent robbing these ped types/models
Config.BlockPolicePeds = true
Config.BlockGangPeds = false -- optional if you want to block gangs etc (you can expand this later)
-- Ped blacklist
Config.PedBlacklist = {
    -- Block all animal ped types automatically
    blockAnimals = true,

    -- Optional explicit model blacklist (for custom peds)
    models = {
        -- Animals (extra safety / custom servers)
        `a_c_chop`,
        `a_c_husky`,
        `a_c_retriever`,
        `a_c_rottweiler`,
        `a_c_shepherd`,
        `a_c_cow`,
        `a_c_deer`,
        `a_c_pig`,
        `a_c_boar`,
        `a_c_mtlion`,
        `a_c_coyote`,
        `a_c_rabbit`,
        `a_c_cat_01`,
        `a_c_chickenhawk`,
        `a_c_hen`,
    }
}


-- Fight-back weapon pool for NPCs
Config.NPCWeapons = {
    `WEAPON_PISTOL`,
    `WEAPON_COMBATPISTOL`,
    `WEAPON_PISTOL50`,
    `WEAPON_PISTOLXM3`,
    `WEAPON_VINTAGEPISTOL`,
    `WEAPON_HEAVYPISTOL`,
    `WEAPON_CERAMICPISTOL`,
    `WEAPON_SNSPISTOL`,

}

-- Rewards
Config.Rewards = {
    Cash = {
        enabled = true,
        min = 60,
        max = 200,
    },
    Items = {
        enabled = true,
        -- Each item entry: { item = "name", min = 1, max = 2, chance = 0.35 }
        pool = {
            { item = "ls_plain_jane_joint",        min = 1, max = 3, chance = 0.50 },
            { item = "ls_cocaine_bag",       min = 1, max = 3, chance = 0.10 },
            { item = "ls_crack_bag",    min = 1, max = 3, chance = 0.10 },
            { item = "safekey",      min = 1, max = 1, chance = 0.20 },
            { item = "trojan_usb",      min = 1, max = 1, chance = 0.15 },
            { item = "WEAPON_SNSPISTOL",      min = 1, max = 1, chance = 0.05 },
        }
    }
}

-- ps-dispatch integration
Config.PSDispatch = {
    enabled = true,
    code = "10-31",
    title = "Armed Robbery (Civilian)",
    description = "Civilian being robbed at gunpoint",
    radius = 0, -- 0 = use dispatch default
    sprite = 156,
    color = 1,
    scale = 1.2,
    length = 2, -- minutes on map (depends on ps-dispatch version)
}

-- Optional: show a small help text when aiming at a valid NPC
Config.ShowHelpText = true
Config.HelpText = "[E] Rob civilian"
