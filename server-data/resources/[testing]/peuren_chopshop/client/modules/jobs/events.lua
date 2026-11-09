RegisterNetEvent('peuren_chopshop:CreateNewMission', function(data)
    Jobs.Set(data)
end)

RegisterNetEvent('peuren_chopshop:client:CreateDropOff', function(data)
    if not data then return end 
    Utils.CreateDropZone(data)
end)

RegisterNetEvent('peuren_chopshop:RemoveMission', function(data)
    Jobs.Remove(data)
end)