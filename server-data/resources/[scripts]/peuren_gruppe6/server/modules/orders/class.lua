Orders = {
    Data = {},
    Locations = {},

    ---Load order data
    Load = function()
        for k,v in pairs(Config.Center.Orders) do 
            Orders.Data[k] = {}
            Orders.Locations[k] = {}
            Orders.Thread(k, v.min, v.sec)
            for id, location in pairs(Config[k]) do 
                Orders.Locations[k][id] = location
            end
        end
    end,

    ---Get order data
    ---@param type string
    ---@param id number | nil
    ---@return table | nil
    Get = function(type, id)
        if not type then return end 
        if not id then return Orders.Data[type] end 
        return Orders.Data[type][id]
    end,

    Update = function(type, id)
        for k,v in pairs(Jobs.Data) do
            Wait(100)
            if not Orders.Locations[type][id] then goto continue end
            if v.args.type == type and Orders.Locations[type][id].type == v.args.job then
                lib.Groups.SendEvent(k, 'peuren_gruppe6:UpdateOrders', Orders.Data[type])
            end
            :: continue ::
        end
    end,

    ---Create new order
    ---@param type string
    Set = function(type)
        if not next(Orders.Locations[type]) then return end
        local id = math.random(1, #Orders.Locations[type])
        
        Orders.Data[type][#Orders.Data[type] + 1] = Orders.Locations[type][id]        
        local data = Orders.Data[type][#Orders.Data[type]]

        data.id = #Orders.Data[type]
        data.bags = math.random(data.bags.min, data.bags.max)
        data.pickup = data.pickup[math.random(1, #data.pickup)]
        data.deliver = data.deliver[math.random(1, #data.deliver)]
        data.progress = 0      

        Orders.Update(type, id)
        table.remove(Orders.Locations[type], id)
    end,

    ---Order request thread
    ---@param type string
    ---@param min number
    ---@param sec number
    Thread = function(type, min, sec)
        CreateThread(function()
            while true do
                Orders.Set(type)
                Wait(min * 60 + sec * 1000)
            end
        end)
    end,

    ---Claim order
    ---@param type string
    ---@param id number | nil
    ---@return table | nil
    Claim = function(type, id)
        if not type or not id then return end 
        if not Orders.Data[type] then return end 
        if not Orders.Data[type][id] then return end

        Orders.Data[type][id].claimed = true 
        Orders.Update(type, id)
        return Orders.Data[type][id]
    end,
}