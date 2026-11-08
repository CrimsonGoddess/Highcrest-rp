local Scenes = {}
Scenes.Synchronised = {}

function SynchronisedScene()
    return Scenes.Synchronised 
end

function ReleaseModel(model)
    local hash = (type(model) == "number" and model or GetHashKey(model))
    if HasModelLoaded(hash) then
        SetModelAsNoLongerNeeded(hash)
    end
end

function ReleaseAnimDict(dict)
    if HasAnimDictLoaded(dict) then
        SetAnimDictAsNoLongerNeeded(dict)
    end
end

function RequestAndWaitModel(modelName) -- Request un modèle de véhicule
	if modelName and IsModelInCdimage(modelName) and not HasModelLoaded(modelName) then
		RequestModel(modelName)
		while not HasModelLoaded(modelName) do
            Citizen.Wait(100) 
        end
	end
end

if not Citizen then
    NetworkCreateSynchronisedScene      = function(...)   return ...            end
    NetworkAddPedToSynchronisedScene    = function(...)   return ...            end
    NetworkAddEntityToSynchronisedScene = function(...)   return ...            end
    NetworkStartSynchronisedScene       = function(...)   return ...            end
    NetworkStopSynchronisedScene        = function(...)   return ...            end
    vector3                             = function(x,y,z) return {x=x,y=y,z=z}  end
end

Scenes.Synchronised = {
    Defaults = {
        SceneConfig = {
          position      = vector3(0.0,0.0,0.0),
          rotation      = vector3(0.0,0.0,0.0),
          rotOrder      = 2,
          useOcclusion  = false,
          loop          = false,
          unk1          = 1.0,
          animTime      = 0,
          animSpeed     = 1.0, 
        },
  
        PedConfig = {
            blendIn       = 1.0,
            blendOut      = 1.0,
            duration      = 0,
            flag          = 0,
            speed         = 1.0,
            unk1          = 0,
        },
  
        EntityConfig = {
            blendIn       = 1.0,
            blendOut      = 1.0,
            flags         = 1,
        }
    },


    Create = function(sceneConfig)    
        return NetworkCreateSynchronisedScene(sceneConfig.position,sceneConfig.rotation,sceneConfig.rotOrder,sceneConfig.useOcclusion,sceneConfig.loop,sceneConfig.unk1,sceneConfig.animTime,sceneConfig.animSpeed)
    end,
    
    SceneConfig = function(pos,rot,rotOrder,useOcclusion,loop,unk1,animTime,animSpeed)
    
        local _D = function(v1,v2) if v1 ~= nil then return v1 else return Scenes.Synchronised.Defaults["SceneConfig"][v2]; end; end
    
        local conObj = {}
        conObj.position     = _D(pos,"position")
        conObj.rotation     = _D(rot,"rotation")
        conObj.rotOrder     = _D(rotOrder,"rotOrder")
        conObj.useOcclusion = _D(useOcclusion,"useOcclusion")
        conObj.loop         = _D(loop,"loop")
        conObj.unk1         = _D(p9,"unk1")
        conObj.animTime     = _D(animTime,"animTime")
        conObj.animSpeed    = _D(animSpeed,"animSpeed")
        return conObj
    end,
    
    AddPed = function(pedConfig)
        return NetworkAddPedToSynchronisedScene(pedConfig.ped,pedConfig.scene,pedConfig.animDict,pedConfig.animName,pedConfig.blendIn,pedConfig.blendOut,pedConfig.duration,pedConfig.flag,pedConfig.speed,pedConfig.unk1)
    end,
    
    PedConfig = function(ped,scene,animDict,animName,blendIn,blendOut,duration,flag,speed,unk1)

        local _D = function(v1,v2) if v1 ~= nil then return v1 else return Scenes.Synchronised.Defaults["PedConfig"][v2]; end; end

        local conObj = {}
        conObj.ped          = ped
        conObj.scene        = scene
        conObj.animDict     = animDict
        conObj.animName     = animName
        conObj.blendIn      = _D(blendIn,"blendIn")
        conObj.blendOut     = _D(blendOut,"blendOut")
        conObj.duration     = _D(duration,"duration")
        conObj.flag         = _D(flag,"flag")
        conObj.speed        = _D(speed,"speed")
        conObj.unk1         = _D(unk1,"unk1")
        return conObj
    end,
    
    AddEntity = function(entityConfig)
        return NetworkAddEntityToSynchronisedScene(entityConfig.entity,entityConfig.scene,entityConfig.animDict,entityConfig.animName,entityConfig.blendIn,entityConfig.blendOut,entityConfig.flags)
    end,
    
    EntityConfig = function(entity,scene,animDict,animName,blendIn,blendOut,flags)

        local _D = function(v1,v2) if v1 ~= nil then return v1 else return Scenes.Synchronised.Defaults["EntityConfig"][v2]; end; end

        local conObj = {}
        conObj.entity       = entity
        conObj.scene        = scene
        conObj.animDict     = animDict
        conObj.animName     = animName
        conObj.blendIn      = _D(blendIn,"blendIn")
        conObj.blendOut     = _D(blendOut,"blendOut")
        conObj.flags        = _D(flags,"flags")
        return conObj
    end,

    Start = function(scene)
        NetworkStartSynchronisedScene(scene)
    end,

    Stop = function(scene)
        NetworkStopSynchronisedScene(scene)
    end,
}

