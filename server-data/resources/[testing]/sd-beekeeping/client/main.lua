local locale = SD.Locale.T -- Variable to store translation function
local shop = {} -- stores relevant shop data for events/functions

-- Build quick lookup tables for shop menu.
shop.itemLabels = {}
for _, def in ipairs(Beekeeping.Shop.BuyItems) do
    shop.itemLabels[def.product] = def.labelKey
end
for _, def in ipairs(Beekeeping.Shop.SellItems) do
    shop.itemLabels[def.product] = def.labelKey
end

-- Function to get the colour
local GetProgressColor = function(pourcentage, inverted)
    if inverted then
        if pourcentage > 75 then return '#2a9d8f' end
        if pourcentage > 50 then return '#e9c46a' end
        if pourcentage > 30 then return '#f4a261' end
        if pourcentage > 0 then return '#e63946' end
    end
    if pourcentage > 75 then return '#e63946' end
    if pourcentage > 50 then return '#f4a261' end
    if pourcentage > 30 then return '#e9c46a' end
    if pourcentage > 0 then return '#2a9d8f' end
end

-- Ped Creation Function
local CreatePedAtCoords = function(pedModel, coords, scenario)
    local options = {
        {
            action = function()
                OpenBeekeepingMenu()
            end,
            icon = Beekeeping.Beekeeper.Interaction.Icon,
            label = locale('target.beekeeper'),
            canInteract = function()
                return true
            end
        },
    }

    local pedData = {
        model = pedModel,           -- Model of the ped (string or hash)
        coords = coords,            -- Coordinates where the ped will appear
        scenario = scenario,        -- Scenario the ped will enact
        distance = Beekeeping.Beekeeper.SpawnDistance,              -- Distance at which the ped spawns
        freeze = true,              -- Freeze the ped
        debug = false,              -- Enable debugging to visualize the point
        targetOptions = {           -- Target interaction options
            options = options,
            distance = Beekeeping.Beekeeper.Interaction.Distance
        },
        interactionType = Beekeeping.Interaction -- Add the interaction type to the data
    }

    -- Create the ped at the point using the SD.Ped module
    local point = SD.Ped.CreatePedAtPoint(pedData)
    
    return point
end

-- Thread for Ped Creation
CreateThread(function()
    while not GlobalState.BeekeeperLocation do Wait(0) end
    if Beekeeping.Beekeeper.Enable then local ped = CreatePedAtCoords(Beekeeping.Beekeeper.Model, GlobalState.BeekeeperLocation, Beekeeping.Beekeeper.Scenario) end
end)

-- Beekeeper Blip Creation Thread
CreateThread(function()
    if Beekeeping.Beekeeper.Enable and Beekeeping.Blip.Enable then
        local coords = GlobalState.BeekeeperLocation
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, Beekeeping.Blip.Sprite)
        SetBlipDisplay(blip, Beekeeping.Blip.Display)
        SetBlipScale(blip, Beekeeping.Blip.Scale)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, Beekeeping.Blip.Colour)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Beekeeping.Blip.Name)
        EndTextCommandSetBlipName(blip)
    end
end)

OpenPurchaseBeekeepingMenu = function()
    local useImages       = Beekeeping.Shop.UseItemImages
    local showPrices      = Beekeeping.Shop.ShowPricesOnTitles
    local purchaseElements = {}

    for _, itemDef in ipairs(Beekeeping.Shop.BuyItems) do
        local rawLabel     = itemDef.labelKey or ""
        local rawDesc      = itemDef.descKey  or ""

        local titleText = locale(rawLabel)
        if titleText == rawLabel then
            titleText = rawLabel
        end

        local descText = locale(rawDesc)
        if descText == rawDesc then
            descText = rawDesc
        end

        local iconString
        if useImages then
            iconString = SD.GetItemImage(itemDef.product)
        else
            iconString = itemDef.iconName or "circle"
        end

        if showPrices and itemDef.price then
            titleText = ("%s – $%d"):format(titleText, itemDef.price)
        end

        table.insert(purchaseElements, {
            title       = titleText,
            description = descText,
            icon        = iconString,
            product     = itemDef.product,
            price       = itemDef.price
        })
    end

    table.insert(purchaseElements, {
        title    = locale("beekeeper.return_main_menu"),
        icon     = "arrow-left",
        onSelect = OpenBeekeepingMenu
    })

    for _, element in ipairs(purchaseElements) do
        if element.product then
            element.onSelect = function()
                local input = lib.inputDialog(element.title, {
                    { type = "number", label = locale("beekeeper.quantity_label"), required = true, min = 1 }
                })
                if not input or not input[1] then return end

                local quantity = tonumber(input[1])
                if quantity and quantity > 0 then
                    local totalCost = element.price * quantity
                    OpenConfirmationDialog("buy", element.product, quantity, totalCost, "sd-beekeeping:buyProduct")
                end
            end
        end
    end

    lib.registerContext({
        id      = "purchase_beekeeping_menu",
        title   = locale("beekeeper.purchase_tools_title"),
        options = purchaseElements
    })
    lib.showContext("purchase_beekeeping_menu")
end

OpenSellBeekeepingMenu = function()
    local useImages     = Beekeeping.Shop.UseItemImages
    local showPrices    = Beekeeping.Shop.ShowPricesOnTitles
    local sellElements  = {}

    for _, itemDef in ipairs(Beekeeping.Shop.SellItems) do
        local rawLabel     = itemDef.labelKey  or ""
        local rawDesc      = itemDef.descKey   or ""
        local fmtParams    = itemDef.formatParams or {}

        local titleText = locale(rawLabel, fmtParams)
        if titleText == rawLabel then
            titleText = rawLabel
        end

        local descText = locale(rawDesc, fmtParams)
        if descText == rawDesc then
            descText = rawDesc
        end

        local iconString
        if useImages then
            iconString = SD.GetItemImage(itemDef.product)
        else
            iconString = itemDef.iconName or "circle"
        end

        local ownedAmount = SD.Inventory.HasItem(itemDef.product)
        local unitPrice   = itemDef.price or 0

        if ownedAmount <= 0 then
            table.insert(sellElements, {
                title       = showPrices and ("%s – $%d"):format(titleText, unitPrice) or titleText,
                description = locale("beekeeper.no_item", { price = unitPrice }),
                icon        = iconString,
                disabled    = true
            })
        else
            local fullDesc = descText .. " " .. locale("beekeeper.item_price", { price = unitPrice })
            table.insert(sellElements, {
                title       = showPrices and ("%s – $%d"):format(titleText, unitPrice) or titleText,
                description = fullDesc,
                icon        = iconString,
                product     = itemDef.product,
                price       = unitPrice
            })
        end
    end

    table.insert(sellElements, {
        title    = locale("beekeeper.return_main_menu"),
        icon     = "arrow-left",
        onSelect = OpenBeekeepingMenu
    })

    for _, element in ipairs(sellElements) do
        if element.product and not element.disabled then
            element.onSelect = function()
                local ownedAmount = SD.Inventory.HasItem(element.product)
                local input = lib.inputDialog(
                    locale("beekeeper.sell_quantity_title", { product = element.title }),
                    { { type = "slider", label = locale("beekeeper.quantity_label"), required = true, min = 1, max = ownedAmount, step = 1 } }
                )
                if not input or not input[1] then return end

                local quantity   = tonumber(input[1])
                local totalPrice = element.price * quantity
                OpenConfirmationDialog("sell", element.product, quantity, totalPrice, "sd-beekeeping:sellProduct")
            end
        end
    end

    lib.registerContext({
        id      = "sell_beekeeping_menu",
        title   = locale("beekeeper.sell_products_title"),
        options = sellElements
    })
    lib.showContext("sell_beekeeping_menu")
