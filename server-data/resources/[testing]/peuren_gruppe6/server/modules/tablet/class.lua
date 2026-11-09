Tablet = {
    Data = {},

    Update = function(id)
        if not id then return end 

        local job = Jobs.Get(id)
        if not job then return end 

        lib.Groups.SendEvent(id, 'peuren_gruppe6:client:UpdateTablet', Tablet.Data[id])  
    end,

    SetPage = function(id, page, args)
        if not id or not page then return end

        if not Tablet.Data[id] then Tablet.Data[id] = {} end 
        Tablet.Data[id].page = page 
        
        if args then 
            Tablet.Data[id].pageData = args
        end

        Tablet.Update(id)
    end,
}