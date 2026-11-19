-- ZLOMA CORE - Client Target Wrapper
-- Unified interface for ox_target, qb-target, qtarget
-- Customer-friendly: Consistent API across all targeting systems

local TargetType = nil
local eventSequence = 0

-- ============================================================================
-- ZONE REGISTRY — tracks which zone names have been added
-- Used to skip RemoveZone calls for zones that were never created,
-- preventing target-system "zone does not exist" warnings.
-- ============================================================================
local registeredZones = {}
local zoneAliases = {}
local registeredEntityOptions = {}

-- ============================================================================
-- EVENT REGISTRY SYSTEM - Memory Leak Prevention
-- ============================================================================
-- Tracks all dynamically registered events for proper cleanup
local registeredEvents = {}
local globalVehicleTargets = {}

local function GetCallerResource()
    return GetInvokingResource() or GetCurrentResourceName()
end

local function MakeOwnerKey(owner, value)
    return ('%s\31%s'):format(owner, tostring(value))
end

local function MakeEntityKey(owner, entity)
    if type(entity) ~= 'table' then return MakeOwnerKey(owner, entity) end

    local entityIds = {}
    for _, entityId in pairs(entity) do
        entityIds[#entityIds + 1] = tostring(entityId)
    end
    table.sort(entityIds)
    return MakeOwnerKey(owner, table.concat(entityIds, ','))
end

local function ResolveTargetType()
    local detected = ZlomaCore.DetectTarget()
    if detected and GetResourceState(detected) ~= 'started' then detected = nil end
    if detected ~= TargetType then
        TargetType = detected
        ZlomaCore.Cache.Target = detected
        ZlomaCore.Debug(('Target detection refreshed: %s'):format(detected or 'none'))
    end

    return TargetType
end

local function LogTargetError(operation, owner, err)
    print(('^1[ZLOMA TARGET ERROR]^0 %s failed for resource %s: %s'):format(
        tostring(operation), tostring(owner), tostring(err)
    ))
end

local function InvokeTargetFunction(callback, operation, owner, ...)
    local args = table.pack(...)
    local success, result = xpcall(function()
        return callback(table.unpack(args, 1, args.n))
    end, debug.traceback)

    if not success then
        LogTargetError(operation, owner, result)
        return false, nil
    end

    return true, result
end

-- Cleanup function to remove registered event handlers
local function CleanupTargetEvent(eventName)
    local registration = registeredEvents[eventName]
    if registration then
        RemoveEventHandler(registration.handler)
        registeredEvents[eventName] = nil
        ZlomaCore.Debug(string.format("Cleaned up target event: %s", eventName))
    end
end

-- Cleanup all registered events (called on resource stop)
local function CleanupAllTargetEvents()
    local count = 0
    for eventName, registration in pairs(registeredEvents) do
        RemoveEventHandler(registration.handler)
        count = count + 1
    end
    registeredEvents = {}
    if count > 0 then
        print(string.format("^3[ZLOMA CLEANUP]^0 Removed %d registered target events", count))
    end
end

CreateThread(function()
    ResolveTargetType()
end)

-- EXPORT: GetTargetSystem() - Get current target system name
-- Returns: 'ox_target', 'qb-target', 'qtarget', or nil if none detected
exports('GetTargetSystem', function()
    return ResolveTargetType()
end)
exports('SetTargetingEnabled', function(enabled)
    local targetType = ResolveTargetType()
    if not targetType then
        ZlomaCore.Warn('Target', 'SetTargetingEnabled')
        return false
    end

    if targetType == 'ox_target' and exports.ox_target then
        local success = InvokeTargetFunction(function()
            exports.ox_target:disableTargeting(not enabled)
        end, 'SetTargetingEnabled', GetCallerResource())
        return success == true
    end

    return true
end)

-- EXPORT: AddEntity(entity, options) - Add target options to entity
-- entity: Entity handle or array of entities
-- options: Table of target options (standardized format)
-- Returns: true if successful, false otherwise
-- Helper: Dynamic Event Registry for qb-target/qtarget compatibility
-- These frameworks require an event string, they cannot handle direct function callbacks
-- ============================================================================
-- ADD NEW TARGET SUPPORT HERE
-- ============================================================================
-- To add support for a new target system:
-- 1. Add detection in shared/config.lua -> ZlomaCore.DetectTarget()
-- 2. Add the target name to ZlomaCore.Config.Manual.Target options
-- 3. Add elseif blocks in AddEntity, AddBoxZone, AddSphereZone, AddGlobalVehicle, RemoveZone
-- ============================================================================
local function RegisterTargetEvent(action, owner, eventNames)
    if type(action) == 'string' then return action end -- Already string? Return it

    local actionType = type(action)

    if actionType ~= 'function' and actionType ~= 'table' and actionType ~= 'userdata' then
        return nil
    end

    eventSequence = eventSequence + 1
    local eventName = ('zloma_core:target:%s:%s'):format(owner, eventSequence)

    local handler = AddEventHandler(eventName, function(...)
        InvokeTargetFunction(action, eventName, owner, ...)
    end)

    registeredEvents[eventName] = {
        handler = handler,
        owner = owner
    }
    if eventNames then
        eventNames[#eventNames + 1] = eventName
    end

    return eventName
end

local function CleanupEventList(eventNames)
    for _, eventName in ipairs(eventNames or {}) do
        CleanupTargetEvent(eventName)
    end
end

local function RemoveEntityRegistration(registration)
    if not registration then return end

    local targetType = registration.targetType
    if targetType and GetResourceState(targetType) == 'started' then
        InvokeTargetFunction(function()
            if targetType == 'ox_target' and #registration.optionNames > 0 then
                exports.ox_target:removeLocalEntity(registration.entity, registration.optionNames)
            elseif targetType == 'qb-target' then
                exports['qb-target']:RemoveTargetEntity(registration.entity, registration.labels)
            elseif targetType == 'qtarget' then
                exports['qtarget']:RemoveTargetEntity(registration.entity, registration.labels)
            end
        end, 'RemoveEntity', registration.owner)
    end

    CleanupEventList(registration.eventNames)
    registeredEntityOptions[registration.key] = nil
end

local function RemoveZoneRegistration(registration)
    if not registration then return false end

    local targetType = registration.targetType
    if targetType and GetResourceState(targetType) == 'started' then
        InvokeTargetFunction(function()
            if targetType == 'ox_target' then
                exports.ox_target:removeZone(registration.removeId)
            elseif targetType == 'qb-target' then
                exports['qb-target']:RemoveZone(registration.actualName)
            elseif targetType == 'qtarget' then
                exports['qtarget']:RemoveZone(registration.actualName)
            end
        end, 'RemoveZone', registration.owner)
    end

    CleanupEventList(registration.eventNames)
    registeredZones[registration.key] = nil
    for _, alias in ipairs(registration.aliases) do
        if zoneAliases[alias] == registration.key then
            zoneAliases[alias] = nil
        end
    end
    return true
end

local function RemoveGlobalVehicleRegistration(registration)
    if not registration then return end

    local targetType = registration.targetType
    if targetType and GetResourceState(targetType) == 'started' then
        InvokeTargetFunction(function()
            if targetType == 'ox_target' and #registration.optionNames > 0 then
                exports.ox_target:removeGlobalVehicle(registration.optionNames)
            elseif targetType == 'qb-target' then
                exports['qb-target']:RemoveGlobalVehicle(registration.labels)
            elseif targetType == 'qtarget' then
                exports['qtarget']:RemoveGlobalVehicle(registration.labels)
            end
        end, 'RemoveGlobalVehicle', registration.owner)
    end

    CleanupEventList(registration.eventNames)
    globalVehicleTargets[registration.owner] = nil
end

local function CloneOption(option)
    local copy = {}
    for key, value in pairs(option) do
        copy[key] = value
    end
    return copy
end

local function WrapCanInteract(callback, owner, optionName, adaptQbArguments)
    if not callback then return nil end

    return function(entity, distance, data, name, bone)
        local args
        if adaptQbArguments then
            local coords = nil
            if type(entity) == 'number' and entity > 0 and DoesEntityExist(entity) then
                coords = GetEntityCoords(entity)
            end
            local resolvedName = type(data) == 'table' and (data.name or data.label) or ''
            args = table.pack(entity, distance, coords, resolvedName, bone)
        else
            args = table.pack(entity, distance, data, name, bone)
        end

        local success, result = InvokeTargetFunction(
            callback,
            ('canInteract:%s'):format(optionName),
            owner,
            table.unpack(args, 1, args.n)
        )
        return success and result or false
    end
end

local function StoreZoneRegistration(registration, ...)
    registeredZones[registration.key] = registration
    local aliases = table.pack(...)
    for index = 1, aliases.n do
        local alias = aliases[index]
        if alias ~= nil then
            local ownerAlias = MakeOwnerKey(registration.owner, alias)
            zoneAliases[ownerAlias] = registration.key
            registration.aliases[#registration.aliases + 1] = ownerAlias

            if type(alias) == 'number' then
                local numericAlias = tostring(alias)
                zoneAliases[numericAlias] = registration.key
                registration.aliases[#registration.aliases + 1] = numericAlias
            end
        end
    end
end

-- EXPORT: AddEntity(entity, options) - Add target options to entity
-- entity: Entity handle or array of entities
-- options: Table of target options (standardized format)
-- Returns: true if successful, false otherwise
exports('AddEntity', function(entity, options)
    local owner = GetCallerResource()
    local targetType = ResolveTargetType()

    if not entity or type(options) ~= 'table' or #options == 0 then
        print("^1[ZLOMA ERROR]^0 AddEntity - Entity and options are required")
        return false
    end

    if not targetType then
        ZlomaCore.Warn("Target", "AddEntity")
        return false
    end

    local entityKey = MakeEntityKey(owner, entity)
    RemoveEntityRegistration(registeredEntityOptions[entityKey])

    local registration = {
        key = entityKey,
        owner = owner,
        targetType = targetType,
        entity = entity,
        optionNames = {},
        labels = {},
        eventNames = {}
    }

    local success, result

    if targetType == 'ox_target' then
        local oxOptions = {}
        for index, opt in ipairs(options) do
            if type(opt) ~= 'table' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local optionName = opt.name or ('zloma_core:%s:entity:%s:%s'):format(owner, tostring(entity), index)
            local action = opt.onSelect or opt.action
            local oxOpt = CloneOption(opt)
            oxOpt.name = optionName
            oxOpt.icon = opt.icon or 'fas fa-hand'
            oxOpt.distance = opt.distance or 2.5
            oxOpt.action = nil
            oxOpt.canInteract = WrapCanInteract(opt.canInteract, owner, optionName, false)

            if type(action) == 'string' then
                oxOpt.event = action
                oxOpt.onSelect = nil
            elseif action then
                oxOpt.event = nil
                oxOpt.onSelect = function(...)
                    InvokeTargetFunction(action, ('onSelect:%s'):format(optionName), owner, ...)
                end
            end

            oxOptions[#oxOptions + 1] = oxOpt
            registration.optionNames[#registration.optionNames + 1] = optionName
        end

        success, result = InvokeTargetFunction(function()
            exports.ox_target:addLocalEntity(entity, oxOptions)
            return true
        end, 'AddEntity', owner)
    elseif targetType == 'qb-target' then
        local qbOptions = {
            options = {},
            distance = (options[1] and options[1].distance) or 2.5
        }

        for index, opt in ipairs(options) do
            if type(opt) ~= 'table' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local actionOrEvent = opt.event or opt.onSelect or opt.action
            if type(opt.label) ~= 'string' or opt.label == '' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local eventName = RegisterTargetEvent(actionOrEvent, owner, registration.eventNames)
            local qbOpt = CloneOption(opt)
            qbOpt.type = type(actionOrEvent) == 'string' and (opt.type or 'client') or 'client'
            qbOpt.event = eventName
            qbOpt.action = nil
            qbOpt.onSelect = nil
            qbOpt.icon = opt.icon or 'fas fa-hand'
            qbOpt.canInteract = WrapCanInteract(opt.canInteract, owner, opt.name or opt.label or index, true)
            qbOptions.options[#qbOptions.options + 1] = qbOpt

            if opt.label then
                registration.labels[#registration.labels + 1] = opt.label
            end
        end

        success, result = InvokeTargetFunction(function()
            exports['qb-target']:AddTargetEntity(entity, qbOptions)
            return true
        end, 'AddEntity', owner)
    elseif targetType == 'qtarget' then
        local qtOptions = {
            options = {},
            distance = (options[1] and options[1].distance) or 2.5
        }

        for index, opt in ipairs(options) do
            if type(opt) ~= 'table' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local actionOrEvent = opt.event or opt.onSelect or opt.action
            if type(opt.label) ~= 'string' or opt.label == '' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local eventName = RegisterTargetEvent(actionOrEvent, owner, registration.eventNames)
            local qtOpt = CloneOption(opt)
            qtOpt.type = type(actionOrEvent) == 'string' and (opt.type or 'client') or 'client'
            qtOpt.event = eventName
            qtOpt.action = nil
            qtOpt.onSelect = nil
            qtOpt.icon = opt.icon or 'fas fa-hand'
            qtOpt.canInteract = WrapCanInteract(opt.canInteract, owner, opt.name or opt.label or index, true)
            qtOptions.options[#qtOptions.options + 1] = qtOpt
            if opt.label then
                registration.labels[#registration.labels + 1] = opt.label
            end
        end

        success, result = InvokeTargetFunction(function()
            exports['qtarget']:AddTargetEntity(entity, qtOptions)
            return true
        end, 'AddEntity', owner)
    end

    if not success or result == false then
        CleanupEventList(registration.eventNames)
        return false
    end

    registeredEntityOptions[entityKey] = registration
    ZlomaCore.Debug(('%s: Added %s entity target option(s) for %s'):format(targetType, #options, owner))
    return true
end)

-- EXPORT: AddBoxZone(name, coords, options) - Add target box zone
-- name: Unique zone name
-- coords: vector3 coordinates
-- options: Table with size, heading, debugPoly, and target options
-- Returns: true if successful, false otherwise
exports('AddBoxZone', function(name, coords, options)
    local owner = GetCallerResource()
    local targetType = ResolveTargetType()

    if not name or not coords or type(options) ~= 'table' then
        print("^1[ZLOMA ERROR]^0 AddBoxZone - Name, coords, and options are required")
        return false
    end

    local sourceOptions = options.targetOptions or {}
    if type(sourceOptions) ~= 'table' or #sourceOptions == 0 then
        print("^1[ZLOMA ERROR]^0 AddBoxZone - targetOptions must be a non-empty table")
        return false
    end

    if not targetType then
        ZlomaCore.Warn("Target", "AddBoxZone")
        return false
    end

    local key = MakeOwnerKey(owner, name)
    RemoveZoneRegistration(registeredZones[key])

    local actualName = ('zloma_core:%s:%s'):format(owner, tostring(name))
    local registration = {
        key = key,
        owner = owner,
        targetType = targetType,
        actualName = actualName,
        removeId = actualName,
        eventNames = {},
        aliases = {}
    }
    local success, result

    if targetType == 'ox_target' then
        local oxOptions = {}
        for index, opt in ipairs(sourceOptions) do
            if type(opt) ~= 'table' then return false end
            local optionName = opt.name or ('%s:option:%s'):format(actualName, index)
            local action = opt.onSelect or opt.action
            local oxOpt = CloneOption(opt)
            oxOpt.name = optionName
            oxOpt.icon = opt.icon or 'fas fa-hand'
            oxOpt.distance = opt.distance or 2.5
            oxOpt.action = nil
            oxOpt.canInteract = WrapCanInteract(opt.canInteract, owner, optionName, false)
            if type(action) == 'string' then
                oxOpt.event = action
                oxOpt.onSelect = nil
            elseif action then
                oxOpt.event = nil
                oxOpt.onSelect = function(...)
                    InvokeTargetFunction(action, ('onSelect:%s'):format(optionName), owner, ...)
                end
            end
            oxOptions[#oxOptions + 1] = oxOpt
        end

        success, result = InvokeTargetFunction(function()
            local zoneId = exports.ox_target:addBoxZone({
                name = actualName,
                coords = coords,
                size = options.size or vec3(2, 2, 2),
                rotation = options.heading or 0,
                debug = options.debugPoly or false,
                options = oxOptions
            })
            registration.removeId = zoneId or actualName
            return true
        end, 'AddBoxZone', owner)
    elseif targetType == 'qb-target' or targetType == 'qtarget' then
        local convertedOptions = {}
        for index, opt in ipairs(sourceOptions) do
            if type(opt) ~= 'table' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local actionOrEvent = opt.event or opt.onSelect or opt.action
            if type(opt.label) ~= 'string' or opt.label == '' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local eventName = RegisterTargetEvent(actionOrEvent, owner, registration.eventNames)
            local converted = CloneOption(opt)
            converted.type = type(actionOrEvent) == 'string' and (opt.type or 'client') or 'client'
            converted.event = eventName
            converted.action = nil
            converted.onSelect = nil
            converted.icon = opt.icon or 'fas fa-hand'
            converted.canInteract = WrapCanInteract(opt.canInteract, owner, opt.name or opt.label or index, true)
            convertedOptions[#convertedOptions + 1] = converted
        end

        local size = options.size or vec3(2, 2, 2)
        local targetOptionsWrapper = {
            options = convertedOptions,
            distance = (sourceOptions[1] and sourceOptions[1].distance) or 2.5
        }
        success, result = InvokeTargetFunction(function()
            local targetExport = targetType == 'qb-target' and exports['qb-target'] or exports['qtarget']
            targetExport:AddBoxZone(
                actualName,
                coords,
                size.x or 2,
                size.y or 2,
                {
                    name = actualName,
                    heading = options.heading or 0,
                    debugPoly = options.debugPoly or false,
                    minZ = coords.z - ((size.z or 2) / 2),
                    maxZ = coords.z + ((size.z or 2) / 2)
                },
                targetOptionsWrapper
            )
            return true
        end, 'AddBoxZone', owner)
    end

    if not success or result == false then
        CleanupEventList(registration.eventNames)
        return false
    end

    StoreZoneRegistration(registration, name, registration.removeId)
    ZlomaCore.Debug(("%s: Added box zone '%s' for %s"):format(targetType, tostring(name), owner))
    return true
end)

-- EXPORT: AddSphereZone(options) - Add target sphere zone (ox_target style)
-- options: Table with name, coords, radius, options, debug
-- Returns: zoneId if successful, nil otherwise
exports('AddSphereZone', function(options)
    local owner = GetCallerResource()
    local targetType = ResolveTargetType()

    if type(options) ~= 'table' or not options.coords then
        print("^1[ZLOMA ERROR]^0 AddSphereZone - Options with coords required")
        return nil
    end

    -- Validate options.options exists and is a non-empty table
    if not options.options or type(options.options) ~= 'table' then
        print("^1[ZLOMA ERROR]^0 AddSphereZone - options.options must be a table, got: " .. type(options.options))
        return nil
    end

    if #options.options == 0 then
        print("^1[ZLOMA ERROR]^0 AddSphereZone - options.options is empty")
        return nil
    end

    if not targetType then
        ZlomaCore.Warn("Target", "AddSphereZone")
        return nil
    end

    local name = options.name or ('sphere_%s'):format(GetGameTimer())
    local key = MakeOwnerKey(owner, name)
    RemoveZoneRegistration(registeredZones[key])

    local actualName = ('zloma_core:%s:%s'):format(owner, tostring(name))
    local registration = {
        key = key,
        owner = owner,
        targetType = targetType,
        actualName = actualName,
        removeId = actualName,
        eventNames = {},
        aliases = {}
    }
    local success, result

    if targetType == 'ox_target' then
        local zoneOptions = CloneOption(options)
        zoneOptions.name = actualName
        zoneOptions.options = {}
        for index, opt in ipairs(options.options) do
            if type(opt) ~= 'table' then return nil end
            local optionName = opt.name or ('%s:option:%s'):format(actualName, index)
            local action = opt.onSelect or opt.action
            local converted = CloneOption(opt)
            converted.name = optionName
            converted.icon = opt.icon or 'fas fa-dot-circle'
            converted.action = nil
            converted.canInteract = WrapCanInteract(opt.canInteract, owner, optionName, false)
            if type(action) == 'string' then
                converted.event = action
                converted.onSelect = nil
            elseif action then
                converted.event = nil
                converted.onSelect = function(...)
                    InvokeTargetFunction(action, ('onSelect:%s'):format(optionName), owner, ...)
                end
            end
            zoneOptions.options[#zoneOptions.options + 1] = converted
        end

        success, result = InvokeTargetFunction(function()
            registration.removeId = exports.ox_target:addSphereZone(zoneOptions) or actualName
            return true
        end, 'AddSphereZone', owner)
    elseif targetType == 'qb-target' or targetType == 'qtarget' then
        local convertedOptions = {}
        for index, opt in ipairs(options.options) do
            if type(opt) ~= 'table' then
                CleanupEventList(registration.eventNames)
                return nil
            end
            local actionOrEvent = opt.event or opt.onSelect or opt.action
            if type(opt.label) ~= 'string' or opt.label == '' then
                CleanupEventList(registration.eventNames)
                return nil
            end
            local eventName = RegisterTargetEvent(actionOrEvent, owner, registration.eventNames)
            local converted = CloneOption(opt)
            converted.type = type(actionOrEvent) == 'string' and (opt.type or 'client') or 'client'
            converted.event = eventName
            converted.action = nil
            converted.onSelect = nil
            converted.icon = opt.icon or 'fas fa-dot-circle'
            converted.canInteract = WrapCanInteract(opt.canInteract, owner, opt.name or opt.label or index, true)
            convertedOptions[#convertedOptions + 1] = converted
        end

        success, result = InvokeTargetFunction(function()
            local targetExport = targetType == 'qb-target' and exports['qb-target'] or exports['qtarget']
            targetExport:AddCircleZone(
                actualName,
                options.coords,
                options.radius or 1.0,
                {
                    name = actualName,
                    debugPoly = options.debug or false,
                    useZ = true
                },
                {
                    options = convertedOptions,
                    distance = (options.options[1] and options.options[1].distance) or 2.5
                }
            )
            return true
        end, 'AddSphereZone', owner)
    end

    if not success or result == false then
        CleanupEventList(registration.eventNames)
        return nil
    end

    StoreZoneRegistration(registration, name, registration.removeId)
    ZlomaCore.Debug(("%s: Added sphere zone '%s' for %s"):format(targetType, tostring(name), owner))
    return targetType == 'ox_target' and registration.removeId or name
end)

-- EXPORT: RemoveEntity(entity, optionNames) - Remove target options from entity
-- entity: Entity handle
-- optionNames: String or table of option names to remove
-- Returns: true if successful, false otherwise
exports('RemoveEntity', function(entity, optionNames)
    local owner = GetCallerResource()
    local targetType = ResolveTargetType()

    if not entity then
        print("^1[ZLOMA ERROR]^0 RemoveEntity - Entity is required")
        return false
    end

    if not targetType then
        ZlomaCore.Warn("Target", "RemoveEntity")
        return false
    end

    local entityKey = MakeEntityKey(owner, entity)
    local registration = registeredEntityOptions[entityKey]
    if registration then
        RemoveEntityRegistration(registration)
        return true
    end

    if type(optionNames) == 'string' then optionNames = { optionNames } end
    if type(optionNames) ~= 'table' or #optionNames == 0 then return false end

    local success = InvokeTargetFunction(function()
        if targetType == 'ox_target' then
            exports.ox_target:removeLocalEntity(entity, optionNames)
        elseif targetType == 'qb-target' then
            exports['qb-target']:RemoveTargetEntity(entity, optionNames)
        elseif targetType == 'qtarget' then
            exports['qtarget']:RemoveTargetEntity(entity, optionNames)
        end
        return true
    end, 'RemoveEntity', owner)
    return success == true
end)

-- EXPORT: AddGlobalVehicle(options) - Add target to all vehicles
-- options: Table of target options
-- Returns: true if successful, false otherwise
exports('AddGlobalVehicle', function(options)
    local owner = GetCallerResource()
    local targetType = ResolveTargetType()

    if type(options) ~= 'table' or #options == 0 then
        print("^1[ZLOMA ERROR]^0 AddGlobalVehicle - Options are required")
        return false
    end

    if not targetType then
        ZlomaCore.Warn("Target", "AddGlobalVehicle")
        return false
    end

    RemoveGlobalVehicleRegistration(globalVehicleTargets[owner])
    local registration = {
        owner = owner,
        targetType = targetType,
        optionNames = {},
        labels = {},
        eventNames = {}
    }
    local success, result

    if targetType == 'ox_target' then
        local oxOptions = {}
        for index, opt in ipairs(options) do
            if type(opt) ~= 'table' then return false end
            local optionName = opt.name or ('zloma_core:%s:globalVehicle:%s'):format(owner, index)
            local action = opt.onSelect or opt.action
            local converted = CloneOption(opt)
            converted.name = optionName
            converted.icon = opt.icon or 'fas fa-car'
            converted.distance = opt.distance or 2.5
            converted.action = nil
            converted.canInteract = WrapCanInteract(opt.canInteract, owner, optionName, false)
            if type(action) == 'string' then
                converted.event = action
                converted.onSelect = nil
            elseif action then
                converted.event = nil
                converted.onSelect = function(...)
                    InvokeTargetFunction(action, ('onSelect:%s'):format(optionName), owner, ...)
                end
            end
            oxOptions[#oxOptions + 1] = converted
            registration.optionNames[#registration.optionNames + 1] = optionName
        end

        success, result = InvokeTargetFunction(function()
            exports.ox_target:addGlobalVehicle(oxOptions)
            return true
        end, 'AddGlobalVehicle', owner)
    elseif targetType == 'qb-target' or targetType == 'qtarget' then
        local convertedOptions = {}
        for index, opt in ipairs(options) do
            if type(opt) ~= 'table' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local actionOrEvent = opt.event or opt.onSelect or opt.action
            if type(opt.label) ~= 'string' or opt.label == '' then
                CleanupEventList(registration.eventNames)
                return false
            end
            local eventName = RegisterTargetEvent(actionOrEvent, owner, registration.eventNames)
            local converted = CloneOption(opt)
            converted.type = type(actionOrEvent) == 'string' and (opt.type or 'client') or 'client'
            converted.event = eventName
            converted.action = nil
            converted.onSelect = nil
            converted.icon = opt.icon or 'fas fa-car'
            converted.canInteract = WrapCanInteract(opt.canInteract, owner, opt.name or opt.label or index, true)
            convertedOptions[#convertedOptions + 1] = converted
            if opt.label then registration.labels[#registration.labels + 1] = opt.label end
        end

        success, result = InvokeTargetFunction(function()
            local targetExport = targetType == 'qb-target' and exports['qb-target'] or exports['qtarget']
            targetExport:AddGlobalVehicle({
                options = convertedOptions,
                distance = (options[1] and options[1].distance) or 2.5
            })
            return true
        end, 'AddGlobalVehicle', owner)
    end

    if not success or result == false then
        CleanupEventList(registration.eventNames)
        return false
    end

    globalVehicleTargets[owner] = registration
    ZlomaCore.Debug(('%s: Added global vehicle target for %s'):format(targetType, owner))
    return true
end)

-- EXPORT: RemoveGlobalVehicle() - Remove options registered by the calling resource
exports('RemoveGlobalVehicle', function()
    local owner = GetCallerResource()
    local registration = globalVehicleTargets[owner]
    if not registration then return false end

    RemoveGlobalVehicleRegistration(registration)
    return true
end)

-- EXPORT: RemoveZone(name) - Remove target zone
-- name: Zone name to remove
-- Returns: true if successful, false otherwise
exports('RemoveZone', function(name)
    local owner = GetCallerResource()
    if not name then
        print("^1[ZLOMA ERROR]^0 RemoveZone - Name is required")
        return false
    end

    local directKey = MakeOwnerKey(owner, name)
    local registrationKey = registeredZones[directKey] and directKey or zoneAliases[directKey]
    if not registrationKey and type(name) == 'number' then
        registrationKey = zoneAliases[tostring(name)]
    end

    return RemoveZoneRegistration(registrationKey and registeredZones[registrationKey] or nil)
end)

local function CleanupOwnerTargets(owner)
    local entities, zones = {}, {}
    for _, registration in pairs(registeredEntityOptions) do
        if registration.owner == owner then entities[#entities + 1] = registration end
    end
    for _, registration in pairs(registeredZones) do
        if registration.owner == owner then zones[#zones + 1] = registration end
    end

    for _, registration in ipairs(entities) do RemoveEntityRegistration(registration) end
    for _, registration in ipairs(zones) do RemoveZoneRegistration(registration) end
    RemoveGlobalVehicleRegistration(globalVehicleTargets[owner])

    for eventName, registration in pairs(registeredEvents) do
        if registration.owner == owner then CleanupTargetEvent(eventName) end
    end
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == 'ox_target' or resourceName == 'qb-target' or resourceName == 'qtarget' then
        TargetType = nil
        ResolveTargetType()
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local owners = {}
        for _, registration in pairs(registeredEntityOptions) do owners[registration.owner] = true end
        for _, registration in pairs(registeredZones) do owners[registration.owner] = true end
        for owner in pairs(globalVehicleTargets) do owners[owner] = true end
        for owner in pairs(owners) do CleanupOwnerTargets(owner) end
        CleanupAllTargetEvents()
        return
    end

    CleanupOwnerTargets(resourceName)
    if resourceName == TargetType then TargetType = nil end
end)
