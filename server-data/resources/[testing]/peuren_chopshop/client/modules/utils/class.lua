Utils = {
    Data = {},

    Bones = {
        seat_dside_f = 0,
        seat_dside_r = 2,
        seat_pside_f = 1,
        seat_pside_r = 3,
        bonnet = 4,
        boot = 5,
    },

    WheelBones = {
		wheel_lf = 0,
		wheel_rf = 1,
		wheel_lm1 = 2,
		wheel_rm1 = 3,
		wheel_lm2 = 45,
		wheel_rm2 = 47,
		wheel_lm3 = 46,
		wheel_rm3 = 48,
		wheel_lr = 2,
		wheel_rr = 3,
    },

    Animtaions = {
        wheel = {
            clip = 'machinic_loop_mechandplayer',
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'
        },
        seat = {
            scenario = 'WORLD_HUMAN_WELDING'
        },
        bonnet = {
            scenario = 'WORLD_HUMAN_WELDING'
        },
        boot = {
            scenario = 'WORLD_HUMAN_WELDING'
        },
        chassis = {
            scenario = 'WORLD_HUMAN_WELDING'
        },
        engine = {
            clip = 'fixing_a_ped',
            dict = 'mini@repair'
        }
    },

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

    SpawnGuardAnimal = function(model, pos)    
        local AGGRESSIVE_GROUP = "AGGRESSIVE"
        AddRelationshipGroup(AGGRESSIVE_GROUP)
        
        Utils.LoadModel(model)
        local pPed = PlayerPedId()
        local dog = CreatePed(0, model, pos.x + 5, pos.y + 5, pos.z, 0.0, true, true)
    
        SetPedCombatAttributes(dog, 46, 1)
        SetPedFleeAttributes(dog, 0, 0)
        SetPedCombatRange(dog, 2)
        SetPedRelationshipGroupHash(dog, GetHashKey(AGGRESSIVE_GROUP))
        SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey(AGGRESSIVE_GROUP))
        SetRelationshipBetweenGroups(5, GetHashKey(AGGRESSIVE_GROUP), GetHashKey("PLAYER"))
        TaskCombatPed(dog, pPed, 0, 16)
        SetPedKeepTask(pPed, true)
    end,
    

    ToggleAnimation = function(bone, state)
        if not bone then return end
        local type = ""

        for k, _ in pairs(Utils.Animtaions) do 
            if not string.find(bone, k) then goto continue end
            type = k
            :: continue ::
        end

        if not Utils.Animtaions[type] then return end 

        if state then 
            if Utils.Animtaions[type].scenario then 
                FreezeEntityPosition(PlayerPedId(), true)
                TaskStartScenarioInPlace(PlayerPedId(), Utils.Animtaions[type].scenario, 0, true)
            else
                FreezeEntityPosition(PlayerPedId(), true)
                Utils.LoadAnimDict(Utils.Animtaions[type].dict)
                TaskPlayAnim(PlayerPedId(), Utils.Animtaions[type].dict, Utils.Animtaions[type].clip, 3.0, 1.0, -1, 0, 0, false, false, false)
                RemoveAnimDict(Utils.Animtaions[type].dict)
            end
        else 
            FreezeEntityPosition(PlayerPedId(), false)
            ClearPedTasks(PlayerPedId())
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
        SetBlipAsShortRange(Blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blip.label)
        EndTextCommandSetBlipName(Blip)
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

    HasVehicleBeenChopped = function(inZone, bones, data)
        if not inZone then return end
        if not data.client then return end
        if not data.client.vehicle.netId then return end

        local netId = data.client.vehicle.netId
        local veh = NetworkGetEntityFromNetworkId(netId)
        local chopped = 0
        
        
        for _, bone in pairs(bones) do 
            if not Entity(veh).state["bones:"..bone] then goto continue end 
            
            if Entity(veh).state["bones:"..bone].chopped == nil then 
                chopped += 1
            end

            :: continue ::
        end

        return chopped == #bones
    end,

    ChopVehicle = function(inZone, bone, data)
        if not inZone or not bone then return end
        if not data.client then return end
        if not data.client.vehicle.netId then return end

        if Config.Disassemble.requiredItem then 
            local result = lib.Framework.Callbacks.Trigger('peuren_chopshop:HasPlayerItem', Config.Disassemble.requiredItem)
            if not result then 
                lib.Notify(lib.Locale("notify_dont_have_item"), nil, "error")
                return 
            end
        end

        local netId = data.client.vehicle.netId
        local veh = NetworkGetEntityFromNetworkId(netId)

        if Entity(veh).state["bones:"..bone] then 
            if Entity(veh).state["bones:"..bone].busy then 
                lib.Notify(lib.Locale("someones_chopping_part"), nil, "error")
                return 
            end

            if Entity(veh).state["bones:"..bone].chopped then
                lib.Notify(lib.Locale("part_chopped"), nil, "error")
                return 
            end
        end

        if Utils.Bones[bone] then 
            SetVehicleDoorOpen(veh, Utils.Bones[bone], true, true)
        end
        
        Utils.ToggleAnimation(bone, true)
        TriggerServerEvent('peuren_chopshop:SetEntityBoneData', netId, bone, { busy = true })

        local skill = lib.Framework.Callbacks.Trigger('peuren_chopshop:GetPlayerSkill', 'disassemble')
        if not skill then return end
        local completeTime = Config.Skills['disassemble'].Levels[skill.Level].completeTime 

        lib.ProgressBar(lib.Locale("chopping"), completeTime, {
            disableCarMovement = true,
            disableMouse = true,
            disableCombat = true
        })

        Utils.ToggleAnimation(bone, false)
        lib.Framework.Callbacks.Trigger('peuren_chopshop:SetPlayerSkill', 'disassemble', true)
        
        if bone == "chassis" then return Jobs.Remove(data) end 
        if string.find(bone, "wheel") then 
            BreakOffVehicleWheel(veh, Utils.WheelBones[bone], true, true, true, false)
            lib.Framework.Callbacks.Trigger('peuren_chopshop:AddItem', data.dealer, data.location.class, bone)
            return 
        end
        
        SetVehicleDoorBroken(veh, Utils.Bones[bone], true)  
        TriggerServerEvent('peuren_chopshop:SetEntityData', netId, bone, { busy = false, chopped = true })
        lib.Framework.Callbacks.Trigger('peuren_chopshop:AddItem', data.dealer, data.location.class, bone)
    end,

    CanChopBone = function(entity, bone)
        if not Entity(entity).state["bones:"..bone] then return true end
        if bone == 'engine' then
            return Entity(entity).state["bones:bonnet"].chopped == nil and not Entity(entity).state["bones:"..bone].busy
        end
        return not Entity(entity).state["bones:"..bone].busy and not Entity(entity).state["bones:"..bone].chopped
    end,

    CreateDropZone = function(data)
        local bones = data.location.bones
        local inZone = false           
        
        local netId = data.client.vehicle.netId
        TriggerServerEvent('peuren_chopshop:RegisterEntityBones', netId, bones)

        local pos = data.client.dropOff.pos
        local radius = data.client.dropOff.radius

        data.client.zone = lib.Poly.AddCircularZone(pos, radius, function(entered)
            inZone = entered

            if entered then 
                lib.Notify(lib.Locale("chop_zone_entered"), nil, "success")
            else 
                lib.Notify(lib.Locale("chop_zone_left"), nil, "error")
            end
        end)

        for _, bone in pairs(bones) do
            local id = math.random(100, 999)
            lib.Target.AddBone(bone, {
                {
                    name = bone..id,
                    icon = "fas fa-wrench",
                    label = lib.Locale('disassemble_part'),
                    onSelect = function()
                        Utils.ChopVehicle(inZone, bone, data)
                    end,
                    canInteract = function(entity)
                        local veh = NetworkGetEntityFromNetworkId(netId)
                        if entity ~= veh then return end
                        return inZone and Utils.CanChopBone(veh, bone)     
                    end
                },
                {
                    name = bone..id,
                    icon = "fas fa-wrench",
                    label = lib.Locale('disassemble_frame'),
                    onSelect = function()
                        Utils.ChopVehicle(inZone, 'chassis', data)
                    end,
                    canInteract = function(entity)
                        local veh = NetworkGetEntityFromNetworkId(netId)
                        if entity ~= veh then return end
                        return inZone and Utils.CanChopBone(veh, 'chassis') and Utils.HasVehicleBeenChopped(inZone, bones, data)        
                    end
                }
            }, 1.2)
        end
    end
}