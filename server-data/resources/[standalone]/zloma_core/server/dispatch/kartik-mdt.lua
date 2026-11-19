ZlomaCore.DispatchAdapters['kartik-mdt'] = function(_, coords, jobs, data)
    local alertJobs = {}
    for _, jobName in ipairs(jobs) do alertJobs[jobName] = true end

    TriggerEvent('kartik-mdt:server:sendDispatchNotification', {
        title = data.title,
        code = data.code,
        description = data.description,
        sound = 'dispatch',
        x = coords.x,
        y = coords.y,
        z = coords.z,
        type = 'Alert',
        blip = {
            sprite = data.blip.sprite,
            color = data.blip.color,
            scale = data.blip.scale,
            length = data.time,
        },
        jobs = alertJobs
    })
end
