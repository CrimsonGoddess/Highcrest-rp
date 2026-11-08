-- Highcrest spawn picker. qbx_core opens it for returning characters (new characters go to
-- qbx_properties' starter apartment instead). The camera circles the selected spot, flying
-- between spots as the player browses.
local options = {}
local cam
local center
local angle = 0.0
local active = false

local function zoneLabel(coords)
    local label = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    return label ~= 'NULL' and label or nil
end

local function orbitPoint(spot, at)
    local settings = Config.camera
    return vec3(spot.x + math.cos(at) * settings.distance, spot.y + math.sin(at) * settings.distance, spot.z + settings.height)
end

local function focusOn(index, instant)
    local spot = options[index]
    if not spot then return end
    center = spot.coords
    SetFocusPosAndVel(center.x, center.y, center.z, 0.0, 0.0, 0.0)

    local pos = orbitPoint(center, angle)
    local newCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 50.0, false, 2)
    PointCamAtCoord(newCam, center.x, center.y, center.z)

    if cam and not instant then
        SetCamActiveWithInterp(newCam, cam, Config.camera.flyMs, 1, 1)
        local old = cam
        SetTimeout(Config.camera.flyMs + 200, function() if DoesCamExist(old) then DestroyCam(old, false) end end)
    else
        SetCamActive(newCam, true)
        RenderScriptCams(true, false, 0, true, true)
        if cam and DoesCamExist(cam) then DestroyCam(cam, false) end
    end
    cam = newCam
end

-- Slowly circles the selected spot once the flight there has finished.
local function orbit()
    local last = GetGameTimer()
    while active do
        local now = GetGameTimer()
        angle = angle + (now - last) / 1000 * (2 * math.pi / Config.camera.orbitSeconds)
        last = now
        if cam and center and not IsCamInterpolating(cam) then
            local pos = orbitPoint(center, angle)
            SetCamCoord(cam, pos.x, pos.y, pos.z)
            PointCamAtCoord(cam, center.x, center.y, center.z)
        end
        Wait(0)
    end
end

local function closePicker()
    active = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    RenderScriptCams(false, false, 0, true, true)
    if cam and DoesCamExist(cam) then DestroyCam(cam, false) end
    cam, center = nil, nil
    ClearFocus()
end

local function waitForGround(ped)
    local deadline = GetGameTimer() + 5000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < deadline do
        RequestCollisionAtCoord(GetEntityCoords(ped))
        Wait(50)
    end
end

local function spawnAt(spot)
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do Wait(0) end
    closePicker()

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')

    local ped = cache.ped
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)

    if spot.propertyId then
        TriggerServerEvent('qbx_properties:server:enterProperty', { id = spot.propertyId, isSpawn = true })
    else
        local c = spot.coords
        FreezeEntityPosition(ped, true)
        SetEntityCoords(ped, c.x, c.y, c.z, false, false, false, false)
        SetEntityHeading(ped, c.w or 0.0)
        waitForGround(ped)
        FreezeEntityPosition(ped, false)
    end

    DisplayRadar(true)
    DoScreenFadeIn(1200)
end

local function buildOptions(data)
    local list = {}
    if data and data.last then
        list[#list + 1] = {
            kind = 'last',
            label = 'Last location',
            area = data.last.label or zoneLabel(data.last.coords) or 'Where you left off',
            coords = data.last.coords,
            propertyId = data.last.propertyId,
        }
    end
    for _, home in ipairs(data and data.homes or {}) do
        list[#list + 1] = {
            kind = 'home',
            label = home.label,
            area = home.renting and 'Your rental' or 'Your home',
            coords = home.coords,
            propertyId = home.propertyId,
        }
    end
    for _, spot in ipairs(Config.spawns) do
        list[#list + 1] = {
            kind = spot.label:find('International') and 'airport' or 'city',
            label = spot.label,
            area = spot.area,
            coords = spot.coords,
        }
    end
    return list
end

RegisterNetEvent('qb-spawn:client:setupSpawns', function()
    if active then return end
    options = buildOptions(lib.callback.await('highcrest_spawn:server:options', false))
    if #options == 0 then return end

    local ped = cache.ped
    SetEntityVisible(ped, false, false)
    SetEntityCollision(ped, false, false)
    FreezeEntityPosition(ped, true)
    DisplayRadar(false)

    active = true
    angle = 0.0
    focusOn(1, true)
    CreateThread(orbit)

    local menu = {}
    for i, option in ipairs(options) do
        menu[i] = { label = option.label, area = option.area, kind = option.kind }
    end
    SendNUIMessage({ action = 'open', options = menu })
    SetNuiFocus(true, true)
    Wait(600)
    DoScreenFadeIn(1500)
end)

RegisterNUICallback('select', function(index, cb)
    index = tonumber(index)
    if active and index and options[index] then focusOn(index) end
    cb(1)
end)

RegisterNUICallback('spawn', function(index, cb)
    cb(1)
    index = tonumber(index)
    if active and index and options[index] then spawnAt(options[index]) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and active then closePicker() end
end)
