array = {}

function array.map(tbl, callback)
    local result = {}
    for index, value in ipairs(tbl) do
        result[index] = callback(value, index)
    end
    return result
end

function array.filter(tbl, callback)
    local result = {}
    local index = 1
    for _, value in ipairs(tbl) do
        if callback(value) then
            result[index] = value
            index = index + 1
        end
    end
    return result
end

function array.find(tbl, callback)
    for index, value in ipairs(tbl) do
        if callback(value, index) then
            return value
        end
    end
    return nil
end

function array.push(tbl, value)
    table.insert(tbl, value)
    return tbl
end

function array.keys(tbl)
    local result = {}
    for key, _ in pairs(tbl) do
        table.insert(result, key)
    end
    return result
end

function table.isEmpty(tbl)
    if type(tbl) ~= "table" then
        error("Expected a table, got " .. type(tbl))
    end
    for _ in pairs(tbl) do
        return false
    end
    return true
end

function table.includes(tbl, value)
    for _, item in ipairs(tbl) do
        if item == value then
            return true
        end
    end
    return false
end

function match(str, pattern)
    return str:lower():match(pattern:lower()) ~= nil
end

function numberToBoolean(num)
    return num > 0
end

function replaceFalseWithNil(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local result = {}
    for key, value in pairs(tbl) do
        if value == false then
            result[key] = nil
        else
            result[key] = value
        end
    end
    return result
end
