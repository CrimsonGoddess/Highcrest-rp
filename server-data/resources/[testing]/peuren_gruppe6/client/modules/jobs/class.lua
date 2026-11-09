Jobs = {
    Data = {},

    ---Loads client sided job data
    ---@param data table
    ---@return table
    Load = function(data)
        Jobs.Data = data
        Jobs.Data.args.client = {}
        return Jobs.Data
    end,

    Clear = function(isOwner)
        local id = Jobs.Data.args.groupId

        local result = States.Get(id)

        if isOwner and result then 
            for k,v in pairs(result) do
                if v.type == 'vehicle' then 
                    local entity = NetworkGetEntityFromNetworkId(v.netId)
                    if DoesEntityExist(entity) then DeleteVehicle(entity) end
                end
            end
        end       
        
        States.Data[id] = nil 
        Cache.Data[id] = nil 
        Interactions.Data[id] = nil
        Orders.Data = {}
        Utils.Data = {}
        Jobs.Data = {}
    end,

    HandleJob = function()
        local job = Jobs.Data.args
        if not job then return end

        local spawns = Config.Center.Spawns
        local data = Config.Jobs[job.job]            

        Vehicle.SapwnVehicles(spawns.vehicle, data.vehicle)
    end
}