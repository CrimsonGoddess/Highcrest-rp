local currentInstance = ""

RegisterNetEvent("drc_houserobbery_instance:onEnter")
AddEventHandler("drc_houserobbery_instance:onEnter", function(instance)
    currentInstance = instance
end)

RegisterNetEvent("drc_houserobbery_instance:onLeave")
AddEventHandler("drc_houserobbery_instance:onLeave", function()
    currentInstance = ""
end)

function getPlayerInstance()
    return currentInstance
end