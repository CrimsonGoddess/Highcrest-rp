Config = {
    -- Inventory item a player must carry to use the phone.
    phoneItem = 'phone',

    -- Gallery limits. Photos are stored in the database, so these control its growth.
    maxPhotosPerCharacter = 40,
    photoCooldownSeconds = 3,
    -- Photos are cropped to the phone screen when viewed, so they're captured at higher resolution.
    photoMaxWidth = 1920,
    photoMaxHeight = 1080,

    defaults = {
        caseColor = '#0B0B0D',
        accentColor = '#C8102E',
        wallpaper = 'preset:crimson',
    },

    -- Garage "Bring to me": a valet drives a stored vehicle to the player and walks off.
    valet = {
        fee = 250,                      -- Taken from cash, then bank. 0 makes it free.
        driverModel = 's_m_y_valet_01',
        spawnDistance = { min = 120, max = 260 }, -- How far away the valet starts, in metres.
        cooldownSeconds = 60,
        giveUpSeconds = 150,            -- After this the vehicle is placed at the nearest road instead.
    },

    -- Housing app and the /addhouse menu. Houses are saved into qbx_properties, which handles
    -- entering, stashes, wardrobes and keys.
    housing = {
        realtorJob = 'realestate',      -- This job can add houses, as can admins (group.admin).
        maxPrice = 100000000,
        defaultRentHours = 24,          -- How often rent is taken from the bank (1-24 hours).
        -- Shells realtors can choose from. Each model also needs an entry under `interiors`
        -- in qbx_properties/config/shared.lua (exit, stash, wardrobe and logout points).
        shells = {
            { model = 'furnitured_midapart', label = 'Furnished mid-size apartment' },
        },
    },

    -- Events a mail's action button may trigger. Anything else is ignored, because
    -- the mail system lets clients send mail that names its own event.
    mailButtonEvents = {
        'qb-drugs:client:setLocation',
    },

    -- Quick choices shown in Settings. Players can also pick any custom color.
    swatches = {
        '#0B0B0D', '#1C1C22', '#F5F5F5', '#C8102E', '#D4AF37',
        '#1F4E8C', '#1E7A5A', '#6B2FA0', '#E0689A', '#E07A1F',
    },

    -- id is saved per player. css is any CSS background.
    wallpapers = {
        { id = 'crimson', label = 'Crimson', css = 'radial-gradient(circle at 30% 15%, #8a0b20, #2a060c 55%, #0b0b0d)' },
        { id = 'gold', label = 'Gold Leaf', css = 'linear-gradient(155deg, #5c4a12, #1c1c22 60%, #0b0b0d)' },
        { id = 'midnight', label = 'Midnight', css = 'linear-gradient(170deg, #12233f, #0b0b0d 70%)' },
        { id = 'charcoal', label = 'Charcoal', css = 'linear-gradient(160deg, #2c2c35, #0b0b0d)' },
        { id = 'sunset', label = 'Vinewood', css = 'linear-gradient(170deg, #e07a1f, #8a1538 50%, #1b0a24)' },
        { id = 'neon', label = 'Street', css = 'linear-gradient(145deg, #3b0f5c, #0b0b0d 55%, #5c0714)' },
    },
}
