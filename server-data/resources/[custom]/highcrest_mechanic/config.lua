Config = {}

-- Job that can use the mechanic tablet (must be on duty).
Config.job = 'mechanic'

-- Mechanic shops. Customers design their build in the design bay with their own car.
--   business: the Empire business id that receives the shop's share (nil = none yet).
Config.shops = {
    vinewood = {
        label = 'Highcrest Motorworks',
        -- LS Customs Vinewood, middle of the floor. Keep clear of qbx_mechanicjob's lifts
        -- (-340.95 -128.24 and -327.91 -144.34) and exit box, or its prompt hides ours.
        bay = vec4(-333.0, -136.0, 38.9, 160.0),
        bayRadius = 4.0,
        business = nil,
    },
}

-- Money split. Parts money goes to the shop; labour is split between shop and mechanic.
Config.mechanicCut = 0.40   -- the mechanic's share of the labour fee
Config.maxLabour = 25000    -- highest labour fee a mechanic can charge on one order

-- Suggested labour per part; it fills in the quote box and the mechanic can change it.
Config.labourPerPart = 500

-- How far a shop boss can move each price on the tablet, as multiples of the standard price.
Config.priceLimits = { min = 0.5, max = 3.0 }

-- Standard part prices. Each shop's boss can change them on the tablet (Prices tab).
-- Self-service LS Customs charges 50% more than these (qbx_customs config).
Config.prices = {
    cosmetic = 500,
    color = 1000,
    turbo = 10000,
    -- Upgrade levels: the first price is stock, then level 1, 2...
    levels = {
        modEngine = { 0, 10000, 20000, 30000, 40000 },
        modBrakes = { 0, 2500, 5000, 7500 },
        modTransmission = { 0, 5000, 10000, 15000, 20000 },
        modSuspension = { 0, 3000, 6000, 9000, 12000, 15000 },
        modArmor = { 0, 2500, 5000, 7500, 10000, 12500 },
    },
}

-- Seconds a mechanic spends fitting each part.
Config.installSeconds = { performance = 8, default = 5 }

-- Body parts and other mod slots: ox_lib property name -> GTA mod index.
Config.modSlots = {
    modSpoilers = 0, modFrontBumper = 1, modRearBumper = 2, modSideSkirt = 3, modExhaust = 4,
    modFrame = 5, modGrille = 6, modHood = 7, modFender = 8, modRightFender = 9, modRoof = 10,
    modEngine = 11, modBrakes = 12, modTransmission = 13, modHorns = 14, modSuspension = 15,
    modArmor = 16, modFrontWheels = 23, modLivery = 48,
}

-- What customers can change, grouped by tab.
--   kind: mod (a mod slot list), level (upgrade levels), toggle, color, list, neon, neoncolor
Config.catalogue = {
    {
        id = 'performance', label = 'Performance',
        items = {
            { key = 'modEngine', label = 'Engine', kind = 'level' },
            { key = 'modBrakes', label = 'Brakes', kind = 'level' },
            { key = 'modTransmission', label = 'Transmission', kind = 'level' },
            { key = 'modSuspension', label = 'Suspension', kind = 'level' },
            { key = 'modArmor', label = 'Armour', kind = 'level' },
            { key = 'modTurbo', label = 'Turbo', kind = 'toggle' },
        },
    },
    {
        id = 'body', label = 'Body',
        items = {
            { key = 'modSpoilers', label = 'Spoiler', kind = 'mod' },
            { key = 'modFrontBumper', label = 'Front bumper', kind = 'mod' },
            { key = 'modRearBumper', label = 'Rear bumper', kind = 'mod' },
            { key = 'modSideSkirt', label = 'Side skirts', kind = 'mod' },
            { key = 'modExhaust', label = 'Exhaust', kind = 'mod' },
            { key = 'modGrille', label = 'Grille', kind = 'mod' },
            { key = 'modHood', label = 'Hood', kind = 'mod' },
            { key = 'modFender', label = 'Left fender', kind = 'mod' },
            { key = 'modRightFender', label = 'Right fender', kind = 'mod' },
            { key = 'modRoof', label = 'Roof', kind = 'mod' },
            { key = 'modFrame', label = 'Roll cage', kind = 'mod' },
            { key = 'modLivery', label = 'Livery', kind = 'mod' },
        },
    },
    {
        id = 'paint', label = 'Paint',
        items = {
            { key = 'color1', label = 'Primary colour', kind = 'color' },
            { key = 'color2', label = 'Secondary colour', kind = 'color' },
            { key = 'pearlescentColor', label = 'Pearlescent', kind = 'color' },
        },
    },
    {
        id = 'wheels', label = 'Wheels',
        items = {
            { key = 'wheels', label = 'Wheel type', kind = 'list', list = 'wheelTypes' },
            { key = 'modFrontWheels', label = 'Rims', kind = 'mod' },
            { key = 'wheelColor', label = 'Rim colour', kind = 'color' },
        },
    },
    {
        id = 'lights', label = 'Lights & Glass',
        items = {
            { key = 'windowTint', label = 'Window tint', kind = 'list', list = 'windowTints' },
            { key = 'modXenon', label = 'Xenon headlights', kind = 'toggle' },
            { key = 'xenonColor', label = 'Xenon colour', kind = 'list', list = 'xenonColors' },
            { key = 'neonEnabled', label = 'Underglow', kind = 'neon' },
            { key = 'neonColor', label = 'Underglow colour', kind = 'neoncolor' },
        },
    },
    {
        id = 'extras', label = 'Extras',
        items = {
            { key = 'modHorns', label = 'Horn', kind = 'mod' },
            { key = 'plateIndex', label = 'Plate style', kind = 'list', list = 'plateStyles' },
        },
    },
}

