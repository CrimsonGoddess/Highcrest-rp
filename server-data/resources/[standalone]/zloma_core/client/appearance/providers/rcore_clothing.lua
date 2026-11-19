ZlomaCore.RegisterClientAppearance('rcore_clothing', {
    get = function() return exports['rcore_clothing']:getPlayerSkin(false) end,
    setSkin = function(data) exports['rcore_clothing']:setPlayerSkin(data) return true end,
    setClothing = function(data) exports['rcore_clothing']:setPlayerSkin(data) return true end,
    openWardrobe = function()
        return ZlomaCore.AppearanceHelpers.try({
            function() return exports['rcore_clothing']:openWardrobe() end,
            function() TriggerEvent('rcore_clothing:openOutfits') return true end,
            function() TriggerEvent('rcore_clothing:openWardrobe') return true end,
        })
    end,
})
