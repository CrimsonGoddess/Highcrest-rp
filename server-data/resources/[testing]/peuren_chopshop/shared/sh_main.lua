Config = {}

Config.Dispatch = {
    enabled = true, --Send alert to police
    dispatch_code = '10-90', -- Dispatch code added to the message.
    message = 'Grand theft auto in progress', -- Dispatch message.
    color = 2, -- Blip Color, more info: https://docs.fivem.net/docs/game-references/blips/#blip-colors
    sprite = 500, -- Blip Sprite, more info: https://docs.fivem.net/docs/game-references/blips/#blips
    scale = 1.0, -- Blip Scale
    time = 300, -- Blip Seconds Visible in seconds.
    delay = 5, -- Dispatch delay after first interaction in seconds.
}

Config.Jobs = { 
    policeRequired = 0,--How many police officer have to be on, to get a job 
    policeJobs = { 'police', 'sheriff' }, --Police job names (Highcrest)
    enabled = false,--If this is set to true, then it will enable a time frame in which you need to find a given location and hack the keys
    searchingTime = false,--Chop vehicle searching time, if you don't need this set it to: searchingTime = false
    timeToFind = { min = 0, sec = 10 },--How much time you have to find a given location and hack the keys, if you don't need this set it to: timeToFind = false
    decreaseRepOnExpiredTime = { min = 1, max = 2 },--How much reputation does a player loose on failing to chop the vehicle
}

Config.Hacking = {
    requiredItem = 'weapon_digiscanner',--Item used to boost the signal of the key and the hack it
    hackingTime = 5000,--Progress bar time in ms
    chance = 50--Chance of breaking the signal booster device item when failed to hack the security system
}

Config.Disassemble = {
    requiredItem = 'toolbox',--Item used to boost the signal of the key and the hack it
}

Config.SetVehicleAtributes = function(veh, plate)--This function is triggered when the vehicle is spawned, this could be used to set properties to a vehicle (server side only)

end

Config.JobMail = function(source, model, plate)--Job information mail that is sent when you start a job
    -- source = player id,
    -- model = vehicle model name,
    -- plate = vehicle number plate

    ---qb-phone mail export
    --[[        
        local id = lib.Framework.GetIdentifier(source)
        TriggerEvent('qb-phone:server:sendNewEventMail', id, {
            sender = "Chop shop",
            subject = "New job",
            message = ("Hey, \n Go find %s vehicle with plates %s \n I'll update you soon on the location/radius of the vehicle"):format(model, plate),
            button = {}
        })    
    ]]

    ---lb-phone mail export
    --[[
        local number = exports["lb-phone"]:GetEquippedPhoneNumber(source)
        local mail = exports["lb-phone"]:GetEmailAddress(number)
        exports["lb-phone"]:SendMail({
            to = mail,
            subject = "Chop shop",
            message = ("Hey, \n Go find %s vehicle with plates %s \n I'll update you soon on the location/radius of the vehicle"):format(model, plate),
            attachments = {},
            actions = {}
        })
    ]]
end

