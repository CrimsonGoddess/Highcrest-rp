Users = {
    Data = {},
    Identifiers = {},

    ---Save provided player data into the database
    ---@param id string
    ---@param rank any
    Save = function(id, rank)
        if not id then return nil end
        
        local result = lib.Database.FetchSync('SELECT ranks FROM `gruppe6_players` WHERE identifier = ?', {id})
        result = result[1]

        local ranks = rank or Ranks.Get(id, nil)

        if not result then
            lib.Database.Insert('INSERT INTO `gruppe6_players` (identifier, ranks) VALUES (?, ?)', { id, json.encode(ranks) })
        else 
            lib.Database.ExecuteSync("UPDATE `gruppe6_players` SET ranks = ? WHERE identifier = ?", { json.encode(ranks), id })
        end
    end,

    ---Gets player identifier
    ---@param id number
    ---@return string
    GetIdentifier = function(id)
        local identifier = lib.Framework.GetIdentifier(id)
        if not identifier then
            identifier = Users.Identifiers[id]
        else
            Users.Identifiers[id] = identifier
        end
        return identifier
    end
}