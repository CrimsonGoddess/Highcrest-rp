TrackedAnimals = {}

function DeleteTrackedAnimals()
    for i = 1, #TrackedAnimals do
        if TrackedAnimals[i].blip then
            RemoveBlip(TrackedAnimals[i].blip)
        end
    end
    TrackedAnimals = {}
end

function HuntingHorn()
    if #TrackedAnimals > 0 then
        return ShowNotification(_L("track_already"))
    end
    
    local hornCfg = Config.HuntingHorn
    local animals = GetAnimals(hornCfg.radius)
    
    for _, animal in ipairs(animals) do
        local blip = AddBlipForEntity(animal)
        SetBlipSprite(blip, hornCfg.blip.ID)
        SetBlipDisplay(blip, hornCfg.blip.Display)
        SetBlipScale(blip, hornCfg.blip.Scale)
        SetBlipColour(blip, hornCfg.blip.Color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(hornCfg.blip.Label)
        EndTextCommandSetBlipName(blip)
        
        table.insert(TrackedAnimals, {
            entity = animal,
            blip = blip
        })
    end
    
    ShowNotification(_L("tracking"))
    
    CreateThread(function()
        local duration = hornCfg.time
        for i = 1, duration do
            local alpha = math.ceil(lerp(255, 0, i / duration))
            for j = 1, #TrackedAnimals do
                SetBlipAlpha(TrackedAnimals[j].blip, alpha)
            end
            Wait(1000)
        end
        DeleteTrackedAnimals()
        ShowNotification(_L("track_done"))
    end)
end

RegisterNetEvent("pickle_hunting:useHorn", function()
    HuntingHorn()
end)
