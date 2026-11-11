lib = exports.peuren_lib:Core()
lib.LoadLocales()

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then    
        Dealers.LoadDealers()    
        for _,v in pairs(Config.ItemCarrying) do
            if v.carrying then 
                lib.Inventory.AddCarriableItem(v.item, v.carrying)
            end
        end  
        Jobs.Init()
    end
end)

RegisterNetEvent('peuren_lib:PlayerLoaded', function()
    Dealers.LoadDealers()
    for _,v in pairs(Config.ItemCarrying) do 
        if v.carrying then 
            lib.Inventory.AddCarriableItem(v.item, v.carrying)
        end
    end  
    Jobs.Init()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Dealers.ClearAllDealers()
end)