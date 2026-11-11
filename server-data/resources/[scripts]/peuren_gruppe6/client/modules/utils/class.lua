Utils = {
    Data = {},
    
    ---Laods model
    ---@param model string
    LoadModel = function(model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
    end,

    ---Loads animation dictionaries
    ---@param dict string
    LoadAnimDict = function(dict)
        while not HasAnimDictLoaded(dict) do
            RequestAnimDict(dict)
            Wait(100)
        end
    end,

    ---Creates blip
    ---@param type string 
    ---@param pos vector3 
    CreateBlip = function(type, pos)
        local blip = Config.Blips[type]

        local xPos = blip.radius.enabled and pos.x + blip.radius.offsets or pos.x 
        local yPos = blip.radius.enabled and pos.y + blip.radius.offsets or pos.y

        if not Utils.Data.blip then Utils.Data.blip = {} end 
        if not Utils.Data.radiusBlip then Utils.Data.radiusBlip = {} end 
    
        if blip.radius.enabled then 
            Utils.Data.radiusBlip[type] = {}
            local Radius = AddBlipForRadius(xPos, yPos, 0.0, blip.radius.radius + 0.0)
            SetBlipSprite(Radius, blip.radius.sprite)
            SetBlipColour(Radius, blip.radius.color + 0.0)
            SetBlipAlpha(Radius, 80) 
            Utils.Data.radiusBlip[type] = Radius
        end
    
        Utils.Data.blip[type] = {}
        local Blip = AddBlipForCoord(xPos, yPos, pos.z)
        SetBlipSprite(Blip, blip.sprite)
        SetBlipDisplay(Blip, 4)
        SetBlipColour(Blip, blip.color)
        SetBlipScale(Blip, blip.scale + 0.0)
        SetBlipAsShortRange(Blip, false) -- Highcrest: HQ and job blips show on the whole map
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blip.label)
        EndTextCommandSetBlipName(Blip)
        if blip.route then 
            SetBlipRoute(Blip, true)
        end
        Utils.Data.blip[type] = Blip
    end, 

    ---Removes created blips
    ---@param type string
    RemoveBlip = function(type)
        if not Utils.Data then return end

        if Utils.Data.radiusBlip[type] then
            RemoveBlip(Utils.Data.radiusBlip[type])        
        end

        if Utils.Data.blip[type] then   
            RemoveBlip(Utils.Data.blip[type])
        end
    end,

    ---Spawns ped
    ---@param type string
    ---@param model string
    ---@param pos vector4
    ---@return number
    SpawnPed = function(type, model, pos)     
        if not Utils.Data.ped then Utils.Data.ped = {} end        

        Utils.LoadModel(model)        
        local ped = CreatePed(4, model, pos.x, pos.y, pos.z - 1.0, pos.w, false, false)
        while not DoesEntityExist(ped) do Wait(100) end
        
        Utils.Data.ped[type] = ped     

        FreezeEntityPosition(ped, true)
        SetPedCanRagdoll(ped, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 17, true)
        SetEntityInvincible(ped, true)
        SetPedSeeingRange(ped, 0)
        return ped
    end,

    ---Removes spawned ped
    ---@param type string
    RemovePed = function(type)
        if not type then return end
        if not Utils.Data then return end
        if not Utils.Data.ped[type] then return end
        local entity = Utils.Data.ped[type]                    
        Interactions.Delete(Jobs.Data.args.groupId, 'pickup', entity)
        ClearPedTasks(entity)
        FreezeEntityPosition(entity, false)
        TaskWanderStandard(entity, 10.0, 10)

        CreateThread(function()
            Wait(10000)
            DeletePed(entity)
        end)

        Utils.Data.ped[type] = nil
    end,

    ---Gets if a spawnpoint is clear of vehicles or objects
    ---@param pos vector3
    ---@param radius number
    ---@return boolean
    ---@return string 
    IsSpawnPointClear = function(pos, radius)
        -- Check for vehicles in the vicinity
        for _, vehicle in pairs(GetGamePool('CVehicle')) do
            local distance = #(pos - GetEntityCoords(vehicle))
            if distance < radius then
                return false, "Vehicle nearby"
            end
        end

        -- Check for objects in the vicinity
        for _, object in pairs(GetGamePool('CObject')) do
            local distance = #(pos - GetEntityCoords(object))
            if distance < radius then
                return false, "Object nearby"
            end
        end

        return true, "Spawn point clear"
    end,  

    ---Gets available spawnpoints to spawn vehicles, packages, pallets, etc.
    ---@param spawns table
    ---@return vector3 | nil
    ---@return number | nil
    GetAvailableSpawn = function(spawns)
        local pos, heading = nil, nil
    
        for _,v in pairs(spawns) do
            if Utils.IsSpawnPointClear(v.pos, 2) then 
                pos = v.pos
                heading = v.heading
                return pos, heading
            end
        end
    
        return pos, heading
    end,

    SpawnTrolley = function(pos)
        local model = 'hei_prop_hei_cash_trolly_01'

        Utils.LoadModel(model)   
        local trolley = CreateObject(GetHashKey(model), pos.x, pos.y, pos.z, true, true, false)    
        while not DoesEntityExist(trolley) do Wait(100) end
        PlaceObjectOnGroundProperly(trolley)
        SetEntityHeading(trolley, pos.w)

        local id = Jobs.Data.args.groupId
        local netId = NetworkGetNetworkIdFromEntity(trolley)
        States.Register(id, 'trolley', { netId = netId, state = { busy = false }}) 
        Interactions.Register(id, 'trolley', netId)   
        return trolley    
    end,

    SpawnBag = function(pos)      
        local id = Jobs.Data.args.groupId  
        local model = Config.Jobs[Jobs.Data.args.job].bag.model
        Utils.LoadModel(model)  
        local bag = CreateObjectNoOffset(model, pos.x, pos.y, pos.z + 2, true, true, false)
        while not DoesEntityExist(bag) do Wait(100) end
        PlaceObjectOnGroundProperly(bag)
        SetEntityHeading(bag, pos.w)
        FreezeEntityPosition(bag, true)

        local netId = NetworkGetNetworkIdFromEntity(bag)       
        States.Register(id, 'bag', { netId = netId, state = { busy = false }}) 
        Interactions.Register(id, 'bag', netId)
        return bag
    end,

    SpawnContainer = function(pos)
        pos = vector4(pos.x, pos.y, pos.z - 1.0, pos.w)
        local rot = pos.w
        local cSettings = Config.Jobs[Jobs.Data.args.job].container

        if not cSettings then return end
        local container = CreateObject(GetHashKey(cSettings.model), pos.x, pos.y, pos.z, true, true, false)
        while not DoesEntityExist(container) do Citizen.Wait(1000) end
        PlaceObjectOnGroundProperly(container)
        SetEntityHeading(container, rot)
        local minimum, maximum = GetModelDimensions(GetHashKey(cSettings.model))
        local pos = vector3(pos.x, pos.y, pos.z)
        minimum = minimum + pos
        maximum = maximum + pos
        local size = maximum - minimum
        local offset = GetOffsetFromEntityInWorldCoords(container, -size.x / 2 + 0.023, -size.y / 2, size.z)
        local lDoorPos = vector3(offset.x, offset.y, offset.z - size.z)
        offset = GetOffsetFromEntityInWorldCoords(container, size.x / 2 - 0.023, -size.y / 2, size.z)
        local rDoorPos = vector3(offset.x, offset.y, offset.z - size.z)
        FreezeEntityPosition(container, true)
        local doorLeft = CreateObject(GetHashKey(cSettings.doors.left), lDoorPos.x, lDoorPos.y, lDoorPos.z + 0.1, true, true, false)
        local doorRight = CreateObject(GetHashKey(cSettings.doors.right), rDoorPos.x, rDoorPos.y, rDoorPos.z + 0.1, true, true, false)
        while not DoesEntityExist(doorLeft) or not DoesEntityExist(doorRight) do Citizen.Wait(10) end
        SetEntityHeading(doorLeft, rot)
        SetEntityHeading(doorRight, rot)
        SetObjectTextureVariant(container, cSettings.color)
        SetObjectTextureVariant(doorLeft, cSettings.color)
        SetObjectTextureVariant(doorRight, cSettings.color)
        
        container = NetworkGetNetworkIdFromEntity(container)
        doorLeft = NetworkGetNetworkIdFromEntity(doorLeft)
        doorRight = NetworkGetNetworkIdFromEntity(doorRight)

        Interactions.Register(Jobs.Data.args.groupId, 'container', container, {
            leftDoor = doorLeft,
            rightDoor = doorRight,
        })
        States.Register(Jobs.Data.args.groupId, 'container', { netId = container, states = { opened = false, doors = { leftDoor = doorLeft, rightDoor = doorRight } } }) 
        return container
    end,

    ToggleContainerDoor = function(open, leftDoor, rightDoor)
        leftDoor = NetworkGetEntityFromNetworkId(leftDoor)
        rightDoor = NetworkGetEntityFromNetworkId(rightDoor)

        local rotationDiff = 0
        local rotatePerTick = 1.0
        while rotationDiff < 100.0 do
            local currRotOne = GetEntityHeading(leftDoor)
            local currRotTwo = GetEntityHeading(rightDoor)
            rotationDiff = rotationDiff + rotatePerTick
            if open then 
                SetEntityHeading(leftDoor, currRotOne - rotatePerTick)
                SetEntityHeading(rightDoor, currRotTwo + rotatePerTick)
            else 
                SetEntityHeading(leftDoor, currRotOne + rotatePerTick)
                SetEntityHeading(rightDoor, currRotTwo - rotatePerTick)
            end

            Wait(10)
        end        
    end,

    TakeFromTrolley = function(trolley)
        local ped = PlayerPedId()
        local model = "hei_prop_heist_cash_pile"
        local pPos = GetEntityCoords(ped)   

        Utils.LoadModel(model)   
        local money = CreateObject(model, pPos.x, pPos.y, pPos.z, true, true, false)
        while not DoesEntityExist(money) do Wait(100) end
        FreezeEntityPosition(money, true)
        SetEntityInvincible(money, true)
        SetEntityVisible(money, false, false)
        SetEntityNoCollisionEntity(money, ped, false)
        AttachEntityToEntity(money, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
        local started = GetGameTimer()

        CreateThread(function()
            while GetGameTimer() - started < 37000 do
                Wait(1)
                DisableControlAction(0, 73, true)
                if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
                    if not IsEntityVisible(money) then
                        SetEntityVisible(money, true, false)
                    end
                end
                if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
                    if IsEntityVisible(money) then
                        SetEntityVisible(money, false, false)
                    end
                end
            end
            DeleteObject(money)
        end)

        local emptyobj = GetHashKey("hei_prop_hei_cash_trolly_03")
        local baghash = GetHashKey("hei_p_m_bag_var22_arm_s")
        local dict = "anim@heists@ornate_bank@grab_cash"
    
        if IsEntityPlayingAnim(trolley, dict, "cart_cash_dissapear", 3) then
            return
        end

        Utils.LoadAnimDict(dict)
        Utils.LoadModel(baghash) 
        Utils.LoadModel(emptyobj) 
  
        while not NetworkHasControlOfEntity(trolley) do
            Citizen.Wait(1)
            NetworkRequestControlOfEntity(trolley)
        end

        local bag = CreateObject(baghash, pPos.x, pPos.y, pPos.z, true, true, false)
        local scene1 = NetworkCreateSynchronisedScene(GetEntityCoords(trolley), GetEntityRotation(trolley), 2, false, false, 1065353216, 0, 1.3)
    
        NetworkAddPedToSynchronisedScene(ped, scene1, dict, "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(bag, scene1, dict, "bag_intro", 4.0, -8.0, 1)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        NetworkStartSynchronisedScene(scene1)
        Citizen.Wait(1500)
        local scene2 = NetworkCreateSynchronisedScene(GetEntityCoords(trolley), GetEntityRotation(trolley), 2, false, false, 1065353216, 0, 1.3)
    
        NetworkAddPedToSynchronisedScene(ped, scene2, dict, "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(bag, scene2, dict, "bag_grab", 4.0, -8.0, 1)
        NetworkAddEntityToSynchronisedScene(trolley, scene2, dict, "cart_cash_dissapear", 4.0, -8.0, 1)
        NetworkStartSynchronisedScene(scene2)
        Citizen.Wait(37000)
        local scene3 = NetworkCreateSynchronisedScene(GetEntityCoords(trolley), GetEntityRotation(trolley), 2, false, false, 1065353216, 0, 1.3)
    
        NetworkAddPedToSynchronisedScene(ped, scene3, dict, "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(bag, scene3, dict, "bag_exit", 4.0, -8.0, 1)
        NetworkStartSynchronisedScene(scene3)
        NewTrolley = CreateObject(emptyobj, GetEntityCoords(trolley) + vector3(0.0, 0.0, - 0.985), true, false, false)

        SetEntityRotation(NewTrolley, GetEntityRotation(trolley))
        while not NetworkHasControlOfEntity(trolley) do
            Citizen.Wait(1)
            NetworkRequestControlOfEntity(trolley)
        end
        DeleteObject(trolley)
        local netId = NetworkGetNetworkIdFromEntity(NewTrolley)
        PlaceObjectOnGroundProperly(NewTrolley)

        local id = Jobs.Data.args.groupId
        States.Register(id, 'trolley', { netId = netId, state = { busy = false }}) 
        
        Citizen.Wait(1800)
        DeleteObject(bag)
        SetPedComponentVariation(ped, 5, 45, 0, 0)
        RemoveAnimDict(dict)
        SetModelAsNoLongerNeeded(emptyobj)
        SetModelAsNoLongerNeeded(baghash)
    end,

    ---Gets last attached entity to an entity
    ---@param id string
    ---@param entity number
    ---@param type string
    ---@return number | nil
    GetAttachedEntity = function(id, entity, type)
        local netId = NetworkGetNetworkIdFromEntity(entity)
        local data = States.Get(id, netId)
        local entities = {}
        if not data then return end
        
        for _, v in pairs(States.Data[id]) do 
            if v.type == type and v.states.attached == data.type then 
                entities[#entities + 1] = NetworkGetEntityFromNetworkId(v.netId)
            end
        end 

        return entities[#entities]
    end,

    ---Object pickup handler
    ---@param id string
    ---@param type string
    ---@param entity number | nil
    PickUpObject = function(id, type, entity, attached)
        local job = Jobs.Data.args.job
        local data = Config.Jobs[job].bag  
        local netId = nil

        if data.item then 
            Utils.LoadAnimDict("veh@common@motorbike@low@ps")
            TaskPlayAnim(PlayerPedId(), "veh@common@motorbike@low@ps", "pickup", 2.0, 2.0, -1, 51, 0, false, false, false)
            Wait(500)
            ClearPedTasks(PlayerPedId())
            
            Utils.GiveBag(1)
            print('entity:', entity)
            if entity and DoesEntityExist(entity) then 
                DeleteEntity(entity)
            end
            return
        end
        
        if attached then 
            entity = Utils.GetAttachedEntity(id, entity, type) or entity
            if not entity then return end
            netId = NetworkGetNetworkIdFromEntity(entity)
        else 
            netId = NetworkGetNetworkIdFromEntity(entity)
        end
        
        if not netId or not entity then return end        
        local ped = PlayerPedId()

        Utils.LoadAnimDict("veh@common@motorbike@low@ps")
        TaskPlayAnim(ped, "veh@common@motorbike@low@ps", "pickup", 2.0, 2.0, -1, 51, 0, false, false, false)
        Wait(500)
        ClearPedTasks(ped)

        States.Remove(id, netId)
        DeleteEntity(entity)
        local clohting = IsPedMale(ped) and data.clothing.male or data.clothing.female
        SetPedComponentVariation(ped, clohting.id, clohting.drawable, clohting.texture, 0)

        CreateThread(function()
            Cache.Set(id, 'holding', { state = false })
            Cache.Set(id, 'caryying', { state = true, type = type, netId = netId })

            while Cache.Get(id, 'caryying').state do
                lib.TextUI.Draw(lib.Locale('textui_carry_place'))

                if IsControlJustPressed(1, Config.Keybinds.placeBag) then    
                    if IsPedInAnyVehicle(ped, true) then goto continue end   

                    lib.TextUI.Stop()                    
                    Cache.Set(id, 'caryying', { state = false, type = nil, netId = nil })   
                    Utils.LoadAnimDict("veh@common@motorbike@low@ps")
                    TaskPlayAnim(ped, "veh@common@motorbike@low@ps", "pickup", 2.0, 2.0, -1, 51, 0, false, false, false)
                    Wait(500)
                    ClearPedTasks(ped)

                    local clohting = IsPedMale(ped) and data.clothing.male or data.clothing.female
                    SetPedComponentVariation(ped, clohting.id, 0, 0, 0)

                    local pos, heading = GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId())
                    local package = CreateObjectNoOffset(GetHashKey(data.model), pos.x - 0.5, pos.y, pos.z, true, true, false)

                    PlaceObjectOnGroundProperly(package)        
                    SetEntityHeading(package, heading)
                    FreezeEntityPosition(package, true)

                    local netId = NetworkGetNetworkIdFromEntity(package)
                    States.Register(id, 'bag', { netId = netId })
                    Interactions.Register(id, 'bag', netId)
                end
                
                :: continue ::
                Wait(1)
            end
            local clohting = IsPedMale(ped) and data.clothing.male or data.clothing.female
            SetPedComponentVariation(ped, clohting.id, 0, 0, 0)
            lib.TextUI.Stop()
            ClearPedTasks(ped)
        end)
    end,

    TabletAnimation = function()
        if not UI.isOpen then return end
        local tabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
        local tabletAnim = "base"
        local tabletProp = `prop_cs_tablet`
        local tabletBone = 60309
        local tabletOffset = vector3(0.03, 0.002, -0.0)
        local tabletRot = vector3(10.0, 160.0, 0.0)
        -- Animation
        RequestAnimDict(tabletDict)
        while not HasAnimDictLoaded(tabletDict) do Citizen.Wait(100) end
        -- Model
        RequestModel(tabletProp)
        while not HasModelLoaded(tabletProp) do Citizen.Wait(100) end
    
        local plyPed = PlayerPedId()
        local tabletObj = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)
        local tabletBoneIndex = GetPedBoneIndex(plyPed, tabletBone)
    
        AttachEntityToEntity(tabletObj, plyPed, tabletBoneIndex, tabletOffset.x, tabletOffset.y, tabletOffset.z, tabletRot.x, tabletRot.y, tabletRot.z, true, false, false, false, 2, true)
        SetModelAsNoLongerNeeded(tabletProp)
    
        CreateThread(function()
            while UI.isOpen do
                Wait(0)
                if not IsEntityPlayingAnim(plyPed, tabletDict, tabletAnim, 3) then
                    TaskPlayAnim(plyPed, tabletDict, tabletAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
                end
            end    
    
            ClearPedSecondaryTask(plyPed)
            Citizen.Wait(250)
            DetachEntity(tabletObj, true, false)
            DeleteEntity(tabletObj)
        end)
    end,

    GiveBag = function(amount)
        if not amount then return end        
        local bag = Config.Jobs[Jobs.Data.args.job].bag
        if not bag.item then return end 
        local result = lib.Framework.Callbacks.Trigger("peuren_gruppe6:AddItem", bag.item, amount)
        return result
    end,

    RemoveBag = function(amount)
        if not amount then return end
        local bag = Config.Jobs[Jobs.Data.args.job].bag
        if not bag.item then return end 
        local result = lib.Framework.Callbacks.Trigger("peuren_gruppe6:RemoveItem", bag.item, amount)
        return result
    end,
}