end

OpenConfirmationDialog = function(actionType, product, quantity, totalCost, serverEvent)
    local dialogTitle = locale('beekeeper.transaction_confirmation_title')

    local labelKey = shop.itemLabels[product] or product

    local productName = locale(labelKey)
    if productName == labelKey then
        productName = labelKey
    end

    local baseMessageKey = actionType == 'buy' and 'beekeeper.confirm_purchase' or 'beekeeper.confirm_sale'
    local baseMessage = locale(baseMessageKey)

    local confirmMessage = baseMessage:gsub('{quantity}', quantity):gsub('{product}', productName):gsub('{totalCost}', totalCost)

    local icon = (actionType == 'buy' and 'dollar-sign' or 'hand-holding-usd')

    lib.registerContext({
        id    = 'confirmation_dialog',
        title = dialogTitle,
        options = {
            {
                title       = (actionType == 'buy' and 'Confirm Purchase' or 'Confirm Sale'),
                description = confirmMessage,
                icon        = icon,
                onSelect    = function()
                    TriggerServerEvent(serverEvent, product, quantity)
                    lib.hideContext()
                end
            },
            {
                title    = 'Cancel',
                icon     = 'times',
                onSelect = function()
                    lib.hideContext()
                end
            }
        }
    })

    lib.showContext('confirmation_dialog')
end

-- Function to open the main Beekeeping Menu
OpenBeekeepingMenu = function()
    local elements = {
        {
            title = locale('beekeeper.purchase_tools'),
            icon = 'tools',
            description = locale('beekeeper.purchase_tools_desc'),
            onSelect = OpenPurchaseBeekeepingMenu
        },
        {
            title = locale('beekeeper.sell_items'),
            icon = 'dollar-sign',
            description = locale('beekeeper.sell_items_desc'),
            onSelect = OpenSellBeekeepingMenu
        }
    }

    lib.registerContext({
        id = 'beekeeping_main_menu',
        title = locale('beekeeper.main_menu_title'),
        options = elements
    })

    lib.showContext('beekeeping_main_menu')
end

-- Mapping from category-name → component/prop slots
local CategoryMap = {
    face        = { type = "component", ids = { 0 } },   -- 0 = Face
    masks       = { type = "component", ids = { 1 } },   -- 1 = Mask
    hair        = { type = "component", ids = { 2 } },   -- 2 = Hair
    torso       = { type = "component", ids = { 3 } },   -- 3 = Torso
    legs        = { type = "component", ids = { 4 } },   -- 4 = Legs
    bags        = { type = "component", ids = { 5 } },   -- 5 = Bags & Parachutes
    shoes       = { type = "component", ids = { 6 } },   -- 6 = Shoes
    accessories = { type = "component", ids = { 7 } },   -- 7 = Accessories
    undershirt  = { type = "component", ids = { 8 } },   -- 8 = Undershirt
    armor       = { type = "component", ids = { 9 } },   -- 9 = Body Armor
    decals      = { type = "component", ids = { 10 } },  -- 10 = Decals
    jackets     = { type = "component", ids = { 11 } },  -- 11 = Tops (Jackets)

    hats        = { type = "prop",      ids = { 0 } },   -- 0 = Hats/Helmets
    glasses     = { type = "prop",      ids = { 1 } },   -- 1 = Glasses
    ears        = { type = "prop",      ids = { 2 } },   -- 2 = Ears
    watches     = { type = "prop",      ids = { 6 } },   -- 6 = Watches
    bracelets   = { type = "prop",      ids = { 7 } },   -- 7 = Bracelets
}

local IsWearingProtective = function()
    local cfg = Beekeeping.Aggression.ProtectiveClothing
    if not cfg.Enable then return false end

    local ped    = PlayerPedId()
    local model  = GetEntityModel(ped)
    local isMale = (model == GetHashKey("mp_m_freemode_01"))

    local comps = {}
    for _, v in ipairs(cfg.Components.Common or {}) do table.insert(comps, v) end
    if isMale then
        for _, v in ipairs(cfg.Components.Male or {}) do table.insert(comps, v) end
    else
        for _, v in ipairs(cfg.Components.Female or {}) do table.insert(comps, v) end
    end

    local props = {}
    for _, v in ipairs(cfg.Props.Common or {}) do table.insert(props, v) end
    if isMale then
        for _, v in ipairs(cfg.Props.Male or {}) do table.insert(props, v) end
    else
        for _, v in ipairs(cfg.Props.Female or {}) do table.insert(props, v) end
    end

    local cats = cfg.Categories or {}

    if cfg.Mode == "category_any" then
        for _, cat in ipairs(cats) do
            local map = CategoryMap[cat]
            if map then
                for _, slot in ipairs(map.ids) do
                    if map.type == "component" and GetPedDrawableVariation(ped, slot) > 0 then
                        return true
                    elseif map.type == "prop" and GetPedPropIndex(ped, slot) > -1 then
                        return true
                    end
                end
            end
        end
        return false

    elseif cfg.Mode == "category_all" then
        for _, cat in ipairs(cats) do
            local map = CategoryMap[cat]
            local catOk = false
            if map then
                for _, slot in ipairs(map.ids) do
                    if map.type == "component" and GetPedDrawableVariation(ped, slot) > 0 then
                        catOk = true break
                    elseif map.type == "prop" and GetPedPropIndex(ped, slot) > -1 then
                        catOk = true break
                    end
                end
            end
            if not catOk then return false end
        end
        return true
    end

    local anyOk, allOk = false, true

    for _, piece in ipairs(comps) do
        local match = false

        if type(piece.id) == "string" then
            local map = CategoryMap[piece.id]
            if map and map.type == "component" then
                for _, slot in ipairs(map.ids) do
                    local cd = GetPedDrawableVariation(ped, slot)
                    local ct = GetPedTextureVariation(ped, slot)
                    if cd == piece.drawable and (not piece.texture or ct == piece.texture) then
                        match = true break
                    end
                end
            end
        else
            local cd = GetPedDrawableVariation(ped, piece.id)
            local ct = GetPedTextureVariation(ped, piece.id)
            match = (cd == piece.drawable) and (not piece.texture or ct == piece.texture)
        end

        anyOk = anyOk or match
        allOk = allOk and match
        if cfg.Mode == "any" and match then return true end
        if cfg.Mode == "all" and not match then return false end
    end

    for _, piece in ipairs(props) do
        local match = false

        if type(piece.id) == "string" then
            local map = CategoryMap[piece.id]
            if map and map.type == "prop" then
                for _, slot in ipairs(map.ids) do
                    local cp = GetPedPropIndex(ped, slot)
                    if cp == piece.drawable then
                        match = true break
                    end
                end
            end
        else
            local cp = GetPedPropIndex(ped, piece.id)
            match = (cp == piece.drawable)
        end

        anyOk = anyOk or match
        allOk = allOk and match
        if cfg.Mode == "any" and match then return true end
        if cfg.Mode == "all" and not match then return false end
    end

    if cfg.Mode == "any" then
        return anyOk
    else
        return allOk
    end
