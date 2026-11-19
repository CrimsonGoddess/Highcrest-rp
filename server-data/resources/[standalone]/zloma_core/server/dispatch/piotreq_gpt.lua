ZlomaCore.DispatchAdapters['piotreq_gpt'] = function(source, coords, jobs, data)
    local dispatchJobs = {}
    for _, jobName in ipairs(jobs) do dispatchJobs[jobName] = 0 end

    exports['piotreq_gpt']:SendAlert(source, {
        title = data.title,
        code = data.code,
        icon = data.icon or 'fa-solid fa-bell',
        info = {
            { icon = 'fa-solid fa-road', isStreet = true },
            { icon = 'fa-solid fa-circle-info', data = data.description },
        },
        jobs = dispatchJobs,
        coords = vec3(coords.x, coords.y, coords.z),
        blip = {
            scale = data.blip.scale,
            sprite = data.blip.sprite,
            category = data.blip.category,
            color = data.blip.color,
            hidden = data.blip.hidden,
            priority = data.blip.priority,
            short = data.blip.short,
            alpha = data.blip.alpha,
            name = data.blip.name,
        },
        type = data.priority == 'high' and 'risk' or 'normal',
        canAnswer = data.code == '911',
        maxOfficers = data.maxOfficers,
        time = data.time,
        notifyTime = data.notify,
    })
end
