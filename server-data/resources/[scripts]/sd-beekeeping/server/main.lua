local locale = SD.Locale.T
local beekeepingData = {} -- Table to store beekeeping data
local temporaryLosses = {} --- Tracks infection progression, severity, and bee deaths without storing these temporary losses in the database.
local ownerHives = {} -- Sub-Table of beekeepingData to store owners and collaborators
local hiveTypeIndex = { hives = {}, houses = {} } -- Sub-Table of beekeepingData to store facility types and use them to update main data.
local allHives = {} -- A table to store all hive and house IDs in one place
local cachedFormattedData = {} -- Cache formatted data for ObjectList
local beekeepingDataLoaded = false -- Variable to track if data is loaded or not
local logConfig = require("server/logs") -- logs.lua in this resource
local shop = {} -- stores relevant shop data for events/functions
SD.Logger.Setup(logConfig.logs) -- initialize SD.Logger with logConfig config

-- Build quick lookup tables after defining Beekeeping.Shop.BuyItems/SellItems:
shop.buyPriceMap = {}
for _, def in ipairs(Beekeeping.Shop.BuyItems) do
    shop.buyPriceMap[def.product] = def.price
end

shop.sellPriceMap = {}
for _, def in ipairs(Beekeeping.Shop.SellItems) do
    shop.sellPriceMap[def.product] = def.price
end

-- Event to set the location of the beekeeper when resource starts
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
		math.randomseed(os.time())
        GlobalState.BeekeeperLocation = Beekeeping.Beekeeper.Location[math.random(#Beekeeping.Beekeeper.Location)]

    end
end)

-- Helper function to format Product Name
local FormatProductName = function(product)
    return product:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end):gsub("-", " ")
end

-- Parses a raw `citizenid` column (either `"abc123"` or `{"id":"abc123","name":"Sam"}`)  
local ParseOwner = function(raw)
  if not raw or raw == "" then return nil end
  local ok, dec = pcall(json.decode, raw)
  if ok and type(dec)=="table" and dec.id then
    return { id = dec.id, name = dec.name }
  else
    return { id = raw, name = nil }
  end
end

-- Parses a raw `collaborators` JSON array of strings or objects  
local ParseCollaborators = function(raw)
  local out = {}
  if not raw or raw=="null" then return out end

  local ok, dec = pcall(json.decode, raw)
  if not ok or type(dec)~="table" then
    return out
  end

  for _, e in ipairs(dec) do
    if type(e)=="table" and e.id then
      table.insert(out, { id = e.id,name = e.name })
    elseif type(e)=="string" then
      table.insert(out, { id = e, name = nil })
    end
  end

  return out
end

-- Beekeeper Buying/Selling Logic
RegisterNetEvent('sd-beekeeping:buyProduct', function(product, quantity)
    local src = source
    local unitPrice = shop.buyPriceMap[product]
    if not unitPrice then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.invalid_product'), 'error')
        return
    end

    local cost = unitPrice * quantity
    local cashFunds = SD.Money.GetPlayerAccountFunds(src, 'money', cost)
    if cashFunds >= cost then
        SD.Money.RemoveMoney(src, 'cash', cost)
    else
        local bankFunds = SD.Money.GetPlayerAccountFunds(src, 'bank', cost)
        if bankFunds >= cost then
            SD.Money.RemoveMoney(src, 'bank', cost)
        elseif (cashFunds + bankFunds) >= cost then
            SD.Money.RemoveMoney(src, 'cash', cashFunds)
            SD.Money.RemoveMoney(src, 'bank', cost - cashFunds)
        else
            TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_money'), 'error')
            return
        end
    end

    SD.Inventory.AddItem(src, product, quantity)
    TriggerClientEvent('sd_bridge:notification', src, locale('notifications.purchase_success', {product = FormatProductName(product), quantity = quantity}), 'success')
    if logConfig.logs.events.buy_product then
        local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
        SD.Logger.Log(src, "buy_product", locale('logs.buy_product', {source = src, srcName = srcName, charName = charName, identifier = citizenId, quantity = quantity, product = FormatProductName(product), cost = cost}))
    end
end)

-- Selling Items
RegisterNetEvent('sd-beekeeping:sellProduct', function(product, quantity)
    local src = source
    local unitPrice = shop.sellPriceMap[product]
    if not unitPrice then
        TriggerClientEvent('sd_bridge:notification', src, 'Unknown product.', 'error')
        return
    end

    if SD.Inventory.HasItem(src, product) >= quantity then
        local totalPay = unitPrice * quantity
        SD.Inventory.RemoveItem(src, product, quantity)
        SD.Money.AddMoney(src, 'cash', totalPay)
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.sell_success', {product = FormatProductName(product), quantity = quantity}), 'success')
        if logConfig.logs.events.sell_product then
            local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
            SD.Logger.Log(src, "sell_product", locale('logs.sell_product', {source = src, srcName = srcName, charName = charName, identifier = citizenId, quantity = quantity, product = FormatProductName(product), price = totalPay}))
        end
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_items'), 'error')
    end
end)

-- [[ USABLE ITEMS ]]
-- Beehouse
SD.Inventory.RegisterUsableItem(Beekeeping.Items.HouseItem, function(source)
    TriggerClientEvent('sd-beekeeping:objects:client:SpawnObject', source, {
        object = Beekeeping.Props.bee_house,
        hive_type = 'house',
        distance = Beekeeping.SpawnRange,
        item = Beekeeping.Items.HouseItem,
        citizenid = SD.GetIdentifier(source)
    })
end)

-- Beehive
SD.Inventory.RegisterUsableItem(Beekeeping.Items.HiveItem, function(source)
    TriggerClientEvent('sd-beekeeping:objects:client:SpawnObject', source, {
        object = Beekeeping.Props.bee_hive,
        hive_type = 'hive',
        distance = Beekeeping.SpawnRange,
        item = Beekeeping.Items.HiveItem,
        citizenid = SD.GetIdentifier(source)
    })
end)