end

--- Applies “bee sting” damage to the local player (with protective‐gear check)
--- @param damage number Amount of HP to remove
local ApplyBeeStingDamage = function(damage)
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end

    if Beekeeping.Aggression.ProtectiveClothing.Enable and IsWearingProtective() then
        return
    end

    local current   = GetEntityHealth(ped)
    local newHealth = math.max(0, current - damage)
    SetEntityHealth(ped, newHealth)

    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.1)
    SD.ShowNotification(locale('notifications.bee_sting', { damage = damage }), 'error')
end

--- Damages the player based on a hive's aggression level and per‐level sting chance.
--- @param hData table Full hive data returned by the server callback
local DamagePlayerFromAggression = function(hData)
    local lvl  = hData.data.aggression or Beekeeping.Aggression.DefaultLevel
    local info = Beekeeping.Aggression.Levels[lvl] or { damage = 0 }

    local stingPct = Beekeeping.Aggression.StingChance[lvl] or 0

    if not (info.damage and info.damage > 0) or stingPct <= 0 then
        return
    end

    local roll = math.random(100)

    if roll <= stingPct then
        ApplyBeeStingDamage(info.damage)
    end
end

-- openBeeHouseMenu Function
openBeeHouseMenu = function(data)
    local originalData = data
    lib.callback('sd-beekeeping:getHiveFullData', false, function(hData)
        if not hData or type(hData) ~= 'table' then print('Error retrieving Data') return end
        local hiveData = hData.data
        local hiveOptions = {}
        if hiveData then
            local owner = hData.citizenid
            local citizenid = SD.GetIdentifier()
            local collaborators = hData.collaborators or {}
            local useImages = Beekeeping.House.UseItemImages
            hiveOptions[#hiveOptions+1] = {
                title = locale('houses.capturing'),
                description = locale('houses.capturing_description', {progress = (hiveData.time / Beekeeping.House.CaptureTime) * 100}),
                icon = 'fa-solid fa-spinner fa-spin',
                progress = (hiveData.time / Beekeeping.House.CaptureTime) * 100,
            }
            hiveOptions[#hiveOptions+1] = {
                title = locale('houses.queens', {currentQueens = hiveData.queens, maxQueens = Beekeeping.House.MaxQueens}),
                description = locale('houses.queens_description', {currentQueens = hiveData.queens, maxQueens = Beekeeping.House.MaxQueens}),
                icon = useImages and SD.GetItemImage(Beekeeping.Items.QueenItem) or 'fa-solid fa-crown',
                progress = (hiveData.queens / Beekeeping.House.MaxQueens) * 100,
                colorScheme = GetProgressColor((hiveData.queens / Beekeeping.House.MaxQueens) * 100),
                arrow = true,
                onSelect = function()
                    if hiveData.queens <= 0 then 
                        TriggerEvent('sd-beekeeping:openBeeHouse', hData)
                        SD.ShowNotification(locale('notifications.not_enough_bees'), 'error')
                        return 
                    end
                    WithdrawBeeDialog(hData.id, 'queens', hiveData.queens, hData)
                end
            }
            hiveOptions[#hiveOptions+1] = {
                title = locale('houses.workers', {currentWorkers = hiveData.workers, maxWorkers = Beekeeping.House.MaxWorkers}),
                description = locale('houses.workers_description', {currentWorkers = hiveData.workers, maxWorkers = Beekeeping.House.MaxWorkers}),
                icon = useImages and SD.GetItemImage(Beekeeping.Items.WorkerItem) or 'fa-solid fa-users',
                progress = (hiveData.workers / Beekeeping.House.MaxWorkers) * 100,
                colorScheme = GetProgressColor((hiveData.workers / Beekeeping.House.MaxWorkers) * 100),
                arrow = true,
                onSelect = function()
                    if hiveData.workers <= 0 then 
                        TriggerEvent('sd-beekeeping:openBeeHouse', hData)
                        SD.ShowNotification(locale('notifications.not_enough_bees'), 'error')
                        return 
                    end
                    WithdrawBeeDialog(hData.id, 'workers', hiveData.workers, hData)
                end
            }
            if Beekeeping.Expiry.EnableExpiration then
                local durability = hData.durability or 100
                local repairCost = (100 - durability) * Beekeeping.Expiry.RepairCostPerOne
                local canRepair = durability < 100
                hiveOptions[#hiveOptions+1] = {
                    title = locale('houses.maintenance_and_repair_title'),
                    description = locale('houses.maintenance_and_repair_description'),
                    icon = "fa-solid fa-tools",
                    onSelect = function()
                        openMaintenanceMenu(hData, repairCost, canRepair, data, "house")
                    end
                }
            end
            if Beekeeping.FacilityBlip.Enable then
                local currentBlipState = false
                if hiveData.blipData and hiveData.blipData[citizenid] then
                    currentBlipState = hiveData.blipData[citizenid]
                end
                hiveOptions[#hiveOptions+1] = {
                    title = locale('houses.toggle_blip_title'),
                    description = currentBlipState and locale('houses.blip_active_desc') or locale('houses.blip_inactive_desc'),
                    icon = 'fa-solid fa-map-marker-alt',
                    iconColor = currentBlipState and 'green' or 'red',
                    onSelect = function()
                        local newState = not currentBlipState
                        hiveData.blipData = hiveData.blipData or {}
                        hiveData.blipData[citizenid] = newState
                        TriggerServerEvent('sd-beekeeping:toggleBlip', data.id, newState)
                        SD.ShowNotification(locale('notifications.blip_toggled', {state = newState and locale('misc.enabled') or locale('misc.disabled')}), 'success')
                        openBeeHouseMenu(originalData)
                    end
                }
            end

            if Beekeeping.Aggression.Enable then
                local cfg    = Beekeeping.Aggression
                local lvl    = hiveData.aggression or cfg.DefaultLevel
                local info   = cfg.Levels[lvl] or { name = "?", damage = 0 }
                local colors = { [1]='green',[2]='yellow',[3]='orange',[4]='red' }

                hiveOptions[#hiveOptions+1] = {
                    title       = locale('houses.aggression_title'),
                    description = locale('houses.aggression_desc', {level  = locale(info.nameKey), damage = info.damage}),
                    icon        = 'fa-solid fa-exclamation-triangle',
                    iconColor   = colors[lvl] or 'white',
                    onSelect    = function()
                        OpenAggressionMenu(hData, 'house')
                    end
                }
            end

            hiveOptions[#hiveOptions+1] = {
                title = locale('houses.refresh'),
                description = locale('houses.refresh_description'),
                icon = 'fa-solid fa-rotate',
                onSelect = function()
                    openBeeHouseMenu(hData)
                end
            }
            hiveOptions[#hiveOptions+1] = {
                title = locale('houses.destroy'),
                description = locale('houses.destroy_description'),
                icon = 'fa-solid fa-trash',
                onSelect = function()
                    OpenDeleteConfirmDialog(hData.id, hData, 'house', locale('houses.confirm_destroy'))
                end
            }
            if Beekeeping.LockAccess then
                hiveOptions[#hiveOptions+1] = {
                    title = locale('misc.return_to_menu'),
                    icon = 'arrow-left',
                    onSelect = function()
                        TriggerEvent('sd-beekeeping:openBeeHouse', data)
                    end
                }
            end
        else
            hiveOptions = {{
                title = locale('notifications.title'),
                description = locale('notifications.house_error'),
                icon = 'fa-solid fa-ban'
            }}
        end
        lib.registerContext({
            id = 'sdbeekeeping_house_menu',
            title = locale('houses.title'),
            options = hiveOptions,
        })
        lib.showContext('sdbeekeeping_house_menu')
    end, data.id)
