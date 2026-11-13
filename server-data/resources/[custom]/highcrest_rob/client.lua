local function victimId(ped)
    return GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
end

exports.ox_target:addGlobalPlayer({
    {
        name = 'highcrest_rob',
        icon = 'fa-solid fa-sack-dollar',
        label = 'Rob',
        distance = 2.0,
        canInteract = function(entity)
            -- ox_inventory refuses past 1.8m ped to ped, and only opens while canSteal is set
            return cache.weapon and not cache.vehicle
                and IsEntityPlayingAnim(entity, 'random@mugging3', 'handsup_standing_base', 3)
                and #(GetEntityCoords(entity) - GetEntityCoords(cache.ped)) <= 1.8
                and Player(victimId(entity)).state.canSteal
        end,
        onSelect = function(data)
            exports.ox_inventory:openInventory('player', victimId(data.entity))
        end,
    },
})