-- Remove item
RegisterNetEvent('sd-beekeeping:server:removeItem', function(item, amount)
    local isValid = item == 'bee-house' or item == 'bee-hive'
    if not isValid then return end

    local src = source

    if logConfig.logs.events.remove_item then
        local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
        SD.Logger.Log(src, "remove_item", locale('logs.remove_item', { source=src, srcName=srcName, charName=charName, identifier=citizenId, amount=amount, item=item }))
    end

    SD.Inventory.RemoveItem(src, item, amount)
end)

-- Function to update the cache for a specific hive or house
local UpdateCache = function(id)
    local data = beekeepingData[id]
    if data then
        local blipData = {}
        if data.data then
            blipData = data.data.blipData or {}
        end
        cachedFormattedData[id] = {
            id = data.id,
            coords = data.coords,
            hive_type = data.hive_type,
            options = { SpawnRange = data.options and data.options.SpawnRange or nil },
            blipData = blipData
        }
    else
        cachedFormattedData[id] = nil
    end
end

-- Function to update the honey production multiplier based on the number of workers
local UpdateHoneyMultiplier = function(hiveId)
    local hiveData = beekeepingData[hiveId]
    if hiveData and hiveData.hive_type == 'hive' then
        local workers = hiveData.data.workers or 0
        local level = math.floor(workers / Beekeeping.WorkerThreshold)
        hiveData.honeyMultiplier = Beekeeping.Multipliers[level] or 1.0
        hiveData.adjustedHoneyTime = math.ceil(Beekeeping.Hives.HoneyTime / hiveData.honeyMultiplier)
    end
end

CreateThread(function()
    local success, err = pcall(function()
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `sd_beekeeping` (
              `id`           INT(11) NOT NULL AUTO_INCREMENT,
              `hive_type`    VARCHAR(50) NOT NULL,
              `coords`       VARCHAR(255) NOT NULL,
              `options`      JSON        NOT NULL,
              `data`         JSON        DEFAULT NULL,
              `citizenid`    VARCHAR(255) DEFAULT NULL,
              `collaborators` JSON       DEFAULT NULL,
              `durability`   INT         DEFAULT NULL,
              PRIMARY KEY (`id`) USING BTREE
            ) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]])
    end)
    if not success then
        print("Error creating sd_beekeeping table:", err)
    end
