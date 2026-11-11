Config.Peds = {
    "a_f_m_eastsa_01", "a_m_y_golfer_01", "a_m_y_stwhi_02", "a_m_y_vindouche_01", "cs_janet", "cs_joeminuteman"
}

Config.Pickup = {
    {
        type = 'atm',
        title = 'FLEECA ATM JOB',
        description = 'Collect money from atms and then deliver the to various fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(-56.81, -1751.43, 29.42, 242.1), ped = true },
            { pos = vector4(33.53, -1348.19, 29.5, 28.87), ped = true },
            { pos = vector4(25.34, -946.36, 29.36, 135.3), ped = true },
        },

        deliver = {
            { pos = vector4(311.17, -284.18, 54.16, 45.56), ped = true },
            { pos = vector4(-353.86, -55.0, 49.04, 42.57), ped = true },
            { pos = vector4(-1211.08, -336.35, 37.78, 88.57), ped = true },
        }
    },
    {
        type = 'atm',
        title = 'FlEECA ATM JOB',
        description = 'Collect money from atms and then deliver the to various fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(-710.98, -818.89, 23.73, 174.64), ped = true },
            { pos = vector4(-612.87, -704.75, 31.24, 4.64), ped = true },
            { pos = vector4(25.34, -946.36, 29.36, 135.3), ped = true },
        },

        deliver = {
            { pos = vector4(146.83, -1045.83, 29.37, 46.54), ped = true },
            { pos = vector4(-1317.85, -831.95, 16.97, 129.6), ped = true },
            { pos = vector4(-2957.0, 481.37, 15.7, 157.45), ped = true },
        }
    },
    {
        type = 'atm',
        title = 'FLEECA ATM JOB',
        description = 'Collect money from atms and then deliver the to various fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(-3040.84, 593.51, 7.91, 147.03), ped = true },
            { pos = vector4(-3144.97, 1127.24, 20.86, 222.01), ped = true },
            { pos = vector4(539.76, 2671.03, 42.16, 245.52), ped = true },
        },

        deliver = {
            { pos = vector4(1176.03, 2712.82, 38.09, 242.81), ped = true },
            { pos = vector4(-103.06, 6472.36, 31.63, 150.37), ped = true },
            { pos = vector4(-2957.0, 481.37, 15.7, 157.45), ped = true },
        }
    },
    {
        type = 'bank',
        title = 'FLEECA ATM JOB',
        description = 'Collect packages from various locations and deliver them to the fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(1732.55, 6422.17, 35.04, 158.16), ped = true },
            { pos = vector4(1707.55, 4918.75, 42.06, 48.44), ped = true },
            { pos = vector4(1689.67, 4816.98, 42.06, 9.47), ped = true },
        },

        deliver = {
            { pos = vector4(311.17, -284.18, 54.16, 45.56), ped = true },
            { pos = vector4(-353.86, -55.0, 49.04, 42.57), ped = true },
            { pos = vector4(-1211.08, -336.35, 37.78, 88.57), ped = true },
        }
    },
    {
        type = 'bank',
        title = 'Fleeca bank job',
        description = 'Collect packages from various locations and deliver them to the fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(27.4, -1339.03, 29.5, 155.66), ped = true },
            { pos = vector4(166.79, -1553.37, 29.26, 235.22), ped = true },
            { pos = vector4(-42.55, -1748.41, 29.42, 160.26), ped = true },
        },

        deliver = {
            { pos = vector4(146.83, -1045.83, 29.37, 46.54), ped = true },
            { pos = vector4(-1317.85, -831.95, 16.97, 129.6), ped = true },
            { pos = vector4(-2957.0, 481.37, 15.7, 157.45), ped = true },
        }
    },
    {
        type = 'vault',
        title = 'PACIFIC BANK JOB',
        description = 'You will need to collect a cargo shipment and then transport the money into secure banks',
        bags = { min = 3, max = 3 },
        pickup = {
            { pos = vector4(1170.76, -2976.71, 6.1, 90.59), ped = false, trolleys = {
                vector4(1168.5, -2977.46, 6.1, 358.79),
                vector4(1170.2, -2977.4, 6.1, 359.18),
                vector4(1172.0, -2977.58, 6.1, 1.13),
            }, bags = {
                vector4(1168.55, -2976.32, 6.1, 358.11),
                vector4(1170.1, -2976.5, 6.1, 359.83),
                vector4(1172.72, -2976.57, 6.1, 0.24),
            }, container = {
                vector4(1170.76, -2976.71, 6.1, 90.59)
            }},
            { pos = vector4(1054.53, -3207.89, 5.9, 179.85), ped = false, trolleys = {
                vector4(1053.66, -3209.73, 6.1, 270.43),
                vector4(1053.71, -3207.84, 6.1, 270.15),
                vector4(1054.02, -3205.66, 6.1, 263.98),
            }, bags = {
                vector4(1054.92, -3205.72, 6.1, 180.8),
                vector4(1055.05, -3206.8, 6.1, 173.14),
                vector4(1055.08, -3209.0, 6.1, 180.8),
            }, container = {
                vector4(1054.53, -3207.89, 5.9, 179.85)
            }},
            { pos = vector4(994.79, -2926.97, 6.1, 265.74), ped = false, trolleys = {
                vector4(996.96, -2926.3, 6.1, 169.56),
                vector4(994.73, -2926.06, 6.1, 179.26),
                vector4(993.29, -2925.75, 6.1, 180.29),
            }, bags = {
                vector4(996.58, -2927.47, 6.1, 266.75),
                vector4(994.7, -2927.3, 6.1, 86.87),
                vector4(993.31, -2927.19, 6.1, 85.63),
            }, container = {
                vector4(994.79, -2926.97, 6.1, 265.74)
            }},
        },

        deliver = {
            { pos = vector4(256.81, 219.97, 106.29, 146.96), ped = true },
            { pos = vector4(-103.21, 6471.64, 31.63, 153.82), ped = true },
            { pos = vector4(146.95, -1045.65, 29.37, 44.28), ped = true },
        }
    }
}

