Tablet = {
    Data = {},
    IsOpen = false,

    Update = function(data)
        if not data then return end 

        Tablet.Data = data 
        SendNUIMessage({ type = 'page', value = data.page })
        SendNUIMessage({ type = data.page, value = data.pageData or {} })
    end,

    SetPage = function(id, page, args)
        if not id or not page then return end
        TriggerServerEvent('peuren_gruppe6:server:SetPage', id, page, args)
    end,

    Open = function()
        if Tablet.IsOpen then return end
        
        if not Jobs.Data.args then 
            lib.Notify(lib.Locale('you_do_not_have_job'), nil, "error")
            return
        end

        SendNUIMessage({
            type = "locale",
            value = {
                ui_contract_progress_header = lib.Locale("ui_contract_progress_header"),
                ui_contract_progress_description = lib.Locale("ui_contract_progress_description"),
                ui_header_contracts = lib.Locale("ui_header_contracts"),
                ui_header_your_group = lib.Locale("ui_header_your_group"),
                ui_take_contract = lib.Locale("ui_take_contract"),
                ui_job_progress = lib.Locale("ui_job_progress"),
                ui_cancel_contract = lib.Locale("ui_cancel_contract"),
                ui_cancel_contract_confirm = lib.Locale("ui_cancel_contract_confirm"),
                ui_cancel_contract_confirm_no = lib.Locale("ui_cancel_contract_confirm_no"),
                ui_cancel_contract_confirm_yes = lib.Locale("ui_cancel_contract_confirm_yes"),
                ui_contract_progress_pickup = lib.Locale("ui_contract_progress_pickup"),
                ui_contract_progress_transport = lib.Locale("ui_contract_progress_transport"),
                ui_contract_progress_deliver = lib.Locale("ui_contract_progress_deliver"),
                ui_group_owner_tag = lib.Locale("ui_group_owner_tag"),
                ui_group_id = lib.Locale("ui_group_id"),
                ui_group_password = lib.Locale("ui_group_password"),
                ui_group_end_job = lib.Locale("ui_group_end_job"),
                ui_group_end_job_confirm = lib.Locale("ui_group_end_job_confirm"),
                ui_group_end_job_confirm_no = lib.Locale("ui_group_end_job_confirm_no"),
                ui_group_end_job_confirm_yes = lib.Locale("ui_group_end_job_confirm_yes"),
                ui_group_kick_player_confirm = lib.Locale("ui_group_kick_player_confirm"),
                ui_group_kick_player_confirm_yes = lib.Locale("ui_group_kick_player_confirm_yes"),
                ui_group_kick_player_confirm_no = lib.Locale("ui_group_kick_player_confirm_no"),
                ui_group_members = lib.Locale("ui_group_members")
            }
        })

        local result = Cache.Get(Jobs.Data.args.groupId, 'finished')
        if result then return end 
        
        local orders = lib.Framework.Callbacks.Trigger("peuren_gruppe6:GetOrders", Jobs.Data.args.type)
        if not orders then return end
        SendNUIMessage({ type = "contracts", value = orders })

        local group = lib.Framework.Callbacks.Trigger("peuren_gruppe6:GetGroupJob", Jobs.Data.args.groupId)
        if not group then return end
        SendNUIMessage({ type = "group", value = group })
        
        if Tablet.Data.page then 
            SendNUIMessage({ type = 'page', value = Tablet.Data.page })
            SendNUIMessage({ type = Tablet.Data.page, value = Tablet.Data.pageData or {} })
        end

        SetNuiFocus(true, true)
        SendNUIMessage({ type = "visible", value = true })
        Tablet.IsOpen = true
    end,

    Close = function()
        if not Tablet.IsOpen then return end

        SetNuiFocus(false, false)
        SendNUIMessage({ type = "visible", value = false })
        Tablet.IsOpen = false
    end,
}