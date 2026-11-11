Config = {}

-- Job that can use the mechanic tablet (must be on duty).
Config.job = 'mechanic'

-- Mechanic shops. Customers design their build in the design bay with their own car.
--   business: the Empire business id that receives the shop's share (nil = none yet).
Config.shops = {
    vinewood = {
        label = 'Highcrest Motorworks',
        -- LS Customs Vinewood. Stalls: the middle of the floor plus the two old
        -- qbx_mechanicjob lift spots (those lifts are turned off in its config).
        bay = vec4(-333.0, -136.0, 38.9, 160.0), -- map blip
        bays = {
            vec4(-333.0, -136.0, 38.9, 160.0),
            vec4(-340.95, -128.24, 39.0, 160.0),
            vec4(-327.91, -144.34, 38.86, 70.34),
        },
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
    customPaint = 2500,  -- custom colour wheel and Wild paints
    illegalTint = 5000,  -- Pure Black window tint (not street legal)
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
            { key = 'color1', label = 'Primary colour', kind = 'paint' },
            { key = 'color2', label = 'Secondary colour', kind = 'paint' },
            { key = 'pearlescentColor', label = 'Pearlescent shine', kind = 'color' },
        },
    },
    {
        id = 'wheels', label = 'Wheels & Tyres',
        items = {
            { key = 'wheels', label = 'Rim category', kind = 'list', list = 'wheelTypes' },
            { key = 'modFrontWheels', label = 'Rims', kind = 'mod' },
            { key = 'wheelColor', label = 'Rim colour', kind = 'color' },
            { key = 'tyres', label = 'Tyres', kind = 'list', list = 'tyreTypes' },
            { key = 'tyreSmoke', label = 'Tyre smoke', kind = 'list', list = 'smokeColors' },
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

-- Paint, grouped for the menu. { GTA colour index, name, swatch hex for the menu }.
Config.paintGroups = {
    {
        label = 'Classic',
        colors = {
            { 0, 'Black', '#0d1116' }, { 1, 'Graphite', '#1c1d21' }, { 2, 'Black Steel', '#32383d' },
            { 11, 'Anthracite', '#1d2129' }, { 3, 'Dark Silver', '#454b4f' }, { 4, 'Silver', '#999da0' },
            { 5, 'Blue Silver', '#c2c4c6' }, { 7, 'Shadow Silver', '#637380' }, { 10, 'Gun Metal', '#444e54' },
            { 111, 'Ice White', '#fffff6' }, { 112, 'Frost White', '#eaeaea' }, { 107, 'Cream', '#f1e3c3' },
            { 27, 'Red', '#c00e1a' }, { 28, 'Torino Red', '#da1918' }, { 29, 'Formula Red', '#b6111b' },
            { 35, 'Candy Red', '#b60f25' }, { 150, 'Lava Red', '#bc1917' }, { 34, 'Cabernet', '#49111d' },
            { 143, 'Black Red', '#26030b' }, { 36, 'Sunrise Orange', '#d44a17' }, { 38, 'Orange', '#f78616' },
            { 37, 'Classic Gold', '#c2944f' }, { 88, 'Taxi Yellow', '#ffcf20' }, { 89, 'Race Yellow', '#fbe212' },
            { 92, 'Lime', '#98d223' }, { 53, 'Green', '#155c2d' }, { 50, 'Racing Green', '#122e2b' },
            { 54, 'Gasoline Green', '#1b6770' }, { 49, 'Dark Green', '#132428' }, { 70, 'Bright Blue', '#0b9cf1' },
            { 68, 'Surf Blue', '#76afbe' }, { 73, 'Ultra Blue', '#2354a1' }, { 64, 'Blue', '#47578f' },
            { 62, 'Dark Blue', '#233155' }, { 61, 'Midnight Blue', '#222e46' }, { 141, 'Black Blue', '#0a0c17' },
            { 145, 'Purple', '#621276' }, { 71, 'Purple Blue', '#2f2d52' }, { 135, 'Hot Pink', '#f21f99' },
            { 137, 'Vermillion Pink', '#df5891' }, { 136, 'Salmon Pink', '#f69799' }, { 90, 'Bronze', '#946025' },
            { 96, 'Choco Brown', '#221b19' }, { 104, 'Choco Orange', '#a95d27' }, { 105, 'Beach Sand', '#e2bd8f' },
        },
    },
    {
        label = 'Matte',
        colors = {
            { 12, 'Matte Black', '#13181f' }, { 13, 'Matte Grey', '#26282a' }, { 14, 'Matte Light Grey', '#515554' },
            { 131, 'Matte Ice White', '#fcf9f1' }, { 39, 'Matte Red', '#cf1f21' }, { 40, 'Matte Dark Red', '#732021' },
            { 41, 'Matte Orange', '#f27d20' }, { 42, 'Matte Yellow', '#ffc91f' }, { 55, 'Matte Lime', '#66b81f' },
            { 128, 'Matte Green', '#4e6443' }, { 151, 'Matte Forest Green', '#2d362a' }, { 155, 'Matte Foliage Green', '#5a6352' },
            { 152, 'Matte Olive Drab', '#696748' }, { 153, 'Matte Desert Brown', '#7a6c55' }, { 154, 'Matte Desert Tan', '#c3b492' },
            { 83, 'Matte Blue', '#253aa7' }, { 82, 'Matte Dark Blue', '#1f2852' }, { 84, 'Matte Midnight Blue', '#1c3551' },
            { 148, 'Matte Purple', '#6b1f7b' }, { 149, 'Matte Dark Purple', '#1e1d22' },
        },
    },
    {
        label = 'Metals & Chrome',
        colors = {
            { 120, 'Chrome', '#c9d1d9' }, { 117, 'Brushed Steel', '#6a747c' }, { 118, 'Brushed Black Steel', '#354158' },
            { 119, 'Brushed Aluminium', '#9ba0a8' }, { 158, 'Pure Gold', '#c9a33a' }, { 159, 'Brushed Gold', '#ae8e4c' },
        },
    },
}

-- Paint finishes for custom colours (GTA paint types).
Config.finishes = { { 0, 'Gloss' }, { 1, 'Metallic' }, { 2, 'Pearl' }, { 3, 'Matte' }, { 4, 'Metal' }, { 5, 'Chrome' } }

-- Wild paints: custom colours with a finish. { { r, g, b, finish }, name }.
Config.wildPaints = {
    { { 255, 0, 170, 2 }, 'Hyper Magenta' }, { { 110, 0, 255, 2 }, 'Ultraviolet' }, { { 0, 240, 255, 2 }, 'Electric Cyan' },
    { { 57, 255, 20, 2 }, 'Toxic Green' }, { { 255, 80, 0, 2 }, 'Lava Orange' }, { { 220, 255, 0, 3 }, 'Acid Yellow' },
    { { 255, 100, 0, 3 }, 'Matte Neon Orange' }, { { 60, 0, 90, 3 }, 'Matte Midnight Grape' }, { { 4, 4, 6, 3 }, 'Vanta Black' },
    { { 180, 0, 20, 5 }, 'Blood Chrome' }, { { 255, 190, 40, 5 }, 'Gold Chrome' }, { { 150, 220, 255, 5 }, 'Ice Chrome' },
    { { 255, 120, 170, 5 }, 'Rose Chrome' }, { { 90, 0, 160, 5 }, 'Purple Chrome' }, { { 0, 160, 80, 5 }, 'Emerald Chrome' },
}

-- Index colours for pearlescent and rim colour (every paint above that isn't custom).
Config.colors = {}
for _, group in ipairs(Config.paintGroups) do
    for _, c in ipairs(group.colors) do Config.colors[#Config.colors + 1] = { c[1], c[2], c[3] } end
end

Config.lists = {
    -- Rim categories (GTA wheel types).
    wheelTypes = {
        { 11, 'Street' }, { 12, 'Track' }, { 0, 'Sport' }, { 5, 'Tuner' }, { 1, 'Muscle' }, { 7, 'High End' },
        { 2, 'Lowrider' }, { 3, 'SUV' }, { 4, 'Off-road' }, { 8, "Benny's Original" }, { 9, "Benny's Bespoke" },
        { 10, 'Open Wheel' },
    },
    tyreTypes = { { 0, 'Stock tyres' }, { 1, 'Custom sidewall tyres' }, { 2, 'Drift tyres' } },
    smokeColors = {
        { 0, 'Off' }, { 1, 'White' }, { 2, 'Black' }, { 3, 'Crimson' }, { 4, 'Orange' }, { 5, 'Yellow' },
        { 6, 'Lime' }, { 7, 'Blue' }, { 8, 'Purple' }, { 9, 'Pink' },
    },
    -- A third value of true marks an option that isn't street legal (charged at the illegalTint price).
    windowTints = {
        { 0, 'None' }, { 3, 'Light Smoke' }, { 2, 'Dark Smoke' }, { 5, 'Limo' }, { 6, 'Green' },
        { 1, 'Pure Black (not street legal)', true },
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

-- Tyre smoke colours by smokeColors value.
Config.smokeRgb = {
    [1] = { 254, 254, 254 }, [2] = { 1, 1, 1 }, [3] = { 200, 16, 46 }, [4] = { 255, 120, 0 }, [5] = { 255, 220, 0 },
    [6] = { 94, 255, 1 }, [7] = { 0, 80, 255 }, [8] = { 120, 0, 255 }, [9] = { 255, 60, 160 },
}

Config.neonColors = {
    { { 255, 255, 255 }, 'White' }, { { 200, 16, 46 }, 'Crimson' }, { { 255, 1, 1 }, 'Red' },
    { { 255, 150, 0 }, 'Gold' }, { { 255, 255, 0 }, 'Yellow' }, { { 94, 255, 1 }, 'Lime' },
    { { 0, 255, 140 }, 'Mint' }, { { 3, 83, 255 }, 'Electric Blue' }, { { 2, 21, 255 }, 'Blue' },
    { { 35, 1, 255 }, 'Purple' }, { { 255, 50, 100 }, 'Pink' },
}

-- Some catalogue keys are menu shortcuts for one or more vehicle properties.
-- toProps: menu value -> ox_lib vehicle properties. fromProps: properties -> menu value.
local PAINT_TYPE = { color1 = 'paintType1', color2 = 'paintType2' }

function Config.toProps(key, value)
    if PAINT_TYPE[key] then
        if type(value) == 'table' then
            return { [key] = { value[1], value[2], value[3] }, [PAINT_TYPE[key]] = value[4] or 0 }
        end
        return { [key] = value }
    end
    if key == 'tyres' then
        return { modCustomTiresF = value == 1, modCustomTiresR = value == 1, driftTyres = value == 2 }
    end
    if key == 'tyreSmoke' then
        if value == 0 then return { modSmokeEnabled = false } end
        return { modSmokeEnabled = true, tyreSmokeColor = Config.smokeRgb[value] }
    end
    return { [key] = value }
end

function Config.fromProps(key, props)
    props = props or {}
    if PAINT_TYPE[key] then
        local v = props[key]
        if type(v) == 'table' then return { v[1], v[2], v[3], props[PAINT_TYPE[key]] or 0 } end
        return v
    end
    if key == 'tyres' then
        if props.driftTyres then return 2 end
        return props.modCustomTiresF and 1 or 0
    end
    if key == 'tyreSmoke' then
        if not props.modSmokeEnabled then return 0 end
        local c = props.tyreSmokeColor
        if type(c) ~= 'table' then return nil end
        for i, rgb in pairs(Config.smokeRgb) do
            if rgb[1] == c[1] and rgb[2] == c[2] and rgb[3] == c[3] then return i end
        end
        return nil
    end
    return props[key]
end

-- Which camera view and how long each part takes, by catalogue tab.
Config.workViews = {
    performance = { angle = 90.0, dist = 5.0, height = 1.3, hood = true },  -- front, bonnet up
    body = { angle = 135.0, dist = 6.0, height = 1.4 },
    paint = { angle = 150.0, dist = 6.5, height = 1.8 },
    wheels = { angle = 20.0, dist = 3.8, height = 0.6 },                    -- low, side on
    lights = { angle = 75.0, dist = 5.0, height = 1.0 },
    extras = { angle = -90.0, dist = 5.0, height = 1.1 },                   -- rear
}
