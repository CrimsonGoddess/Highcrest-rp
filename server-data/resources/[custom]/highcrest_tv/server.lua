-- What each TV is playing. TVs are keyed by routing bucket and position, so a TV in one
-- house never plays what someone chose in another copy of the same shell.
local screens = {}
local lastChange = {}

local function screenKey(bucket, coords)
    return ('%d:%.1f:%.1f:%.1f'):format(bucket, coords.x, coords.y, coords.z)
end

-- Only YouTube videos and direct https video files are accepted.
local function parseLink(url)
    if type(url) ~= 'string' or #url > 300 then return end
    url = url:gsub('^%s+', ''):gsub('%s+$', '')
    if not url:match('^https://') then return end

    local id = url:match('youtube%.com/watch%?.-v=([%w_%-]+)')
        or url:match('youtu%.be/([%w_%-]+)')
        or url:match('youtube%.com/shorts/([%w_%-]+)')
        or url:match('youtube%.com/live/([%w_%-]+)')
        or url:match('youtube%.com/embed/([%w_%-]+)')
    if id and #id >= 6 and #id <= 20 then
        return { kind = 'youtube', id = id }
    end

    local path = url:match('^https://[^?#]+')
    if path and (path:lower():match('%.mp4$') or path:lower():match('%.webm$')) then
        return { kind = 'video', url = url }
    end
end

local function validCoords(coords)
    return type(coords) == 'table' or type(coords) == 'vector3'
end

local function toVec(coords)
    return vector3(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0, tonumber(coords.z) or 0.0)
end

-- The player must be standing near the TV they change.
local function closeEnough(source, coords)
    local ped = GetPlayerPed(source)
    return ped ~= 0 and #(GetEntityCoords(ped) - coords) <= 6.0
end

local function pushToBucket(bucket, coords, state)
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if GetPlayerRoutingBucket(src) == bucket then
            TriggerClientEvent('highcrest_tv:client:update', src, coords, state, os.time())
        end
    end
end

lib.callback.register('highcrest_tv:get', function(source, coords)
    if not validCoords(coords) then return end
    local key = screenKey(GetPlayerRoutingBucket(source), toVec(coords))
    return screens[key], os.time()
end)

RegisterNetEvent('highcrest_tv:server:play', function(coords, url)
    local src = source
    if not validCoords(coords) then return end
    coords = toVec(coords)
    if not closeEnough(src, coords) then return end

    local now = os.time()
    if lastChange[src] and now - lastChange[src] < Config.cooldown then
        return TriggerClientEvent('ox_lib:notify', src, { description = 'Wait a moment before changing the TV again.', type = 'error' })
    end

    local media = parseLink(url)
    if not media then
        return TriggerClientEvent('ox_lib:notify', src, { description = 'Use a YouTube link or a direct .mp4 / .webm video link.', type = 'error' })
    end

    lastChange[src] = now
    media.startedAt = now
    local bucket = GetPlayerRoutingBucket(src)
    screens[screenKey(bucket, coords)] = media
    pushToBucket(bucket, coords, media)
end)

RegisterNetEvent('highcrest_tv:server:stop', function(coords)
    local src = source
    if not validCoords(coords) then return end
    coords = toVec(coords)
    if not closeEnough(src, coords) then return end

    local bucket = GetPlayerRoutingBucket(src)
    screens[screenKey(bucket, coords)] = nil
    pushToBucket(bucket, coords, nil)
end)

AddEventHandler('playerDropped', function()
    lastChange[source] = nil
end)