end

RegisterNetEvent('sd-beekeeping:openBeeHouse', function(data)
    lib.callback('sd-beekeeping:getHiveCollaborators', false, function(hMemberData)
        if not hMemberData then 
            print('Error retrieving Data') 
            return 
        end

        local ownerObj      = hMemberData.owner or {}
        local ownerId       = ownerObj.id
        local citizenid     = SD.GetIdentifier()
        local collaborators = hMemberData.collaborators or {}

        if Beekeeping.LockAccess then
            local isCollab = false
            for _, c in ipairs(collaborators) do
                if c.id == citizenid then
                    isCollab = true
                    break
                end
            end

            if citizenid ~= ownerId and not isCollab then
                SD.ShowNotification(locale('notifications.no_access'), 'error')
                return
            end

            local mainMenuOptions = {
                {
                    title = locale('houses.main_menu_title'),
                    description = locale('houses.main_menu_description'),
                    icon = 'fa-solid fa-house-user',
                    onSelect = function()
                        openBeeHouseMenu(data)
                    end
                },
                {
                    title = locale('collaborators_menu.collaborators_menu_title'),
                    description = locale('collaborators_menu.collaborators_menu_description'),
                    icon = 'fa-solid fa-user-friends',
                    onSelect = function()
                        openCollaboratorsMenu(hMemberData, data.id, "house")
                    end
                }
            }

            lib.registerContext({
                id = 'sdbeekeeping_house_menu',
                title = locale('houses.menu_title'),
                options = mainMenuOptions,
            })
            lib.showContext('sdbeekeeping_house_menu')
        else
            openBeeHouseMenu(data)
        end
    end, data.id)
end)

WithdrawBeeDialog = function(id, type, max, originalData)
    lib.hideContext()
    local title
    if type == 'queens' then title = locale('houses.withdraw_queens')
    elseif type == 'workers' then title = locale('houses.withdraw_workers') end

    local input = lib.inputDialog(title, {
        {
            type = 'slider',
            min = 1,
            max = max,
            step = 1,
            icon = 'fa-solid fa-hashtag'
        }
    })

    if input then
        DamagePlayerFromAggression(originalData)
        TriggerServerEvent('sd-beekeeping:withdrawBee', id, type, input[1])
        Wait(50)
        TriggerEvent('sd-beekeeping:openBeeHouse', originalData)
    end
end

OpenDeleteConfirmDialog = function(id, originalData, type, header)
    lib.hideContext()
    local confirmed = lib.alertDialog({
        header = header,
        centered = true,
        cancel = true,
        size = 'md'
    })
    
    if confirmed == 'confirm' then TriggerServerEvent('sd-beekeeping:removeStructure', id) end
end

--- Opens the shield protection menu, allowing the user to choose a tier of protection.
--- @param hiveId number The hive ID to protect.
--- @param originalData table The original hive data passed from the event.
local openHiveProtectionMenu = function(hiveId, originalData)
    -- Check if shield purchasing is enabled
    if not Beekeeping.Infection.ShieldsEnabled then
        SD.ShowNotification(locale('hives.shields_disabled'), 'error')
        return
    end

    local data = originalData
    if not data then
        SD.ShowNotification(locale('notifications.hive_error'), 'error')
        return
    end

    -- Prevent shield purchase while hive is infected
    if data.infected then
        SD.ShowNotification(locale('notifications.hive_infected_cannot_purchase_shield'), 'error')
        return
    end

    local options = {}
    for id, tier in ipairs(Beekeeping.Infection.ProtectionTiers) do
        options[#options+1] = {
            title = locale(tier.localeKey),
            description = locale('hives.upkeeper_shield_description', {cost = tier.cost, duration = tier.duration / 60}),
            icon = 'fa-solid fa-shield',
            onSelect = function()
                local confirmed = lib.alertDialog({
                    header = locale('hives.upkeeper_confirm_title'),
                    content = locale('hives.upkeeper_confirm_description', {cost = tier.cost}),
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = locale('misc.confirm'),
                        cancel = locale('misc.cancel')
                    }
                })
        
                if confirmed == 'confirm' then
                    TriggerServerEvent('sd-beekeeping:purchaseShield', hiveId, id)
                end
            end
        }
    end

    -- Option to go back to the infection menu
    options[#options+1] = {
        title = locale('misc.return_to_menu'),
        icon = 'fa-solid fa-arrow-left',
        onSelect = function()
            openHiveInfectionMenu({ data = originalData }, originalData)
        end
    }

    lib.registerContext({
        id = 'sdbeekeeping_hive_protection_menu',
        title = locale('hives.upkeeper_menu_title'),
        options = options
    })

    lib.showContext('sdbeekeeping_hive_protection_menu')
end

--- Maps infection severity to icon colors.
local getIconColorBySeverity = function(severity)
    if severity <= 1 then
        return 'yellow'
    elseif severity == 2 then
        return 'orange'
    else
        return 'red'
    end
end

