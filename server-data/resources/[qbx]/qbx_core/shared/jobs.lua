---Job names must be lower case (top level table key)
---@type table<string, Job>
return {
    ['unemployed'] = {
        label = 'Civilian',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Freelancer',
                payment = 50
            },
        },
    },
    ['government'] = {
        label = 'City Government',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Clerk',
                payment = 250
            },
            [1] = {
                name = 'Councillor',
                payment = 500
            },
            [2] = {
                name = 'Mayor',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['police'] = {
        label = 'LSPD',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 250
            },
            [1] = {
                name = 'Officer',
                payment = 375
            },
            [2] = {
                name = 'Sergeant',
                payment = 500
            },
            [3] = {
                name = 'Lieutenant',
                payment = 625
            },
            [4] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['bcso'] = {
        label = 'BCSO',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 250
            },
            [1] = {
                name = 'Officer',
                payment = 375
            },
            [2] = {
                name = 'Sergeant',
                payment = 500
            },
            [3] = {
                name = 'Lieutenant',
                payment = 625
            },
            [4] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['sasp'] = {
        label = 'SASP',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 250
            },
            [1] = {
                name = 'Officer',
                payment = 375
            },
            [2] = {
                name = 'Sergeant',
                payment = 500
            },
            [3] = {
                name = 'Lieutenant',
                payment = 625
            },
            [4] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['ambulance'] = {
        label = 'EMS',
        type = 'ems',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 250
            },
            [1] = {
                name = 'Paramedic',
                payment = 375
            },
            [2] = {
                name = 'Doctor',
                payment = 500
            },
            [3] = {
                name = 'Surgeon',
                payment = 625
            },
            [4] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['realestate'] = {
        label = 'Real Estate',
        type = 'realestate',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 250
            },
            [1] = {
                name = 'House Sales',
                payment = 375
            },
            [2] = {
                name = 'Business Sales',
                payment = 500
            },
            [3] = {
                name = 'Broker',
                payment = 625
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['taxi'] = {
        label = 'Taxi',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 250
            },
            [1] = {
                name = 'Driver',
                payment = 375
            },
            [2] = {
                name = 'Event Driver',
                payment = 500
            },
            [3] = {
                name = 'Sales',
                payment = 625
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['bus'] = {
        label = 'Bus',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Driver',
                payment = 250
            },
        },
    },
    ['cardealer'] = {
        label = 'Vehicle Dealer',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 250
            },
            [1] = {
                name = 'Showroom Sales',
                payment = 375
            },
            [2] = {
                name = 'Business Sales',
                payment = 500
            },
            [3] = {
                name = 'Finance',
                payment = 625
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['mechanic'] = {
        label = 'Mechanic',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 250
            },
            [1] = {
                name = 'Novice',
                payment = 375
            },
            [2] = {
                name = 'Experienced',
                payment = 500
            },
            [3] = {
                name = 'Advanced',
                payment = 625
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 750
            },
        },
    },
    ['judge'] = {
        label = 'Honorary',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Judge',
                payment = 500
            },
        },
    },
    ['lawyer'] = {
        label = 'Law Firm',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Associate',
                payment = 250
            },
        },
    },
    ['reporter'] = {
        label = 'Reporter',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Journalist',
                payment = 250
            },
        },
    },
    ['trucker'] = {
        label = 'Trucker',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Driver',
                payment = 250
            },
        },
    },
    ['tow'] = {
        label = 'Towing',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Driver',
                payment = 250
            },
        },
    },
    ['garbage'] = {
        label = 'Garbage',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Collector',
                payment = 250
            },
        },
    },
    ['vineyard'] = {
        label = 'Vineyard',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Picker',
                payment = 250
            },
        },
    },
    ['hotdog'] = {
        label = 'Hotdog',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Sales',
                payment = 250
            },
        },
    },
}
