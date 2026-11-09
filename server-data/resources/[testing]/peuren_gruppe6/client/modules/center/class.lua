Center = {
    Data = {},

    LoadNpcs = function()
        for type, _ in pairs(Config.Center.peds) do
            Center.SpawnNpc(type)
        end
    end,

    ---Spawns job npc
    ---@param type string
    SpawnNpc = function(type)
        local data = Config.Center.peds[type]        

        Utils.LoadModel(data.model)        
        local ped = CreatePed(4, data.model, data.pos.x, data.pos.y, data.pos.z - 1.0, data.heading, false, true)

        Center.Data[type] = ped

        if type == 'job_manager' then 
            Utils.CreateBlip(type, data.pos)
            lib.Target.AddEntity(ped, {
                {
                    name = lib.Locale('interact_with_job_npc'),
                    icon = 'fas fa-user',
                    label = lib.Locale('interact_with_job_npc'),
                    jobs = Config.RequiredJob and { Config.RequiredJob } or nil,
                    onSelect = JobMenu,
                }
            }, 3)  
        elseif type == 'warehouse_manager' then
            lib.Target.AddEntity(ped, {
                {
                    name = lib.Locale('interact_with_warehouse_npc_vehicle'),
                    icon = 'fas fa-retweet',
                    label = lib.Locale('interact_with_warehouse_npc_vehicle'),
                    canInteract = function()
                        if not Jobs.Data.args then return end
                        local id = Jobs.Data.args.groupId
                        local result = Cache.Get(id, 'finished')
                        if not result then return end 
                        return result.state
                    end,
                    onSelect = function()
                        if not Jobs.Data.args then return end
                        local id = Jobs.Data.args.groupId
                        TriggerServerEvent('peuren_gruppe6:server:EndJob', { id = id, finished = true })
                    end,
                }
            }, 3)       
        end

        if data.animation then
            if data.animation.dict then
                RequestAnimDict(data.animation.dict)
                TaskPlayAnim(ped, data.animation.dict, data.animation.clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                RemoveAnimDict(data.animation.dict)
            elseif data.animation.scenario then
                TaskStartScenarioInPlace(ped, data.animation.scenario, 0, true)
            end
        end        

        SetEntityAsMissionEntity(ped, true, false)
        FreezeEntityPosition(ped, true)
        SetPedCanRagdoll(ped, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 17, true)
        SetEntityInvincible(ped, true)
        SetPedSeeingRange(ped, 0)
    end,

    ---Deletes all created job npc peds
    ClearAllNpcs = function()
        for k,v in pairs(Center.Data) do
            DeleteEntity(v)
            Center.Data[k] = nil
        end
    end,
}