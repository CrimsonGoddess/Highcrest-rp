function FormatNumber(num)
    local prefix, number, suffix = string.match(tostring(num), "^([^%d]*%d)(%d*)(.-)$")
    local reversed = number:reverse()
    local formatted = reversed:gsub("(%d%d%d)", "%1,")
    formatted = formatted:reverse()
    return prefix .. formatted .. suffix
end

RegisterNetEvent("lation_detecting:BuyDetector", function(level)
    local source = source
    if not source or not level then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: params missing or nil", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: unable to retrieve player identifier", "error")
        return
    end
    local playerName = GetName(source)
    if not playerName then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: unable to retrieve player name", "error")
        return
    end
    local detectorData = Config.Detectors[level]
    if not detectorData then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: unable to retrieve detector data", "error")
        return
    end
    local playerLevel = exports.lation_detecting:GetPlayerData(source, "level")
    if not playerLevel then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: unable to retrieve player level", "error")
        return
    end
    if Config.Detecting.verify_level and level > playerLevel then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: player has incorrect level for this detector", "error")
        return
    end
    local balance = GetPlayerBalance(source, Config.Shops.detectors.account)
    if not balance then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: unable to retrieve player account balance", "error")
        return
    end
    if balance < detectorData.price then
        TriggerClientEvent("lation_detecting:Notify", source, Strings.Notify.noMoney, "error")
        return
    end
    RemoveMoney(source, Config.Shops.detectors.account, detectorData.price)
    AddItem(source, detectorData.item, 1)
    if Logs.Events.buy_detector then
        local logMessage = string.format(Strings.Logs.buy_detector.message, tostring(playerName), tostring(identifier), tostring(detectorData.item))
        PlayerLog(source, Strings.Logs.buy_detector.title, logMessage)
    end
end)

RegisterNetEvent("lation_detecting:BuyShovel", function()
    if not Config.Shovel.addToShop then
        EventLog("[shops.lua]: lation_detecting:BuyShovel: shovel is not purchasable", "error")
        return
    end
    local source = source
    if not source then
        EventLog("[shops.lua]: lation_detecting:BuyShovel: params missing or nil", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[shops.lua]: lation_detecting:BuyShovel: unable to retrieve player identifier", "error")
        return
    end
    local balance = GetPlayerBalance(source, Config.Shops.sellShop.account)
    if not balance then
        EventLog("[shops.lua]: lation_detecting:BuyShovel: unable to retrieve player account balance", "error")
        return
    end
    if balance < Config.Shovel.price then
        TriggerClientEvent("lation_detecting:Notify", source, Strings.Notify.noMoney, "error")
        return
    end
    local account = Config.Shovel.addToShop == "sellShop" and Config.Shops.sellShop.account or Config.Shops.detectors.account
    RemoveMoney(source, account, Config.Shovel.price)
    AddItem(source, Config.Shovel.item, 1)
end)

RegisterNetEvent("lation_detecting:SellOne", function(item, count)
    local source = source
    if not (source and item) or not count then
        EventLog("[shops.lua]: lation_detecting:SellOne: params missing or nil", "error")
        return
    end
    if type(item) ~= "string" or type(count) ~= "number" then
        EventLog("[shops.lua]: lation_detecting:SellOne: invalid param types", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[shops.lua]: lation_detecting:SellOne: unable to retrieve player identifier", "error")
        return
    end
    local playerName = GetName(source)
    if not playerName then
        EventLog("[shops.lua]: lation_detecting:SellOne: unable to retrieve player name", "error")
        return
    end
    if GetItemCount(source, item) < count then
        EventLog("[shops.lua]: lation_detecting:SellOne: player is missing item being sold", "error")
        return
    end
    local sellPrice = Config.Shops.sellShop.items[item]
    if not sellPrice then
        EventLog("[shops.lua]: lation_detecting:SellOne: item passed is not valid", "error")
        return
    end
    local totalValue = math.floor(sellPrice * count)
    RemoveItem(source, item, count)
    AddMoney(source, Config.Shops.sellShop.account, totalValue)
    exports.lation_detecting:AddPlayerData(source, "money_earned", totalValue)
    if Logs.Events.item_sold then
        local logMessage = string.format(Strings.Logs.item_sold.message, tostring(playerName), tostring(identifier), tostring(count), tostring(item), tostring(FormatNumber(totalValue)))
        PlayerLog(source, Strings.Logs.item_sold.title, logMessage)
    end
end)

RegisterNetEvent("lation_detecting:SellAll", function(items)
    local source = source
    if not source or not items then
        EventLog("[shops.lua]: lation_detecting:SellAll: params missing or nil", "error")
        return
    end
    if type(items) ~= "table" then
        EventLog("[shops.lua]: lation_detecting:SellAll: invalid param types", "error")
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog("[shops.lua]: lation_detecting:SellAll: unable to retrieve player identifier", "error")
        return
    end
    local playerName = GetName(source)
    if not playerName then
        EventLog("[shops.lua]: lation_detecting:SellAll: unable to retrieve player name", "error")
        return
    end
    local allValid = true
    for itemName, itemCount in pairs(items) do
        if not Config.Shops.sellShop.items[itemName] then
            allValid = false
            break
        end
        if GetItemCount(source, itemName) < itemCount then
            allValid = false
            break
        end
    end
    if not allValid then
        EventLog("[shops.lua]: lation_detecting:SellAll: invalid items or item quantities", "error")
        return
    end
    local totalValue = 0
    local itemList = {}
    for itemName, itemCount in pairs(items) do
        RemoveItem(source, itemName, itemCount)
        local sellPrice = Config.Shops.sellShop.items[itemName]
        local itemValue = math.floor(sellPrice * itemCount)
        totalValue = totalValue + itemValue
        table.insert(itemList, string.format("x%s %s ($%s each)", tostring(itemCount), tostring(itemName), tostring(sellPrice)))
    end
    AddMoney(source, Config.Shops.sellShop.account, totalValue)
    exports.lation_detecting:AddPlayerData(source, "money_earned", totalValue)
    if Logs.Events.item_sold then
        local itemListStr = table.concat(itemList, ", ")
        local logMessage = string.format(Strings.Logs.item_sold_all.message, tostring(playerName), tostring(identifier), itemListStr, tostring(FormatNumber(totalValue)))
        PlayerLog(source, Strings.Logs.item_sold_all.title, logMessage)
    end
end)
