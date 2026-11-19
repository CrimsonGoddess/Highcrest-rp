ZlomaCore.RegisterClientAppearance('qb-clothing', {
    get = function() return ZlomaCore.AppearanceHelpers.getSkinchangerSkin() end,
    setSkin = function(data) TriggerEvent('qb-clothing:client:loadPlayerClothing', data, nil) return true end,
    setClothing = function(data) TriggerEvent('qb-clothing:client:loadOutfit', { outfitData = data }) return true end,
    openWardrobe = function() TriggerEvent('qb-clothing:client:openOutfitMenu') return true end,
})
