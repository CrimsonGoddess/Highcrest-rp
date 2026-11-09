Config.Tasks = {
    --Basic dealer reputation tasks
    ['basic'] = {
        ['get_meth'] = {--['your task name id'] = {}
            Type = 'item',--Task type, supported types are minigame and item
            Item = 'meth',--Item that is needed
            Amount = 10,--Item amount that is needed
            Rewards = {
                money = { 
                    chance = 50, 
                    account = 'cash', 
                    amount = { min = 100, max = 3000 } 
                },

                items = { 
                    --{ name = item spawn name, min = min amount, max = max amount, chance = the chance from 0-100 of getting this item },
                    { name = 'WEAPON_DIGISCANNER', min = 1, max = 3, chance = 100},
                },

                reputation = {--When a task is completed how much rep levels should be given to a player, min and max
                    min = 1,
                    max = 3,
                }
            },

            Penalty = {--If a task is not finished or canceled, how much rep levels should a player loose, min and max
                min = 1,
                max = 2,
            }
        },
        
        ['hacking_five'] = { --['your task name id'] = {}
            Type = 'minigame',--Task type, supported types are minigame and item
            Minigame = 'hacking',--Minigame type, supported minigame name types are disassemble and hacking
            Count = 3,--How many successfull minigames should a player do to complete this task
            Rewards = {
                money = { 
                    chance = 50, 
                    account = 'cash', 
                    amount = { min = 50, max = 2000 } 
                },

                items = { 
                    --{ name = item spawn name, min = min amount, max = max amount, chance = the chance from 0-100 of getting this item },
                    { name = 'WEAPON_DIGISCANNER', min = 1, max = 3, chance = 100},
                },

                reputation = {--When a task is completed how much rep levels should be given to a player, min and max
                    min = 1,
                    max = 3,
                }
            },
            Penalty = {--If a task is not finished or canceled, how much rep levels should a player loose, min and max
                min = 1,
                max = 2,
            }
        },

        ['disassemble_five'] = { 
            Type = 'minigame',--Task type, supported types are minigame and item
            Minigame = 'disassemble',--Minigame type, supported minigame name types are disassemble and hacking
            Count = 3,--How many successfull minigames should a player do to complete this task
            Rewards = {
                money = { 
                    chance = 50, 
                    account = 'cash', 
                    amount = { min = 50, max = 2000 } 
                },

                items = { 
                    --{ name = item spawn name, min = min amount, max = max amount, chance = the chance from 0-100 of getting this item },
                    { name = 'WEAPON_DIGISCANNER', min = 1, max = 2, chance = 100},
                },

                reputation = {--When a task is completed how much rep levels should be given to a player, min and max
                    min = 1,
                    max = 3,
                }
            },
            Penalty = {--If a task is not finished or canceled, how much rep levels should a player loose, min and max
                min = 1,
                max = 2,
            }
        },
    },    
}