--- Opens the infection menu for the hive, allowing the user to treat it if infected
--- and now also to purchase a shield/upkeeper.
--- @param hiveData table The hive data returned from the server.
--- @param originalData table The original hive data passed from the event.
openHiveInfectionMenu = function(hiveData, originalData)
    local hiveId = originalData.id
    local data = hiveData.data
    local severity = data.infectionSeverity or 0
    local queenStatus = data.infected and locale('hives.queen_is_at_risk') or locale('hives.queen_is_safe')
    local productionHindrance = Beekeeping.Infection.SeverityLevels[severity] and Beekeeping.Infection.SeverityLevels[severity].ProductionDelayMultiplier or 1.0
    local infectionHinderanceInfo = productionHindrance > 1.0 and locale('hives.production_slowed', { factor = productionHindrance }) or locale('hives.production_not_hindered')

    -- Determine icon color based on severity
    local iconColor = getIconColorBySeverity(severity)

    lib.callback('sd-beekeeping:getInfectionLosses', false, function(lossData)
        lib.callback('sd-beekeeping:getServerTime', false, function(currentTime)
            local workerLost = lossData.lostWorkers or 0
            local queenLost = lossData.lostQueens or 0

            local options = {}

            if data.infected then
                -- Infection Treat Option
                options[#options+1] = {
                    title = locale('hives.infection_treat'),
                    description = locale('hives.infection_treat_description'),
                    icon = 'fa-solid fa-syringe',
                    onSelect = function()
                        local confirmed = lib.alertDialog({
                            header = locale('hives.infection_treat'),
                            content = locale('hives.infection_treat_confirmation'),
                            centered = true,
                            cancel = true,
                            labels = {
                                confirm = locale('misc.confirm'),
                                cancel = locale('misc.cancel')
                            }
                        })
            
                        if confirmed == 'confirm' then
                            TriggerServerEvent('sd-beekeeping:treatHive', hiveId)
                        end
                    end
                }

                -- Infection Report with Severity
                options[#options+1] = {
                    title = locale('hives.infection_report'),
                    description = locale('hives.infection_report_full_description', {
                        workers = workerLost,
                        queens = queenLost,
                        queenStatus = queenStatus,
                        hindranceInfo = infectionHinderanceInfo
                    }) .. " " .. locale('hives.infection_severity', { severity = severity }),
                    icon = 'fa-solid fa-info-circle',
                    iconColor = iconColor,
                    disabled = true
                }
            else
                -- No Infection
                local shieldRemainingText = ""
                if data.shieldUntil and data.shieldUntil > currentTime then
                    local timeLeft = data.shieldUntil - currentTime
                    local hours = math.floor(timeLeft / 3600)
                    local minutes = math.floor((timeLeft % 3600) / 60)
                    shieldRemainingText = "\n" .. locale('hives.shield_remaining', { hours = hours, minutes = minutes })
                end

                options[#options+1] = {
                    title = locale('hives.no_infection'),
                    description = locale('hives.no_infection_description') .. shieldRemainingText,
                    icon = 'fa-solid fa-check',
                    iconColor = 'green',
                    disabled = true
                }
            end

            -- Shield/Upkeeper Option (only if shields are enabled and no infection)
            if Beekeeping.Infection.ShieldsEnabled and not data.infected then
                options[#options+1] = {
                    title = locale('hives.upkeeper_menu_option'),
                    description = locale('hives.upkeeper_menu_description'),
                    icon = 'fa-solid fa-shield-halved',
                    disabled = data.shieldUntil and data.shieldUntil > currentTime or false,
                    onSelect = function()
                        openHiveProtectionMenu(hiveId, originalData)
                    end
                }
            end

            -- Return to Previous Menu
            options[#options+1] = {
                title = locale('misc.return_to_menu'),
                icon = 'fa-solid fa-arrow-left',
                onSelect = function()
                    openBeeHive(originalData)
                end
            }

            lib.registerContext({
                id = 'sdbeekeeping_hive_infection_menu',
                title = locale('hives.infection_menu_title'),
                options = options
            })

            lib.showContext('sdbeekeeping_hive_infection_menu')
        end)
    end, hiveId)
end

--- Opens the Aggression menu for a hive or house, always pulling the latest aggression
--- @param hData table The hive/house data (must contain .id and .data.aggression)
--- @param type  string "hive" or "house" to know which menu to return to
OpenAggressionMenu = function(hData, type)
    lib.callback('sd-beekeeping:getAggressionLevel', false, function(freshLvl)
        hData.data.aggression = freshLvl

        local cfg       = Beekeeping.Aggression
        local lvl       = freshLvl
        local info      = cfg.Levels[lvl] or { nameKey = "hives.aggression_name_calm", damage = 0 }
        local levelName = locale(info.nameKey)
        local colors    = { [1]='green', [2]='yellow', [3]='orange', [4]='red' }
        local isMin     = (lvl == cfg.DefaultLevel)

        local descKey, descArgs
        if isMin then
            descKey  = 'aggression.use_smoker_desc_disabled'
            descArgs = {}
        else
            local targetLvl = (cfg.SmokerReduceBy == "all")
                and cfg.DefaultLevel
                or math.max(cfg.DefaultLevel, lvl - cfg.SmokerReduceBy)
            local targetInfo = cfg.Levels[targetLvl] or { nameKey = "hives.aggression_name_calm" }
            local targetName = locale(targetInfo.nameKey)

            descKey  = 'aggression.use_smoker_desc_range'
            descArgs = { from = levelName, to = targetName }
        end

        lib.registerContext({
            id    = 'sdbeekeeping_aggression_'..hData.id,
            title = locale('aggression.title'),
            options = {
                {
                    title       = locale('aggression.level',  { level  = levelName }),
                    description = locale('aggression.damage', { damage = info.damage }),
                    icon        = 'fa-solid fa-bug',
                    iconColor   = colors[lvl] or 'white',
                    readOnly    = true,
                },
                {
                    title       = locale('aggression.use_smoker'),
                    description = locale(descKey, descArgs),
                    icon        = 'fa-solid fa-smog',
                    disabled    = isMin,
                    onSelect    = function()
                        TriggerServerEvent('sd-beekeeping:server:useSmoker', hData.id)
                        TriggerEvent('sd-beekeeping:client:openAggressionMenu', hData, type)
                    end
                },
                {
                    title    = locale('misc.return_to_menu'),
                    icon     = 'fa-solid fa-arrow-left',
                    onSelect = function()
                        if type == 'hive' then
                            openBeeHive({ id = hData.id })
                        else
                            openBeeHouseMenu({ id = hData.id })
                        end
                    end
                }
            }
        })
        lib.showContext('sdbeekeeping_aggression_'..hData.id)
    end, hData.id)
end

RegisterNetEvent('sd-beekeeping:client:openAggressionMenu', OpenAggressionMenu)