end)
local LoadBeekeepingData = function()
  Wait(5000)
  MySQL.Async.fetchAll('SELECT * FROM sd_beekeeping', {}, function(results)
    for _, v in ipairs(results) do
      local ok, coords  = pcall(json.decode, v.coords)
      local ok2, options= pcall(json.decode, v.options or 'null')
      local ok3, data   = pcall(json.decode, v.data    or 'null')
      if data and data.aggression==nil then
        data.aggression = Beekeeping.Aggression.DefaultLevel
      end

      local owner        = ParseOwner(v.citizenid)
      local collaborators= ParseCollaborators(v.collaborators)

      local hive = {
        id             = v.id,
        hive_type      = v.hive_type,
        coords         = ok and coords or {x=0,y=0,z=0,w=0},
        options        = ok2 and options or nil,
        data           = ok3 and data or nil,
        owner          = owner,
        collaborators  = collaborators,
        durability     = v.durability or 100,
      }

      local decayCfg = Beekeeping.Expiry.DecaySettings[hive.hive_type]
      hive.nextUpdate = GetGameTimer() + (decayCfg.DecayInterval * 60000)

      beekeepingData[v.id] = hive
      ownerHives[owner.id] = ownerHives[owner.id] or {}
      ownerHives[owner.id][v.id] = true
      allHives[v.id] = true
      UpdateCache(v.id)

      if hive.hive_type=='hive' then
        hiveTypeIndex.hives[v.id] = true
        UpdateHoneyMultiplier(v.id)
      else
        hiveTypeIndex.houses[v.id] = true
      end
    end

    print(("sd-beekeeping: Loaded %d beekeeping objects."):format(#results))
    beekeepingDataLoaded = true
  end)
end

-- Event handler for creating new beekeeping object (hive or house)
--- Event: sd-beekeeping:objects:server:CreateNewObject
--- @param hive_type string The type of hive ('hive' or 'house')
--- @param coords table The coordinates where the object is placed
--- @param options table The options for the object
--- @param defaultData table The default data for the hive
--- @param citizenid string The identifier of the player placing the object
RegisterNetEvent("sd-beekeeping:objects:server:CreateNewObject", function(hive_type, coords, options, defaultData, _)
    local src = source

    if (hive_type ~= 'hive' and hive_type ~= 'house')or type(coords) ~= 'table' or not coords.x or not coords.y or not coords.z or not coords.w
    or type(options) ~= 'table'
    or type(defaultData) ~= 'table' then

        TriggerClientEvent('sd_bridge:notification', src, 'Invalid parameters provided.', 'error')
        return
    end

    if hive_type == 'hive' then
        local ht = defaultData.honeyType or 'basic'
        if not Beekeeping.HoneyTypes[ht] then
            defaultData.honeyType = 'basic'
        end
    end

    local cid      = SD.GetIdentifier(src)
    local ownerObj = {
        id   = cid,
        name = SD.Name.GetFullName(src)
    }

    local res = MySQL.query.await([[INSERT INTO sd_beekeeping(hive_type, coords, options, data, citizenid, durability)VALUES (?,         ?,      ?,       ?,    ?,         ?)]], {hive_type,json.encode(coords),json.encode(options),json.encode(defaultData),json.encode(ownerObj),100})

    if not res or not res.insertId then
        TriggerClientEvent('sd_bridge:notification', src, 'Failed to create object.', 'error')
        return
    end

    local newHive = {
        id               = res.insertId,
        hive_type        = hive_type,
        coords           = coords,
        options          = options,
        data             = defaultData,
        owner            = ownerObj,
        collaborators    = {},
        durability       = 100,
        nextUpdate       = GetGameTimer() + (Beekeeping.Expiry.DecaySettings[hive_type].DecayInterval * 60000),
        adjustedHoneyTime= Beekeeping.Hives.HoneyTime,
    }
    beekeepingData[newHive.id] = newHive

    ownerHives[cid] = ownerHives[cid] or {}
    ownerHives[cid][newHive.id] = true
    allHives[newHive.id] = true
    UpdateCache(newHive.id)

    if hive_type == 'hive' then
        hiveTypeIndex.hives[newHive.id] = true
    else
        hiveTypeIndex.houses[newHive.id] = true
    end

    TriggerClientEvent("sd-beekeeping:objects:client:AddObject", -1, {
        id        = newHive.id,
        hive_type = hive_type,
        coords    = coords,
        options   = { SpawnRange = options.SpawnRange or nil }
    })

    if logConfig.logs.events.create_object then
        local srcName  = GetPlayerName(src)
        local charName = SD.Name.GetFullName(src)
        SD.Logger.Log(src, "create_object", locale('logs.create_object', {source    = src,srcName   = srcName,charName  = charName,identifier= cid,hive_type = hive_type,id        = newHive.id}))
    end
end)

--- Callback to request objects using cached data
lib.callback.register("sd-beekeeping:objects:server:RequestObjects", function(source)
    Wait(6000)
    local player = Player(source)
    if not Beekeeping.LoadOnStart and player.state.beekeepingInit then
        return nil
    end

    Player(source).state.beekeepingInit = true
    if not Beekeeping.LoadOnStart and logConfig.logs.events.request_objects then
        local srcName, charName, citizenId = GetPlayerName(source), SD.Name.GetFullName(source), SD.GetIdentifier(source)
        SD.Logger.Log(source, "request_objects", locale('logs.request_objects', { source=source, srcName=srcName, charName=charName, identifier=citizenId }))
    end

    return cachedFormattedData
end)

-- Delete object event
local DeleteBeeObject = function(objectid)
    local src = source
    if objectid > 0 then
        MySQL.query.await('DELETE FROM sd_beekeeping WHERE id = ?', {objectid})
        beekeepingData[objectid] = nil
        TriggerClientEvent("sd-beekeeping:objects:client:receiveObjectDelete", -1, objectid)
        cachedFormattedData[objectid] = nil

        if logConfig.logs.events.delete_object then
            local objectid = objectid
            SD.Logger.Log(nil, "delete_object", locale('logs.delete_object', { id=objectid }))
        end
    end
end

-- Function to update a single hive's collaborators and persist changes to the database
-- @param hiveData   table     the hive entry
-- @param action     string    "add" or "remove"
-- @param collabId   string    the collaborator’s citizen id
-- @param collabSrc  number    the collaborator’s player source (for name lookup)
-- @param src        number    the owner’s player source who initiated the change
-- @param isSingle   boolean   whether this is for a single hive (vs. all)
-- @param callback   function(success:boolean, message:string, type:string)
local UpdateHiveCollaborators = function(hiveData, action, collabId, collabSrc, src, isSingle, callback)
    hiveData.collaborators = hiveData.collaborators or {}

    local collabObj = {
        id   = collabId,
        name = collabSrc and SD.Name.GetFullName(collabSrc) or nil
    }

    -- Find existing collaborator index
    local idx
    for i, e in ipairs(hiveData.collaborators) do
        if e.id == collabId then
            idx = i
            break
        end
    end

    if action == "add" then
        if not idx then
            table.insert(hiveData.collaborators, collabObj)
        else
            return callback(false, locale('notifications.collaborator_already_added'))
        end

    elseif action == "remove" then
        if idx then
            table.remove(hiveData.collaborators, idx)
        else
            return callback(false, locale('notifications.collaborator_not_found'))
        end

    else
        return callback(false, 'Invalid action specified.')
    end

    local serialized = json.encode(hiveData.collaborators)
    MySQL.Async.execute(
        'UPDATE sd_beekeeping SET collaborators = ? WHERE id = ?',
        { serialized, hiveData.id },
        function(affected)
            if affected > 0 then
                local key = action == "add"
                    and (isSingle and "added_single" or "added_all")
                    or (isSingle and "removed_single" or "removed_all")
                local msg = locale('notifications.collaborator_' .. key, { identifier = collabId })
                callback(true, msg, 'success')
            else
                callback(false, locale('notifications.database_update_failed'))
            end
        end
    )
end

--- Manages adding or removing a collaborator across one or multiple hives
-- @param action         string   "add" or "remove"
-- @param hiveId         number   the hive ID (ignored if applyToAll)
-- @param ownerId        string   the owner's citizen id
-- @param collaboratorId string   the collaborator's citizen id
-- @param applyToAll     boolean  whether to apply to all of the owner's hives
-- @param src            number   the owner’s player source who initiated this
-- @param collabSrc      number   the collaborator’s player source (for name lookup)
local ManageCollaborator = function(action, hiveId, ownerId, collaboratorId, applyToAll, src, collabSrc)
    local hivesToUpdate = {}

    if applyToAll then
        for id in pairs(ownerHives[ownerId] or {}) do
            local h = beekeepingData[id]
            if h then
                table.insert(hivesToUpdate, h)
            end
        end
        if #hivesToUpdate == 0 then
            return TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_hives_found'), 'error')
        end
    else
        local hiveData = beekeepingData[hiveId]
        if not hiveData then
            return TriggerClientEvent('sd_bridge:notification', src, locale('notifications.hive_not_found'), 'error')
        end
        local realOwner = hiveData.owner and hiveData.owner.id
        if ownerId ~= realOwner then
            return TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_owner_of_hive'), 'error')
        end
        table.insert(hivesToUpdate, hiveData)
    end

    if action == "add" and Beekeeping.LimitCollaborators.Enable then
        local count = 0
        for _, h in pairs(beekeepingData) do
            for _, c in ipairs(h.collaborators or {}) do
                if c.id == collaboratorId then
                    count = count + 1
                    break
                end
            end
        end
        local slots = Beekeeping.LimitCollaborators.Max - count
        if slots <= 0 then
            return TriggerClientEvent('sd_bridge:notification', src, locale('notifications.collaborator_limit_reached'), 'error')
        end
    end

    local total, successCount, failCount = #hivesToUpdate, 0, 0
    local errors = {}

    local function onComplete(success, msg, ntype)
        if success then
            successCount = successCount + 1
        else
            failCount = failCount + 1
            table.insert(errors, msg)
        end
        if successCount + failCount == total then
            if applyToAll then
                if successCount > 0 then
                    TriggerClientEvent('sd_bridge:notification', src,locale('notifications.collaborator_updated_all',{ success = successCount, total = total }),'success')
                end
                if failCount > 0 then
                    TriggerClientEvent('sd_bridge:notification', src,locale('notifications.collaborator_update_partial',{ failed = failCount, messages = table.concat(errors, "; ") }),'error')
                end
            else
                if successCount > 0 then
                    TriggerClientEvent('sd_bridge:notification', src, msg, ntype)
                elseif failCount > 0 then
                    TriggerClientEvent('sd_bridge:notification', src, table.concat(errors, "; "), 'error')
                end
            end
        end
    end

    for _, hiveData in ipairs(hivesToUpdate) do
        UpdateHiveCollaborators(hiveData, action, collaboratorId, collabSrc, src, not applyToAll, onComplete)
    end
end

RegisterNetEvent('sd-beekeeping:toggleBlip', function(hiveId, newState)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    local hive = beekeepingData[hiveId]
    if not hive or not hive.data then
        TriggerClientEvent('sd_bridge:notification', src, "Hive not found.", 'error')
        return
    end

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
          if c.id == citizenId then isCollab = true break end
        end
      
        if citizenId ~= ownerId and not isCollab then
          TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
          return
        end
      end

    hive.data.blipData = hive.data.blipData or {}
    hive.data.blipData[citizenId] = newState

    local serializedData = json.encode(hive.data)
    MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('sd-beekeeping:client:UpdateBlip', src, hiveId, newState, hive.coords, hive.hive_type)
        end
    end)

    if logConfig.logs.events.toggle_blip then
        local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
        SD.Logger.Log(src, "toggle_blip", locale('logs.toggle_blip', { source=src, srcName=srcName, charName=charName, identifier=citizenId, id=hiveId, state=tostring(newState) }))
    end
end)

-- Event handler for adding a collaborator
RegisterNetEvent('sd-beekeeping:addCollaborator', function(hiveId, collaboratorInput, applyToAll)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    local collaboratorId = SD.GetIdentifier(tonumber(collaboratorInput))

    if citizenId == collaboratorId then 
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.cannot_add_self'), 'error')
        return 
    end

    if collaboratorId and collaboratorId ~= "" then
        ManageCollaborator("add", hiveId, citizenId, collaboratorId, applyToAll, src, tonumber(collaboratorInput))
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.collaborator_not_found_or_offline'), 'error')
    end
end)

-- Event handler for removing a collaborator
RegisterNetEvent('sd-beekeeping:removeCollaborator', function(hiveId, collaboratorIdentifier, applyToAll)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    ManageCollaborator("remove", hiveId, citizenId, collaboratorIdentifier, applyToAll, src)
end)

local RemoveFromData = function(id)
    if beekeepingData[id] then beekeepingData[id] = nil end
end

RegisterNetEvent('sd-beekeeping:repairFacility', function(hiveId, repairAmount)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    local pRepairAmount = repairAmount

    -- Fetch hive data
    local hiveData = beekeepingData[hiveId]
    if not hiveData then 
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.hive_not_found'), 'error')
        return 
    end

    if type(pRepairAmount) ~= 'number' or pRepairAmount <= 0 then
        TriggerClientEvent('sd_bridge:notification', src, 'Invalid repair amount', 'error')
        return
    end

    local maxRepairableAmount = 100 - hiveData.durability
    if maxRepairableAmount <= 0 then
        TriggerClientEvent('sd_bridge:notification', src, 'Hive is already fully repaired', 'error')
        return
    end

    if pRepairAmount > maxRepairableAmount then
        -- DropPlayer(src, 'Attempted to repair more than possible.')
        return
    end

    if Beekeeping.LockAccess then
        local ownerId = hiveData.owner.id
        local isCollab = false
        for _, c in ipairs(hiveData.collaborators or {}) do
        if c.id == citizenId then isCollab = true; break end
        end
    
    if citizenId ~= ownerId and not isCollab then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_permission_for_repair'), 'error')
        return
        end
    end

    local repairCost = repairAmount * Beekeeping.Expiry.RepairCostPerOne
    local hasMoney = SD.Money.GetPlayerAccountFunds(src, 'money', repairCost)

    if hasMoney >= repairCost then
        SD.Money.RemoveMoney(src, 'cash', repairCost)
        hiveData.durability = math.min(hiveData.durability + repairAmount, 100)

        if logConfig.logs.events.repair_facility then
            local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
            SD.Logger.Log(src, "repair_facility", locale('logs.repair_facility', { source=src, srcName=srcName, charName=charName, identifier=citizenId, id=hiveId, amount=repairAmount }))
        end
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.insufficient_funds_for_repair'), 'error')
    end
end)

local UpdateQueensAndWorkers = function(data)
    local spawnQueen = math.random(1, 100)
    local queens, bees, workers = 0, 0, 0

    if spawnQueen < Beekeeping.House.QueenSpawnChance and data.queens < Beekeeping.House.MaxQueens then
        queens = type(Beekeeping.House.QueensPerCapture) == 'number' and Beekeeping.House.QueensPerCapture or math.random(Beekeeping.House.QueensPerCapture[1], Beekeeping.House.QueensPerCapture[2])
        queens = math.min(queens, Beekeeping.House.MaxQueens - data.queens)
        data.queens = data.queens + queens
    end

    if data.workers < Beekeeping.House.MaxWorkers then
        bees = type(Beekeeping.House.BeesPerCapture) == 'number' and Beekeeping.House.BeesPerCapture or math.random(Beekeeping.House.BeesPerCapture[1], Beekeeping.House.BeesPerCapture[2])
        workers = bees - queens
        workers = math.min(workers, Beekeeping.House.MaxWorkers - data.workers)
        data.workers = data.workers + workers
    end
end

local UpdateHoneyAndWax = function(data)
    local honeyLevel = math.random(Beekeeping.Hives.HoneyPerTime[1], Beekeeping.Hives.HoneyPerTime[2])
    local honeyToAdd = math.min(honeyLevel, Beekeeping.Hives.MaxHoney - (data.honey or 0))
    data.honey = (data.honey or 0) + honeyToAdd

    if math.random(1, 100) <= Beekeeping.Hives.ChanceOfWax then
        local waxLevel = math.random(Beekeeping.Hives.WaxPerTime[1], Beekeeping.Hives.WaxPerTime[2])
        local waxToAdd = math.min(waxLevel, Beekeeping.Hives.MaxWax - (data.wax or 0))
        data.wax = (data.wax or 0) + waxToAdd
    end
end

--- Handles production progression for both houses and hives using hiveTypeIndex for efficient iteration.
--- Houses and hives are iterated separately for optimal performance.
local UpdateHousesProgress = function()
    for id in pairs(hiveTypeIndex.houses) do
        local v = beekeepingData[id]
        if v and v.data then
            local data = v.data
            if data.time and data.queens and data.workers then
                if not (data.queens >= Beekeeping.House.MaxQueens and data.workers >= Beekeeping.House.MaxWorkers) then
                    if data.time >= Beekeeping.House.CaptureTime then
                        UpdateQueensAndWorkers(data)
                        data.time = 0
                    else
                        data.time = data.time + 1
                    end
                end
            end
        end
    end

    for id in pairs(hiveTypeIndex.hives) do
        local v = beekeepingData[id]
        if v and v.data then
            local data = v.data
            if data.haveQueen and data.haveWorker then
                if not ((data.honey or 0) >= Beekeeping.Hives.MaxHoney and (data.wax or 0) >= Beekeeping.Hives.MaxWax) then
                    local requiredTime = v.adjustedHoneyTime
                    if data.infected then
                        requiredTime = requiredTime * (Beekeeping.Infection.ProductionDelayMultiplier or 2.0)
                    end

                    if data.time and data.time >= requiredTime then
                        UpdateHoneyAndWax(data)
                        data.time = 0
                    elseif data.time then
                        data.time = data.time + 1
                    end
                end
            end
        end
    end
end

CreateThread(function()
    LoadBeekeepingData()
    while true do
        Wait(1250) UpdateHousesProgress()
    end
end)

--- Function to update durability of hives/houses using the allHives table
local UpdateDurability = function()
    local currentTime = GetGameTimer()

    for id in pairs(allHives) do
        local hive = beekeepingData[id]
        if hive and hive.durability and hive.durability > 0 then
            local decayRate = Beekeeping.Expiry.DecaySettings[hive.hive_type].DecayRate
            local decayInterval = Beekeeping.Expiry.DecaySettings[hive.hive_type].DecayInterval

            if not hive.nextUpdate or currentTime >= hive.nextUpdate then
                hive.durability = hive.durability - decayRate

                if hive.durability <= 0 then
                    MySQL.Async.execute('DELETE FROM sd_beekeeping WHERE id = ?', {id})
                    RemoveFromData(id)
                    TriggerClientEvent("sd-beekeeping:objects:client:receiveObjectDelete", -1, id)
                else
                    hive.nextUpdate = currentTime + decayInterval * 60000
                end
            end
        end
    end
end

if Beekeeping.Expiry.EnableExpiration then
    CreateThread(function()
        while true do
            UpdateDurability()
            Wait(60000)
        end
    end)
end

-- chance-based aggression calculation
local CalculateAggression = function(hive)
    local cfg  = Beekeeping.Aggression
    if not cfg.Enable then
        return hive.data.aggression or cfg.DefaultLevel
    end

    local data   = hive.data or {}
    local lvl    = data.aggression or cfg.DefaultLevel

    local chance = cfg.Chance.Base
    chance = chance + (data.workers or 0) * cfg.Chance.PerWorker

    if data.infected and data.infectionSeverity then
        chance = chance + data.infectionSeverity * cfg.Chance.PerSeverity
    end

    if hive.hive_type == 'hive' then
        if data.haveQueen
        and data.haveWorker
        and (data.honey or 0) >= (Beekeeping.Hives.MaxHoney or 0) then
            chance = chance + cfg.Chance.FullHiveBonus
        end

    elseif hive.hive_type == 'house' then
        if (data.queens or 0) >= Beekeeping.House.MaxQueens
        and (data.workers or 0) >= Beekeeping.House.MaxWorkers then
            chance = chance + cfg.Chance.FullHouseBonus
        end
    end

    chance = math.min(chance, cfg.Chance.Max)
    if math.random(100) <= chance then
        lvl = math.min(lvl + 1, #cfg.Levels)
    end

    return lvl
end

CreateThread(function()
    if not Beekeeping.Aggression.Enable then return end
    while not beekeepingDataLoaded do Wait(500) end

    local ms = Beekeeping.Aggression.UpdateInterval * 60000
    local defaultLvl = Beekeeping.Aggression.DefaultLevel

    while true do
        Wait(ms)

        for id, hive in pairs(beekeepingData) do
            local data = hive.data or {}

            local isEmpty = false
            if hive.hive_type == 'hive' then
                isEmpty = ((data.workers or 0) == 0) and (not data.haveQueen)
            else
                isEmpty = ((data.queens or 0) == 0) and ((data.workers or 0) == 0)
            end

            local newLvl
            if isEmpty then
                newLvl = defaultLvl
            else
                newLvl = CalculateAggression(hive)
            end

            if data.aggression ~= newLvl then
                data.aggression = newLvl
            end
        end
    end
end)

-- Use a smoker to reduce aggression on a hive/house
RegisterNetEvent('sd-beekeeping:server:useSmoker', function(hiveId)
    local src       = source
    local citizenId = SD.GetIdentifier(src)
    local hive      = beekeepingData[hiveId]

    if not hive then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.hive_not_found'), 'error')
        return
    end

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
            if c.id == citizenId then
                isCollab = true
                break
            end
        end

        if citizenId ~= ownerId and not isCollab then
            TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_permission'), 'error')
            return
        end
    end

    local item = Beekeeping.Items.SmokerItem
    if SD.Inventory.HasItem(src, item) < 1 then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_smoker_item'), 'error')
        return
    end

    local cfg  = Beekeeping.Aggression
    local data = hive.data or {}
    local lvl  = data.aggression or cfg.DefaultLevel
    local newLvl

    if cfg.SmokerReduceBy == "all" then
        newLvl = cfg.DefaultLevel
    else
        newLvl = math.max(cfg.DefaultLevel, lvl - cfg.SmokerReduceBy)
    end

    data.aggression = newLvl

    TriggerClientEvent('sd_bridge:notification', src, locale('notifications.smoker_success', { level = newLvl }), 'success')

    if math.random(100) <= cfg.SmokerRemoveChance then
        SD.Inventory.RemoveItem(src, item, 1)
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.smoker_broken'), 'error')
    end
end)

--- Attempts to treat the hive infection using a defined treatment item.
RegisterNetEvent('sd-beekeeping:treatHive', function(hiveId)
    local src = source
    local hive = beekeepingData[hiveId]
    local citizenId = SD.GetIdentifier(src)

    if not hive or not hive.data then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.hive_not_found'), 'error')
        return
    end

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
        if c.id == citizenId then isCollab = true; break end
    end
    
    if citizenId ~= ownerId and not isCollab then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return
        end
    end

    if not hive.data.infected then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.hive_not_infected'), 'error')
        return
    end

    local treatmentItem = Beekeeping.Items.TreatmentItem or 'bee-treatment'
    local hasItem = SD.Inventory.HasItem(src, treatmentItem)
    if hasItem > 0 then
        SD.Inventory.RemoveItem(src, treatmentItem, 1)
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.treatment_item_not_found'), 'error')
        return
    end

    hive.data.infected = false
    hive.data.infectionTime = 0
    hive.data.infectionSeverity = 0
    local serializedData = json.encode(hive.data)
    MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})
    TriggerClientEvent('sd_bridge:notification', src, locale('notifications.hive_cured'), 'success')

    if logConfig.logs.events.treat_hive then
        local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
        SD.Logger.Log(src, "treat_hive", locale('logs.treat_hive', { source=src, srcName=srcName, charName=charName, identifier=citizenId, id=hiveId }))
    end
end)


