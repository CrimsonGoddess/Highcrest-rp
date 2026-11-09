---Event that is executed when the group job is started | From server
---@param data any
RegisterNetEvent('peuren_gruppe6:StartJob', function(data)
    local result = Jobs.Load(data)
    if not result then return end 
    Jobs.HandleJob()
end)

RegisterNetEvent('peuren_gruppe6:SyncStartJob', function(data)
    local result = Jobs.Load(data)
    if not result then return end 
    lib.Notify(lib.Locale('successfully_started_job'), nil, "success")
end)

RegisterNetEvent('peuren_gruppe6:client:ClearJobData', function(data, isOwner)
    Jobs.Clear(isOwner)
    lib.Notify(lib.Locale('job_successfully_finished'), nil, "success")
end)

RegisterNetEvent('peuren_gruppe6:client:EndGroupJob', function(id)
    Cache.Set(id, 'finished', { state = true })
    lib.Notify(lib.Locale('job_ended_return_vehicle'), nil, "success")
end)
