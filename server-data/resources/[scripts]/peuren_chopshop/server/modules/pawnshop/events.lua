lib.Framework.RegisterCallback('peuren_chopshop:GetDealerPrices', function(source, cb, dealer)
    cb(PawnShop.GetDealerPrices(dealer))
end)

function ManageAccountBalance(source, type, dealer, amount)
    local Currency = Config.PawnShop[dealer].Currency
    if type == 'remove' then 
        if Currency.accountItem.enabled then 
            if not lib.Inventory.HasPlayerItem(source, Currency.accountItem.itemName, amount) then return false end 
            lib.Inventory.RemoveItem(source, Currency.accountItem.itemName, amount)
            return true
        else 
            return lib.Framework.Money.Remove(source, amount, Currency.account)
        end 
    elseif type == 'add' then 
        if Currency.accountItem.enabled then 
            lib.Inventory.AddItem(source, Currency.accountItem.itemName, amount)
            return true
        else 
            -- Highcrest: selling chopped parts pays one marked-bills stack worth the sale (money wash).
            return exports.ox_inventory:AddItem(source, 'markedbills', 1, { worth = amount, description = ('Value: $%d'):format(amount) }) ~= false
        end 
    end
end

lib.Framework.RegisterCallback("peuren_chopshop:BuyItem", function(source, cb, dealer, item, amount)
    if not Config.PawnShop[dealer].Buy[item] then 
        cb(false)
        return
    end

    local money = amount * Config.PawnShop[dealer].Buy[item].price
    
    if not ManageAccountBalance(source, 'remove', dealer, money) then
        cb(false)
        TriggerClientEvent("peuren_lib:notify", source, lib.Locale("notify_not_enough_money"), nil, "error")
        return
    end

    lib.Inventory.AddItem(source, Config.PawnShop[dealer].Buy[item].name, amount)
    TriggerClientEvent("peuren_lib:notify", source, lib.Locale("notify_buy_success_title"), lib.Locale("notify_buy_success_description"):format(money), "success")
    cb(true)
end)

lib.Framework.RegisterCallback("peuren_chopshop:SellItem", function(source, cb, dealer, item, amount)
    if not PawnShop.data[dealer][item] then 
        cb(false)
        return 
    end

    if not lib.Inventory.HasPlayerItem(source, item, amount) then
        cb(false)
        TriggerClientEvent("peuren_lib:notify", source, lib.Locale("notify_not_enough_items"), nil, "error")
        return
    end
    
    lib.Inventory.RemoveItem(source, item, amount)
    local money = PawnShop.data[dealer][item].price * amount    

    ManageAccountBalance(source, 'add', dealer, money)
    table.insert(PawnShop.data[dealer][item].sales, {amount = amount, timeStamp = os.time()})

    TriggerClientEvent("peuren_lib:notify", source, lib.Locale("notify_sale_success_title"), lib.Locale("notify_sale_success_description"):format(money), "success")
    
    cb(true)
end)
