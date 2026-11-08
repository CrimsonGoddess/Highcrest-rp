lib.locale()

local onTimerShop = {}
lib.callback.register('drc_truckrobbery:Shop:getitem', function(source, price, amount)
    local src = source
    if GetMoney(price * amount, src) then
        return true
    else
        return false
    end
end)

RegisterServerEvent("drc_truckrobbery:Shop:giveitems")
AddEventHandler("drc_truckrobbery:Shop:giveitems", function(item, price, amount)
    local src = source
    if onTimerShop[src] and onTimerShop[src] > GetGameTimer() then
        Logs(src, "TRUCK ROBBERY (Shop, Timer): Player Tried to exploit Event")
        BanPlayer(src, "TRUCK ROBBERY (Shop, Timer): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "TRUCK ROBBERY: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    local ShopCoords = Config.Shop.Ped.coords
    local dist = #(vec3(ShopCoords) - srcCoords)
    if dist <= 20 then
        for _, v in pairs(Config.Shop.Items) do
            if item == v.item and price == v.price and amount >= v.MinAmount and amount <= v.MaxAmount then
                if GetMoney(price * amount, src) then
                    onTimerShop[src] = GetGameTimer() + (1 * 1000)
                    RemoveMoney(price * amount, src)
                    AddItem(item, amount, src)
                    Logs(src, locale("HasSold", amount, item, price * amount))
                end
            end
        end
    else
        Logs(src, "TRUCK ROBBERY (Shop, Timer): Player Tried to exploit Event")
        BanPlayer(src, "TRUCK ROBBERY (Shop, Timer): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "TRUCK ROBBERY: Player Tried to exploit Event")
        end
    end
end)
