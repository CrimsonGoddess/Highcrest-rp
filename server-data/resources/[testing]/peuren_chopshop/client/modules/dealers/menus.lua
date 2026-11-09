
RegisterNetEvent('peuren_chopshop:OpenMainMenu', function(dealer)
    if not dealer then print('[ERROR] - You need to provide a dealer type string name') return end
    DealerMenu(dealer)
end)

---Dealer main menu
---@param dealer string
function DealerMenu(dealer)
    local result = lib.Framework.Callbacks.Trigger('peuren_chopshop:CanAccessDealer', dealer)

    if not result then 
        lib.Notify(lib.Locale("notify_cant_interact_dealer"), nil, "error")
        return
    end

    local options = {
        {
            icon = 'fas fa-car-burst',
            title = lib.Locale('dealer_menu_job_title'),
            description = lib.Locale('dealer_menu_job_desciption'),
            event = 'peuren_chopshop:GetNewJob',
            args = { dealer = dealer }
        },
        {
            icon = 'fas fa-handshake',
            title = lib.Locale('dealer_menu_rep_title'),
            description = lib.Locale('dealer_menu_rep_desciption'),
            event = 'peuren_chopshop:DealersRepMenu',
            args = { dealer = dealer }
        },
    }

    if Config.PawnShop[dealer] then 
        options[#options + 1] = {
            icon = 'fas fa-cart-flatbed-suitcase',
            title = lib.Locale('dealer_menu_pawn_title'),
            description = lib.Locale('dealer_menu_apwn_desciption'),
            event = 'peuren_chopshop:PawnShopMenu',
            args = { dealer = dealer }
        }
    end

    lib.Menu(Config.Dealers[dealer].Dealer.name, options)
end

RegisterNetEvent('peuren_chopshop:GetNewJob', function(data)
    local result = lib.Framework.Callbacks.Trigger('peuren_chopshop:GetPersonalCooldown', data.dealer)
    
    if result then 
        lib.Notify(lib.Locale("notify_personal_cooldown"), nil, "error")
        return
    end
    
    lib.Framework.Callbacks.TriggerAsync('peuren_chopshop:GetNewJob', function(result)
        if result == 'you_have_house' then 
            lib.Notify(lib.Locale("you_have_house"), nil, "error")
            return
        end

        if result == 'you_have_job' then 
            lib.Notify(lib.Locale("you_have_job"), nil, "error")
            return 
        end

        if result == 'failed_to_find_job' then 
            lib.Notify(lib.Locale("notify_job_not_found"), nil, "error")
            return 
        end

        if result == 'not_enough_police_to_start' then 
            lib.Notify(lib.Locale("not_enough_police_to_start"), nil, "error")
            return 
        end

        if result == 'no_required_job_items' then 
            lib.Notify(lib.Locale("no_required_job_items"), nil, "error")
            return 
        end

        lib.Notify(lib.Locale("job_found_go_to_blip"), nil, "success")
        -- if not Job.data then Job.data = {} end
        -- Job.CreateBlip(result)
    end, data.dealer)
end)

RegisterNetEvent('peuren_chopshop:DealersRepMenu', function(data)    
    local result = lib.Framework.Callbacks.Trigger('peuren_chopshop:GetReputation', data.dealer)

    local taskMenu = {}

    if result.Task then
        taskMenu = {
            icon = 'fa-solid fa-list-check',
            title = lib.Locale('dealer_menu_rep_active_task_title'),
            description = lib.Locale('dealer_menu_rep_active_task_description'),
            event = 'peuren_chopshop:DealersTaskMenu',
            args = { dealer = data.dealer, task = result.Task, taskProgress = result.TaskProgress }
        }
    else
        taskMenu = {
            icon = 'fas fa-user-plus',
            title = lib.Locale('dealer_menu_rep_new_task_title'),
            description = lib.Locale('dealer_menu_rep_new_task_description'),
            event = 'peuren_chopshop:GetNewTask',
            args = { dealer = data.dealer}
        }
    end

    lib.Menu(Config.Dealers[data.dealer].Dealer.name, {
        {
            icon = 'fas fa-chart-bar',
            title = lib.Locale('dealer_menu_rep_level_title'),
            description = lib.Locale('dealer_menu_rep_level_description'):format(result.Level),
        },    
        taskMenu
    })
end)

