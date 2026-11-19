ZlomaCore.DispatchAdapters['origen_police'] = function(_, coords, _, data)
    exports['origen_police']:SendAlert({
        coords = vec3(coords.x, coords.y, coords.z),
        title = data.title,
        type = 'GENERAL',
        message = data.description or data.code,
        job = 'police',
    })
end
