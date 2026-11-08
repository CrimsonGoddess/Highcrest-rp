Config = {
    VoiceSystem = "pma-voice", -- Voice system selection: "pma-voice" or "saltychat".
    UseCustomNotify = false, -- Use a custom notification system (true) or the default one (false).
    RadioItem = "radio", -- Radio item name
    RadioToggleKey = "Y",
    AllowMovement = true, -- By activating this, you enable the player to move while the menu is open.
    RestrictedChannels = { -- Restricted channels for jobs.
        [1] = { police = true, ambulance = true },
        [2] = { police = true, ambulance = true },
        [3] = { police = true, ambulance = true },
        [4] = { police = true, ambulance = true },
        [5] = { police = true, ambulance = true },
        [6] = { police = true, ambulance = true },
        [7] = { police = true, ambulance = true },
        [8] = { police = true, ambulance = true },
        [9] = { police = true, ambulance = true },
        [10] = { police = true, ambulance = true }
    },
    JammerSettings = { -- Jammer settings to interfere with communication.
        available = true, -- Jammers are available in the game.
        item_name = 'jammer', -- Name of the jammer item used by players.
        enable_jobs = false,
        restricted_jobs = { police = true }, -- Only certain jobs can use jammers.
        object = "ch_prop_ch_mobile_jammer_01x", -- Object representing the jammer in the game world.
        min_distance_between_jammers = 15, -- Minimum distance allowed between two jammers.
        range = 10.0, -- Effective range of the jammers.
    },
    MaxFrequency = 500, -- Maximum frequency value allowed in the game's radio communication system.
    Locale = 'en',
    -- ! PMA Voice Configs
    -- Radio communication effects and animation settings.
    RadioEffect = true, -- Enable radio submix (voice sounds like on real radio).
    RadioAnimation = true, -- Enable animation while talking on the radio.
    RadioKey = 'CAPS', -- Default keybind for talking on the radio (CAPS).
    RadioThemes = {
        [1] = { job = "police", theme = "theme2" },
        [2] = { job = "sheriff", theme = "theme3" },
    },
    CheckIsDead = function()
        local pData = GetPlayerData()
        return gPlayer.isDead or pData.metadata.isdead or pData.metadata.inlaststand
    end
}