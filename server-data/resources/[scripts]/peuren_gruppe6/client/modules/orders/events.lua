RegisterNetEvent('peuren_gruppe6:client:ClaimOrder', function(data, isOwner)
    Orders.Data = data
    local gorupId = Jobs.Data.args.groupId
    Tablet.SetPage(gorupId, 'current', Orders.Data)
    Orders.Create['Pickup'](data, isOwner)
end)

RegisterNetEvent('peuren_gruppe6:client:OrderNext', function(data, isOwner)   
    if not Orders.Data then Orders.Data = data end
    Orders.Data.progress += 1
    local gorupId = Jobs.Data.args.groupId
    Tablet.SetPage(gorupId, 'current', Orders.Data)
    lib.Notify(lib.Locale('finished_go_next_place'), nil, "success")
    Orders.Create['Deliver'](data, isOwner)
    Orders.Remove['Pickup'](data, isOwner)
end)

RegisterNetEvent('peuren_gruppe6:client:OrderFinished', function(data, isOwner)
    if not Orders.Data then Orders.Data = data end
    Orders.Data.progress += 1
    lib.Notify(lib.Locale('successfully_finished_order'), nil, "success")
    local gorupId = Jobs.Data.args.groupId

    local orders = lib.Framework.Callbacks.Trigger("peuren_gruppe6:GetOrders", Jobs.Data.args.type)
    if orders then 
        Tablet.SetPage(gorupId, 'contracts', orders)
    end

    Orders.Remove['Deliver'](data, isOwner)
    Orders.Remove['Pickup'](data, isOwner)
end)