--- Updates disease status of hives over time, using only severity levels for configuration.
local UpdateDiseaseProgress = function()
    local currentTime = os.time()
    local infectionConfig = Beekeeping.Infection
    local severityIncreaseSeconds = (infectionConfig.SeverityIncreaseInterval or 10) * 60
    local maxSeverity = #infectionConfig.SeverityLevels

    for hiveId in pairs(hiveTypeIndex.hives) do
        local hive = beekeepingData[hiveId]
        if hive and hive.data and infectionConfig.Enable then
            local data = hive.data
            temporaryLosses[hiveId] = temporaryLosses[hiveId] or {lostWorkers = 0, lostQueens = 0}

            local isShielded = (data.shieldUntil and currentTime < data.shieldUntil)
            if not isShielded then
                if not data.haveQueen or not data.haveWorker then
                    data.infected = false
                    data.infectionTime = 0
                    data.infectionSeverity = 0
                    local serializedData = json.encode(data)
                    MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})
                else
                    if not data.infected then
                        if math.random(1, 100) <= infectionConfig.InfectionChance then
                            data.infected = true
                            data.infectionTime = currentTime
                            data.infectionSeverity = 1
                            local serializedData = json.encode(data)
                            MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})
                        end
                    else
                        local timeSinceInfection = currentTime - data.infectionTime
                        if data.infectionSeverity < maxSeverity and severityIncreaseSeconds > 0 then
                            if timeSinceInfection > (data.infectionSeverity * severityIncreaseSeconds) then
                                data.infectionSeverity = data.infectionSeverity + 1
                                data.infectionTime = currentTime
                                local serializedData = json.encode(data)
                                MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})
                            end
                        end

                        local severityLevel = data.infectionSeverity
                        local severityConfig = infectionConfig.SeverityLevels[severityLevel]

                        if severityConfig then
                            local workerDeathChance = severityConfig.WorkerDeathChance
                            local workerDeathCountRange = severityConfig.WorkerDeathCountRange
                            local queenDeathChance = severityConfig.QueenDeathChance

                            if math.random(1, 100) <= workerDeathChance then
                                local killCount = math.random(workerDeathCountRange[1], workerDeathCountRange[2]) * severityLevel
                                killCount = math.min(killCount, data.workers or 0)
                                if killCount > 0 then
                                    data.workers = data.workers - killCount
                                    temporaryLosses[hiveId].lostWorkers = temporaryLosses[hiveId].lostWorkers + killCount
                                    if data.workers < Beekeeping.Hives.NeededWorkers then
                                        data.haveWorker = false
                                    end
                                    local serializedData = json.encode(data)
                                    MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})
                                end
                            end

                            if data.haveQueen and math.random(1, 100) <= queenDeathChance then
                                data.haveQueen = false
                                temporaryLosses[hiveId].lostQueens = temporaryLosses[hiveId].lostQueens + 1
                                local serializedData = json.encode(data)
                                MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})
                            end

                            if not data.haveQueen or not data.haveWorker then
                                data.infected = false
                                data.infectionTime = 0
                                data.infectionSeverity = 0
                                local serializedData = json.encode(data)
                                MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})
                            end
                        else
                            data.infected = false
                            data.infectionTime = 0
                            data.infectionSeverity = 0
                            local serializedData = json.encode(data)
                            MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})
                        end
                    end
                end
                if (data.workers or 0) == 0 and not data.haveQueen then
                    data.aggression = Beekeeping.Aggression.DefaultLevel
                    local serializedAgg = json.encode(data)
                    MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedAgg, hiveId})
                end
            end
        end
    end