openBeeHive = function(data)
    local originalData = data
    lib.callback('sd-beekeeping:getHiveFullData', false, function(hData)
        if not hData or type(hData) ~= 'table' then
            print('Error retrieving Data')
            return
        end

        local hiveData        = hData.data or {}
        local owner           = hData.citizenid
        local citizenid       = SD.GetIdentifier()
        local collaborators   = hData.collaborators or {}
        local durability      = hData.durability or 100
        local honeyType       = hiveData.honeyType or 'basic'
        local honeyInfo       = Beekeeping.HoneyTypes[honeyType]
        local honeyDisplay    = honeyInfo.displayName or 'Bee Honey'
        local honeyItem       = honeyInfo.item or Beekeeping.Items.HoneyItem
        local isProdDisabled  = not hiveData.haveQueen or (hiveData.workers or 0) < Beekeeping.Hives.NeededWorkers
        local adjustedHoneyTime = hiveData.adjustedHoneyTime or Beekeeping.Hives.HoneyTime
        local useImages       = Beekeeping.Hives.UseItemImages

        local hiveOptions = {}

        hiveOptions[#hiveOptions+1] = {
            title       = locale('hives.producing_status', { status = isProdDisabled and locale('hives.status_inactive') or locale('hives.status_active') }),
            description = locale('hives.producing_description'),
            icon        = 'fa-brands fa-hive',
            iconColor   = isProdDisabled and 'red' or 'green',
            progress    = (hiveData.time or 0) / adjustedHoneyTime * 100,
            disabled    = isProdDisabled
        }

        if not hiveData.haveQueen then
            hiveOptions[#hiveOptions+1] = {
                title       = locale('hives.insert_queens_title', { needed = Beekeeping.Hives.NeededQueens }),
                description = locale('hives.insert_queens_description', { needed = Beekeeping.Hives.NeededQueens }),
                icon        = useImages and SD.GetItemImage(Beekeeping.Items.QueenItem) or 'fa-solid fa-crown',
                onSelect    = function()
                    TriggerServerEvent('sd-beekeeping:insertQueen', data.id)
                end
            }
        end

        if not hiveData.haveWorker then
            hiveOptions[#hiveOptions+1] = {
                title       = locale('hives.insert_workers_title',        { needed = Beekeeping.Hives.NeededWorkers }),
                description = locale('hives.insert_workers_description', { needed = Beekeeping.Hives.NeededWorkers }),
                icon        = useImages and SD.GetItemImage(Beekeeping.Items.WorkerItem) or 'fa-solid fa-users',
                onSelect    = function()
                    local available = SD.Inventory.HasItem(Beekeeping.Items.WorkerItem)
                    if available < Beekeeping.Hives.NeededWorkers then
                        SD.ShowNotification(
                            locale('notifications.not_enough_workers', { needed = Beekeeping.Hives.NeededWorkers }),'error')
                        return
                    end
        
                    local input = lib.inputDialog(
                        locale('hives.insert_worker_amount'),
                        {
                            {
                                type    = 'slider',
                                min     = Beekeeping.Hives.NeededWorkers,
                                max     = available,
                                default = Beekeeping.Hives.NeededWorkers,
                            }
                        }
                    )
                    if not input or not input[1] then return end
        
                    local amt = tonumber(input[1])
                    TriggerServerEvent('sd-beekeeping:insertWorker', hData.id, amt)
                end
            }
        end

        if hiveData.haveQueen and hiveData.haveWorker then
            hiveOptions[#hiveOptions+1] = {
                title       = locale('hives.honey_level_title_with_type', {
                    honeyType   = honeyDisplay,
                    currentHoney= hiveData.honey or 0,
                    maxHoney    = Beekeeping.Hives.MaxHoney
                }),
                description = locale('hives.honey_level_description_with_type', { honeyType = honeyDisplay }),
                icon        = useImages and SD.GetItemImage(honeyItem) or 'fa-solid fa-droplet',
                progress    = (hiveData.honey or 0) / Beekeeping.Hives.MaxHoney * 100,
                colorScheme = GetProgressColor((hiveData.honey or 0) / Beekeeping.Hives.MaxHoney * 100),
                arrow       = true,
                onSelect    = function()
                    if (hiveData.honey or 0) <= 0 then
                        openBeeHive(originalData)
                        SD.ShowNotification(locale('notifications.not_enough_product'), 'error')
                        return
                    end
                    WithdrawProductDialog(data.id, 'honey', hiveData.honey, originalData, honeyType, hData)
                end
            }
            hiveOptions[#hiveOptions+1] = {
                title       = locale('hives.wax_level_title', {
                    currentWax = hiveData.wax or 0,
                    maxWax     = Beekeeping.Hives.MaxWax
                }),
                description = locale('hives.wax_level_description'),
                icon        = useImages and SD.GetItemImage(Beekeeping.Items.WaxItem) or 'fa-solid fa-cube',
                progress    = (hiveData.wax or 0) / Beekeeping.Hives.MaxWax * 100,
                colorScheme = GetProgressColor((hiveData.wax or 0) / Beekeeping.Hives.MaxWax * 100),
                arrow       = true,
                onSelect    = function()
                    if (hiveData.wax or 0) <= 0 then
                        openBeeHive(originalData)
                        SD.ShowNotification(locale('notifications.not_enough_product'), 'error')
                        return
                    end
                    WithdrawProductDialog(data.id, 'wax', hiveData.wax, originalData, nil, hData)
                end
            }
            hiveOptions[#hiveOptions+1] = {
                title       = locale('hives.worker_management'),
                description = locale('hives.worker_management_description'),
                icon        = 'fa-solid fa-briefcase',
                onSelect    = function()
                    openWorkerManagementMenu(hiveData, originalData)
                end
            }
            if Beekeeping.Infection.Enable then
                hiveOptions[#hiveOptions+1] = {
                    title       = locale('hives.infection_status'),
                    description = hiveData.infected and locale('hives.infected_description') or locale('hives.not_infected_description'),
                    icon        = hiveData.infected and 'fa-solid fa-virus' or 'fa-solid fa-shield-virus',
                    iconColor   = hiveData.infected and 'red' or 'green',
                    onSelect    = function()
                        openHiveInfectionMenu(hData, data)
                    end
                }
            end
        end

        if Beekeeping.Expiry.EnableExpiration then
            local repairCost = (100 - durability) * Beekeeping.Expiry.RepairCostPerOne
            hiveOptions[#hiveOptions+1] = {
                title       = locale('hives.maintenance_and_repair_title'),
                description = locale('hives.maintenance_and_repair_description'),
                icon        = 'fa-solid fa-screwdriver-wrench',
                onSelect    = function()
                    openMaintenanceMenu(hData, repairCost, durability < 100, data, "hive")
                end
            }
        end

        if Beekeeping.FacilityBlip and Beekeeping.FacilityBlip.Enable then
            local currentBlip = hiveData.blipData and hiveData.blipData[citizenid] or false
            hiveOptions[#hiveOptions+1] = {
                title       = locale('hives.toggle_blip_title'),
                description = currentBlip and locale('hives.blip_active_desc') or locale('hives.blip_inactive_desc'),
                icon        = 'fa-solid fa-map-marker-alt',
                iconColor   = currentBlip and 'green' or 'red',
                onSelect    = function()
                    local newState = not currentBlip
                    hiveData.blipData = hiveData.blipData or {}
                    hiveData.blipData[citizenid] = newState
                    TriggerServerEvent('sd-beekeeping:toggleBlip', data.id, newState)
                    SD.ShowNotification(locale('notifications.blip_toggled', {
                        state = newState and locale('enabled') or locale('disabled')
                    }), 'success')
                    openBeeHive(originalData)
                end
            }
        end

        if Beekeeping.Aggression.Enable then
            local lvl      = hiveData.aggression or Beekeeping.Aggression.DefaultLevel
            local info     = Beekeeping.Aggression.Levels[lvl] or {}
            local colorMap = { [1]='green',[2]='yellow',[3]='orange',[4]='red' }
            hiveOptions[#hiveOptions+1] = {
                title       = locale('hives.aggression_title'),
                description = locale('hives.aggression_desc', { level = locale(info.nameKey), damage = info.damage }),
                icon        = 'fa-solid fa-exclamation-triangle',
                iconColor   = colorMap[lvl] or 'white',
                onSelect    = function()
                    OpenAggressionMenu(hData, 'hive')
                end
            }
        end

        hiveOptions[#hiveOptions+1] = {
            title       = locale('hives.refresh'),
            description = locale('hives.refresh_description'),
            icon        = 'fa-solid fa-rotate',
            onSelect    = function()
                openBeeHive(originalData)
            end
        }

        hiveOptions[#hiveOptions+1] = {
            title       = locale('hives.destroy'),
            description = locale('hives.destroy_description'),
            icon        = 'fa-solid fa-trash',
            onSelect    = function()
                OpenDeleteConfirmDialog(data.id, originalData, 'hive', locale('hives.confirm_destroy'))
            end
        }

        if Beekeeping.LockAccess then
            hiveOptions[#hiveOptions+1] = {
                title = locale('misc.return_to_menu'),
                icon  = 'arrow-left',
                onSelect = function()
                    TriggerEvent('sd-beekeeping:openBeeHive', data)
                end
            }
        end

        lib.registerContext({
            id      = 'sdbeekeeping_hive_menu',
            title   = locale('hives.menu_title'),
            options = hiveOptions,
        })
        lib.showContext('sdbeekeeping_hive_menu')
    end, data.id)
