lib = exports.peuren_lib:Core()
lib.LoadLocales()

local loaded = false

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() and not loaded then     
        loaded = true
        Center.LoadNpcs()
        for _,v in pairs(Config.Jobs) do
            if v.bag.item then 
                lib.Inventory.AddCarriableItem(v.bag.item, v.bag)
            end
        end  
    end
end)

RegisterNetEvent('peuren_lib:PlayerLoaded', function()
    if loaded then return end
    loaded = true
    Center.LoadNpcs()
    for _,v in pairs(Config.Jobs) do
        if v.bag.item then 
            lib.Inventory.AddCarriableItem(v.bag.item, v.bag)
        end
    end  
end)

AddEventHandler('peuren_lib:AddedItem', function(item)
    if not Jobs.Data.args then return end 
    local data = Config.Jobs[Jobs.Data.args.job].bag 
    if not data.item then return end 
    if data.item ~= item then return end 
    Cache.Set(Jobs.Data.args.groupId, 'caryying', { state = true, type = 'bag', })
end)

AddEventHandler('peuren_lib:RemovedItem', function(item)
    if not Jobs.Data.args then return end 
    local data = Config.Jobs[Jobs.Data.args.job].bag 
    if not data.item then return end 
    if data.item ~= item then return end 
    Cache.Set(Jobs.Data.args.groupId, 'caryying', { state = false, type = nil, })
end)
