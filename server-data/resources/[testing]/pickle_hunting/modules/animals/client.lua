IsPlacingAnimal = false
CarryingAnimal = nil
SpawnedAnimals = {} -- Used in some versions to track animals, though not heavily used here

function RequestNetworkControl(entity)
    NetworkRequestControlOfEntity(entity)
    local timeout = 2000
    while timeout > 0 do
        if NetworkHasControlOfEntity(entity) then break end
        Wait(100)
        timeout = timeout - 100
    end
    SetEntityAsMissionEntity(entity, true, true)
    timeout = 2000
    while timeout > 0 do
        if IsEntityAMissionEntity(entity) then break end
        Wait(100)
        timeout = timeout - 100
    end
    return NetworkHasControlOfEntity(entity)
end

function SkinAnimal(entity)
    if not RequestNetworkControl(entity) then return end
    
    local netId = PedToNet(entity)
    local model = GetEntityModel(entity)
    local animalCfg = Config.Animals[model]
    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)
    local eCoords = GetEntityCoords(entity)
    local dist = #(pCoords - eCoords)
    local _, currentWeapon = GetCurrentPedWeapon(playerPed, true)
    
    if not animalCfg then
        return ShowNotification(_L("animal_not_animal"))
    end
    
    if not NetworkDoesNetworkIdExist(netId) then
        return ShowNotification(_L("animal_not_net"))
    end
    
    if dist > 2.0 then
        return ShowNotification(_L("animal_not_near"))
    end
    
    if currentWeapon ~= -1716189206 then -- Knife hash
        return ShowNotification(_L("animal_not_knife"))
    end
    
    SpawnedAnimals[entity] = nil
    ClearPedTasksImmediately(playerPed)
    
    ServerCallback("pickle_hunting:skinAnimal", function(success)
        if success then
            ShowNotification(_L("animal_skinning"))
            local ped = PlayerPedId()
            PlayAnim(ped, "amb@medic@standing@kneel@idle_a", "idle_a", -8.0, 8.0, -1, 1, 1.0)
            PlayAnim(ped, "melee@knife@streamed_variations", "ground_attack_var_a", -8.0, 8.0, -1, 49, 1.0)
            FreezeEntityPosition(ped, true)
            
            lib.progressCircle({
                duration = animalCfg.skinTime * 1000,
                position = "bottom"
            })
            
            FreezeEntityPosition(ped, false)
            ShowNotification(_L("animal_skinned"))
            ClearPedTasksImmediately(ped)
        else
            ShowNotification(_L("animal_already_skinned"))
        end
    end, netId)
end

function ChopAnimal(entity, chopPointIdx)
    if not RequestNetworkControl(entity) then return end
    
    local netId = PedToNet(entity)
    local model = GetEntityModel(entity)
    local animalCfg = Config.Animals[model]
    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)
    local eCoords = GetEntityCoords(entity)
    local dist = #(pCoords - eCoords)
    
    if not animalCfg then
        return ShowNotification(_L("animal_not_animal"))
    end
    
    if not NetworkDoesNetworkIdExist(netId) then
        return ShowNotification(_L("animal_not_net"))
    end
    
    if dist > 2.0 then
        return ShowNotification(_L("animal_not_near"))
    end
    
    ClearPedTasksImmediately(playerPed)
    
    ServerCallback("pickle_hunting:chopAnimal", function(success)
        if success then
            ShowNotification(_L("animal_chopping"))
            DeletePed(entity)
            local ped = PlayerPedId()
            FreezeEntityPosition(ped, true)
            
            lib.progressCircle({
                duration = animalCfg.chopTime * 1000,
                position = "bottom"
            })
            
            FreezeEntityPosition(ped, false)
            ShowNotification(_L("animal_chopped"))
        else
            ShowNotification(_L("animal_cant_chop"))
        end
    end, chopPointIdx, netId)
end

