Jobs = {
    Data = {},

    --Gets job data by grouop ID
    ---@param id string
    ---@return table | nil
    Get = function(id)
        if not Jobs.Data[id] then return end 
        return Jobs.Data[id]
    end,

    ---Sets job data for a group
    ---@param id string
    ---@param data table
    Set = function(id, data)
        if not Jobs.Data[id] then return end 
        Jobs.Data[id] = data
    end,

    ---Updates job data
    ---@param id number
    ---@param data any
    ---@return table | nil
    Update = function (id, data)
        if not Jobs.Data[id] then return end
        Jobs.Data[id] = data
        return Jobs.Data[id]
    end,

    ---Remove job
    ---@param id number
    Remove = function(id)
        if not Jobs.Data[id] then return end
        Jobs.Data[id] = nil
    end,

    ---Returns if a player is in groups
    ---@param source number
    ---@return any
    IsPLayerInGroup = function(source)
        local user = Users.GetIdentifier(source)

        for _, data in pairs(Jobs.Data) do 
            for _, player in pairs(data.players) do
                if player.id == user then                 
                    return true 
                end
            end
        end

        return false
    end,

    ---Gets all available groups that have not yet started a job
    ---@return table
    GetAvailableGroups = function()
        local groups = {}

        for _,v in pairs(Jobs.Data) do 
            if not v.args.started and Config.Jobs[v.args.job].group then 
                groups[#groups + 1] = v
            end
        end

        return groups
    end,

    ---Gets all available job types of player
    ---@param source number
    GetAvailableJobs = function(source)
        local rank = Ranks.Get(source)
        local jobs = {}

        for level,v in pairs(Config.Ranks.Levels) do 
            if level <= rank.Level then 
                jobs[#jobs + 1] = v.job
            end
        end

        if not next(jobs) then return end 
        return jobs
    end,

    --Generates a random 6 letter password
    CreatePassword = function()
        local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local id = ""
    
        for i = 1, 6 do
            local index = math.random(1, #characters)
            id = id .. string.sub(characters, index, index)
        end
    
        return id
    end,

    ---Creates a group
    ---@param source number
    ---@param data table
    Create = function(source, data)
        local user = Users.GetIdentifier(source)
        local id, group = lib.Groups.Create({
            job = 'gruppe6',
            owner = user,
            pass = Jobs.CreatePassword(),
            args = {               
                type = data.type,
                started = false, 
                job = data.job,
                client = {},
                bags = 0
            },
            players = {
                { source = source, id = user, name = lib.Framework.GetCharName(source), owner = true }
            }
        })

        Jobs.Data[id] = group

        return Jobs.Data[id]
    end,

    AddPlayer = function(id, source)
        if not id or not source then return end

        local job = Jobs.Get(id)
        if not job then return end

        job.players[#job.players + 1] = {
            source = source, 
            id = Users.GetIdentifier(source),
            name = lib.Framework.GetCharName(source),
            owner = false
        } 

        TriggerClientEvent("peuren_lib:notify", source, lib.Locale("entered_group_job"), nil, "success")
        lib.Groups.AddPlayer(id, source)
    end,

    RemovePlayer = function(id, source)
        if not id or not source then return end

        local job = Jobs.Get(id)
        if not job then return end

        for k,v in pairs(job.players) do 
            if v.source == source or v.id == Users.GetIdentifier(source) then 
                job.players[k] = nil
            end
        end

        TriggerClientEvent("peuren_lib:notify", source, lib.Locale("left_group_job"), nil, "error")
        TriggerClientEvent('peuren_deliveries:client:ClearJobData', source, {})
        lib.Groups.RemovePlayer(id, source)
    end,

    GiveRewards = function(job, bags)
        if bags == 0 then return end
        local rewards = Config.Jobs[job.args.job].rewards
        local players = #job.players

        local amount = rewards.perBag * bags

        if rewards.groupMultiplier then 
            amount = amount * players
        end

        for _,v in pairs(job.players) do 
            lib.Framework.Money.Give(v.source, amount / players, rewards.account)

            if rewards.rankXp then 
                Ranks.AddRankXP(v.source, rewards.rankXp)
            end
            
            Wait(100)
        end
    end,
}