end

CreateThread(function()
    if Beekeeping.Infection.Enable then 
        while true do
            Wait(Beekeeping.Infection.CheckInterval * 60000) 
            UpdateDiseaseProgress()
        end
    end
end)

RegisterNetEvent('sd-beekeeping:purchaseShield', function(hiveId, tierId)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    local hive = beekeepingData[hiveId]

    if not hive or not hive.data then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.hive_not_found'), 'error')
        return
    end

    if not Beekeeping.Infection.ShieldsEnabled then
        TriggerClientEvent('sd_bridge:notification', src, locale('hives.shields_disabled'), 'error')
        return
    end

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
        if c.id == citizenId then isCollab = true; break end
    end
    
    if citizenId ~= ownerId and not isCollab then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return
        end
    end

    if hive.data.infected then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.hive_infected_cannot_purchase_shield'), 'error')
        return
    end

    local tierConfig = Beekeeping.Infection.ProtectionTiers[tierId]
    if not tierConfig then
        TriggerClientEvent('sd_bridge:notification', src, 'Invalid protection tier selected.', 'error')
        return
    end

    local cost = tierConfig.cost
    local durationMinutes = tierConfig.duration

    local hasMoney = SD.Money.GetPlayerAccountFunds(src, 'money', cost)
    if hasMoney >= cost then
        SD.Money.RemoveMoney(src, 'cash', cost)

        local currentTime = os.time()
        hive.data.shieldUntil = currentTime + (durationMinutes * 60)

        local serializedData = json.encode(hive.data)
        MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, hiveId})

        TriggerClientEvent('sd_bridge:notification', src, locale('hives.upkeeper_purchased'), 'success')

        if logConfig.logs.events.purchase_shield then
            local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
            SD.Logger.Log(src, "purchase_shield", locale('logs.purchase_shield', { source=src, srcName=srcName, charName=charName, identifier=citizenId, tier=tierId, id=hiveId }))
        end
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_money'), 'error')
    end
