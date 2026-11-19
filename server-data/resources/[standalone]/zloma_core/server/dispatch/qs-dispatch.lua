ZlomaCore.DispatchAdapters['qs-dispatch'] = function(_, coords, jobs, data)
    TriggerEvent('qs-dispatch:server:CreateDispatchCall', {
        job = jobs,
        callLocation = vector3(coords.x, coords.y, coords.z),
        callCode = { code = data.code, snippet = data.code },
        message = data.description or data.title,
        flashes = data.priority == 'high',
        blip = {
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            colour = data.blip.color,
            flashes = data.priority == 'high',
            text = data.title,
            time = data.time * 60 * 1000,
        }
    })
end
