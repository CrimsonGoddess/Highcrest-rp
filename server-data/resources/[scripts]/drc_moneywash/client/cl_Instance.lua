local currentInstance = ""

RegisterNetEvent("drc_moneywash_instance:onEnter")
AddEventHandler("drc_moneywash_instance:onEnter", function(instance)
    currentInstance = instance
end)

RegisterNetEvent("drc_moneywash_instance:onLeave")
AddEventHandler("drc_moneywash_instance:onLeave", function()
    currentInstance = ""
end)

function getPlayerInstance()
    return currentInstance
end