ZlomaCore.RegisterClientAppearance('crm-appearance', {
    get = function() return exports['crm-appearance']:crm_get_ped_appearance(PlayerPedId()) end,
    setSkin = function(data) exports['crm-appearance']:crm_set_ped_appearance(PlayerPedId(), data) return true end,
    setClothing = function(data)
        exports['crm-appearance']:crm_set_ped_clothing(PlayerPedId(), data.crm_clothing or {})
        exports['crm-appearance']:crm_set_ped_accessories(PlayerPedId(), data.crm_accessories or {})
        return true
    end,
    openWardrobe = function()
        return ZlomaCore.AppearanceHelpers.try({
            function() return exports['crm-appearance']:crm_open_outfit_menu() end,
            function() TriggerEvent('crm-appearance:client:openOutfitMenu') return true end,
        })
    end,
})
