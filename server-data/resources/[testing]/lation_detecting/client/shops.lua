local shopOptions = {}
local isNearShop = false
local shopPeds = {}
local isMenuOpen = false

function FormatNumber(num)
    local prefix, number, suffix = string.match(tostring(num), "^([^%d]*%d)(%d*)(.-)$")
    local reversed = number:reverse()
    local formatted = reversed:gsub("(%d%d%d)", "%1,")
    formatted = formatted:reverse()
    return prefix .. formatted .. suffix
end

function CreateShopBlips()
    for _, shop in pairs(Config.Shops) do
        if shop.blip.enabled then
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
            SetBlipSprite(blip, shop.blip.sprite)
            SetBlipColour(blip, shop.blip.color)
            SetBlipScale(blip, shop.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(shop.blip.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end

AddEventHandler("lation_detecting:onPlayerLoaded", function()
    while not PlayerLoaded do
        Wait(0)
    end
    if Config.Detecting.job.require then
        local playerJob = GetPlayerJob()
        if playerJob ~= Config.Detecting.job.job then
            return
        end
    end
    CreateShopBlips()
end)

for level = 1, #Config.Detecting.levels do
    local levelStrings = Strings.ContextMenu.detector_shop["level" .. level]
    local subtitle = tostring(Strings.ContextMenu.detector_shop.subtitle .. FormatNumber(Config.Detectors[level].price))
    table.insert(shopOptions, {
        title = levelStrings.title .. subtitle,
        description = levelStrings.description,
        icon = levelStrings.icon,
        image = levelStrings.image,
        event = "lation_detecting:BuyDetector",
        args = {level = level},
        metadata = {
            levelStrings.metadata.radius,
            levelStrings.metadata.depth,
            levelStrings.metadata.accuracy
        }
    })
end

if Config.Shovel.addToShop then
    if Config.Shovel.addToShop == "detectors" then
        table.insert(shopOptions, {
            title = Strings.ContextMenu.sell_shop.shovel.title,
            icon = Strings.ContextMenu.sell_shop.shovel.icon,
            onSelect = function()
                isMenuOpen = false
            end,
            serverEvent = "lation_detecting:BuyShovel"
        })
    end
end

function OpenDetectorShop()
    if Config.Detecting.job.require then
        local playerJob = GetPlayerJob()
        if playerJob ~= Config.Detecting.job.job then
            ShowNotification(Strings.Notify.notAuthorized, "error")
            return
        end
    end
    RegisterMenu({
        id = "detector_shop",
        title = Strings.ContextMenu.detector_shop.title,
        onExit = function()
            isMenuOpen = false
        end,
        options = shopOptions
    })
    ShowMenu("detector_shop")
    HideTextUI(Strings.TextUI.shop.label)
    isMenuOpen = true
    isNearShop = false
end

function OpenSellShop()
    if Config.Detecting.job.require then
        local playerJob = GetPlayerJob()
        if playerJob ~= Config.Detecting.job.job then
            ShowNotification(Strings.Notify.notAuthorized, "error")
            return
        end
    end
    local sellStrings = Strings.ContextMenu.sell_shop
    local inventory = GetPlayerInventory()
    local itemOptions = {}
    for _, item in pairs(inventory) do
        local itemName = item.name
        local sellPrice = Config.Shops.sellShop.items[itemName]
        if sellPrice then
            local itemCount = item.amount or item.count
            local itemData = GetItemData(itemName)
            table.insert(itemOptions, {
                title = itemData.label,
                description = string.format(sellStrings.singleItem.description, tostring(FormatNumber(itemCount)), tostring(FormatNumber(sellPrice))),
                icon = sellStrings.singleItem.icon,
                image = "nui://lation_detecting/install/images/" .. itemName .. ".png",
                event = "lation_detecting:SellOne",
                args = {item = itemName, count = itemCount}
            })
        end
    end
    local mainOptions = {}
    if Config.Shops.sellShop.sellAll then
        table.insert(mainOptions, {
            title = sellStrings.sellAll.title,
            description = sellStrings.sellAll.description,
            icon = sellStrings.sellAll.icon,
            event = "lation_detecting:SellAll",
            arrow = true
        })
    end
    table.insert(mainOptions, {
        title = sellStrings.selectItem.title,
        description = sellStrings.selectItem.description,
        icon = sellStrings.selectItem.icon,
        menu = "items_list",
        arrow = true
    })
    if Config.Shovel.addToShop then
        if Config.Shovel.addToShop == "sellShop" then
            table.insert(mainOptions, {
                title = sellStrings.shovel.title,
                icon = sellStrings.shovel.icon,
                onSelect = function()
                    isMenuOpen = false
                end,
                serverEvent = "lation_detecting:BuyShovel"
            })
        end
    end
    RegisterMenu({
        id = "items_list",
        title = sellStrings.title,
        onExit = function()
            isMenuOpen = false
        end,
        menu = "sell_shop",
        options = itemOptions
    })
    RegisterMenu({
        id = "sell_shop",
        title = sellStrings.title,
        onExit = function()
            isMenuOpen = false
        end,
        options = mainOptions
    })
    ShowMenu("sell_shop")
    HideTextUI(Strings.TextUI.shop.label)
    isMenuOpen = true
    isNearShop = false
end

function HandleShopProximity(coords, shopType)
    local isNear = false
    while true do
        if not shopPeds[shopType] then
            break
        end
        Wait(750)
        local playerCoords = GetEntityCoords(cache.ped)
        local distance = #(playerCoords - vec3(coords.x, coords.y, coords.z))
        if distance < 2.25 then
            if not isNearShop and not isMenuOpen then
                ShowTextUI(Strings.TextUI.shop.label, Strings.TextUI.shop.icon)
                isNearShop = true
            end
            if not isNear then
                isNear = true
                CreateThread(function()
                    while isNear do
                        if not isNear then
                            break
                        end
                        Wait(0)
                        if IsControlJustReleased(0, Config.Setup.control) then
                            if shopType == "detectors" then
                                OpenDetectorShop()
                            elseif shopType == "sellShop" then
                                OpenSellShop()
                            end
                        end
                    end
                end)
            end
        else
            if isNearShop then
                HideTextUI(Strings.TextUI.shop.label)
                isNearShop = false
            end
            if isNear then
                isNear = false
            end
        end
    end
end

AddEventHandler("lation_detecting:BuyDetector", function(data)
    if not data or type(data) ~= "table" then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: missing or invalid param type")
        isMenuOpen = false
        return
    end
    local detectorData = Config.Detectors[data.level]
    if not detectorData then
        EventLog("[shops.lua]: lation_detecting:BuyDetector: unable to retrieve detector data")
        isMenuOpen = false
        return
    end
    if Config.Detecting.verify_level then
        local playerLevel = exports.lation_detecting:GetPlayerData("level")
        if not playerLevel then
            return
        end
        if playerLevel < data.level then
            ShowNotification(Strings.Notify.noLevel, "error")
            isMenuOpen = false
            return
        end
    end
    local alertStrings = Strings.AlertDialog.buyDetector
    local result = ShowAlert({
        header = alertStrings.header,
        content = string.format(alertStrings.content, tostring(FormatNumber(detectorData.price))),
        centered = alertStrings.centered,
        cancel = alertStrings.cancel,
        labels = alertStrings.labels
    })
    if not result or result == "cancel" then
        isMenuOpen = false
        return
    end
    TriggerServerEvent("lation_detecting:BuyDetector", data.level)
    isMenuOpen = false
end)

AddEventHandler("lation_detecting:SellOne", function(data)
    if not data or type(data) ~= "table" then
        EventLog("[shops.lua]: lation_detecting:SellOne: missing or invalid param types")
        isMenuOpen = false
        return
    end
    local itemData = GetItemData(data.item)
    if not itemData then
        EventLog("[shops.lua]: lation_detecting:SellOne: unable to retrieve item data")
        isMenuOpen = false
        return
    end
    if not HasItem(data.item, data.count) then
        EventLog("[shops.lua]: lation_detecting:SellOne: player is missing item being sold")
        isMenuOpen = false
        return
    end
    local inputStrings = Strings.InputDialog
    local input = ShowInput({
        title = string.format(inputStrings.title, tostring(itemData.label)),
        options = {
            {
                type = "number",
                label = inputStrings.label,
                description = string.format(inputStrings.description, tostring(FormatNumber(data.count))),
                icon = inputStrings.icon,
                required = true,
                min = 1,
                max = data.count
            }
        }
    })
    if not input or not input[1] or input[1] <= 0 or input[1] > data.count then
        isMenuOpen = false
        EventLog("[shops.lua]: lation_detecting:SellOne: invalid input received")
        return
    end
    TriggerServerEvent("lation_detecting:SellOne", data.item, input[1])
    isMenuOpen = false
end)

AddEventHandler("lation_detecting:SellAll", function()
    local inventory = GetPlayerInventory()
    if not inventory then
        EventLog("[shops.lua]: lation_detecting:SellAll: unable to retrieve player inventory")
        isMenuOpen = false
        return
    end
    local totalValue = 0
    local itemsToSell = {}
    for _, item in pairs(inventory) do
        local itemCount = item.count or item.amount
        local sellPrice = Config.Shops.sellShop.items[item.name]
        if sellPrice then
            totalValue = totalValue + (sellPrice * itemCount)
            itemsToSell[item.name] = itemCount
        end
    end
    if totalValue <= 0 then
        ShowNotification(Strings.Notify.nothingToSell, "error")
        isMenuOpen = false
        return
    end
    local alertStrings = Strings.AlertDialog.selling
    local result = ShowAlert({
        header = alertStrings.header,
        content = string.format(alertStrings.content, tostring(FormatNumber(totalValue))),
        centered = true,
        cancel = true,
        labels = alertStrings.labels
    })
    if not result or result == "cancel" then
        isMenuOpen = false
        return
    end
    TriggerServerEvent("lation_detecting:SellAll", itemsToSell)
    isMenuOpen = false
end)

for shopName, shop in pairs(Config.Shops) do
    while true do
        if PlayerLoaded then
            break
        end
        Wait(0)
    end
    if Config.Detecting.job.require then
        local playerJob = GetPlayerJob()
        if playerJob ~= Config.Detecting.job.job then
            return
        end
    end
    if shop.enabled then
        local point = lib.points.new(shop.coords, 65)
        point.onEnter = function()
            shopPeds[shopName] = SpawnNPC(shop.ped, shop.coords)
            if Config.Setup.interact == "textui" then
                CreateThread(function()
                    HandleShopProximity(shop.coords, shopName)
                end)
            else
                local options = {
                    {
                        name = Strings.Target.shop.label,
                        icon = Strings.Target.shop.icon,
                        label = Strings.Target.shop.label,
                        onSelect = function()
                            if shopName == "detectors" then
                                OpenDetectorShop()
                            elseif shopName == "sellShop" then
                                OpenSellShop()
                            end
                        end,
                        action = function()
                            if shopName == "detectors" then
                                OpenDetectorShop()
                            elseif shopName == "sellShop" then
                                OpenSellShop()
                            end
                        end,
                        distance = Strings.Target.distance
                    }
                }
                AddTargetEntity(shopPeds[shopName], options)
            end
        end
        point.onExit = function()
            DeleteEntity(shopPeds[shopName])
            shopPeds[shopName] = nil
            if Config.Setup.interact ~= "textui" then
                RemoveTargetEntity(shopPeds[shopName], Strings.Target.shop.label)
            end
        end
    end
end

exports("OpenDetectorShop", OpenDetectorShop)
exports("OpenSellShop", OpenSellShop)