end)

-- Function to save all beekeeping data.
local SaveAllBeekeepingData = function()
    print('Attempting to save all beekeeping data!')

    local queries = {}
    for id, hive in pairs(beekeepingData) do
        queries[#queries+1] = {
            query = 'UPDATE sd_beekeeping SET data = ?, collaborators = ?, durability = ? WHERE id = ?',
            values = { json.encode(hive.data), json.encode(hive.collaborators or {}), hive.durability or 100, id }
        }
    end

    -- Perform batch update in a single transaction
    MySQL.Async.transaction(queries, {}, function()
    end, function(error)
    end)
end

-- Evaluate the configured saving method and set up appropriate handlers
if Beekeeping.Saving.Method == 'interval' then
    -- Thread to periodically update the Database, saving all beekeeping data.
    CreateThread(function()
        while true do
            Wait(Beekeeping.Saving.Interval * 60000)  -- Use configured interval
            SaveAllBeekeepingData()
        end
    end)
elseif Beekeeping.Saving.Method == 'txadmin' then
    -- Event handler to save all beekeeping data on a server restart/shutdown using txAdmin
    AddEventHandler('txAdmin:events:serverShuttingDown', function()
        SaveAllBeekeepingData()  -- Call the function that saves all beekeeping data
    end)
end

