Config = {
    -- Inventory item a player must carry to use the phone.
    phoneItem = 'phone',

    -- Gallery limits. Photos are stored in the database, so these control its growth.
    maxPhotosPerCharacter = 40,
    photoCooldownSeconds = 3,
    photoMaxWidth = 1280,
    photoMaxHeight = 720,

    defaults = {
        caseColor = '#0B0B0D',
        accentColor = '#C8102E',
        wallpaper = 'preset:crimson',
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
