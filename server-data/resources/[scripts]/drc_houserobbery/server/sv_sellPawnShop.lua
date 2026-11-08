lib.locale()

local onTimerSellShop = {}
lib.callback.register('drc_houserobbery:SellShop:getitem', function(source, item, amount)
    local src = source
    if GetItem(item, amount, src) then
        return true
    else
        return false
    end
end)

RegisterServerEvent("drc_houserobbery:SellShop:sellall")
AddEventHandler("drc_houserobbery:SellShop:sellall", function()
    local src = source
    if onTimerSellShop[src] and onTimerSellShop[src] > GetGameTimer() then
        Logs(src, "HouseRobbery (SellShop, Timer): Player Tried to exploit Event")
        BanPlayer(src, "HouseRobbery (SellShop, Timer): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "HouseRobbery: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    local SellShopCoords = Config.SellShop.Ped.coords
    local dist = #(vec3(SellShopCoords) - srcCoords)
    local price = 0
    if dist <= 20 then
        for _, v in pairs(Config.SellShop.Items) do
            if GetItemCount(v.item, src) then
                if GetItemCount(v.item, src) > 0 then
                    local amount = GetItemCount(v.item, src)
                    onTimerSellShop[src] = GetGameTimer() + (2 * 1000)
                    price = price + (v.price * amount)
                    RemoveItem(v.item, amount, src)
                    Logs(src, locale("HasSold", amount, v.item, v.price * amount))
                end
            end
        end
        if price > 0 then
            AddMoney(price, src)
        end
    else
        Logs(src, "HouseRobbery (SellShop, Coords): Player Tried to exploit Event")
        BanPlayer(src, "HouseRobbery (SellShop, Coords): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "HouseRobbery: Player Tried to exploit Event")
        end
    end
end)

RegisterServerEvent("drc_houserobbery:SellShop:giveitems")
AddEventHandler("drc_houserobbery:SellShop:giveitems", function(item, price, amount)
    local src = source
    if onTimerSellShop[src] and onTimerSellShop[src] > GetGameTimer() then
        Logs(src, "HouseRobbery (SellShop, Timer): Player Tried to exploit Event")
        BanPlayer(src, "HouseRobbery (SellShop, Timer): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "HouseRobbery: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    SellShopCoords = Config.SellShop.Ped.coords
    local dist = #(vec3(SellShopCoords) - srcCoords)
    if dist <= 20 then
        for _, v in pairs(Config.SellShop.Items) do
            if item == v.item and price == v.price and amount >= v.MinAmount and amount <= v.MaxAmount then
                if GetItem(item, amount, src) then
                    onTimerSellShop[src] = GetGameTimer() + (2 * 1000)
                    AddMoney(price * amount, src)
                    RemoveItem(item, amount, src)
                    Logs(src, locale("HasSold", amount, item, price * amount))
                end
            end
        end
    else
        Logs(src, "HouseRobbery (SellShop, Coords): Player Tried to exploit Event")
        BanPlayer(src, "HouseRobbery (SellShop, Coords): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "HouseRobbery: Player Tried to exploit Event")
        end
    end
end)