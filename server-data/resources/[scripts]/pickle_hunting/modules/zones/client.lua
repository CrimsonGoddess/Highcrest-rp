SpawnedAnimals = {}

function GetRandomSpawnpoint(location, radius)
    local x = math.ceil(location.x)
    local y = math.ceil(location.y)
    local r = math.ceil(radius)
    
    local randX = math.random(x - r, x + r)
    local randY = math.random(y - r, y + r)
    
    local dist = #(vector2(location.x, location.y) - vector2(randX, randY))
    if dist > radius then
        return GetRandomSpawnpoint(location, radius)
    end
    
    local success, groundZ = GetGroundZFor_3dCoord(randX + 0.1, randY + 0.1, location.z + 100.0)
    return vector3(randX, randY, groundZ)
end

function GetAnimalsInZone(zoneIdx)
    local zone = Config.HuntingZones[zoneIdx]
    local list = {}
    local peds = GetGamePool("CPed")
    for _, ped in ipairs(peds) do
        local model = GetEntityModel(ped)
        local coords = GetEntityCoords(ped)
        local dist = #(zone.location - coords)
        if dist < zone.radius then
            if zone.animals[model] then
                table.insert(list, { model = model, entity = ped })
            end
        end
    end
    return list
end

function SpawnRandomAnimal(zoneIdx)
    local zone = Config.HuntingZones[zoneIdx]
    local spawnPos = GetRandomSpawnpoint(zone.location, zone.radius)
    
    local selectedModel = nil
    repeat
        for model, data in pairs(zone.animals) do
            local roll = math.random(1, 100)
            if roll <= data.Chance then
                selectedModel = model
            end
        end
    until selectedModel
    
    local ped = CreateNPC(28, selectedModel, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, true)
    Wait(1000)
    TaskWanderStandard(ped, 10.0, 10)
    SetModelAsNoLongerNeeded(selectedModel)
    SpawnedAnimals[ped] = zoneIdx
    return ped
end

CreateThread(function()
    for i, zone in ipairs(Config.HuntingZones) do
        if zone.blip then
            if zone.blip.Radius then
                zone.blip.Radius.Size = zone.radius
            end
            CreateBlip(zone.blip)
        end
    end

    while true do
        local sleep = 1000
        local pCoords = GetEntityCoords(PlayerPedId())
        local playerPed = PlayerPedId()
        
        for i, zone in ipairs(Config.HuntingZones) do
            local dist = #(zone.location - pCoords)
            local animalsInZone = GetAnimalsInZone(i)
            
            if dist < zone.radius * 2 then
                -- Handle existing animals behavior
                for _, animalData in ipairs(animalsInZone) do
                    local aCoords = GetEntityCoords(animalData.entity)
                    local aDist = #(pCoords - aCoords)
                    
                    if aDist < Config.ActionDistance then
                        -- Check if animal is aggressive (defined in Config.Animals)
                        if Config.Animals[animalData.model] then
                            TaskCombatPed(animalData.entity, playerPed, 0, 16)
                        else
                            TaskReactAndFleePed(animalData.entity, playerPed)
                        end
                    end
                end
                
                -- Spawn new animals if needed
                if #animalsInZone < zone.maxAnimals then
                    SpawnRandomAnimal(i)
                end
            end
        end
        
        -- Cleanup animals that wandered out of bounds or no longer exist
        for entity, zoneIdx in pairs(SpawnedAnimals) do
            local zone = Config.HuntingZones[zoneIdx]
            if DoesEntityExist(entity) then
                local eCoords = GetEntityCoords(entity)
                local dist = #(zone.location - eCoords)
                if dist > zone.radius then
                    DeleteEntity(entity)
                    SpawnedAnimals[entity] = nil
                end
            else
                SpawnedAnimals[entity] = nil
            end
        end
        
        Wait(sleep)
    end
end)
