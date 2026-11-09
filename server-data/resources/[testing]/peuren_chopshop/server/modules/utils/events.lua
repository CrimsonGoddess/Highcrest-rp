RegisterNetEvent('peuren_chopshop:RegisterEntityBones', function(netId, bones)
    if not netId or not bones then return end 

    local entity = NetworkGetEntityFromNetworkId(netId)
    for _,bone in pairs(bones) do 
        Entity(entity).state["bones:"..bone] = { busy = false, chopped = false }
    end
end)

RegisterNetEvent('peuren_chopshop:SetEntityBoneData', function(netId, bone, data)
    if not netId or not data then return end 

    local entity = NetworkGetEntityFromNetworkId(netId)
    Entity(entity).state["bones:"..bone] = data
end)