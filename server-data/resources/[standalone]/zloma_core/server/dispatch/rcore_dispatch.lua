ZlomaCore.DispatchAdapters['rcore_dispatch'] = function(_, coords, jobs, data)
    TriggerEvent('rcore_dispatch:server:sendAlert', {
        code = data.code,
        default_priority = data.priority or 'normal',
        coords = vec3(coords.x, coords.y, coords.z),
        job = jobs,
        text = data.description or data.title,
        type = 'alerts',
        -- rcore_dispatch accepts seconds; Core accepts minutes.
        blip_time = data.time * 60,
        blip = {
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            colour = data.blip.color,
            text = data.title,
        }
    })
end
