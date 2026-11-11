-- Plays the chosen video on the nearest playing TV. Only one TV is drawn at a time, which
-- keeps it light: the picture goes on the TV's "tvscreen" render target, and the sound fades
-- with distance.

local SCREEN_URL = ('https://cfx-nui-%s/html/screen.html'):format(GetCurrentResourceName())
local TXD = 'highcrest_tv_txd'
local TXN -- a new texture name for each screen, so a stale texture is never reused
local textureCount = 0

local modelSet = {}
for _, name in ipairs(Config.models) do modelSet[joaat(name)] = name end

local current      -- { entity, coords, model, state, timeOffset }
local dui, duiReady, renderId, runtimeTxd
local volumePref = GetResourceKvpInt('highcrest_tv:volume')
if volumePref == 0 and GetResourceKvpString('highcrest_tv:volumeSet') == nil then volumePref = 60 end

local function sameSpot(a, b)
    return a and b and #(vector3(a.x, a.y, a.z) - vector3(b.x, b.y, b.z)) < 0.3
end

local function sendToScreen(message)
    if dui and duiReady then SendDuiMessage(dui, json.encode(message)) end
end

local function releaseRenderTarget()
    if renderId and IsNamedRendertargetRegistered('tvscreen') then
        ReleaseNamedRendertarget('tvscreen')
    end
    renderId = nil
end

local function destroyScreen()
    if dui then
        DestroyDui(dui)
        dui, duiReady = nil, false
    end
    releaseRenderTarget()
end

local function playOnScreen()
    if not (current and current.state) then return end
    local elapsed = math.max(0, current.serverNow - current.state.startedAt + (GetGameTimer() - current.receivedAt) // 1000)
    sendToScreen({ action = 'play', media = current.state, start = elapsed, volume = 0 })
end

local function createScreen()
    if dui then return end
    dui = CreateDui(SCREEN_URL, Config.resolution.width, Config.resolution.height)
    duiReady = false
    if not runtimeTxd then runtimeTxd = CreateRuntimeTxd(TXD) end
    textureCount = textureCount + 1
    TXN = ('highcrest_tv_tex_%d'):format(textureCount)
    CreateRuntimeTextureFromDuiHandle(runtimeTxd, TXN, GetDuiHandle(dui))

    CreateThread(function()
        local timeout = GetGameTimer() + 10000
        while dui and not IsDuiAvailable(dui) and GetGameTimer() < timeout do Wait(100) end
        if not dui then return end
        Wait(300)
        duiReady = true
        playOnScreen()
    end)
end

local function linkRenderTarget(model)
    releaseRenderTarget()
    if not IsNamedRendertargetRegistered('tvscreen') then
        RegisterNamedRendertarget('tvscreen', false)
    end
    if not IsNamedRendertargetLinked(model) then
        LinkNamedRendertarget(model)
    end
    renderId = GetNamedRendertargetRenderId('tvscreen')
end

local function applyState(state, serverNow)
    if not current then return end
    current.state = state
    current.serverNow = serverNow or current.serverNow or 0
    current.receivedAt = GetGameTimer()
    if state then
        createScreen()
        linkRenderTarget(current.model)
        playOnScreen()
    else
        destroyScreen()
    end
end

local function findClosestTv()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local best, bestDist
    for _, entity in ipairs(GetGamePool('CObject')) do
        local model = GetEntityModel(entity)
        if modelSet[model] then
            local dist = #(pos - GetEntityCoords(entity))
            if dist < Config.drawRange and (not bestDist or dist < bestDist) then
                best, bestDist = entity, dist
            end
        end
    end
    return best
end

-- Every second: pick the closest TV and ask the server what it's playing.
CreateThread(function()
    while true do
        local tv = findClosestTv()
        if tv ~= (current and current.entity) then
            destroyScreen()
            current = nil
            if tv then
                local coords = GetEntityCoords(tv)
                current = { entity = tv, coords = coords, model = GetEntityModel(tv) }
                local state, serverNow = lib.callback.await('highcrest_tv:get', false, { x = coords.x, y = coords.y, z = coords.z })
                if current and current.entity == tv then applyState(state, serverNow) end
            end
        end
        Wait(1000)
    end
end)

-- Every frame while a TV is playing: draw the video onto its screen.
CreateThread(function()
    while true do
        if dui and renderId and current and current.state then
            SetTextRenderId(renderId)
            SetScriptGfxDrawOrder(4)
            SetScriptGfxDrawBehindPausemenu(true)
            DrawSprite(TXD, TXN, 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- Sound follows distance from the TV.
CreateThread(function()
    while true do
        if dui and duiReady and current and current.state and DoesEntityExist(current.entity) then
            local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(current.entity))
            local fade = math.max(0.0, 1.0 - dist / Config.audioRange)
            sendToScreen({ action = 'volume', volume = math.floor(volumePref * fade) })
        end
        Wait(250)
    end
end)

RegisterNetEvent('highcrest_tv:client:update', function(coords, state, serverNow)
    if current and sameSpot(current.coords, coords) then
        applyState(state, serverNow)
    end
end)

-- Target options on every supported TV.
local function tvCoords(entity)
    local c = GetEntityCoords(entity)
    return { x = c.x, y = c.y, z = c.z }
end

exports.ox_target:addModel(Config.models, {
    {
        name = 'highcrest_tv:watch',
        icon = 'fa-solid fa-tv',
        label = 'Watch something',
        distance = 2.5,
        onSelect = function(data)
            local input = lib.inputDialog('Television', {
                { type = 'input', label = 'YouTube or video link', description = 'A YouTube link, or a direct .mp4 / .webm link', required = true, max = 300 },
            })
            if input and input[1] then
                TriggerServerEvent('highcrest_tv:server:play', tvCoords(data.entity), input[1])
            end
        end,
    },
    {
        name = 'highcrest_tv:off',
        icon = 'fa-solid fa-power-off',
        label = 'Turn off',
        distance = 2.5,
        canInteract = function(entity)
            return current and current.entity == entity and current.state ~= nil
        end,
        onSelect = function(data)
            TriggerServerEvent('highcrest_tv:server:stop', tvCoords(data.entity))
        end,
    },
    {
        name = 'highcrest_tv:volume',
        icon = 'fa-solid fa-volume-high',
        label = 'Volume',
        distance = 2.5,
        onSelect = function()
            local input = lib.inputDialog('TV volume', {
                { type = 'slider', label = 'Volume (only for you)', default = volumePref, min = 0, max = 100, step = 5 },
            })
            if input and input[1] then
                volumePref = math.floor(input[1])
                SetResourceKvpInt('highcrest_tv:volume', volumePref)
                SetResourceKvp('highcrest_tv:volumeSet', '1')
            end
        end,
    },
})

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then destroyScreen() end
end)
