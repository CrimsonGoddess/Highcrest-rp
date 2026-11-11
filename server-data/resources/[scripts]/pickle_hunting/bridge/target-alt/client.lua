-- I don't recommend using this unless you really don't want to use third-eye target solutions or commands.

if not Config.NoTarget then 
    return
end

local NearestAnimal = nil

function InteractAnimal()
    lib.registerMenu({
        id = 'pickle_hunting_interact',
        title = _L("interact_menu"),
        position = 'top-right',
        options = {
            {label = _L("interact_menu_skin")},
            {label = _L("interact_menu_carry")},
            {label = _L("interact_menu_trunk")},
        }
    }, function(selected, scrollIndex, args)
        if selected == 1 then 
            SkinAnimal(NearestAnimal)
        elseif selected == 2 then 
            CarryAnimal(NearestAnimal)
        elseif selected == 3 then
            TrunkAnimal(NearestAnimal)
        end
    end)
    
    lib.showMenu('pickle_hunting_interact')
end

Citizen.CreateThread(function()
    while true do 
        Wait(2000)
        NearestAnimal = GetNearestAnimal()
    end
end)

Citizen.CreateThread(function()
    local showUI = false
    while true do
        local wait = 1000
        local animal = NearestAnimal
        if animal then 
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local coords = GetEntityCoords(animal)
            local dist = #(coords - pCoords)
            if (dist < 2.5) then 
                wait = 0
                if not showUI then
                    lib.showTextUI(_L("info_interact_animal"))
                    showUI = true
                end
                if IsControlJustPressed(1, 51) then 
                    InteractAnimal()
                end
            elseif showUI then
                lib.hideTextUI()
                showUI = false
            end
        elseif showUI then
            lib.hideTextUI()
            showUI = false
        end 
        Wait(wait)
    end
end)