-- Last location and owned homes for the spawn picker.
local function decodeCoords(value)
    local ok, coords = pcall(json.decode, value or '')
    if not ok or type(coords) ~= 'table' then return end
    local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    if not (x and y and z) then return end
    return vec4(x, y, z, tonumber(coords.w) or tonumber(coords.heading) or 0.0)
end

lib.callback.register('highcrest_spawn:server:options', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    local citizenid = player.PlayerData.citizenid

    local last
    local position = MySQL.scalar.await('SELECT position FROM players WHERE citizenid = ?', { citizenid })
    local lastCoords = decodeCoords(position)
    if lastCoords then
        last = { coords = lastCoords, propertyId = player.PlayerData.metadata.currentPropertyId }
    end

    local homes = {}
    if GetResourceState('qbx_properties'):find('start') then
        for _, row in ipairs(MySQL.query.await('SELECT id, property_name, coords, rent_interval FROM properties WHERE owner = ?', { citizenid }) or {}) do
            local coords = decodeCoords(row.coords)
            if coords then
                homes[#homes + 1] = { label = row.property_name, coords = coords, propertyId = row.id, renting = row.rent_interval ~= nil }
                if last and last.propertyId == row.id then last.label = row.property_name end
            end
        end
    end

    return { last = last, homes = homes }
end)
