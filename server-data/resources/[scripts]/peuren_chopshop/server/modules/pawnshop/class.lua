PawnShop = {
    data = {},

    ---Inits the PawnShop threads
    Init = function()
        PawnShop.Load()
        for k, v in pairs(Config.PawnShop) do
            Citizen.CreateThread(function()
                while true do
                    PawnShop.UpdatePrices(k)
                    Citizen.Wait(v.Market.MarketCycle * 1000)
                end
            end)
        end
    end,

    ---Get item prices for a specific dealer
    ---@param dealer DealerName
    ---@return table
    GetDealerPrices = function(dealer)
        local items = {}
        for k, v in pairs(PawnShop.data[dealer]) do
            items[k] = v
        end
        return items
    end,

    ---Loads the PawnShop data
    Load = function()
        local file = LoadResourceFile("peuren_chopshop", "pawnshop.json")
        if not file then
            return warn("Couldn't load the pawnshop.json file !!! \n PawnShop will not work.")
        end

        PawnShop.data = json.decode(file)

        if not PawnShop.data then PawnShop.data = {} end

        -- Highcrest: keep only the dealers and items in Config.PawnShop. The shipped pawnshop.json
        -- held the author's test items (stolentv, gold_chain...), which showed as NO_LABEL.
        local saved = PawnShop.data
        PawnShop.data = {}
        for k, v in pairs(Config.PawnShop) do
            PawnShop.data[k] = {}

            for _, iData in pairs(v.Sell) do
                local old = saved[k] and saved[k][iData.name]
                PawnShop.data[k][iData.name] = old or {
                    sales = {},
                    item = iData.name,
                    price = math.floor((iData.min + iData.max) / 2)
                }
            end
        end

        PawnShop.Save()
    end,

    ---Saves the PawnShop data
    Save = function() 
        local saved = SaveResourceFile("peuren_chopshop", "pawnshop.json", json.encode(PawnShop.data, {indent=true}), -1)
    end,

    ---Update specific Dealers item prices
    ---@param dealer DealerName
    UpdatePrices = function(dealer)
        if not PawnShop.data[dealer] then return end
        for _, iData in pairs(PawnShop.data[dealer]) do
            PawnShop.UpdateItemPrice(dealer, iData.name)
        end
        PawnShop.Save()
    end,

    ---Update specific items price of a specific dealer
    ---@param dealer DealerName
    ---@param item string
    UpdateItemPrice = function(dealer, item)
        local itemData = PawnShop.data[dealer][item]
        if not itemData then return end

        local currTime = os.time()
        local actualSales = {}
        local salesAmount = 0
        local lastSaleTimestamp = Config.PawnShop[dealer].Market.SaleAge
        for k, v in pairs(itemData.sales) do
            if currTime - v.timeStamp < Config.PawnShop[dealer].Market.SaleAge then
                actualSales[#actualSales+1] = v
                salesAmount += v.amount
                if lastSaleTimestamp > currTime - v.timeStamp then
                    lastSaleTimestamp = currTime - v.timeStamp
                end
            end
        end
        itemData.sales = actualSales
        
        local priceChange = 0

        if salesAmount > 0 then
            priceChange -= (salesAmount / 10)
        end

        priceChange += (lastSaleTimestamp / 1000)

        local currPrice = itemData.price

        local finalPrice = math.ceil(currPrice + (priceChange * Config.PawnShop[dealer].Market.PriceChangeFactor))

        if Config.PawnShop[dealer].Sell[item].min > finalPrice then
            finalPrice = Config.PawnShop[dealer].Sell[item].min
        end

        if Config.PawnShop[dealer].Sell[item].max < finalPrice then
            finalPrice = Config.PawnShop[dealer].Sell[item].max
        end

        itemData.price = finalPrice
    end
}

PawnShop.Init()