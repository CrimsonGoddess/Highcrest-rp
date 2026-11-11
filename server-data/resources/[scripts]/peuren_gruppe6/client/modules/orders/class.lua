Orders = {
    Data = {},

    Remove = {
        ['Pickup'] = function(data, isOwner)
            local job = Jobs.Data.args
            Utils.RemoveBlip('Pickup')

            if data.pickup.ped then 
                Utils.RemovePed('pickup')
            end

            if not isOwner then return end
            local result = States.Get(job.groupId)
            if not result then return end            
        end,

        ['Deliver'] = function(data, isOwner)
            local job = Jobs.Data.args
            Utils.RemoveBlip('Deliver')

            if data.pickup.ped then 
                Utils.RemovePed('pickup')
            end

            if data.pickup.ped then 
                Utils.RemovePed('deliver')
            end

            if not isOwner then return end
            local result = States.Get(job.groupId)
            if not result then return end

            if data.pickup.trolleys then 
                for _, v in pairs(result) do 
                    if v.type == 'trolley' then 
                        local entity = NetworkGetEntityFromNetworkId(v.netId)
                        DeleteEntity(entity)
                        Interactions.Delete(job.groupId, 'trolley', v.netId)
                    end
                end 
            end

            if data.pickup.bags then 
                for _, v in pairs(result) do 
                    if v.type == 'bag' then 
                        local entity = NetworkGetEntityFromNetworkId(v.netId)
                        if DoesEntityExist(entity) then 
                            DeleteEntity(entity)
                        end
                    end
                end
            end

            if data.pickup.container then 
                for _, v in pairs(result) do 
                    if v.type == 'container' then 
                        local entity = NetworkGetEntityFromNetworkId(v.netId)
                        Interactions.Delete(job.groupId, 'container', v.netId, v.states)
                        DeleteEntity(entity)                        

                        for _,door in pairs(v.states.doors) do
                            local entity = NetworkGetEntityFromNetworkId(door)
                            DeleteEntity(entity)   
                        end
                    end 
                end
            end
        end
    },

    Create = {
        ['Pickup'] = function(data, isOwner)
            local job = Jobs.Data.args
            data.groupId = job.groupId

            local pos = vec3(data.pickup.pos.x, data.pickup.pos.y, data.pickup.pos.z)
            Utils.CreateBlip('Pickup', pos)

            if data.pickup.ped then 
                local model = GetHashKey(Config.Peds[math.random(1, #Config.Peds)])

                local ped = Utils.SpawnPed('pickup', model, data.pickup.pos)
                if not ped then return end

                Interactions.Set['pickup'](job.groupId, ped, nil) 
            end  

            if not isOwner then return end

            if data.pickup.bags then 
                for i = 1, data.bags do
                    if not data.pickup.bags[i] then goto continue end
                    Utils.SpawnBag(data.pickup.bags[i])
                    :: continue ::
                end  
            end

            if data.pickup.container then
                for i = 1, #data.pickup.container do
                    if not data.pickup.container[i] then goto continue end
                    Utils.SpawnContainer(data.pickup.container[i])  
                    :: continue ::
                end 
            end    
    
            if data.pickup.trolleys then 
                for i = 1, data.bags do
                    if not data.pickup.trolleys[i] then goto continue end
                    Utils.SpawnTrolley(data.pickup.trolleys[i])
                    :: continue ::
                end  
            end   
            
            Tasks.Set(job.groupId, 'pickup', {
                min = 0,
                max = data.bags,
                event = 'peuren_gruppe6:client:OrderNext',
                args = data
            })
        end,

        ['Deliver'] = function(data, isOwner)
            local job = Jobs.Data.args
            data.groupId = job.groupId

            local pos = vec3(data.deliver.pos.x, data.deliver.pos.y, data.deliver.pos.z)
            Utils.CreateBlip('Deliver', pos)    
            
            if data.deliver.ped then 
                local model = GetHashKey(Config.Peds[math.random(1, #Config.Peds)])

                local ped = Utils.SpawnPed('deliver', model, data.deliver.pos)
                if not ped then return end

                Interactions.Set['deliver'](job.groupId, ped, nil)
            end

            if not isOwner then return end
    
            Tasks.Set(job.groupId, 'deliver', {
                min = 0,
                max = data.bags,
                serverEvent = 'peuren_gruppe6:server:OrderFinished',
                args = data
            })
        end,
    },

}