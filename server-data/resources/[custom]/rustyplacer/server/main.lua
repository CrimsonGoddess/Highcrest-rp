local storagePath = Config.StorageFile

local function readProps()
    local raw = LoadResourceFile(GetCurrentResourceName(), storagePath)
    if not raw or raw == '' then return {} end
    local decoded = json.decode(raw)
    if type(decoded) ~= 'table' then return {} end
    return decoded
end

local function writeProps(props)
    SaveResourceFile(GetCurrentResourceName(), storagePath, json.encode(props, { indent = true }), -1)
end

local Props = readProps()

local function makeId()
    return ('%d_%d'):format(os.time(), math.random(100000, 999999))
end

local function getCitizenId(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return nil end
    return player.PlayerData.citizenid
end

local function getCharName(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return 'Unknown' end
    local c = player.PlayerData.charinfo or {}
    return (c.firstname or 'Unknown') .. ' ' .. (c.lastname or '')
end

local function countPropsForCitizen(citizenid)
    local n = 0
    for _, p in pairs(Props) do
        if p.owner == citizenid then n += 1 end
    end
    return n
end

local function isValidModelHash(hash)
    if type(hash) ~= 'number' then return false end
    if hash == 0 then return false end
    return true
end

local function ensureItemAllowed(itemName)
    local def = Config.PlaceableItems[itemName]
    if not def then return nil end
    local model = def.model
    local modelHash = type(model) == 'number' and model or joaat(model)
    return {
        item = itemName,
        modelHash = modelHash,
        label = def.label or itemName,
        consume = def.consume == true,
        allowRotate = def.allowRotate ~= false
    }
end

lib.callback.register('zoov_placeprops:server:getNearby', function(source, coords)
    if type(coords) ~= 'table' or type(coords.x) ~= 'number' then return {} end
    local pos = vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)

    local out = {}
    local distLimit = Config.StreamDistance + 10.0
    for id, p in pairs(Props) do
        if p and p.coords then
            local ppos = vec3(p.coords.x + 0.0, p.coords.y + 0.0, p.coords.z + 0.0)
            if #(ppos - pos) <= distLimit then
                out[#out + 1] = p
            end
        end
    end
    return out
end)

local lastPlace = {}
RegisterNetEvent('zoov_placeprops:server:place')
AddEventHandler('zoov_placeprops:server:place', function(itemName, coords, heading)
    local src = source

    local now = os.clock() * 1000.0
    if lastPlace[src] and (now - lastPlace[src]) < Config.PlaceCooldownMs then
        TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'Slow down.' })
        return
    end
    lastPlace[src] = now

    local citizenid = getCitizenId(src)
    if not citizenid then return end

    local allowed = ensureItemAllowed(itemName)
    if not allowed then
        TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'Invalid item.' })
        return
    end

    if type(coords) ~= 'table' or type(coords.x) ~= 'number' or type(coords.y) ~= 'number' or type(coords.z) ~= 'number' then
        TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'Invalid placement.' })
        return
    end

    heading = tonumber(heading) or 0.0
    if heading ~= heading then heading = 0.0 end

    local pcoords = GetEntityCoords(GetPlayerPed(src))
    local target = vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
    if #(pcoords - target) > (Config.PlaceMaxDistance + 2.0) then
        TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'Too far away.' })
        return
    end

    if countPropsForCitizen(citizenid) >= Config.MaxPropsPerPlayer then
        TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'Prop limit reached.' })
        return
    end

    if not isValidModelHash(allowed.modelHash) then
        TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'Invalid prop model.' })
        return
    end

    if allowed.consume then
        local count = exports.ox_inventory:GetItemCount(src, itemName)
        if not count or count < 1 then
            TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'You do not have that item.' })
            return
        end

        local removed = exports.ox_inventory:RemoveItem(src, itemName, 1)
        if not removed then
            TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'Could not remove item.' })
            return
        end
    end

    local id = makeId()
    local prop = {
        id = id,
        owner = citizenid,
        ownerName = getCharName(src),
        item = itemName,
        model = allowed.modelHash,
        coords = { x = target.x + 0.0, y = target.y + 0.0, z = target.z + 0.0 },
        heading = heading + 0.0,
        createdAt = os.time(),
    }

    Props[id] = prop
    writeProps(Props)

    TriggerClientEvent('zoov_placeprops:client:placed', -1, prop)
end)

RegisterNetEvent('zoov_placeprops:server:remove')
AddEventHandler('zoov_placeprops:server:remove', function(propId)
    local src = source
    local citizenid = getCitizenId(src)
    if not citizenid then return end

    if type(propId) ~= 'string' then return end
    local prop = Props[propId]
    if not prop then return end

    if Config.RemovePermission == 'owner' and prop.owner ~= citizenid then
        TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'You do not own this.' })
        return
    end

    local pcoords = GetEntityCoords(GetPlayerPed(src))
    local tcoords = vec3(prop.coords.x + 0.0, prop.coords.y + 0.0, prop.coords.z + 0.0)
    if #(pcoords - tcoords) > (Config.Target.removeDistance + 2.0) then
        TriggerClientEvent('zoov_placeprops:client:notify', src, { type = 'error', description = 'Too far away.' })
        return
    end

    Props[propId] = nil
    writeProps(Props)

    TriggerClientEvent('zoov_placeprops:client:removed', -1, propId)

    local def = Config.PlaceableItems[prop.item]
    if def and def.consume then
        exports.ox_inventory:AddItem(src, prop.item, 1)
    end
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    math.randomseed(os.time())

    if LoadResourceFile(GetCurrentResourceName(), storagePath) == nil then
        SaveResourceFile(GetCurrentResourceName(), storagePath, json.encode({}, { indent = true }), -1)
    end

    Props = readProps()
end)