RegisterNetEvent('peuren_chopshop:DealersTaskMenu', function(data)
    local taskData = Config.Tasks[data.dealer][data.task]
    if not taskData then return end
    if not data.taskProgress then data.taskProgress = 0 end

    local completeDescription = lib.Locale('task_menu_complete_task_description')
    local taskDescription = ""
    if taskData.Type == "item" then
        taskDescription = lib.Locale("task_menu_bring_item_count"):format(taskData.Amount, lib.Inventory.GetItemLabel(taskData.Item))
    end

    if taskData.Type == "minigame" then
        taskDescription = lib.Locale("task_menu_complete_minigame"):format(lib.Locale("minigame_"..taskData.Minigame), taskData.Count)
        local progress = math.ceil(data.taskProgress / taskData.Count * 100)
        if progress >= 100 then progress = 100 end
        completeDescription = lib.Locale("task_menu_minigame_progress"):format(progress.."%")
    end

    lib.Menu(Config.Dealers[data.dealer].Dealer.name, {
        {
            icon = 'fa-solid fa-list-check',
            title = lib.Locale('dealer_menu_rep_active_task_title'),
            description = taskDescription,
        },    
        {
            icon = 'fa-solid fa-check',
            title = lib.Locale('task_menu_complete_task_title'),
            description = completeDescription,
            event = 'peuren_chopshop:CompleteTask',
            args = { dealer = data.dealer }
        },   
        {
            icon = 'fa-solid fa-ban',
            title = lib.Locale('task_menu_cancel_task_title'),
            description = lib.Locale('task_menu_cancel_task_description'),
            event = 'peuren_chopshop:CancelTask',
            args = { dealer = data.dealer }
        },   
    })
end)

RegisterNetEvent("peuren_chopshop:GetNewTask", function(data)
    local result = lib.Framework.Callbacks.Trigger("peuren_chopshop:GetNewTask", data.dealer)
    if not result then return end

    lib.Notify(lib.Locale("notify_received_task_title"), lib.Locale("notify_received_task_description"), "success")
    TriggerEvent("peuren_chopshop:DealersTaskMenu", {dealer = data.dealer, task = result})
end)

RegisterNetEvent("peuren_chopshop:CompleteTask", function(data)
    local result = lib.Framework.Callbacks.Trigger("peuren_chopshop:CompleteTask", data.dealer)
    if not result then return end

    lib.Notify(lib.Locale("notify_completed_task_title"), lib.Locale("notify_completed_task_description"), "success")
    TriggerEvent("peuren_chopshop:DealersRepMenu", data)
end)

RegisterNetEvent("peuren_chopshop:CancelTask", function(data)
    local result = lib.Framework.Callbacks.Trigger("peuren_chopshop:CancelTask", data.dealer)
    if not result then return end

    lib.Notify(lib.Locale("notify_canceled_task_title"), lib.Locale("notify_canceled_task_description"), "error")
    TriggerEvent("peuren_chopshop:DealersRepMenu", data)
end)

RegisterNetEvent('peuren_chopshop:PawnShopMenu', function(data)
    lib.Menu(Config.Dealers[data.dealer].Dealer.name, {
        {
            icon = 'fa-solid fa-store',
            title = lib.Locale('dealer_menu_shop_buy_title'),
            description = lib.Locale('dealer_menu_shop_buy_description'),
            event = 'peuren_chopshop:BuyMenu',
            args = { dealer = data.dealer }
        },    
        {
            icon = 'fa-solid fa-dollar-sign',
            title = lib.Locale('dealer_menu_shop_sell_title'),
            description = lib.Locale('dealer_menu_shop_sell_description'),
            event = 'peuren_chopshop:SellMenu',
            args = { dealer = data.dealer }
        },   
    })
end)

