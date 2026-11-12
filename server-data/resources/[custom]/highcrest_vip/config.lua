Config = {}

-- VIP tiers, lowest to highest. A higher tier gets everything a lower tier has.
--   rank:   used for "this tier or higher" checks
--   plates: how many cars can have a custom plate at once
--   perks:  on/off perks (see the list below)
-- Perks:
--   earlyAccess   new imports can be bought before everyone else (Config.earlyAccess)
--   collection    can buy the VIP Collection cars (Config.collection)
--   freeValet     the phone's "Bring to me" valet is free
--   freeTransfers moving a car between garages is free (recovering a car left out still costs)
Config.tiers = {
    supporter = { label = 'Supporter', rank = 1, colour = '#c0c0c0', plates = 0, perks = {} },
    vip = { label = 'VIP', rank = 2, colour = '#d4af37', plates = 1, perks = { freeValet = true } },
    elite = { label = 'Elite', rank = 3, colour = '#c8102e', plates = 3, perks = { freeValet = true, freeTransfers = true } },
}

-- VIP Collection (off for now): imports only tiers with the 'collection' perk can buy. Model names.
-- Keep this small so everyone else still has the full dealership. Example:
--   Config.collection = { 'rrbuffalosx', 'schlagenstr' }
Config.collection = {}

-- Early access (off for now): new imports tiers with the 'earlyAccess' perk can buy first. Everyone else from the
-- date given (year-month-day). Example:
--   Config.earlyAccess = { ['elegyrh7'] = '2026-11-25' }
Config.earlyAccess = {}

-- Custom plates: 1 to 8 letters, numbers or spaces.
Config.plateLength = { min = 1, max = 8 }
