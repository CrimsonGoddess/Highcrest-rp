Ply = {
    data = {},
    identifiers = {},

    ---Save provided player data into the database
    ---@param id number
    ---@param dealers any
    ---@param skills any
    ---@return nil
    Save = function(id, dealers, skills)
        if not id then return nil end

        local identifier = Ply.GetIdentifier(id)
        if not identifier then return nil end
        
        local result = lib.Database.FetchSync('SELECT * FROM `chopshop_players` WHERE identifier = ?', {identifier})
        result = result[1]

        dealers = dealers or Reputation.Get(id, nil)
        skills = skills or Skills.Get(id, nil)

        if not result then
            lib.Database.Insert('INSERT INTO `chopshop_players` (identifier, dealers, skills) VALUES (?, ?, ?)', { 
                identifier, 
                json.encode(dealers), 
                json.encode(skills) 
            })
        else 
            lib.Database.ExecuteSync("UPDATE chopshop_players SET dealers = ?, skills = ? WHERE identifier = ?", {
                json.encode(dealers),
                json.encode(skills),
                identifier
            })
        end
        return true
    end,
    
    GetIdentifier = function(player)
        local identifier = lib.Framework.GetIdentifier(player)
        if not identifier then
            identifier = Ply.identifiers[player]
        else
            Ply.identifiers[player] = identifier
        end
        return identifier
    end
}

return Ply