RegisterNetEvent("peuren_chopshop:BuyMenu", function(data)
    local result = lib.Framework.Callbacks.Trigger('peuren_chopshop:GetReputation', data.dealer)
    local items = {}

    for k, v in pairs(Config.PawnShop[data.dealer].Buy) do
        local price = v.price
        if Config.PawnShop[data.dealer].Reputation then
            if result.Level >= Config.PawnShop[data.dealer].Reputation.minRep then
                price -= ((result.Level - Config.PawnShop[data.dealer].Reputation.minRep) * Config.PawnShop[data.dealer].Reputation.multiplier / 100) 
            end
        end
        items[#items + 1] = {
            title = lib.Inventory.GetItemLabel(v.name),
            description = lib.Locale('dealer_menu_shop_buy_price'):format(price),
            event = 'peuren_chopshop:BuyItem',
            args = { dealer = data.dealer, item = k }
        }
    end

    lib.Menu(Config.Dealers[data.dealer].Dealer.name, items)
end)

RegisterNetEvent("peuren_chopshop:BuyItem", function(data)
    if not data.dealer or not data.item then return end

    local input = lib.Input(lib.Locale("dealer_menu_amount"), {
        {
            title = lib.Locale("dealer_menu_amount"),
            name = "amount",
            type = "number",
            isRequired = true,
            default = 1
        }
    })

    if not input or not tonumber(input.amount) then 
        lib.Notify(lib.Locale("input_invalid_input"), nil, "error")
    else
        lib.Framework.Callbacks.Trigger("peuren_chopshop:BuyItem", data.dealer, data.item, tonumber(input.amount))
    end

    TriggerEvent("peuren_chopshop:BuyMenu", {dealer = data.dealer})
end)

RegisterNetEvent("peuren_chopshop:SellMenu", function(data)
    local items = lib.Framework.Callbacks.Trigger("peuren_chopshop:GetDealerPrices", data.dealer)
    local result = lib.Framework.Callbacks.Trigger('peuren_chopshop:GetReputation', data.dealer)
    local menu = {}

    for k, v in pairs(items) do
        local price = v.price
        if Config.PawnShop[data.dealer].Reputation then
            if result.Level >= Config.PawnShop[data.dealer].Reputation.minRep then
                price += ((result.Level - Config.PawnShop[data.dealer].Reputation.minRep) * Config.PawnShop[data.dealer].Reputation.multiplier / 100) 
            end
        end
        if v.item then 
            menu[#menu + 1] = {
                title = lib.Inventory.GetItemLabel(v.item),
                description = lib.Locale('dealer_menu_shop_buy_price'):format(price),
                event = 'peuren_chopshop:SellItem',
                args = { dealer = data.dealer, item = v.item }
            } 
        end
    end

    lib.Menu(Config.Dealers[data.dealer].Dealer.name, menu)
end)

RegisterNetEvent("peuren_chopshop:SellItem", function(data)
    if not data.dealer or not data.item then return end

    local input = lib.Input(lib.Locale("dealer_menu_amount"), {
        {
            text = lib.Locale("dealer_menu_amount"),
            name = "amount",
            type = "number",
            isRequired = true,
            default = 1
        }
    })

    if not input or not tonumber(input.amount) then 
        lib.Notify(lib.Locale("input_invalid_input"), nil, "error")
    else
        lib.Framework.Callbacks.Trigger("peuren_chopshop:SellItem", data.dealer, data.item, tonumber(input.amount))
    end

    TriggerEvent("peuren_chopshop:SellMenu", {dealer = data.dealer})
end)