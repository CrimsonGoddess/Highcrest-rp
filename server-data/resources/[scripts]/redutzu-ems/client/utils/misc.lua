function GetStreetNameFromCoords(coords)
    local zoneName = GetNameOfZone(coords.x, coords.y, coords.z)
    local zoneLabel = GetLabelText(zoneName)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    return string.format("%s, %s", streetName, zoneLabel)
end

function RequestDict(dict)
    if HasAnimDictLoaded(dict) then
        return
    end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

function RequestProp(prop)
    if HasModelLoaded(prop) then
        return
    end
    RequestModel(prop)
    while not HasModelLoaded(prop) do
        Wait(0)
    end
end

function getValueAtPath(obj, path)
    local parts = {}
    for part in string.gmatch(path, "[^%.]+") do
        table.insert(parts, part)
    end
    for _, part in ipairs(parts) do
        if obj then
            if type(obj) == "table" then
                if obj[part] ~= nil then
                    obj = obj[part]
                else
                    local numPart = tonumber(part)
                    if numPart then
                        if type(obj) == "table" then
                            if numPart >= 1 and numPart <= #obj then
                                obj = obj[numPart]
                            else
                                return nil
                            end
                        end
                    else
                        return nil
                    end
                end
            end
        else
            return nil
        end
    end
    return obj
end
