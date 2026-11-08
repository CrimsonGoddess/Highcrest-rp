Cache = {}
Cache.__index = Cache
Cache.instances = {}
Cache.settings = {
    threadDelay = 30000,
    updateInterval = 300
}

function Cache.new()
    local instance = {
        store = {},
        handlers = {}
    }
    setmetatable(instance, Cache)
    table.insert(Cache.instances, instance)
    return instance
end

function Cache._splitKey(self, key)
    local parts = {}
    for part in string.gmatch(key, "[^%.]+") do
        table.insert(parts, part)
    end
    return parts
end

function Cache._getNestedTable(self, store, parts)
    for i = 1, #parts - 1 do
        local part = parts[i]
        if store[part] == nil then
            store[part] = {}
        end
        store = store[part]
    end
    return store
end

function Cache.insert(self, key, value)
    local parts = self:_splitKey(key)
    local nestedTable = self:_getNestedTable(self.store, parts)
    value.__lastUpdated = os.time()
    local finalKey = parts[#parts]
    nestedTable[finalKey] = value
    return value
end

function Cache.get(self, key)
    local parts = self:_splitKey(key)
    local store = self.store
    for _, part in ipairs(parts) do
        store = store[part]
        if store == nil then
            return nil
        end
    end
    return store
end

function Cache.update(self, key, value)
    local parts = self:_splitKey(key)
    local nestedTable = self:_getNestedTable(self.store, parts)
    local finalKey = parts[#parts]
    local existingValue = nestedTable[finalKey]
    
    if type(value) == "table" then
        if existingValue == nil then
            existingValue = {}
        end
        for k, v in pairs(value) do
            existingValue[k] = v
        end
        nestedTable[finalKey] = existingValue
    elseif type(value) == "function" then
        if existingValue then
            nestedTable[finalKey] = value(existingValue)
        end
    else
        nestedTable[finalKey] = value
    end
    
    if nestedTable[finalKey] then
        nestedTable[finalKey].__lastUpdated = os.time()
    end
end

function Cache.invalidate(self, key)
    local parts = self:_splitKey(key)
    local nestedTable = self:_getNestedTable(self.store, parts)
    local finalKey = parts[#parts]
    nestedTable[finalKey] = nil
end

local function deepCompare(obj1, obj2)
    for key, value in pairs(obj2) do
        if type(value) == "table" then
            if type(obj1[key]) == "table" then
                if not deepCompare(obj1[key], value) then
                    return false
                end
            end
        else
            if obj1[key] ~= value then
                return false
            end
        end
    end
    return true
end

function Cache.find(self, query)
    local function searchRecursive(obj, query)
        for _, value in pairs(obj) do
            if type(value) == "table" then
                if deepCompare(value, query) then
                    return value
                else
                    local result = searchRecursive(value, query)
                    if result then
                        return result
                    end
                end
            end
        end
        return nil
    end
    return searchRecursive(self.store, query)
end

function Cache.filter(self, query)
    local function filterRecursive(obj, query, results)
        for _, value in pairs(obj) do
            if type(value) == "table" then
                if deepCompare(value, query) then
                    table.insert(results, value)
                end
                filterRecursive(value, query, results)
            end
        end
    end
    local results = {}
    filterRecursive(self.store, query, results)
    return results
end

function Cache.addHandler(self, pattern, handler)
    self.handlers[pattern] = handler
end

function Cache._checkForUpdatesRecursive(self, store, path)
    local currentTime = os.time()
    for key, value in pairs(store) do
        local fullPath = path and (path .. "." .. key) or key
        
        if type(value) == "table" then
            if value.__lastUpdated then
                for handlerPattern, handler in pairs(self.handlers) do
                    if fullPath:find(handlerPattern) == 1 then
                        local timeSinceUpdate = currentTime - value.__lastUpdated
                        if timeSinceUpdate > Cache.settings.updateInterval then
                            handler(value)
                            value.__lastUpdated = currentTime
                        end
                    end
                end
            else
                self:_checkForUpdatesRecursive(value, fullPath)
            end
        end
    end
end

function Cache.checkForUpdates(self)
    self:_checkForUpdatesRecursive(self.store, nil)
end

function Cache.getInstances()
    return Cache.instances
end

CreateThread(function()
    while true do
        local instances = Cache.getInstances()
        for _, instance in ipairs(instances) do
            instance:checkForUpdates()
        end
        Wait(Cache.settings.threadDelay)
    end
end)

return Cache