-- Event handler for saving all data when the resource stops
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SaveAllBeekeepingData()

        if not Beekeeping.LoadOnStart then
            warn('Objects are set to load on player login.')
            warn('If you want to load objects on resource start, set "LoadOnStart" to true in the config.')
        end
    end
end)

-- Withdrawing Bee's from Houses
RegisterNetEvent('sd-beekeeping:withdrawBee', function(id, type, amount)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    local hive = beekeepingData[id]
    local withdrawAmount = math.abs(tonumber(amount) or 0)

    if not hive or not hive.data then 
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return 
    end

    local data = hive.data

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
        if c.id == citizenId then isCollab = true; break end
        end
    
    if citizenId ~= ownerId and not isCollab then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return
        end
    end

    if data[type] and data[type] >= amount then
        local item
        if type == 'queens' then item = Beekeeping.Items.QueenItem else item = Beekeeping.Items.WorkerItem end

        if SD.Inventory.CanCarry(src, tostring(item), withdrawAmount) then
            SD.Inventory.AddItem(src, tostring(item), withdrawAmount)
            data[type] = data[type] - withdrawAmount

            if (data.queens or 0) == 0 and (data.workers or 0) == 0 then
                data.aggression = Beekeeping.Aggression.DefaultLevel
            end

            local serializedData = json.encode(hive.data)
            
            MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, id}, function(affectedRows)

            if logConfig.logs.events.withdraw_bee then
                local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
                SD.Logger.Log(src, "withdraw_bee", locale('logs.withdraw_bee', { source=src, srcName=srcName, charName=charName, identifier=citizenId, beeType=type, amount=withdrawAmount, id=id }))
            end
        end)
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_inventory'), 'error')
    end
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_bees'), 'error')
    end
end)

-- Withdrawing Product from Hives
--- Event handler for withdrawing product from a hive
--- Event: sd-beekeeping:withdrawProduct
--- @param id number The hive ID
--- @param type string The product type ('honey' or 'wax')
--- @param amount number The amount to withdraw
RegisterNetEvent('sd-beekeeping:withdrawProduct', function(id, type, amount)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    local hive = beekeepingData[id]
    local withdrawAmount = math.abs(tonumber(amount) or 0)

    if not hive or not hive.data then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return
    end

    local data = hive.data

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
        if c.id == citizenId then isCollab = true; break end
        end
    
    if citizenId ~= ownerId and not isCollab then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return
        end
    end

    if data[type] and data[type] >= amount then
        local item
        if type == 'honey' then
            local honeyType = data.honeyType or 'basic'
            item = Beekeeping.HoneyTypes[honeyType].item or Beekeeping.Items.HoneyItem
        else
            item = Beekeeping.Items.WaxItem
        end

        local canCarry = SD.Inventory.CanCarry(src, tostring(item), withdrawAmount)
        if canCarry then
            SD.Inventory.AddItem(src, tostring(item), withdrawAmount)
            data[type] = data[type] - withdrawAmount

            local serializedData = json.encode(hive.data)
            MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, id}, function(affectedRows)
            end)

            if logConfig.logs.events.withdraw_product then
                local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
                SD.Logger.Log(src, "withdraw_product", locale('logs.withdraw_product', { source=src, srcName=srcName, charName=charName, identifier=citizenId, product=type, amount=withdrawAmount, id=id }))
            end
        else
            TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_inventory'), 'error')
        end
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_product'), 'error')
    end