Config.Blips = {
    chop_vehicle = {
        sprite = 523,--Blip icon id
        color = 18,--Blip color id
        scale = 0.9,--Blip scale
        label = "Chop vehicle location",--Blip label
        radius = {
            enabled = true,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },
    chop_location = {
        sprite = 566,--Blip icon id
        color = 1,--Blip color id
        scale = 1.5,--Blip scale
        label = "Chop location",--Blip label
        radius = {
            enabled = false,--If radius is enabled, players will have to find the location in a radius, otherwise it will add a blip directly on the pos
            sprite = 9,--Radius id
            color = 1,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    }
}

Config.Dealers = {
    ['basic'] = {
        GlobalCooldown = { min = 20, sec = 5 },--Dealers cooldown, if don't need this, make it to false, GlobalCooldown = false
        PersonalCooldown = { min = 25, sec = 10 },--Your personal cooldown with the dealer, if don't need this, make it to false, GlobalCooldown = false

        Dealer = {
            name = 'Basic dealer',--Dealers name
            model = 'cs_chengsr',--Dealers ped model, model names can be found @ https://docs.fivem.net/docs/game-references/ped-models/
            pos = vector3(215.9, -1862.06, 29.90),--Dealers positions
            heading = 43.06,--Dealers heading
            animation = {--This controls dealer animation, if you don't want this, make it to: animation = false
                --Supported anim data format:
                    -- anim = ''
                    -- dict = ''
                    -- scenario = ''
                --Examples:
                    -- anim = 'missexile3'
                    -- dict = 'ex03_dingy_search_case_base_michael'
                scenario = 'WORLD_HUMAN_SMOKING'
            }
        },

        AvailableVehicleClasses = {
            ['B'] = 0,--Minimum reputation level required to get this type of vehicle class, ['vehicle class name'] = min rep required
            ['A'] = 40,--Minimum reputation level required to get this type of vehicle class, ['vehicle class name'] = min rep required
            ['S'] = 70,--Minimum reputation level required to get this type of vehicle class, ['vehicle class name'] = min rep required
        },

        RequiredItems = {--Items that are required to get a new job, if you don't need this feature just set it to: RequiredItems = false
            -- ['weapon_digiscanner'] = 1,--[item name] = amount
        },

        RequiredRep = {
            ["basic"] = 0,--How much reputation level you need have with this dealer so basic dealer becomes available           
        }
    },
}

--Reputation data with dealers
Config.Reputation = {
    DecreaseCooldown = { --Set to false if disabled
        minRep = 15, --The amount of rep required for the dealer for the personal cooldown to be lowered
        cooldownMultiplier = 1 --How much to lower to personal cooldown in percentage (Calculated by (Dealer Rep - Min Rep) * multiplier)
    },
    GainPerAction = { min = 2, max = 5 }, --Amount of reputation you get after completing the job
    DecreaseOnFail = { min = 1, max = 3 }, --Amount of reputation you lose after failing the job
    LoseOverTime = { minHours = 48, amount = 1 } --How much hours required to pass before you start losing reputation. Amount = the amount of reputation lost each hour. --  -Use false to disable
}

--Chop Shop skills
Config.Skills = {
    ["hacking"] = {--Hacking skills 
        Levels = {
            [1] = {-- [level number] = {}
                minXP = 0,--The required minimum xp to unlock this level
                numbers = { min = 5, max = 10 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 8000--The time in ms that you have to input numbers
            },
            [2] = {-- [level number] = {}
                minXP = 1000,--The required minimum xp to unlock this level
                numbers = { min = 9, max = 19 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3050--The time in ms that you have to input numbers
            },
            [3] = {-- [level number] = {}
                minXP = 5000,--The required minimum xp to unlock this level
                numbers = { min = 9, max = 18 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3100--The time in ms that you have to input numbers
            },
            [4] = {-- [level number] = {}
                minXP = 9000,--The required minimum xp to unlock this level
                numbers = { min = 9, max = 17 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3150--The time in ms that you have to input numbers
            },
            [5] = {-- [level number] = {}
                minXP = 16000,--The required minimum xp to unlock this level
                numbers = { min = 7, max = 16 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3150--The time in ms that you have to input numbers
            },
            [6] = {-- [level number] = {}
                minXP = 21000,--The required minimum xp to unlock this level
                numbers = { min = 7, max = 15 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3150--The time in ms that you have to input numbers
            },
            [7] = {-- [level number] = {}
                minXP = 26000,--The required minimum xp to unlock this level
                numbers = { min = 7, max = 14 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3250--The time in ms that you have to input numbers
            },
            [8] = {-- [level number] = {}
                minXP = 31000,--The required minimum xp to unlock this level
                numbers = { min = 6, max = 13 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3350--The time in ms that you have to input numbers
            },
            [9] = {-- [level number] = {}
                minXP = 36000,--The required minimum xp to unlock this level
                numbers = { min = 6, max = 12 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3450--The time in ms that you have to input numbers
            },
            [10] = {-- [level number] = {}
                minXP = 41000,--The required minimum xp to unlock this level
                numbers = { min = 5, max = 10 },--How many numbers ar displayed on the keys security hacking minigame
                completeTime = 3550--The time in ms that you have to input numbers
            },
        },
        GainPerAction = {min = 50, max = 100}, --XP you get after succesfully hacking (completing the minigame) -Use false to disable
        DecreaseOnFail = {min = 10, max = 30}, --Remove XP after failing the hack (failing the minigame) -Use false to disable.
        LoseOverTime = {minHours = 48, amount = 20} --How much hours required to pass before you start losing XP. Amount = the amount of XP lost each hour. --  -Use false to disable
    },

    ["disassemble"] = {--Disassemble skills 
        Levels = {
            [1] = {-- [level number] = {}
                minXP = 0,--The required minimum xp to unlock this level
                completeTime = 7000--The time in ms that you have to wait until you chop off a part
            },
            [2] = {-- [level number] = {}
                minXP = 2000,--The required minimum xp to unlock this level
                completeTime = 6500--The time in ms that you have to wait until you chop off a part
            },
            [3] = {-- [level number] = {}
                minXP = 6000,--The required minimum xp to unlock this level
                completeTime = 6000--The time in ms that you have to wait until you chop off a part
            },
            [4] = {-- [level number] = {}
                minXP = 10000,--The required minimum xp to unlock this level
                completeTime = 5500--The time in ms that you have to wait until you chop off a part
            },
            [5] = {-- [level number] = {}
                minXP = 15000,--The required minimum xp to unlock this level
                completeTime = 5000--The time in ms that you have to wait until you chop off a part
            },
            [6] = {-- [level number] = {}
                minXP = 20000,--The required minimum xp to unlock this level
                completeTime = 4500--The time in ms that you have to wait until you chop off a part
            },
            [7] = {-- [level number] = {}
                minXP = 25000,--The required minimum xp to unlock this level
                completeTime = 4000--The time in ms that you have to wait until you chop off a part
            },
            [8] = {-- [level number] = {}
                minXP = 30000,--The required minimum xp to unlock this level
                completeTime = 3500--The time in ms that you have to wait until you chop off a part
            },
            [9] = {-- [level number] = {}
                minXP = 35000,--The required minimum xp to unlock this level
                completeTime = 3000--The time in ms that you have to wait until you chop off a part
            },
            [10] = {-- [level number] = {}
                minXP = 40000,--The required minimum xp to unlock this level
                completeTime = 2500--The time in ms that you have to wait until you chop off a part
            },
        },
        GainPerAction = {min = 150, max = 200}, --XP you get after succesfully chop (completing the minigame) -Use false to disable
        DecreaseOnFail = {min = 100, max = 180}, --Remove XP after failing the chop (failing the minigame) -Use false to disable.
        LoseOverTime = {minHours = 10, amount = 50} --How much hours required to pass before you start losing XP. Amount = the amount of XP lost each hour. --  -Use false to disable
    },
}

Config.PawnShop = {
    ["basic"] = {--Basic dealer pawnshop
        Currency = {--Currency that is used to pay/purchase things at the dealers pawnshop
            account = 'cash',-- Supported types: black_money, bank, cash
            accountItem = {
                enabled = false,--Is currency to pay/purchase an item?
                itemName = 'markedbills'--The currency item that is used to pay/purchase things in the pawnshop
            }
        },

        Reputation = { --How much to lower the price for the items that they're buying or increase the price for the items that they're selling. Use false to disable
            minRep = 3, --Minimum reputation required.
            multiplier = 1 --How much to change the price in percentage. Final Price = actual price +- actual price * ((reputation - minimumReputation) * multiplier / 100) 
        },

        Market = {
            SaleAge = 86400, --In seconds. How long sales affect the item prices.
            MarketCycle = 600,--In seconds. How frequently item prices are updated.
            PriceChangeFactor = 0.5, --Intesnity of the price fluctuations.
        },

        Buy = {
            -- {name = "item spawn name", price = item price },
            { name = "weapon_digiscanner", price = 1000 },
            { name = "toolbox", price = 200 },
        },

        Sell = {
            -- {name = "item spawn name", min = item min price, max = item max price },

            { name = "boot", min = 800, max = 1000 },
            { name = "bonnet", min = 800, max = 1500 },
            { name = "door", min = 800, max = 3000 },
            { name = "wheel", min = 800, max = 2500 },
            { name = "engine", min = 800, max = 4000 },
        }
    },
}