end

RegisterNetEvent('sd-beekeeping:openBeeHive', function(data)
    lib.callback('sd-beekeeping:getHiveCollaborators', false, function(hMemberData)
        if not hMemberData or type(hMemberData) ~= 'table' then
            print('Error retrieving Member Data')
            return
        end

        local ownerObj      = hMemberData.owner or {}
        local ownerId       = ownerObj.id
        local citizenid     = SD.GetIdentifier()
        local collaborators = hMemberData.collaborators or {}

        if Beekeeping.LockAccess then
            local isCollab = false
            for _, c in ipairs(collaborators) do
                if c.id == citizenid then
                    isCollab = true
                    break
                end
            end

            if citizenid ~= ownerId and not isCollab then
                SD.ShowNotification(locale('notifications.no_access'), 'error')
                return
            end

            local mainMenuOptions = {
                {
                    title       = locale('hives.main_menu_title'),
                    description = locale('hives.main_menu_description'),
                    icon        = 'fa-brands fa-hive',
                    onSelect    = function()
                        openBeeHive(data)
                    end
                },
                {
                    title       = locale('collaborators_menu.collaborators_menu_title'),
                    description = locale('collaborators_menu.collaborators_menu_description'),
                    icon        = 'fa-solid fa-user-friends',
                    onSelect    = function()
                        openCollaboratorsMenu(hMemberData, data.id, "hive")
                    end
                }
            }

            lib.registerContext({
                id      = 'sdbeekeeping_hive_menu',
                title   = locale('hives.menu_title'),
                options = mainMenuOptions,
            })
            lib.showContext('sdbeekeeping_hive_menu')
        else
            openBeeHive(data)
        end
    end, data.id)
end)

openWorkerManagementMenu = function(hiveData, originalData)
    local useImages  = Beekeeping.Hives.UseItemImages
    local workerIcon = useImages and SD.GetItemImage(Beekeeping.Items.WorkerItem) or 'fa-solid fa-users'

    local workerMenuOptions = {
        {
            title       = locale('hives.insert_workers_title'),
            description = locale('hives.insert_more_workers'),
            icon        = workerIcon,
            onSelect = function()
                local owned   = SD.Inventory.HasItem(Beekeeping.Items.WorkerItem)
                local current = hiveData.workers or 0
                local capacity   = Beekeeping.Hives.MaxWorkers
                local spaceLeft  = capacity - current
                local maxAdd     = math.min(owned, spaceLeft)
            
                if maxAdd < 1 then
                    return SD.ShowNotification(locale('notifications.not_enough_workers', { needed = 1 }),'error')
                end
            
                local result = lib.inputDialog(
                    locale('hives.insert_worker_amount'),
                    {
                        {
                            type  = 'slider',
                            label = locale('hives.insert_worker_amount'),
                            min   = 1,
                            max   = maxAdd,
                            step  = 1,
                        }
                    }
                )
            
                if result and tonumber(result[1]) and tonumber(result[1]) > 0 then
                    TriggerServerEvent('sd-beekeeping:insertWorker',originalData.id,tonumber(result[1]))
                end
            end
        },
        {
            title       = locale('hives.worker_level_title', { currentWorkers = hiveData.workers or 0, maxWorkers = Beekeeping.Hives.MaxWorkers }),
            description = locale('hives.worker_level_description'),
            icon        = workerIcon,
            progress    = ((hiveData.workers or 0) / Beekeeping.Hives.MaxWorkers) * 100,
            colorScheme = GetProgressColor(((hiveData.workers or 0) / Beekeeping.Hives.MaxWorkers) * 100)
        },
        {
            title    = locale('misc.return_to_menu'),
            icon     = 'fa-solid fa-arrow-left',
            onSelect = function()
                openBeeHive(originalData)
            end
        }
    }

    lib.registerContext({
        id      = 'sdbeekeeping_hive_worker_menu',
        title   = locale('hives.worker_management'),
        options = workerMenuOptions,
    })
    lib.showContext('sdbeekeeping_hive_worker_menu')
end

