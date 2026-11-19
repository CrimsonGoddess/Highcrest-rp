ZlomaCore.RegisterClientAppearance('illenium-appearance', {
    get = function() return exports['illenium-appearance']:getPedAppearance(PlayerPedId()) end,
    setSkin = function(data) exports['illenium-appearance']:setPlayerAppearance(data) return true end,
    setClothing = function(data)
        exports['illenium-appearance']:setPedComponents(PlayerPedId(), data.components or {})
        exports['illenium-appearance']:setPedProps(PlayerPedId(), data.props or {})
        return true
    end,
    openWardrobe = function(options)
        lib.callback('illenium-appearance:server:getOutfits', false, function(outfits)
            if not outfits or #outfits == 0 then exports['zloma_core']:Notify('No saved outfits found', 'error') return end
            local entries = {}
            for _, outfit in ipairs(outfits) do
                entries[#entries + 1] = { title = outfit.name, description = outfit.model, onSelect = function()
                    TriggerEvent('illenium-appearance:client:changeOutfit', { name = outfit.name, model = outfit.model, components = outfit.components, props = outfit.props, disableSave = false })
                end }
            end
            lib.registerContext({ id = 'zloma_core_wardrobe', title = options.title or 'Wardrobe', options = entries })
            lib.showContext('zloma_core_wardrobe')
        end)
        return true
    end,
})
