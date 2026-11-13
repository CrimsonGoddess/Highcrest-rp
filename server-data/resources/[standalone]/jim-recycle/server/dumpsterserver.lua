if Config.DumpsterDiving.Enable then
    onResourceStart(function()
        Wait(100)

        if not Config.DumpsterDiving.DumpItems or #Config.DumpsterDiving.DumpItems == 0 then
            print("^1Error^7: ^2DumpsterDiving^7: ^2No DumpItems configured^7")
            return
        end

        for i = 1, #Config.DumpsterDiving.DumpItems do
            local entry = Config.DumpsterDiving.DumpItems[i]
            if not entry or not entry.item then
                print("^1Error^7: ^2DumpItems^7: Invalid entry at index ^6" .. i .. "^7")
            elseif not Items[entry.item] then
                print("^1Error^7: ^2DumpItems^7: ^2Missing Item from ^5Shared Items^7: '^6" .. entry.item .. "^7'")
            end
        end
    end, true)

    -- Tweak these if you want more/less loot per dumpster
    local MIN_ROLLS = 2
    local MAX_ROLLS = 4

    -- rarity meaning (based on your old code):
    -- 1 = Super Rare, 2 = Rare, 3 = Uncommon, 4 = Common
    -- higher weight = more likely
    local WEIGHT_BY_RARITY = {
        [1] = 1,   -- Super Rare
        [2] = 3,   -- Rare
        [3] = 8,   -- Uncommon
        [4] = 20,  -- Common
    }

    local function buildWeightedPool()
        local pool = {}

        if not Config.DumpsterDiving.DumpItems then return pool end

        for _, entry in pairs(Config.DumpsterDiving.DumpItems) do
            if entry and entry.item then
                local rarity = entry.rarity or 4
                local weight = WEIGHT_BY_RARITY[rarity] or 1

                for _ = 1, weight do
                    pool[#pool + 1] = entry.item
                end
            end
        end

        return pool
    end

    RegisterServerEvent('jim-recycle:server:getDumpsterReward', function()
        local src = source

        local pool = buildWeightedPool()
        if #pool == 0 then
            print("^1Error^7: ^2DumpsterDiving^7: Weighted pool is empty (check Config.DumpsterDiving.DumpItems)^7")
            return
        end

        local rolls = math.random(MIN_ROLLS, MAX_ROLLS)

        for _ = 1, rolls do
            local chosenItem = pool[math.random(1, #pool)]
            local amount = math.random(1, 3)
            addItem(chosenItem, amount, nil, src)
        end
    end)
end
