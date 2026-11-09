Ranks = {
    Data = {},

    ---Gets player rank
    ---@param source number
    Get = function(source)
        local id = Users.GetIdentifier(source)
        if not Ranks.Data[id] then Ranks.Load(id) end
        return Ranks.Data[id]
    end,

    ---Loads player ranks
    ---@param id string
    Load = function(id)
        if not id then return end 

        local result = lib.Database.FetchSync('SELECT ranks FROM `gruppe6_players` WHERE identifier = ?', {id})
        result = result[1]

        local ranks = {}
        if result then
            ranks = json.decode(result.ranks)
        end

        Ranks.Data[id] = {}
 
        if next(ranks) then
            Ranks.Data[id] = ranks
        else
            Ranks.Data[id] = { XP = 0, Level = 1 }
        end
    end,

    ---Saves players rank data
    ---@param source number
    Save = function(source)
        local id = Users.GetIdentifier(source)
        if not Ranks.Data[id] then return end
        return Users.Save(id, Ranks.Data[id])
    end,

    ---Saves and then clears rank data from memory
    ---@param source number
    Clear = function(source)
        local id = Users.GetIdentifier(source)
        Ranks.Save(source)
        Ranks.data[id] = nil
    end,

    ---Calculates the level for the given ranl from the XP amount
    ---@param xp number
    ---@return number
    CalculateLevel = function(xp)
        local level = 0

        for i = 1, #Config.Ranks.Levels do
            if Config.Ranks.Levels[i].minXP <= xp then
                level += 1
            end
        end

        return level
    end,

    ---Adds given amount of XP
    ---@param source number
    ---@param xp number
    AddRankXP = function(source, xp)
        local rank = Ranks.Get(source)
        rank.XP += xp
        rank.Level = Ranks.CalculateLevel(rank.XP)
        Ranks.Save(source)
    end,

    ---Removes given amount of XP
    ---@param source number
    ---@param xp number
    RemoveRankXP = function(source, xp)
        local rank = Ranks.Get(source)
        rank.XP -= xp
        if rank.XP < 0 then rank.XP = 0 end
        rank.Level = Ranks.CalculateLevel(rank.XP)
        Ranks.Save(source)
    end,
}