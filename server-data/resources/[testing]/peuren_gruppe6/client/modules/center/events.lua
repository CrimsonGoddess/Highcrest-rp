RegisterNetEvent('peuren_gruppe6:OpenMainMenu', function()
    JobMenu()
end)

---Job menu
function JobMenu()
    local inGroup = lib.Framework.Callbacks.Trigger("peuren_gruppe6:isPlayerInGroup")
    local options = {}

    if not inGroup then 
        options[#options + 1] = {
            icon = 'fas fa-truck-ramp-box',
            title = lib.Locale('choose_jobs_title'),
            description = lib.Locale('choose_jobs_description'),
            event = 'peuren_gruppe6:selectJobType',
        }
    end

    if Config.Groups.enabled and not inGroup then 
        options[#options + 1] =  {
            icon = 'fas fa-users-gear',
            title = lib.Locale('job_menu_active_groups_title'),
            description = lib.Locale('job_menu_active_groups_description'),
            event = 'peuren_gruppe6:availableGroups',
        }
    end

    if Config.Groups.enabled and inGroup then 
        options[#options + 1] =  {
            icon = 'fas fa-briefcase',
            title = lib.Locale('job_menu_current_job_title'),
            description = lib.Locale('job_menu_current_job_description'),
            event = 'peuren_gruppe6:currentJob',
        }
    end

    options[#options + 1] = {
        icon = 'fas fa-ranking-star',
        title = lib.Locale('job_menu_rank_title'),
        description = lib.Locale('job_menu_rank_description'),
        event = 'peuren_gruppe6:viewRank',
    }

    lib.Menu(lib.Locale('job_menu_header'), options)
end

RegisterNetEvent('peuren_gruppe6:selectJobType', function()
    local options = {}

    options[#options + 1] = {
        icon = 'fas fa-truck-fast',
        title = lib.Locale('job_menu_start_delivery_job_title'),
        description = lib.Locale('job_menu_start_delivery_job_description'),
        event = 'peuren_gruppe6:availableJobs',
        args = { type = 'Deliver' }
    }
    options[#options + 1] = {
        icon = 'fas fa-handshake',
        title = lib.Locale('job_menu_start_pickup_job_title'),
        description = lib.Locale('job_menu_start_pickup_job_description'),
        event = 'peuren_gruppe6:availableJobs',
        args = { type = 'Pickup' }
    }

    lib.Menu(lib.Locale('job_menu_header'), options)
end)

RegisterNetEvent('peuren_gruppe6:currentJob', function(data)
    local result = lib.Framework.Callbacks.Trigger("peuren_gruppe6:currentJobData", Jobs.Data.args.groupId)
    local options = {}

    --Group password, also checks if the job supports group work
    if Config.Jobs[Jobs.Data.args.job].group and Config.Groups.enabled then
        options[#options + 1] = {
            icon = 'fas fa-key',
            title = lib.Locale('current_job_menu_pass_title'):format(Jobs.Data.pass),
            description = lib.Locale('current_job_menu_pass_description'),
        }
    end

    --Option to leave tghe group if you are a member
    if not result.owner and result.started then 
        options[#options + 1] = {
            icon = 'fas fa-user-xmark',
            title = lib.Locale('current_job_menu_leave_title'),
            description = lib.Locale('current_job_menu_leave_description'),
            isServer = true,
            event = 'peuren_gruppe6:leaveGroup',
            args = { id = Jobs.Data.args.groupId }
        }
    end

    --Option to start the job if you're owner of a group
    if result.owner and not result.started then 
        options[#options + 1] = {
            icon = 'fas fa-play',
            title = lib.Locale('current_job_menu_start_job_title'):format(123),
            description = lib.Locale('current_job_menu_start_job_description'),
            isServer = true,
            event = 'peuren_gruppe6:startGroupJob',
            args = { id = Jobs.Data.args.groupId }
        }

        options[#options + 1] = {
            icon = 'fas fa-xmark',
            title = lib.Locale('current_job_menu_cancel_job_title'):format(123),
            description = lib.Locale('current_job_menu_cancel_job_description'),
            isServer = true,
            event = 'peuren_gruppe6:server:EndJob',
            args = { id = Jobs.Data.args.groupId, finished = false }
        }
    end
    
    --Option to end the job if you're owner of a group
    if result.owner and result.started then 
        options[#options + 1] = {
            icon = 'fas fa-ban',
            title = lib.Locale('current_job_menu_end_job_title'):format(123),
            description = lib.Locale('current_job_menu_end_job_description'),
            isServer = true,
            event = 'peuren_gruppe6:server:EndJob',
            args = { id = Jobs.Data.args.groupId, finished = true }
        }
    end

    lib.Menu(lib.Locale('menu_group_id'):format(Jobs.Data.args.groupId), options)
end)

