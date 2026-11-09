STATUS = {
    INSIDE_CHOP_POINT = false
}

ExchangeNPCs = {}

function AttemptExchangeItems(pointIdx)
    local playerPed = PlayerPedId()
    ServerCallback("pickle_hunting:exchangeLocation", function(success, itemName, itemCount)
        if success then
            ShowNotification(_L("exchanging"))
            FreezeEntityPosition(playerPed, true)
            lib.progressCircle({
                duration = Config.Exchange.exchangeTime * 1000,
                position = "bottom"
            })
            FreezeEntityPosition(playerPed, false)
            ShowNotification(_L("exchanged", itemCount, itemName))
        end
    end, pointIdx)
end

-- Chopping Points Thread
CreateThread(function()
    local points = Config.Chopping.points
    for i, point in ipairs(points) do
        if point.blip then
            if point.blip.Radius then
                point.blip.Radius.Size = point.radius
            end
            CreateBlip(point.blip)
        end
    end

    while true do
        local sleep = 1000
        local pCoords = GetEntityCoords(PlayerPedId())
        local insidePoint = false
        
        for i, point in ipairs(points) do
            local dist = #(point.location - pCoords)
            if dist < point.radius then
                insidePoint = i
                sleep = 0
                ShowHelpNotification(_L("info_chopping"))
            end
        end
        
        STATUS.INSIDE_CHOP_POINT = insidePoint
        Wait(sleep)
    end
end)

-- Exchange Points Thread
CreateThread(function()
    local points = Config.Exchange.points
    for i, point in ipairs(points) do
        if point.blip then
            if point.blip.Radius then
                point.blip.Radius.Size = point.radius
            end
            CreateBlip(point.blip)
        end
    end

    while true do
        local sleep = 1000
        local pCoords = GetEntityCoords(PlayerPedId())
        
        for i, point in ipairs(points) do
            local dist = #(point.location - pCoords)
            
            if dist < 50.0 then
                if not ExchangeNPCs[i] or not DoesEntityExist(ExchangeNPCs[i]) then
                    local npc = CreateNPC(26, point.model, point.location.x, point.location.y, point.location.z, point.heading, false, true)
                    FreezeEntityPosition(npc, true)
                    SetEntityHeading(npc, point.heading)
                    SetEntityInvincible(npc, true)
                    SetBlockingOfNonTemporaryEvents(npc, true)
                    ExchangeNPCs[i] = npc
                end
            elseif ExchangeNPCs[i] then
                DeletePed(ExchangeNPCs[i])
                ExchangeNPCs[i] = nil
            end

            if dist < point.radius then
                sleep = 0
                ShowHelpNotification(_L("info_exchange"))
                if IsControlJustPressed(1, 51) then
                    AttemptExchangeItems(i)
                end
            end
        end
        Wait(sleep)
    end
end)
