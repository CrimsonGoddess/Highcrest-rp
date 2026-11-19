local function sendCodeSignDispatch(_, coords, jobs, data)
    -- The current CodeSign API routes the server event to configured jobs.
    TriggerEvent('cd_dispatch:AddNotification', {
        job_table = jobs,
        coords = vec3(coords.x, coords.y, coords.z),
        title = data.code,
        message = data.description or data.title,
        unique_id = tostring(math.random(1000000, 9999999)),
        sound = 1,
        flash = data.priority == 'high',
        blip = {
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            colour = data.blip.color,
            flashes = data.priority == 'high',
            text = ('%s - %s'):format(data.code, data.title),
            time = data.time,
            radius = 0,
        }
    })
end

ZlomaCore.DispatchAdapters['cd_dispatch'] = sendCodeSignDispatch
ZlomaCore.DispatchAdapters['cd_dispatch3d'] = sendCodeSignDispatch
