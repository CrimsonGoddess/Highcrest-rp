---@alias DealerName "basic" | "warehouse" | "exclusive"

---@class Rep
---@field Level number The current level
---@field LastChanged number Last time the Reputation was increased
---@field Task any
---@field TaskProgress any

---@alias PlayerRep { [string]: Rep }

---@class Reputation
---@field private data { [number]: PlayerRep }

Reputation = {
    data = {},

    ---Get the players reputation data
    ---@param id number
    ---@param dealer DealerName
    ---@return Reputation
    Get = function(id, dealer)
        if not Reputation.data[id] then
            Reputation.Load(id)
        end
        Reputation.CheckLoseOverTime(id)
        if not dealer then return Reputation.data[id] end
        return Reputation.data[id][dealer]
    end,

    ---Loads the players reputation data
    ---@param id number
    ---@return PlayerRep
    Load = function(id)
        if not id then return nil end

        local identifier = Ply.GetIdentifier(id)
        if not identifier then return nil end

        local result = lib.Database.FetchSync('SELECT dealers FROM `chopshop_players` WHERE identifier = ?', {identifier})
        result = result[1]

        local reputation = {}
        if result then
            reputation = json.decode(result.dealers)
        end

        Reputation.data[id] = {}
        for dealer, _ in pairs(Config.Dealers) do
            if reputation[dealer] then
                Reputation.data[id][dealer] = reputation[dealer]
            else 
                Reputation.data[id][dealer] = { 
                    Level = 1,
                    LastChanged = os.time(),
                }
            end
        end
    end,

    ---Saves players reputation data
    ---@param id number
    Save = function(id)
        if not Reputation.data[id] then return end        
        return Ply.Save(id, Reputation.data[id], nil)
    end,

    ---Saves and then clears dealer reputation data from memory
    ---@param id number
    Clear = function(id)
        Reputation.Save(id)
        Reputation.data[id] = nil
    end,

    ---Adds given amount of reputation level to the given dealer
    ---@param id number
    ---@param dealer DealerName
    ---@param level number
    AddRep = function(id, dealer, level)
        local repData = Reputation.Get(id, dealer)
        repData.Level += level
        if repData.Level > 100 then repData.Level = 100 end
        repData.LastChanged = os.time()
        Reputation.Save(id)
    end,

    ---Removes given amount of reputation level from the given dealer
    ---@param id number
    ---@param dealer DealerName
    ---@param level number
    RemoveRep = function(id, dealer, level)
        local repData = Reputation.Get(id, dealer)
        repData.Level -= level
        if repData.Level < 0 then repData.Level = 0 end
        Reputation.Save(id)
    end,   

    ---Checks if any reputation should be taken away based on time passed since last interaction
    ---@param id number
    CheckLoseOverTime = function(id)
        if not Config.Reputation.LoseOverTime then return end

        local changed = false
        for k, v in pairs(Reputation.data[id]) do
            if (os.time() - v.LastChanged) / 3600 > Config.Reputation.LoseOverTime.minHours then
                local timeDiff = (os.time() - v.LastChanged) / 3600
                timeDiff -= Config.Reputation.LoseOverTime.minHours
                if math.floor(timeDiff) > 0 then
                    v.Level -= math.floor(timeDiff) * Config.Reputation.LoseOverTime.amount
                    if v.Level < 0 then v.Level = 0 end
                    v.LastChanged = os.time()
                    changed = true
                end
            end
        end
        
        if not changed then return end
        Reputation.Save(id)
    end,

    AddTaskProgress = function(id, dealer, task, count)
        local repData = Reputation.Get(id, dealer)
        if not repData then return end

        if not repData.Task then return end

        local taskData = Config.Tasks[dealer][repData.Task]
        if not taskData then return end

        if taskData.Type == "minigame" then
            if taskData.Minigame == task then
                if not repData.TaskProgress then repData.TaskProgress = 0 end
                repData.TaskProgress += count
            end
        end

        Reputation.Save(id)
    end
}

return Reputation