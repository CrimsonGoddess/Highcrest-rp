Config = {
    -- Spawn spots everyone can pick. Your last location and any homes you own or rent are
    -- added automatically. area is the small line under the name.
    spawns = {
        { label = 'Legion Square', area = 'Downtown', coords = vec4(195.17, -933.77, 29.7, 144.5) },
        { label = 'Vinewood Boulevard', area = 'Vinewood', coords = vec4(300.84, 181.13, 104.18, 250.0) },
        { label = 'Del Perro Pier', area = 'Del Perro', coords = vec4(-1603.44, -1040.92, 13.02, 50.0) },
        { label = 'Pink Cage Motel', area = 'Alta', coords = vec4(327.56, -205.08, 53.08, 163.5) },
        { label = 'Los Santos International', area = 'Airport arrivals', coords = vec4(-1037.74, -2738.04, 20.17, 330.0) },
    },

    -- The camera circles each spot at this distance and height, one lap per orbitSeconds.
    camera = { distance = 140.0, height = 70.0, orbitSeconds = 70.0, flyMs = 2200 },
}
