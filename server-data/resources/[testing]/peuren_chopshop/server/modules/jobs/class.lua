Jobs = {
    Data = {},

    ---Gets job data
    ---@param id number
    ---@param dealer string
    ---@return table | nil
    Get = function(id, dealer)
        if not Jobs.Data[dealer] then return end
        if not Jobs.Data[dealer][id] then return end
        return Jobs.Data[dealer][id]
    end,

    ---Creates new job data
    ---@param id number
    ---@param dealer string
    ---@return any
    Set = function(id, dealer)
        if not Jobs.Data[dealer] then 
            Jobs.Data[dealer] = {}
        end

        local vehicle, chop = Locations.GenerateLocations(id, dealer)
        if not vehicle or not chop then return false end

        if Jobs.Data[dealer][id] then return false end

        local data = {
            id = id, 
            dealer = dealer, 
            locId = vehicle.id, 
            location = vehicle.data,
            locked = true,
            hacking = false, 
            givenTime = os.time() + (Config.Jobs.timeToFind.min * 60) + Config.Jobs.timeToFind.sec,
            client = {},
        }

        data.client = {
            keyPos = Utils.GenerateKeyPos(data.location.key),
            vehicle = Utils.SpawnVehicle(data.location),
            locId = chop.id, 
            dropOff = chop.data
        }

        Jobs.Data[dealer][id] = data
        Jobs.Searching(id, dealer)

        return Jobs.Data[dealer][id]
    end, 

    --Updates job data
    ---@param id number
    ---@param dealer string
    ---@param data any
    ---@return table | nil
    Update = function (id, dealer, data)
        if not Jobs.Data[dealer] then return end
        if not Jobs.Data[dealer][id] then return end
        Jobs.Data[dealer][id] = data
        return Jobs.Data[dealer][id]
    end,

    ---Removes job
    ---@param id number
    ---@param dealer string
    Remove = function(id, dealer)
        if not Jobs.Data[dealer] then return end
        if not Jobs.Data[dealer][id] then return end
        TriggerClientEvent('peuren_chopshop:client:MissionUpdate', id, 'finished', Jobs.Data[dealer][id])
        TriggerClientEvent('peuren_chopshop:RemoveMission', -1, Jobs.Data[dealer][id])
        Locations.Remove('chop', Jobs.Data[dealer][id].client.locId)
        Locations.Remove('vehicle', Jobs.Data[dealer][id].locId)
        Wait(100)
        Jobs.Data[dealer][id] = nil
    end,

    ---Thread that checks if the chop vehicle searching time has passed
    ---@param id number
    ---@param dealer string
    Searching = function(id, dealer)
        local time = Config.Jobs.searchingTime
        if time then
            Jobs.Data[dealer][id].searching = os.time() + (time.min * 60) + time.sec
        else 
            Jobs.Data[dealer][id].searching = 0 
        end

        CreateThread(function()
            while Jobs.Get(id, dealer).searching > os.time() do                
                Wait(1000)
            end
            Jobs.TimeToFind(id, dealer)
            TriggerClientEvent('peuren_chopshop:client:MissionUpdate', id, 'find-vehicle', Jobs.Data[dealer][id])
            TriggerClientEvent('peuren_chopshop:CreateNewMission', id, Jobs.Data[dealer][id])
        end)
    end,

    ---Thread that checks if a vehicle has been unlocked in time
    ---@param id any
    ---@param dealer any
    TimeToFind = function(id, dealer)
        local time = Config.Jobs.timeToFind
        if time then
            Jobs.Data[dealer][id].timeToFind = os.time() + (time.min * 60) + time.sec
        else 
            Jobs.Data[dealer][id].timeToFind = 0 
        end

        CreateThread(function()
            while Jobs.Get(id, dealer) do
                local job = Jobs.Get(id, dealer)

                if job.locked and os.time() > job.givenTime and not job.hacking and Config.Jobs.enabled then           
                    Jobs.Remove(id, dealer)                   
                    
                    if job.locked and os.time() > job.givenTime and not job.hacking then 
                        Reputation.RemoveRep(id, dealer, math.random(Config.Jobs.decreaseRepOnExpiredTime.min, Config.Jobs.decreaseRepOnExpiredTime.max))
                    end
                end

                Wait(1000)
            end
        end)
    end
}