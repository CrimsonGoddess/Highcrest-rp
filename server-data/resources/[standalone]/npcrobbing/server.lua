local function getFramework()
    if Config.Framework ~= "auto" then
        return Config.Framework
    end

    if GetResourceState("qbx_core") == "started" then return "qbx" end
    if GetResourceState("qb-core") == "started" then return "qb" end
    return "standalone"
end

local function addCash(src, amount)
    local fw = getFramework()

    if fw == "qbx" then
        local player = exports.qbx_core:GetPlayer(src)
        if player and player.Functions and player.Functions.AddMoney then
            player.Functions.AddMoney("cash", amount, "npc-robbery")
            return true
        end
    elseif fw == "qb" then
        local QBCore = exports["qb-core"]:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(src)
        if player and player.Functions and player.Functions.AddMoney then
            player.Functions.AddMoney("cash", amount, "npc-robbery")
            return true
        end
    end

    -- standalone: do nothing
    return false
end

local function addItem(src, item, amount)
    -- Prefer ox_inventory if present
    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:AddItem(src, item, amount)
    end

    local fw = getFramework()
    if fw == "qbx" then
        local player = exports.qbx_core:GetPlayer(src)
        if player and player.Functions and player.Functions.AddItem then
            return player.Functions.AddItem(item, amount)
        end
    elseif fw == "qb" then
        local QBCore = exports["qb-core"]:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(src)
        if player and player.Functions and player.Functions.AddItem then
            return player.Functions.AddItem(item, amount)
        end
    end

    return false
end

RegisterNetEvent("et_npcrobbery:server:reward", function()
    local src = source

    -- Cash
    if Config.Rewards.Cash.enabled then
        local cash = math.random(Config.Rewards.Cash.min, Config.Rewards.Cash.max)
        addCash(src, cash)
    end

    -- Items
    if Config.Rewards.Items.enabled and Config.Rewards.Items.pool and #Config.Rewards.Items.pool > 0 then
        for _, entry in ipairs(Config.Rewards.Items.pool) do
            if math.random() < (entry.chance or 0.0) then
                local amt = math.random(entry.min or 1, entry.max or 1)
                addItem(src, entry.item, amt)
            end
        end
    end
end)
