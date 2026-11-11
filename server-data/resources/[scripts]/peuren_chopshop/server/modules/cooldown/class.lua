Cooldown = {
    data = {
        dealers = {},
        players = {}
    },

    ---Gets is cooldown set for player or dealer
    ---@param id number
    ---@param type string
    ---@param dealer string
    ---@return number | nil
    Get = function(id, type, dealer)
        if type == 'personal' then 
            if not Cooldown.data.players[dealer] then return end
            return Cooldown.data.players[dealer][id]
        elseif type == 'global' then 
            return Cooldown.data.dealers[dealer]
        end
        return nil
    end,

    ---Sets cooldown for player or dealer
    ---@param id number
    ---@param type string
    ---@param dealer string
    ---@return boolean
    Set = function(id, type, dealer)
        if not Cooldown.data.players[dealer] then 
            Cooldown.data.players[dealer] = {} 
        end

        if type == 'personal' then 
            local rep = Reputation.Get(id, dealer).Level
            local cooldown = Config.Dealers[dealer].PersonalCooldown
            if Config.Reputation.DecreaseCooldown and Config.Reputation.DecreaseCooldown.minRep < rep then
                Cooldown.data.players[dealer][id] = os.time() + (cooldown.min * 60 + cooldown.sec) * (rep - Config.Reputation.DecreaseCooldown.minRep) *  (Config.Reputation.DecreaseCooldown.cooldownMultiplier / 100)
            else
                Cooldown.data.players[dealer][id] = os.time() + cooldown.min * 60 + cooldown.sec
            end
            Cooldown.Thread(id, dealer, Cooldown.data.players[dealer][id], type)
        elseif type == 'global' then 
            local cooldown = Config.Dealers[dealer].GlobalCooldown

            Cooldown.data.dealers[dealer] = os.time() + cooldown.min * 60 + cooldown.sec
            TriggerClientEvent('peuren_chopshop:SetCooldown', -1, dealer)
            Cooldown.Thread(0, dealer, Cooldown.data.dealers[dealer], type)
        end
    end,

    ---Cooldown threads
    ---@param id number
    ---@param dealer string
    ---@param time number
    ---@param type string
    Thread = function(id, dealer, time, type)   
        CreateThread(function()
            while Cooldown.Get(id, type, dealer) do
                if os.time() > time then            
                    Wait(100) 
                    Cooldown.Remove(id, type, dealer) 
                end

                Wait(1000)
            end
        end)
    end,

    ---Removes cooldown for player or dealer
    ---@param id number
    ---@param type string
    ---@param dealer string
    ---@return boolean
    Remove = function(id, type, dealer)
        if type == 'personal' then 
            Cooldown.data.players[dealer][id] = nil
        elseif type == 'global' then
            Cooldown.data.dealers[dealer] = nil
            TriggerClientEvent('peuren_chopshop:RemoveCooldown', -1, dealer)
        end
    end
}

return Cooldown