end)

RegisterNetEvent('sd-beekeeping:removeStructure', function(id)
    local src = source
    local hive = beekeepingData[id]
    local citizenId = SD.GetIdentifier(src)

    if not hive or not hive.data then 
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return 
    end

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
        if c.id == citizenId then isCollab = true; break end
        end
    
    if citizenId ~= ownerId and not isCollab then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return
        end
    end

    RemoveFromData(id)
    DeleteBeeObject(id)
end)

-- Insert queen into Hive
RegisterNetEvent('sd-beekeeping:insertQueen', function(id)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    local hive = beekeepingData[id]

    if not hive or not hive.data then 
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return 
    end

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
        if c.id == citizenId then isCollab = true; break end
        end
    
    if citizenId ~= ownerId and not isCollab then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return
        end
    end

    if SD.Inventory.HasItem(src, Beekeeping.Items.QueenItem) >= 1 then
        SD.Inventory.RemoveItem(src, Beekeeping.Items.QueenItem, Beekeeping.Hives.NeededQueens)
        if hive.hive_type == 'hive' then
            hive.data.haveQueen = true
            -- Serialize the updated data
            local serializedData = json.encode(hive.data)
            MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, id}, function(affectedRows)
            end)

            if logConfig.logs.events.insert_queen then
                local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
                SD.Logger.Log(src, "insert_queen", locale('logs.insert_queen', { source=src, srcName=srcName, charName=charName, identifier=citizenId, id=id }))
            end
        else
            return
        end
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_queens', {needed = Beekeeping.Hives.NeededQueens}), 'error')
    end
end)

-- Insert worker into Hive.
RegisterNetEvent('sd-beekeeping:insertWorker', function(id, amount)
    local src = source
    local citizenId = SD.GetIdentifier(src)
    local hive = beekeepingData[id]
    local workerAmount = math.abs(tonumber(amount) or 0)

    if not hive or not hive.data then 
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return 
    end

    if Beekeeping.LockAccess then
        local ownerId = hive.owner.id
        local isCollab = false
        for _, c in ipairs(hive.collaborators or {}) do
        if c.id == citizenId then isCollab = true; break end
        end
    
    if citizenId ~= ownerId and not isCollab then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.no_access'), 'error')
        return
        end
    end

    if workerAmount <= 0 then
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.invalid_worker_amount'), 'error')
        return
    end

    if SD.Inventory.HasItem(src, Beekeeping.Items.WorkerItem) >= workerAmount then
        if hive.hive_type == 'hive' then
            if (hive.data.workers or 0) + workerAmount > Beekeeping.Hives.MaxWorkers then
                TriggerClientEvent('sd_bridge:notification', src, locale('notifications.too_many_workers', {max = Beekeeping.Hives.MaxWorkers}), 'error')
                return
            end

            SD.Inventory.RemoveItem(src, Beekeeping.Items.WorkerItem, workerAmount)
            hive.data.workers = (hive.data.workers or 0) + workerAmount

            if logConfig.logs.events.insert_worker then
                local srcName, charName, citizenId = GetPlayerName(src), SD.Name.GetFullName(src), SD.GetIdentifier(src)
                SD.Logger.Log(src, "insert_worker", locale('logs.insert_worker', { source=src, srcName=srcName, charName=charName, identifier=citizenId, amount=workerAmount, id=id }))
            end

            if not hive.data.haveWorker and hive.data.workers >= Beekeeping.Hives.NeededWorkers then
                hive.data.haveWorker = true
                hive.data.honey = 0
                hive.data.wax = 0
            end

            UpdateHoneyMultiplier(id)

            local serializedData = json.encode(hive.data)

            MySQL.Async.execute('UPDATE sd_beekeeping SET data = ? WHERE id = ?', {serializedData, id}, function(affectedRows)   
            end)
        else
            return
        end
    else
        TriggerClientEvent('sd_bridge:notification', src, locale('notifications.not_enough_workers', {needed = workerAmount}), 'error')
    end
end)

lib.callback.register('sd-beekeeping:getHiveFullData', function(_, hiveId)
  if not beekeepingDataLoaded then
    return { success=false, message='Data still loading.' }
  end
  local hive = beekeepingData[hiveId]
  if not hive then
    return { success=false, message='Invalid hive.' }
  end
  return {
    success       = true,
    id            = hive.id,
    data          = hive.data or {},
    owner         = hive.owner,
    collaborators = hive.collaborators or {},
    durability    = hive.durability or 100,
  }
end)

lib.callback.register('sd-beekeeping:getHiveCollaborators', function(_, hiveId)
  if not beekeepingDataLoaded then
    return { success=false, message='Data still loading.' }
  end
  local hive = beekeepingData[hiveId]
  if not hive then
    return { success=false, message='Invalid hive.' }
  end
  return {
    success       = true,
    owner         = hive.owner,
    collaborators = hive.collaborators or {},
  }
end)

lib.callback.register('sd-beekeeping:getAggressionLevel', function(source, hiveId)
    local hive = beekeepingData[hiveId]
    if hive and hive.data then
        return hive.data.aggression or Beekeeping.Aggression.DefaultLevel
    end
    return Beekeeping.Aggression.DefaultLevel
end)

lib.callback.register('sd-beekeeping:getServerTime', function(source)
    return os.time()
end)

lib.callback.register('sd-beekeeping:server:CheckHiveCount', function(source, data)
    local maxLimit = (data.hive_type == 'house') and Beekeeping.Max.Houses or Beekeeping.Max.Hives
    local citizenHives = ownerHives[data.citizenid]
    local count = 0

    if citizenHives then
        for hiveId in pairs(citizenHives) do
            local hive = beekeepingData[hiveId]
            if hive and hive.hive_type == data.hive_type then
                count = count + 1
            end
        end
    end

    return count >= maxLimit
end)

lib.callback.register('sd-beekeeping:getInfectionLosses', function(source, hiveId)
    return temporaryLosses[hiveId] or {lostWorkers = 0, lostQueens = 0}
end)

SD.CheckVersion('sd-versions/sd-beekeeping') -- Check version of specified resource