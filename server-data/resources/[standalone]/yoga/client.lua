local yogaMatModels = {
    `prop_yoga_mat_01`,
    `prop_yoga_mat_02`,
    `prop_yoga_mat_03`
}

local yogaAnimation = {
    dict = "amb@world_human_yoga@male@base",
    anim = "base_a"
}

function doYoga(entity)
    local ped = PlayerPedId()

    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)

    local adjustedHeading = (heading + 90) % 360

    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, adjustedHeading)

    FreezeEntityPosition(ped, true)

    RequestAnimDict(yogaAnimation.dict)
    while not HasAnimDictLoaded(yogaAnimation.dict) do
        Wait(100)
    end

    TaskPlayAnim(ped, yogaAnimation.dict, yogaAnimation.anim, 8.0, -8.0, -1, 1, 0, false, false, false)

    local success = lib.progressCircle({
        duration = 30000,
        position = 'bottom',
        label = 'Meditating...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
            car = true,
        }
    })

    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)

    if success then
        TriggerServerEvent("yoga:reduceStress")
        lib.notify({
            title = "Yoga",
            description = "You feel yourself calming down...",
            type = "success"
        })
    else
        lib.notify({
            title = "Yoga",
            description = "You got distracted and stopped.",
            type = "error"
        })
    end
end

-- TARGET EXISTING MATS (NO SPAWNING)
CreateThread(function()
    exports.ox_target:addModel(yogaMatModels, {
        {
            name = "doYoga",
            label = "Do Yoga",
            icon = "fas fa-dumbbell",
            onSelect = function(data)
                doYoga(data.entity)
            end
        }
    })
end)