-- Paint colours (GTA colour index -> name).
Config.colors = {
    { 0, 'Black' }, { 1, 'Graphite' }, { 3, 'Dark Silver' }, { 4, 'Silver' }, { 7, 'Shadow Silver' },
    { 11, 'Anthracite' }, { 12, 'Matte Black' }, { 13, 'Matte Grey' }, { 27, 'Red' }, { 28, 'Torino Red' },
    { 29, 'Formula Red' }, { 30, 'Blaze Red' }, { 34, 'Cabernet' }, { 35, 'Candy Red' }, { 39, 'Matte Red' },
    { 36, 'Sunrise Orange' }, { 38, 'Orange' }, { 41, 'Matte Orange' }, { 37, 'Classic Gold' }, { 42, 'Matte Yellow' },
    { 88, 'Taxi Yellow' }, { 89, 'Race Yellow' }, { 92, 'Lime' }, { 49, 'Dark Green' }, { 50, 'Racing Green' },
    { 51, 'Sea Green' }, { 53, 'Green' }, { 55, 'Matte Lime' }, { 61, 'Midnight Blue' }, { 62, 'Dark Blue' },
    { 64, 'Blue' }, { 70, 'Bright Blue' }, { 73, 'Ultra Blue' }, { 83, 'Matte Blue' }, { 145, 'Purple' },
    { 148, 'Matte Purple' }, { 135, 'Hot Pink' }, { 137, 'Salmon Pink' }, { 111, 'White' }, { 112, 'Frost White' },
    { 117, 'Brushed Steel' }, { 118, 'Brushed Black Steel' }, { 119, 'Brushed Aluminium' }, { 120, 'Chrome' },
    { 158, 'Pure Gold' }, { 159, 'Brushed Gold' },
}

Config.lists = {
    wheelTypes = {
        { 0, 'Sport' }, { 1, 'Muscle' }, { 2, 'Lowrider' }, { 3, 'SUV' }, { 4, 'Offroad' }, { 5, 'Tuner' },
        { 7, 'High End' }, { 8, "Benny's Original" }, { 9, "Benny's Bespoke" }, { 11, 'Street' }, { 12, 'Track' },
    },
    windowTints = {
        { 0, 'None' }, { 3, 'Light Smoke' }, { 2, 'Dark Smoke' }, { 1, 'Pure Black' }, { 5, 'Limo' }, { 6, 'Green' },
    },
    xenonColors = {
        { -1, 'Stock' }, { 0, 'White' }, { 1, 'Blue' }, { 2, 'Electric Blue' }, { 3, 'Mint' }, { 4, 'Lime' },
        { 5, 'Yellow' }, { 6, 'Gold' }, { 7, 'Orange' }, { 8, 'Red' }, { 9, 'Pony Pink' }, { 10, 'Hot Pink' },
        { 11, 'Purple' }, { 12, 'Blacklight' },
    },
    plateStyles = {
        { 0, 'Blue on White' }, { 1, 'Yellow on Black' }, { 2, 'Yellow on Blue' }, { 3, 'Blue on White 2' },
        { 4, 'Blue on White 3' }, { 5, 'North Yankton' },
    },
}

Config.neonColors = {
    { { 255, 255, 255 }, 'White' }, { { 200, 16, 46 }, 'Crimson' }, { { 255, 1, 1 }, 'Red' },
    { { 255, 150, 0 }, 'Gold' }, { { 255, 255, 0 }, 'Yellow' }, { { 94, 255, 1 }, 'Lime' },
    { { 0, 255, 140 }, 'Mint' }, { { 3, 83, 255 }, 'Electric Blue' }, { { 2, 21, 255 }, 'Blue' },
    { { 35, 1, 255 }, 'Purple' }, { { 255, 50, 100 }, 'Pink' },
}
