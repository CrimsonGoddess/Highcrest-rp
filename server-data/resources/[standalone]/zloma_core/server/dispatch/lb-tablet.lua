ZlomaCore.DispatchAdapters['lb-tablet'] = function(_, coords, jobs, data)
    local priority = data.priority or 'low'
    if priority == 'normal' then priority = 'low' end
    if priority == 'risk' then priority = 'high' end
    if priority ~= 'low' and priority ~= 'medium' and priority ~= 'high' then priority = 'low' end

    exports['lb-tablet']:AddDispatch({
        priority = priority,
        code = data.code,
        title = data.title,
        description = data.description,
        location = { label = data.street, coords = vec2(coords.x, coords.y) },
        time = data.time * 60,
        notificationTime = math.ceil(data.notify / 1000),
        job = jobs,
        blip = {
            sprite = data.blip.sprite,
            size = data.blip.scale,
            color = data.blip.color,
            shortRange = data.blip.short,
            label = data.title,
        }
    })
end