function TrunkAnimal(entity)
    if not RequestNetworkControl(entity) then return end
    
    local model = GetEntityModel(entity)
    local animalCfg = Config.Animals[model]
    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)
    local eCoords = GetEntityCoords(entity)
    local dist = #(pCoords - eCoords)
    local vehicle = GetNearestVehicle()
    local nearbyAnimalsInTrunk = GetAnimals(4.0, GetEntityCoords(vehicle))
    
    if not animalCfg then
        return ShowNotification(_L("animal_not_animal"))
    end
    
    if dist > 2.0 then
        return ShowNotification(_L("animal_not_near"))
    end
    
    if DoesEntityExist(vehicle) then
        local vDist = #(pCoords - GetEntityCoords(vehicle))
        if vDist > 6.0 then
            return ShowNotification(_L("vehicle_not_near"))
        end
    else
        return ShowNotification(_L("vehicle_not_near"))
    end
    
    SpawnedAnimals[entity] = nil
    local attachedTo = GetEntityAttachedTo(entity)
    
    if attachedTo == vehicle then
        -- Detach from trunk
        ClearPedTasksImmediately(playerPed)
        local dropPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -5.0, 0.0)
        DetachEntity(entity, true, true)
        SetEntityHealth(entity, 0)
        SetEntityCoords(entity, dropPos.x, dropPos.y, dropPos.z - 1.0)
    else
        -- Attach to trunk
        if not IsEntityDead(entity) then
            return ShowNotification(_L("animal_not_dead"))
        end
        
        -- Check if already animal in trunk
        local alreadyInTrunk = false
        if #nearbyAnimalsInTrunk > 1 or (#nearbyAnimalsInTrunk == 1 and nearbyAnimalsInTrunk[1] ~= entity) then
             alreadyInTrunk = true
        end
        
        if alreadyInTrunk then
            return ShowNotification(_L("animal_in_trunk"))
        end
        
        CarryingAnimal = nil
        ClearPedTasksImmediately(playerPed)
        DetachEntity(entity, true, true)
        
        PlaceAnimal(entity, function(pos)
            local chassisBone = GetEntityBoneIndexByName(vehicle, "chassis")
            local localPos = GetOffsetFromEntityGivenWorldCoords(vehicle, pos.x, pos.y, pos.z)
            local offset = animalCfg.trunkOffset or vector3(0.0, 0.0, 0.0)
            localPos = localPos + offset
            
            local rotation = GetEntityRotation(entity, 2)
            local vPos = GetEntityCoords(vehicle)
            local distFromVeh = #(pos - vPos)
            
            if distFromVeh < 6 then
                ResurrectPed(entity)
                SetEntityHealth(entity, 0)
                local hOffset = animalCfg.headingOffset or 0.0
                AttachEntityToEntity(entity, vehicle, chassisBone, localPos.x, localPos.y, localPos.z, rotation.x, rotation.y, rotation.z + hOffset, false, false, false, true, 2, true)
            else
                ShowNotification(_L("animal_not_near"))
                ResurrectPed(entity)
                DetachEntity(entity, true, true)
                SetEntityHealth(entity, 0)
                local dropCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -5.0, 0.0)
                SetEntityCoords(entity, dropCoords.x, dropCoords.y, dropCoords.z - 1.0)
            end
        end)
    end
end

