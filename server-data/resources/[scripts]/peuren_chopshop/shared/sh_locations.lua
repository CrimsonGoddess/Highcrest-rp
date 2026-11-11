---Locations of where you can disassemble vehicle parts
Config.DropoffLocations = {
    {
        pos = vector3(604.6920, -418.3262, 24.7449),
        radius = 10
    },
    {
        pos = vector3(722.9381, -591.1066, 27.4062),
        radius = 8.0,
    },
    {
        pos = vector3(872.9791, -946.9094, 26.2812),
        radius = 8.0,
    },
    {
        pos = vector3(182.1009, -1660.1534, 29.8031),
        radius = 8.0,
    },
    {
        pos = vector3(-556.9697, -1797.9022, 22.5923),
        radius = 8.0,
    },
}

---Locations of where mission vehicles will spawn
Config.Locations = {
    {
        class = 'S',--Vehicle class type aka rarity
        model = 'rebla',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_retriever', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = {  -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'seat_dside_r', 'seat_pside_r', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(-137.1963, 902.2413, 235.1098),
            heading = 313.2622
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(-147.4583, 908.7774, 235.6552),
            vector3(-169.2297, 914.6775, 235.6555),
            vector3(-168.3976, 897.2858, 233.4654),
        }
    },  
    {
        class = 'S',--Vehicle class type aka rarity
        model = 'jester4',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = {  -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(-352.6706, 474.9948, 112.3343),
            heading = 295.3983
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(-369.3871, 467.8803, 112.4625),
            vector3(-369.2901, 454.4717, 112.4624),
            vector3(-352.1225, 450.8434, 112.8845),
        }
    },  
    {
        class = 'S',--Vehicle class type aka rarity
        model = 'sultan',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'seat_dside_r', 'seat_pside_r', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(-318.2814, 431.7869, 109.3230),
            heading = 9.0176
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(-322.7722, 417.5675, 110.0796),
            vector3(-310.9042, 414.8888, 109.8765),
            vector3(-300.0561, 419.2068, 110.0742),
        }
    },  
    {
        class = 'S',--Vehicle class type aka rarity
        model = 'infernus',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(-318.2814, 431.7869, 109.3230),
            heading = 9.0176
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(-322.7722, 417.5675, 110.0796),
            vector3(-310.9042, 414.8888, 109.8765),
            vector3(-300.0561, 419.2068, 110.0742),
        }
    },  
    {
        class = 'S',--Vehicle class type aka rarity
        model = 'elegy',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(-917.6602, 111.9810, 54.6425),
            heading = 113.0406
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(-905.0910, 99.5264, 55.3672),
            vector3(-899.4509, 111.0383, 55.1055),
            vector3(-882.1627, 120.2124, 54.9149),
        }
    }, 
    {
        class = 'A',--Vehicle class type aka rarity
        model = 'oracle',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'seat_dside_r', 'seat_pside_r', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(-1586.1224, -86.1674, 53.6176),
            heading = 89.5853
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(-1566.9918, -99.3830, 54.5291),
            vector3(-1554.6422, -115.0714, 54.5185),
            vector3(-1534.2762, -97.6687, 54.5289),
        }
    }, 
    {
        class = 'A',--Vehicle class type aka rarity
        model = 'baller',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'seat_dside_r', 'seat_pside_r', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(-1614.3000, -376.1572, 43.3554),
            heading = 44.1901
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(-1625.6898, -388.8753, 44.0231),
            vector3(-1635.7507, -379.4889, 43.3780),
            vector3(-1626.9749, -363.8654, 46.5650),
        }
    }, 
    {
        class = 'A',--Vehicle class type aka rarity
        model = 'baller2',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'seat_dside_r', 'seat_pside_r', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(-1678.5302, -445.6539, 39.6852),
            heading = 230.1332
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(-1662.1377, -434.3816, 39.7834),
            vector3(-1675.0049, -427.4439, 40.1854),
            vector3(-1680.6584, -437.5459, 39.9841),
        }
    }, 
    {
        class = 'B',--Vehicle class type aka rarity
        model = 'premier',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'seat_dside_r', 'seat_pside_r', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(949.4288, -654.8993, 57.5079),
            heading = 127.2193
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(940.8761, -662.7060, 58.0138),
            vector3(931.6285, -654.8029, 58.0261),
            vector3(934.7001, -651.3184, 58.4418),
        }
    }, 
    {
        class = 'B',--Vehicle class type aka rarity
        model = 'futo',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector3(1005.8190, -732.5751, 57.0301),
            heading = 316.2482
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(997.5359, -736.3442, 57.4448),
            vector3(989.0459, -737.0947, 57.5247),
            vector3(986.3152, -728.9589, 57.4655),
        }
    }, 
    {
        class = 'B',--Vehicle class type aka rarity
        model = 'oracle',--Vehicle spawn name
        type = 'automobile', -- Type of the vehicle automobile/heli/motorcycle/boat
        guard = 'a_c_rottweiler', -- Guard Dogs Ped Model That Spawns After Sucessfully Hacking
        bones = { -- Choppable bones
            'seat_dside_f', 'seat_pside_f', 'seat_dside_r', 'seat_pside_r', 'bonnet', 'boot', 'engine',
            "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"
        },
        vehicle = {--Vehicle spawn position
            pos = vector4(1220.06, -733.93, 59.23, 117.05),
            heading = 117.05
        },
        key = {--The zone radius of were to search for the vehicle key
            vector3(1232.9902, -732.3626, 60.6529),
            vector3(1239.0924, -725.7231, 60.6526),
            vector3(1231.8577, -713.7639, 60.6526),
        }
    }, 
}