RegisterNetEvent('peuren_gruppe6:availableGroups', function()
    local groups = lib.Framework.Callbacks.Trigger("peuren_gruppe6:getAvailableGroups")
    local options = {}
    
    for k,v in pairs(groups) do
        options[#options + 1] =  {
            icon = 'fas fa-users-gear',
            title = lib.Locale('group_menu_group_tile'):format(Config.Jobs[v.args.job].label),
            description = lib.Locale('group_menu_group_description'):format(v.args.groupId, #v.players),
            event = 'peuren_gruppe6:joinGroup',
            args = v
        }
    end

    if not next(options) then
        lib.Notify(lib.Locale('job_menu_header'), lib.Locale('no_available_groups'), "error")
        JobMenu()
        return 
    end

    lib.Menu(lib.Locale('job_menu_header'), options)
end)

RegisterNetEvent('peuren_gruppe6:joinGroup', function(data)
    local inJob = lib.Framework.Callbacks.Trigger("peuren_gruppe6:isPlayerInJob")

    if inJob then 
        lib.Notify(lib.Locale('you_have_job'), nil, "error")
        return 
    end

    local input = lib.Input(lib.Locale("enter_group_password"), {
        {
            title = lib.Locale("enter_group_password"),
            name = "pass",
            type = "input",
            isRequired = true,
        }
    })

    if not input or not input.pass then return end
    local result = lib.Framework.Callbacks.Trigger("peuren_gruppe6:joinGroup", data, input.pass)
    if not result then
        lib.Notify(lib.Locale('incorrect_group_pass'), nil, "error")
        return 
    end
end)

RegisterNetEvent('peuren_gruppe6:availableJobs', function(data)
    local jobs = lib.Framework.Callbacks.Trigger("peuren_gruppe6:getAvailableJobs")
    local options = {}

    if not jobs then
        lib.Notify(lib.Locale('no_available_jobs'), nil, "error")
        return 
    end

    for _, job in pairs(jobs) do 
        options[#options + 1] = {
            icon = 'fas fa-briefcase',
            title = Config.Jobs[job].label,
            description = Config.Jobs[job].description,
            event = 'peuren_gruppe6:startNewJob',
            args = { type = data.type, job = job }
        }
    end

    lib.Menu(lib.Locale('job_menu_header'), options)
end)

RegisterNetEvent('peuren_gruppe6:startNewJob', function(data)
    local result = lib.Framework.Callbacks.Trigger("peuren_gruppe6:startNewJob", data)   

    Jobs.Data = result.group
    TriggerEvent('peuren_gruppe6:currentJob', data)
end)

RegisterNetEvent('peuren_gruppe6:viewRank', function()
    local rank = lib.Framework.Callbacks.Trigger("peuren_gruppe6:viewRank")
    if not rank then return end

    lib.Menu(lib.Locale('job_menu_header'), {
        {
            icon = 'fas fa-ranking-star',
            title = lib.Locale('rank_menu_rank_title'):format(rank),
            description = lib.Locale('rank_menu_rank_description')
        },
    })
end)