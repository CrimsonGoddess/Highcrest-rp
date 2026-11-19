ZlomaCore.RegisterClientAppearance('qs-appearance', {
    get = function() return exports['qs-appearance']:getPedAppearance(PlayerPedId()) end,
    setSkin = function(data) exports['qs-appearance']:setPlayerAppearance(data) return true end,
    setClothing = function(data)
        exports['qs-appearance']:setPedComponents(PlayerPedId(), data.components or {})
        exports['qs-appearance']:setPedProps(PlayerPedId(), data.props or {})
        return true
    end,
    openWardrobe = function()
        return ZlomaCore.AppearanceHelpers.try({
            function() return exports['qs-appearance']:OpenWardrobe() end,
            function() return exports['qs-appearance']:openOutfitMenu() end,
            function() TriggerEvent('qs-clothing:client:openOutfitMenu') return true end,
            function() TriggerEvent('qs-appearance:client:openOutfitMenu') return true end,
        })
    end,
})
