return {
    checkInCost = 2000, -- Price for using the hospital check-in system
    minForCheckIn = 2, -- Minimum number of people with the ambulance job to prevent the check-in system from being used

    locations = { -- Various interaction points
        duty = {
            vec3(331.14, -578.93, 27.76), -- Highcrest: GN Pillbox
            vec3(-254.88, 6324.5, 32.58),
        },
        vehicle = {
            vec4(331.5, -568.47, 27.76, 336.73), -- Highcrest: GN Pillbox garage
            vec4(-234.28, 6329.16, 32.15, 222.5),
        },
        helicopter = {
            vec4(351.84, -587.37, 73.16, 147.24),
            vec4(-475.43, 5988.353, 31.716, 31.34),
        },
        armory = {
            {
                shopType = 'AmbulanceArmory',
                name = 'Armory',
                groups = { ambulance = 0 },
                inventory = {
                    { name = 'radio', price = 0 },
                    { name = 'bandage', price = 0 },
                    { name = 'painkillers', price = 0 },
                    { name = 'firstaid', price = 0 },
                    { name = 'weapon_flashlight', price = 0 },
                    { name = 'weapon_fireextinguisher', price = 0 },
                },
                locations = {
                    vec3(329.35, -580.14, 27.76)
                }
            }
        },
        roof = {
            vec3(338.54, -583.88, 73.17),
        },
        main = {
            vec3(305.44, -594.27, 42.27), -- Highcrest: lift up to the roof
        },
        stash = {
            {
                name = 'ambulanceStash',
                label = 'Personal stash',
                weight = 100000,
                slots = 30,
                groups = { ambulance = 0 },
                owner = true, -- Set to false for group stash
                location = vec3(332.78, -581.03, 27.76)
            }
        },

        ---@class Bed
        ---@field coords vector4
        ---@field model number

        ---@type table<string, {coords: vector3, checkIn?: vector3|vector3[], beds: Bed[]}>
        hospitals = {
            pillbox = {
                coords = vec3(350, -580, 43),
                checkIn = vec3(308.49, -581.55, 42.27),
                beds = {
                    -- Highcrest: GN Pillbox beds, picked in game 2026-11-08
                    {coords = vec4(320.34, -581.46, 43.26, 260.34), model = 2117668672},
                    {coords = vec4(324.99, -588.61, 43.26, 74.45), model = 2117668672},
                    {coords = vec4(329.56, -584.77, 43.27, 248.28), model = 2117668672},
                },
            },
            paleto = {
                coords = vec3(-250, 6315, 32),
                checkIn = vec3(-254.54, 6331.78, 32.43),
                beds = {
                    {coords = vec4(-252.43, 6312.25, 32.34, 313.48), model = 2117668672},
                    {coords = vec4(-247.04, 6317.95, 32.34, 134.64), model = 2117668672},
                    {coords = vec4(-255.98, 6315.67, 32.34, 313.91), model = 2117668672},
                },
            },
            jail = {
                coords = vec3(1761, 2600, 46),
                beds = {
                    {coords = vec4(1761.96, 2597.74, 45.66, 270.14), model = 2117668672},
                    {coords = vec4(1761.96, 2591.51, 45.66, 269.8), model = 2117668672},
                    {coords = vec4(1771.8, 2598.02, 45.66, 89.05), model = 2117668672},
                    {coords = vec4(1771.85, 2591.85, 45.66, 91.51), model = 2117668672},
                },
            },
        },

        stations = {
            {label = 'Pillbox Hospital', coords = vec4(308.49, -581.55, 42.27, 247.35)},
            {label = 'Central Los Santos Medical', coords = vec4(340.0, -1396.0, 32.5, 50.0)}, -- Highcrest: GN Central LS
        }
    },
}