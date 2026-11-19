ZlomaCore.RegisterClientAppearance('p_appearance', {
    get = function() return ZlomaCore.AppearanceHelpers.getSkinchangerSkin() end,
    setSkin = function(data) TriggerEvent('skinchanger:loadSkin', data) return true end,
    setClothing = function(data)
        local skin = ZlomaCore.AppearanceHelpers.getSkinchangerSkin()
        if not skin then return false end
        TriggerEvent('skinchanger:loadClothes', skin, data)
        return true
    end,
    openWardrobe = function() TriggerEvent('esx_skin:openSaveableMenu') return true end,
})