openCollaboratorsMenu = function(hData, hiveId, buildingType)
    local collaboratorMenuOptions = {}

    local ownerObj      = hData.owner or {}
    local ownerDisplay  = ownerObj.name and string.format("%s (%s)", ownerObj.name, ownerObj.id) or ownerObj.id

    local citizenid     = SD.GetIdentifier()
    local collaborators = hData.collaborators or {}

    collaboratorMenuOptions[#collaboratorMenuOptions+1] = {
        title       = locale('collaborators_menu.owner_title', {owner = ownerDisplay}),
        description = locale('collaborators_menu.owner_description'),
        icon        = 'fa-solid fa-crown',
    }

    if #collaborators > 0 then
        for _, collab in ipairs(collaborators) do
            local display = collab.name and 
                string.format("%s (%s)", collab.name, collab.id) 
            or collab.id

            collaboratorMenuOptions[#collaboratorMenuOptions+1] = {
                title       = display,
                description = locale('collaborators_menu.collaborator_listed_description'),
                icon        = 'fa-solid fa-user-tag',
                onSelect    = (tostring(citizenid) == tostring(ownerObj.id)) 
                    and function()
                        openRemoveCollaboratorConfirmMenu(hiveId, collab.id)
                    end
                or nil
            }
        end
    else
        collaboratorMenuOptions[#collaboratorMenuOptions+1] = {
            title       = locale('collaborators_menu.no_collaborators_title'),
            description = locale('collaborators_menu.no_collaborators_description'),
            icon        = 'fa-solid fa-user-slash',
            disabled    = true
        }
    end

    if tostring(citizenid) == tostring(ownerObj.id) then
        collaboratorMenuOptions[#collaboratorMenuOptions+1] = {
            title       = locale('collaborators_menu.add_collaborator_title'),
            description = locale('collaborators_menu.add_collaborator_description'),
            icon        = 'fa-solid fa-user-plus',
            onSelect    = function()
                local input = lib.inputDialog(locale('collaborators_menu.add_collaborator_title'), {
                    {
                        type        = 'input',
                        label       = locale('collaborators_menu.add_collaborator_prompt'),
                        required    = true,
                        placeholder = locale('collaborators_menu.add_collaborator_placeholder'),
                        icon        = 'fa-solid fa-id-badge',
                    },
                    {
                        type        = 'checkbox',
                        label       = locale('collaborators_menu.add_to_all_facilities_label'),
                        description = locale('collaborators_menu.add_to_all_facilities_description'),
                        default     = false,
                    }
                })

                if input and input[1] then
                    local collaboratorIdentifier = input[1]
                    local addToAll                = input[2]
                    TriggerServerEvent('sd-beekeeping:addCollaborator', hiveId, collaboratorIdentifier, addToAll)
                end
            end
        }
    end

    -- 4) Back button
    collaboratorMenuOptions[#collaboratorMenuOptions+1] = {
        title    = locale('misc.return_to_menu'),
        icon     = 'arrow-left',
        onSelect = function()
            if buildingType == "hive" then
                TriggerEvent('sd-beekeeping:openBeeHive', { id = hiveId })
            else
                TriggerEvent('sd-beekeeping:openBeeHouse', { id = hiveId })
            end
        end
    }

    -- register & show
    lib.registerContext({
        id      = 'sdbeekeeping_'..buildingType..'_collaborators_menu',
        title   = locale('collaborators_menu.collaborators_menu_title'),
        options = collaboratorMenuOptions,
    })
    lib.showContext('sdbeekeeping_'..buildingType..'_collaborators_menu')
end

openRemoveCollaboratorConfirmMenu = function(hiveId, collaborator)
    local input = lib.inputDialog(locale('collaborators_menu.remove_collaborator_title'), {
        {
            type = 'checkbox',
            label = locale('collaborators_menu.remove_from_all_facilities_label'),
            description = locale('collaborators_menu.remove_from_all_facilities_description'),
            default = false,
        }
    })

    if input then
        local removeFromAll = input[1]
        TriggerServerEvent('sd-beekeeping:removeCollaborator', hiveId, collaborator, removeFromAll)
    end
end

openMaintenanceMenu = function(hData, repairCost, canRepair, originalData, buildingType)
    local maintenanceMenuOptions = {
        {
            title = locale('maintenance_menu.durability_status_title'),
            description = locale('maintenance_menu.durability_status_description', {durability = hData.durability or 100}),
            icon = 'fa-solid fa-hammer',
            progress = hData.durability or 100
        },
        {
            title = locale('maintenance_menu.repair_hive_title'),
            description = locale('maintenance_menu.repair_hive_description', {repairCost = repairCost}),
            icon = 'fa-solid fa-wrench',
            disabled = not canRepair,
            onSelect = function()
                if canRepair then
                    local input = lib.inputDialog(locale('maintenance_menu.repair_hive_input_title'), {
                        {
                            type = 'slider',
                            min = 1,
                            max = 100 - (hData.durability or 100),
                            step = 1,
                            icon = 'fa-solid fa-hashtag',
                            label = locale('maintenance_menu.repair_hive_input_description', {costPerUnit = Beekeeping.Expiry.RepairCostPerOne})
                        }
                    })

                    if input then
                        local repairAmount = tonumber(input[1])
                        local totalCost = repairAmount * Beekeeping.Expiry.RepairCostPerOne
                        openRepairConfirmationMenu(hData.id, repairAmount, totalCost, originalData, buildingType)
                    end
                end
            end
        },
        {
            title = locale('maintenance_menu.return_to_hive_menu'),
            icon = 'fa-solid fa-arrow-left',
            onSelect = function()
                if buildingType == "hive" then
                    openBeeHive(originalData)
                elseif buildingType == "house" then
                    openBeeHouseMenu(originalData)
                end
            end
        }
    }

    -- Register and show the maintenance menu
    lib.registerContext({
        id = 'sdbeekeeping_hive_maintenance_menu',
        title = locale('maintenance_menu.title'),
        options = maintenanceMenuOptions,
    })
    lib.showContext('sdbeekeeping_hive_maintenance_menu')
end

openRepairConfirmationMenu = function(hiveId, repairAmount, totalCost, originalData)
    local confirmMenuOptions = {
        {
            title = locale('maintenance_menu.confirm_repair'),
            description = locale('maintenance_menu.confirm_repair_description', {repairAmount = repairAmount, totalCost = totalCost}),
            icon = 'fa-solid fa-check',
            onSelect = function()
                -- Trigger a server event to handle the repair
                TriggerServerEvent('sd-beekeeping:repairFacility', hiveId, repairAmount, totalCost)
                if buildingType == "hive" then
                    openBeeHive(originalData)
                elseif buildingType == "house" then
                    openBeeHouseMenu(originalData)
                end
            end
        },
        {
            title = locale('maintenance_menu.cancel_repair'),
            icon = 'fa-solid fa-times',
            onSelect = function()
                if buildingType == "hive" then
                    openBeeHive(originalData)
                elseif buildingType == "house" then
                    openBeeHouseMenu(originalData)
                end
            end
        }
    }

    lib.registerContext({
        id = 'sdbeekeeping_hive_repair_confirmation_menu',
        title = locale('maintenance_menu.confirm_repair_title'),
        options = confirmMenuOptions,
    })
    lib.showContext('sdbeekeeping_hive_repair_confirmation_menu')
end

WithdrawProductDialog = function(id, type, max, originalData, honeyType, hData)
    lib.hideContext()
    local title
    if type == 'honey' then 
        title = locale('hives.withdraw_honey_with_type', {honeyType = Beekeeping.HoneyTypes[honeyType].displayName or 'Bee Honey'})
    elseif type == 'wax' then 
        title = locale('hives.withdraw_wax') 
    end

    local input = lib.inputDialog(title, {
        {
            type = 'slider',
            min = 1,
            max = max,
            step = 1,
            icon = 'fa-solid fa-hashtag'
        }
    })

    if input then
        DamagePlayerFromAggression(hData)
        TriggerServerEvent('sd-beekeeping:withdrawProduct', id, type, input[1])
        Wait(50)
        openBeeHive(originalData)
    end
end