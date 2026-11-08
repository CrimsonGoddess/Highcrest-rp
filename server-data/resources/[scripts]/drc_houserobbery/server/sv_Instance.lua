local instances = {}
local instanceIndex = 0

RegisterNetEvent("drc_houserobbery_instance:addEntityToPlayerInstance")
AddEventHandler("drc_houserobbery_instance:addEntityToPlayerInstance", function(entity)
    local src = source
    if DoesEntityExist(entity) then
        SetEntityRoutingBucket(entity, GetPlayerRoutingBucket(src))
    else
        SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(entity), GetPlayerRoutingBucket(src))
    end
end)

AddEventHandler("entityCreating", function(entity)
    local entityOwner = NetworkGetEntityOwner(entity)
    local entityOwnerBucket = GetPlayerRoutingBucket(entityOwner)

    if entityOwnerBucket ~= 0 then
        SetEntityRoutingBucket(entity, entityOwnerBucket)
    end
end)

RegisterNetEvent("drc_houserobbery_instance:joinInstance")
AddEventHandler("drc_houserobbery_instance:joinInstance", function(instance)
    local src = source
    playerJoinInstance(src, instance)
end)

RegisterNetEvent("drc_houserobbery_instance:quitInstance")
AddEventHandler("drc_houserobbery_instance:quitInstance", function()
    local src = source
    playerQuitInstance(src)
end)

function getPlayerInstance(player)
    local playerRoutingBucket = GetPlayerRoutingBucket(player)

    if playerRoutingBucket == 0 then
        return ""
    end

    return instances[tostring(playerRoutingBucket)]
end

function getInstances()
    return instances
end

function playerJoinInstance(player, instanceName)
    local playerRoutingBucket = GetPlayerRoutingBucket(player)

    if instanceName == "" then
        if playerRoutingBucket ~= 0 then
            playerQuitInstance(player)
        end
        return
    end

    local instanceId = createInstanceIfNotExists(instanceName)

    playerRoutingBucket = GetPlayerRoutingBucket(player)
    if playerRoutingBucket == instanceId then
        return
    elseif playerRoutingBucket ~= 0 then
        playerQuitInstance(player)
    end

    SetPlayerRoutingBucket(player, instanceId)
    TriggerClientEvent("drc_houserobbery_instance:onEnter", player, instanceName)

    if instanceId ~= 0 then
        SetRoutingBucketPopulationEnabled(instanceId, false)
    end
end

function playerQuitInstance(player)
    if GetPlayerRoutingBucket(player) ~= 0 then
        TriggerClientEvent("drc_houserobbery_instance:onLeave", player)
    end

    SetPlayerRoutingBucket(player, 0)
end

AddEventHandler("playerDropped", function()
        local src = source
        playerQuitInstance(src)
end)

function createInstanceIfNotExists(instanceName)
    for i, instance in pairs(instances) do
        if instance == instanceName then
            return tonumber(i)
        end
    end

    instanceIndex = instanceIndex + 1
    instances[tostring(instanceIndex)] = instanceName
    return instanceIndex
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end