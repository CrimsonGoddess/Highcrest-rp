ZlomaCore.DispatchAdapters['tk_dispatch'] = function(_, coords, jobs, data)
    exports['tk_dispatch']:addCall({
        title = data.title,
        code = data.code,
        priority = data.priority or 'normal',
        message = data.description or data.title,
        coords = vector3(coords.x, coords.y, coords.z),
        showTime = data.notify,
        removeTime = data.time * 60 * 1000,
        jobs = jobs,
        blip = {
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            color = data.blip.color,
            flash = data.priority == 'high',
            shortRange = data.blip.short,
        }
    })
end