function FindClosestObjectWithModel(model, pos)
    local closestObject = nil
    local closestDistance = -1
    local modelHash = GetHashKey(model)
    local objects = GetGamePool("CObject")

    for i=1, #objects do
        if GetEntityModel(objects[i]) == modelHash then
            local objectPos = GetEntityCoords(objects[i])
            local distance = Vdist(pos.x, pos.y, pos.z, objectPos.x, objectPos.y, objectPos.z)

            if closestDistance == -1 or distance < closestDistance then
                closestObject = objects[i]
                closestDistance = distance
            end
        end
    end

    return closestObject
end

local sceneObjects  = {}
local Scenes = SynchronisedScene()
local startTime
local currentScene = nil
function SceneHandler(action, pos, place, house, amount)
    if currentScene ~= nil then
        Notify("error", locale("error"), locale("CurrentlyDoing"))
        return
    end
    sceneObjects = {}
    currentScene = true
    local plyPed = PlayerPedId()
    local pPos = GetEntityCoords(plyPed)
    action.location = pos
    local sceneType = action.act
    local doScene = action.scene
    local actPos = action.location - action.offset
    local actRot = action.rotation
    local animDict = SceneDicts[sceneType][doScene]
    local actItems = SceneItems[sceneType][doScene]
    local actAnims = SceneAnims[sceneType][doScene]
    local plyAnim = PlayerAnims[sceneType][doScene]
    while not HasAnimDictLoaded(animDict) do 
        RequestAnimDict(animDict)
        Wait(0)
    end
    local count = 1
    local objectCount = 0
    for k,v in pairs(actItems) do
        local hash = GetHashKey(v)
        while not HasModelLoaded(hash) do RequestModel(hash)
            Wait(0) 
        end
        if v ~= "bkr_prop_fakeid_papercutter" then
            sceneObjects[k] = CreateObject(hash,actPos,true)
            SetModelAsNoLongerNeeded(hash)
            objectCount = objectCount + 1
            while not DoesEntityExist(sceneObjects[k]) do 
                Wait(0)
            end
            SetEntityCollision(sceneObjects[k],false,false)
        end
    end
    local scenes = {}
    local sceneConfig = Scenes.SceneConfig(actPos,actRot,2,false,false,1.0,0,1.0)
    for i=1,math.max(1,math.ceil(objectCount/3)),1 do
      scenes[i] = Scenes.Create(sceneConfig)
    end
    local pedConfig = Scenes.PedConfig(plyPed,scenes[1],animDict,plyAnim)
    Scenes.AddPed(pedConfig)

    FreezeEntityPosition(plyPed, true)

    for k,animation in pairs(actAnims) do      
      local targetScene = scenes[math.ceil(count/3)]
      local entConfig = Scenes.EntityConfig(sceneObjects[k],targetScene,animDict,animation)
      Scenes.AddEntity(entConfig)
      count = count + 1
    end
    local closestObject = FindClosestObjectWithModel("bkr_prop_fakeid_papercutter", actPos)
    if closestObject then
        SetEntityAsMissionEntity(closestObject, true, true)
        NetworkRequestControlOfEntity(closestObject)
        local controlAttempts = 0

        while not NetworkHasControlOfEntity(closestObject) and controlAttempts < 10 do
            Citizen.Wait(100)
            NetworkRequestControlOfEntity(closestObject)
            controlAttempts = controlAttempts + 1
        end

        if NetworkHasControlOfEntity(closestObject) then
            NetworkRegisterEntityAsNetworked(closestObject)
            local closestObjectConfig = Scenes.EntityConfig(closestObject, scenes[1], animDict, actAnims.cutter)
            Scenes.AddEntity(closestObjectConfig)
        end
    end
    local extras = {}
    if action.extraProps then
      for k,v in pairs(action.extraProps) do
        RequestAndWaitModel(v.model)
        local obj = CreateObject(GetHashKey(v.model), actPos + v.pos, true,true,true)
        while not DoesEntityExist(obj) do Wait(0); end
        SetEntityRotation(obj,v.rot)
        FreezeEntityPosition(obj,true)
        extras[#extras+1] = obj
      end
    end
    startTime = GetGameTimer()
    for i=1,#scenes,1 do
      Scenes.Start(scenes[i])
    end

    local isPlayerInScene = true
    Citizen.CreateThread(function()
        while isPlayerInScene do
            Citizen.Wait(500)  -- Adjust the delay as needed
            local playerPos = GetEntityCoords(plyPed)
            local distance = #(playerPos - actPos)
            if distance > 5 then
                -- Player moved away from the scene, stop the animation and exit
                for i=1,#scenes,1 do
                Scenes.Stop(scenes[i])
                end
                for k,v in pairs(extras) do
                DeleteObject(v)
                end
                RemoveAnimDict(animDict)
                for k,v in pairs(sceneObjects) do 
                    NetworkFadeOutEntity(v, false, false)
                end
                -- Unfreeze the player character
                FreezeEntityPosition(plyPed, false)
                isPlayerInScene = false
                currentScene = nil
                return
            end

            if not IsEntityPlayingAnim(plyPed, animDict, plyAnim, 3) or IsPedInAnyVehicle(plyPed, true) then
                -- Player cleared their ped task or entered a vehicle, stop the animation and exit
                for i=1,#scenes,1 do
                Scenes.Stop(scenes[i])
                end
                for k,v in pairs(extras) do
                DeleteObject(v)
                end
                RemoveAnimDict(animDict)
                for k,v in pairs(sceneObjects) do 
                    NetworkFadeOutEntity(v, false, false)
                    Wait(10)
                    DeleteObject(v)
                end
                -- Unfreeze the player character
                FreezeEntityPosition(plyPed, false)
                isPlayerInScene = false
                currentScene = nil
                return
            end
        end
    end)

    Wait(action.time)
    if isPlayerInScene then
        if doScene == 3 then
            DoScreenFadeOut(100)
            Wait(100)
        end
        for i=1,#scenes,1 do
        Scenes.Stop(scenes[i])
        end
        for k,v in pairs(extras) do
        DeleteObject(v)
        end
        RemoveAnimDict(animDict)
        for k,v in pairs(sceneObjects) do 
            NetworkFadeOutEntity(v, false, false)
            Wait(10)
            DeleteObject(v)
        end
        if doScene == 3 then
            Wait(500)
            TriggerServerEvent('drc_moneywash:activateDryer', place, house, amount)
            Wait(500)
            DoScreenFadeIn(100)
            TriggerServerEvent('drc_moneywash:startmoneywash', place, house, amount)
            Notify('success', locale('success'), locale('startedwash'))
        end
        if doScene == 2 then
            TriggerServerEvent('drc_moneywash:cutmoney', place, house, amount)
        end
        if doScene == 1 then
            TriggerServerEvent('drc_moneywash:countmoney', place, house, amount)
        end
        FreezeEntityPosition(plyPed, false)

        currentScene = nil
    end
end

SceneDicts = {
    Money = {
        [1] = 'anim@amb@business@cfm@cfm_counting_notes@',
        [2] = 'anim@amb@business@cfm@cfm_cut_sheets@',
        [3] = 'anim@amb@business@cfm@cfm_drying_notes@',
    }
}

PlayerAnims = {
    Money = {
        [1] = 'note_counting_v2_counter',
        [2] = 'extended_load_tune_cut_billcutter',
        [3] = 'loading_v3_worker',
    }
}

SceneAnims = {
    Money = {
        [1] = {
            binmoney = 'note_counting_v2_binmoney',
            moneybin = 'note_counting_v2_moneybin',
            money1 = 'note_counting_v2_moneyunsorted',
            money2 = 'note_counting_v2_moneyunsorted^1',
            wrap1 = 'note_counting_v2_moneywrap',
            wrap2 = 'note_counting_v2_moneywrap^1',
        },
        [2] = {
            cutter = 'extended_load_tune_cut_papercutter',
            singlep1 = 'extended_load_tune_cut_singlemoneypage',
            singlep2 = 'extended_load_tune_cut_singlemoneypage^1',
            singlep3 = 'extended_load_tune_cut_singlemoneypage^2',
            table = 'extended_load_tune_cut_table',
            stack = 'extended_load_tune_cut_moneystack',
            strip1 = 'extended_load_tune_cut_singlemoneystrip',
            strip2 = 'extended_load_tune_cut_singlemoneystrip^1',
            strip3 = 'extended_load_tune_cut_singlemoneystrip^2',
            strip4 = 'extended_load_tune_cut_singlemoneystrip^3',
            strip5 = 'extended_load_tune_cut_singlemoneystrip^4',
            sinstack = 'extended_load_tune_cut_singlestack',
        },
        [3] = {
            bucket = 'loading_v3_bucket',
            money1 = 'loading_v3_money01',
            money2 = 'loading_v3_money01^1',
        }
    },
}

SceneItems = {
    Money = {
        [1] = {
            binmoney = 'bkr_prop_coke_tin_01',
            moneybin = 'bkr_prop_tin_cash_01a',
            money1 = 'bkr_prop_money_unsorted_01',
            money2 = 'bkr_prop_money_unsorted_01',
            wrap1 = 'bkr_prop_money_wrapped_01',
            wrap2 = 'bkr_prop_money_wrapped_01',
        },
        [2] = {
            cutter = 'bkr_prop_fakeid_papercutter',
            singlep1 = 'bkr_prop_cutter_moneypage',
            singlep2 = 'bkr_prop_cutter_moneypage',
            singlep3 = 'bkr_prop_cutter_moneypage',
            stack = 'bkr_prop_cutter_moneystack_01a',
            strip1 = 'bkr_prop_cutter_moneystrip',
            strip2 = 'bkr_prop_cutter_moneystrip',
            strip3 = 'bkr_prop_cutter_moneystrip',
            strip4 = 'bkr_prop_cutter_moneystrip',
            strip5 = 'bkr_prop_cutter_moneystrip',
            sinstack = 'bkr_prop_cutter_singlestack_01a',
        },
        [3] = {
            bucket = 'bkr_prop_money_pokerbucket',
            money1 = 'bkr_prop_money_unsorted_01',
            money2 = 'bkr_prop_money_unsorted_01',
        }
    },
}

action = {
    {
        offset = vector3(-0.8, 0.896, 0.6),
        rotation = vector3(0.0, 0.0, 180.0),
        time = 20000, 
        act = "Money", 
        scene = 1, 

        extraProps = {
            [1] = {
                model = "bkr_prop_money_counter",
                pos = vector3(-0.25, 0.22, 0.4),
                rot = vector3(0.0, 0.0, 180.0),
            },
            [2] = {
                model = "bkr_prop_moneypack_03a",
                pos = vector3(-0.7, -0.25, 0.4),
                rot = vector3(0.0, 0.00, 0.0),
            },
            [3] = {
                model = "bkr_prop_moneypack_03a",
                pos = vector3(-0.7, -0.25, 0.55),
                rot = vector3(0.0, 0.00, 0.00),
            }
        }
    },
    {
        offset = vector3(2.15, 0.67, 0.6),
        rotation = vector3(0.0, 0.0, 180.0),
        time = 40000,
        act = "Money",
        scene = 2,
    },
    {
        offset = vector3(0.15, 0.0, 0.0),
        rotation = vector3(0.0, 0.0, 65.0),
        time = 10000,
        act = "Money",
        scene = 3,
    }
}