Vehicle = {
    Data = {},

    ---Spawns vehicles for given job and location
    ---@param spawns table
    ---@param data table
    SapwnVehicles = function(spawns, data)
        local id = Jobs.Data.args.groupId
        local vehicle = {}

        local pos, heading = Utils.GetAvailableSpawn(spawns)
        if pos and heading then            
            lib.Framework.SpawnVehicle(data.model, pos, function(veh)
                SetEntityHeading(veh, heading)
                local plate = GetVehicleNumberPlateText(veh)
                lib.Fuel.SetFuel(veh, plate, 100.0)
                lib.VehicleKeys.Give(veh, plate)    
                local netId = NetworkGetNetworkIdFromEntity(veh)
                vehicle = { netId = netId }
                Interactions.Register(id, 'vehicle', vehicle.netId, data)     
                States.Register(id, 'vehicle', { netId = vehicle.netId })      
            end, true)
        end           
        
        return vehicle
    end,

    ---Placing cargo inside of a vehicle
    ---@param id string
    ---@param entity number
    ---@param data table
    PlaceCargo = function(id, entity, data)
        if not id or not entity then return end

        local veh = NetworkGetNetworkIdFromEntity(entity)
        local state = States.Get(id, veh).states
        local offset = vec3(0.0, 0.0, 0.0) 

        if not state then return end
        if not state.cargo then state.cargo = {} end
        if next(state.cargo) then offset = state.cargo[#state.cargo].offset end

        local caryying = Cache.Get(id, 'caryying')
        if not caryying then return end     
        if not caryying.state then return end

        local pos = GetEntityCoords(entity)
        local cargo = Utils.SpawnBag(pos, 0)

        if not DoesEntityExist(cargo) then return end

        if math.abs(offset.x) <= data.areaSize.x and math.abs(offset.y) <= data.areaSize.y and offset.z <= data.areaSize.z then
            Utils.LoadAnimDict("veh@common@motorbike@low@ps")
            TaskPlayAnim(PlayerPedId(), "veh@common@motorbike@low@ps", "pickup", 2.0, 2.0, -1, 51, 0, false, false, false)
            Wait(500)
            ClearPedTasks(PlayerPedId())

            Cache.Set(id, 'caryying', { state = false, netId = nil })

            local item = Config.Jobs[Jobs.Data.args.job].bag.item
            if item then 
                Utils.RemoveBag(1)
            end

            Entity(cargo).state:set(id, { attached = 'vehicle', caryying = false })
            AttachEntityToEntity(cargo, entity, 0, offset.x - data.offsetPos.x, offset.y - data.offsetPos.y, offset.z + data.offsetPos.z, -180.0, -180.0, -90.0, true, false, false, false, 1, true)
            
            offset = vec3(offset.x + data.spacing.x, offset.y, offset.z)
            if offset.x > data.areaSize.x then                 
                offset = vec3(0.0, offset.y + data.spacing.y, offset.z)
                if offset.z > data.areaSize.y then 
                    offset = vec3(offset.x, 0.0, offset.z + data.spacing.z)                
                end
            end

            caryying.offset = offset
            caryying.netId = NetworkGetNetworkIdFromEntity(cargo)
            state.cargo[#state.cargo + 1] = caryying
        else
            offset = vec3(0.0, 0.0, offset.z + 0.1)
        end
        Entity(entity).state:set(id, { cargo = state.cargo  })
    end,

    ---Taking cargo from vehicle
    ---@param id string
    ---@param entity number
    ---@param data table
    TakeCargo = function(id, entity, data)
        if not id or not entity then return end

        local veh = NetworkGetNetworkIdFromEntity(entity)
        local state = States.Get(id, veh).states

        if not state then return end 
        if not state.cargo then return end 
        if not next(state.cargo) then return end 

        local cargo = NetworkGetEntityFromNetworkId(state.cargo[#state.cargo].netId)
        Utils.PickUpObject(id, 'bag', cargo)

        state.cargo[#state.cargo] = nil
        Entity(entity).state:set(id, { cargo = state.cargo })
    end
}