Config.Deliver = {
    {
        type = 'atm',
        title = 'FLEECA ATM JOB',
        description = 'Collect money from atms and then deliver the to various fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(311.17, -284.18, 54.16, 45.56), ped = true },
            { pos = vector4(-353.86, -55.0, 49.04, 42.57), ped = true },
            { pos = vector4(-1211.08, -336.35, 37.78, 88.57), ped = true },
        },
        
        deliver = {
            { pos = vector4(-56.81, -1751.43, 29.42, 242.1), ped = true },
            { pos = vector4(33.53, -1348.19, 29.5, 28.87), ped = true },
            { pos = vector4(25.34, -946.36, 29.36, 135.3), ped = true },
        }
    },
    {
        type = 'atm',
        title = 'FlEECA ATM JOB',
        description = 'Collect money from atms and then deliver the to various fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(146.83, -1045.83, 29.37, 46.54), ped = true },
            { pos = vector4(-1317.85, -831.95, 16.97, 129.6), ped = true },
            { pos = vector4(-2957.0, 481.37, 15.7, 157.45), ped = true },
        },
        
        deliver = {
            { pos = vector4(-710.98, -818.89, 23.73, 174.64), ped = true },
            { pos = vector4(-612.87, -704.75, 31.24, 4.64), ped = true },
            { pos = vector4(25.34, -946.36, 29.36, 135.3), ped = true },
        }
    },
    {
        type = 'atm',
        title = 'FLEECA ATM JOB',
        description = 'Collect money from atms and then deliver the to various fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(1176.03, 2712.82, 38.09, 242.81), ped = true },
            { pos = vector4(-103.06, 6472.36, 31.63, 150.37), ped = true },
            { pos = vector4(-2957.0, 481.37, 15.7, 157.45), ped = true },
        },
        
        deliver = {
            { pos = vector4(-3040.84, 593.51, 7.91, 147.03), ped = true },
            { pos = vector4(-3144.97, 1127.24, 20.86, 222.01), ped = true },
            { pos = vector4(539.76, 2671.03, 42.16, 245.52), ped = true },
        }
    },
    {
        type = 'bank',
        title = 'Fleeca bank job',
        description = 'Collect packages from various locations and deliver them to the fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(311.17, -284.18, 54.16, 45.56), ped = true },
            { pos = vector4(-353.86, -55.0, 49.04, 42.57), ped = true },
            { pos = vector4(-1211.08, -336.35, 37.78, 88.57), ped = true },
        },
        
        deliver = {
            { pos = vector4(1732.55, 6422.17, 35.04, 158.16), ped = true },
            { pos = vector4(1707.55, 4918.75, 42.06, 48.44), ped = true },
            { pos = vector4(1689.67, 4816.98, 42.06, 9.47), ped = true },
        }
    },
    {
        type = 'bank',
        title = 'Fleeca bank job',
        description = 'Collect packages from various locations and deliver them to the fleeca banks',
        bags = { min = 2, max = 3 },
        pickup = {
            { pos = vector4(146.83, -1045.83, 29.37, 46.54), ped = true },
            { pos = vector4(-1317.85, -831.95, 16.97, 129.6), ped = true },
            { pos = vector4(-2957.0, 481.37, 15.7, 157.45), ped = true },
        },
        
        deliver = {
            { pos = vector4(27.4, -1339.03, 29.5, 155.66), ped = true },
            { pos = vector4(166.79, -1553.37, 29.26, 235.22), ped = true },
            { pos = vector4(-42.55, -1748.41, 29.42, 160.26), ped = true },
        }
    },
    {
        type = 'vault',
        title = 'PACIFIC BANK JOB',
        description = 'You will need to collect a cargo shipment and then transport the money into secure banks',
        bags = { min = 3, max = 3 },
        pickup = {
            { pos = vector4(256.81, 219.97, 106.29, 146.96), ped = true },
            { pos = vector4(-103.21, 6471.64, 31.63, 153.82), ped = true },
            { pos = vector4(146.95, -1045.65, 29.37, 44.28), ped = true },
        },
        
        deliver = {
            { pos = vector4(1170.76, -2976.71, 6.1, 90.59), ped = true, },
            { pos = vector4(1054.53, -3207.89, 5.9, 179.85), ped = true, },
            { pos = vector4(994.79, -2926.97, 6.1, 265.74), ped = true, },
        }
    }
}