function CarryAnimal(entity)
    if not RequestNetworkControl(entity) then return end
    
    local model = GetEntityModel(entity)
    local animalCfg = Config.Animals[model]
    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)
    local eCoords = GetEntityCoords(entity)
    local dist = #(pCoords - eCoords)
    
    if not animalCfg then
        return ShowNotification(_L("animal_not_animal"))
    end
    
    if dist > 2.0 then
        return ShowNotification(_L("animal_not_near"))
    end
    
    local attachedTo = GetEntityAttachedTo(entity)
    if attachedTo == playerPed then
        -- Drop animal
        local dropPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.0)
        DetachEntity(CarryingAnimal, true, true)
        SetEntityHealth(CarryingAnimal, 0)
        SetEntityCoords(CarryingAnimal, dropPos.x, dropPos.y, dropPos.z - 1.0)
        CarryingAnimal = nil
        ClearPedTasksImmediately(playerPed)
        
        if STATUS and STATUS.INSIDE_CHOP_POINT then
            ChopAnimal(entity, STATUS.INSIDE_CHOP_POINT)
        end
    else
        -- Pick up animal
        if not IsEntityDead(entity) then
            return ShowNotification(_L("animal_not_dead"))
        end
        
        if CarryingAnimal then return end
        
        CarryingAnimal = entity
        local boneIdx = GetPedBoneIndex(playerPed, animalCfg.player.boneID)
        local offset = animalCfg.player.offset
        local rotation = animalCfg.player.rotation
        
        ResurrectPed(entity)
        SetEntityHealth(entity, 0)
        ClearPedTasksImmediately(playerPed)
        AttachEntityToEntity(entity, playerPed, boneIdx, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, false, false, false, true, 2, true)
        PlayAnim(playerPed, "anim@heists@box_carry@", "idle", -8.0, 8.0, -1, 49, 1.0)
    end
    SpawnedAnimals[entity] = nil
end

function GetAnimals(radius, coords)
    local list = {}
    coords = coords or GetEntityCoords(PlayerPedId())
    local peds = GetGamePool("CPed")
    for _, ped in ipairs(peds) do
        local model = GetEntityModel(ped)
        if Config.Animals[model] then
            if not radius or #(GetEntityCoords(ped) - coords) <= radius then
                table.insert(list, ped)
            end
        end
    end
    return list
end

function GetNearestAnimal()
    local closest = nil
    local pCoords = GetEntityCoords(PlayerPedId())
    local animals = GetAnimals()
    
    for _, animal in ipairs(animals) do
        local dist = #(GetEntityCoords(animal) - pCoords)
        if not closest or dist < closest.dist then
            closest = { entity = animal, dist = dist }
        end
    end
    
    if not closest then return nil end
    return closest.entity, closest.dist
end

RegisterCommand("skinanimal", function()
    local entity = GetNearestAnimal()
    SkinAnimal(entity)
end)

RegisterCommand("trunkanimal", function()
    local entity = GetNearestAnimal()
    TrunkAnimal(entity)
end)

RegisterCommand("carryanimal", function()
    local entity = GetNearestAnimal()
    CarryAnimal(entity)
end)

function GetDirectionFromRotation(rotation)
    local rad = math.pi / 180
    return vector3(
        -math.sin(rad * rotation.z) * math.abs(math.cos(rad * rotation.x)),
         math.cos(rad * rotation.z) * math.abs(math.cos(rad * rotation.x)),
         math.sin(rad * rotation.x)
    )
end

function GetDirectionCoords()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local dir = GetDirectionFromRotation(camRot)
    local targetCoords = camCoords + (dir * 1000.0)
    local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, -1, -1, 1)
    local _, hit, hitCoords, _, hitEntity = GetShapeTestResult(ray)
    return hit, hitCoords, hitEntity
end

function PlaceAnimal(entity, callback)
    if IsPlacingAnimal then
        if callback then callback(nil, true) end
        return
    end
    
    if not callback then return end
    
    IsPlacingAnimal = true
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    FreezeEntityPosition(entity, true)
    SetEntityCollision(entity, false, false)
    
    CreateThread(function()
        local currentCoords = coords
        while IsPlacingAnimal do
            local hit, pos, ent = GetDirectionCoords()
            if hit and pos then
                currentCoords = pos + vector3(0.0, 0.0, 0.04)
                SetEntityCoords(entity, currentCoords.x, currentCoords.y, currentCoords.z)
                SetEntityRotation(entity, 0.0, 0.0, GetGameplayCamRot(2).z, 2)
                
                if IsControlJustPressed(1, 51) then
                    IsPlacingAnimal = false
                end
            end
            Wait(0)
        end
        
        FreezeEntityPosition(entity, false)
        SetEntityCollision(entity, true, true)
        callback(currentCoords)
    end)
end
