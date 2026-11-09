Jobs = {
    Data = {},

    Init = function()
        local result = lib.Framework.Callbacks.Trigger('peuren_chopshop:GetActiveJobs')
        if not result then return end

        for dealer,_ in pairs(result) do 
            for player,_ in pairs(result[dealer]) do
                for _,v in pairs(result[dealer][player]) do 
                    if not v.locked then 
                        Utils.CreateDropZone(v)
                    end
                end
            end
        end
    end,

    ---Creates mission data for the client
    ---@param data table
    ---@return table | nil
    Set = function(data)
        if not data then return end 

        Jobs.Data = data 
        Utils.CreateBlip('chop_vehicle', data.client.keyPos)
        Radar.Start(data.client.keyPos)
    end,

    ---Handles functions that happen after a player has succesfully boosted the key signal
    HackedKeys = function()
        local veh = NetworkGetEntityFromNetworkId(Jobs.Data.client.vehicle.netId)
        if not DoesEntityExist(veh) then return end 

        local plate = GetVehicleNumberPlateText(veh)
        if not plate then return end

        lib.VehicleKeys.Give(veh, plate) 
        lib.Fuel.SetFuel(veh, plate, 100.0)
        SetVehicleDoorsLocked(veh, 0)
        FreezeEntityPosition(veh, false)
        Utils.RemoveBlip('chop_vehicle')
        Utils.CreateBlip('chop_location', Jobs.Data.client.dropOff.pos)
        Utils.SpawnGuardAnimal(Jobs.Data.location.guard, Jobs.Data.location.vehicle.pos)
        TriggerServerEvent('peuren_chopshop:CreateDropOff', Jobs.Data)

        if not Config.Dispatch.enabled then return end
        Config.Dispatch.pos = Jobs.Data.location.vehicle.pos
        Config.Dispatch.police_jobs = Config.Jobs.policeJobs
        lib.Dispatch(Config.Dispatch)
        lib.Notify(lib.Locale("police_called"), nil, "error")
    end,

    Remove = function(data)
        if not data then return end
        if data.id ~= Jobs.Data.id or data.dealer ~= Jobs.Data.dealer then return end

        local netId = data.client.vehicle.netId 
        local veh = NetworkGetEntityFromNetworkId(netId)
        lib.Framework.Callbacks.Trigger('peuren_chopshop:AddTaskProgress', data.dealer, 'disassemble', 1)

        if DoesEntityExist(veh) then 
            DeleteVehicle(veh)
        end

        Utils.RemoveBlip('chop_vehicle')
        Utils.RemoveBlip('chop_location')

        if data.client.zone then 
            lib.Poly.RemoveZone(data.client.zone)
        end

        for _,bone in pairs(data.location.bones) do
            lib.Target.RemoveBone(bone, { 
                lib.Locale('disassemble_part'),
                lib.Locale('disassemble_frame')
            })
        end

        lib.Framework.Callbacks.Trigger('peuren_chopshop:RemoveJob', data.dealer)

        Jobs.Data = {}
    end,
}