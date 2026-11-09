Cache = {
    Data = {},

    ---Sets new cache data for a client
    ---@param id string
    ---@param name string
    ---@param data table
    Set = function(id, name, data)
        if not Cache.Data[id] then Cache.Data[id] = {} end 
        if not Cache.Data[id][name] then Cache.Data[id][name] = {} end

        for k,v in pairs(data) do 
            Cache.Data[id][name][k] = v
        end
    end,

    ---Gets client cache data
    ---@param id string
    ---@param name string
    ---@return table | nil
    Get = function(id, name)
        if not Cache.Data[id] then return end 
        if not Cache.Data[id][name] then return end        
        return Cache.Data[id][name]
    end,

    ---Removes cached data
    ---@param id string
    ---@param name string
    Remove = function(id, name)
        if not Cache.Data[id] then return end 
        if not Cache.Data[id][name] then return end
        Cache.Data[id][name] = nil
    end
}