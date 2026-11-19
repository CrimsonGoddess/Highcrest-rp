ZlomaCore.RegisterClientAppearance('tgiann-clothing', {
    setSkin = function(data) TriggerEvent('tgiann-clothing:changeScriptClothe', data) return true end,
    setClothing = function(data) TriggerEvent('tgiann-clothing:changeScriptClothe', data) return true end,
    openWardrobe = function()
        return ZlomaCore.AppearanceHelpers.try({
            function() TriggerEvent('tgiann-clothing:openMenu') return true end,
            function() TriggerEvent('tgiann-clothing:openOutfitMenu') return true end,
        })
    end,
})
