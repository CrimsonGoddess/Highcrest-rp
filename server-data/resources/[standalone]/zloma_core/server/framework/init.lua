-- ZLOMA CORE - Server Framework Wrapper
-- Unified interface for ESX, QBCore, and QBox frameworks
-- Customer-friendly: Automatic detection, graceful fallbacks, clear error messages
-- QBox Compatibility: Uses export-based API for full QBox support

local Framework = nil
local FrameworkType = nil
local usableItemCallbacks = {}
local registeredUsableItems = {}
local LoadFramework
local RestoreUsableItems
local frameworkReady = false

exports('GetFrameworkType', function()
    if not FrameworkType and LoadFramework then LoadFramework() end
    return FrameworkType
end)

exports('IsFrameworkReady', function()
    if (not FrameworkType or not Framework) and LoadFramework then LoadFramework() end
    return frameworkReady and FrameworkType ~= nil and Framework ~= nil
end)

-- ============================================================================
-- QBOX HELPER FUNCTIONS
-- QBox uses export-based API instead of Framework.Functions.*
-- These helpers ensure compatibility with both QBCore and QBox
-- ============================================================================

-- Helper: Check permission (works for both QBCore and QBox)
local function HasPermission(source, permission)
    if FrameworkType == 'QBox' then
        return exports.qbx_core:HasPermission(source, permission)
    elseif FrameworkType == 'QBCore' then
        return Framework.Functions.HasPermission(source, permission)
    end
    return false
end

-- Helper: Get all jobs (works for both QBCore and QBox)
local function GetAllFrameworkJobs()
    if FrameworkType == 'QBox' then
        return exports.qbx_core:GetJobs()
    elseif FrameworkType == 'QBCore' then
        return Framework.Shared.Jobs
    end
    return {}
end

-- Helper: Get all gangs (works for both QBCore and QBox)
local function GetAllFrameworkGangs()
    if FrameworkType == 'QBox' then
        return exports.qbx_core:GetGangs()
    elseif FrameworkType == 'QBCore' then
        return Framework.Shared.Gangs
    end
    return {}
end

-- Helper: Get all players (works for both QBCore and QBox)
local function GetFrameworkPlayers()
    if FrameworkType == 'QBox' then
        local players = {}
        for src in pairs(exports.qbx_core:GetQBPlayers()) do
            players[#players + 1] = src
        end
        return players
    elseif FrameworkType == 'QBCore' then
        return Framework.Functions.GetPlayers()
    end
    return {}
end

-- Helper: Get job grade value (QBCore uses grade.level, QBox uses integer directly)
local function GetJobGradeValue(job)
    if not job or not job.grade then return 0 end
    
    -- QBox: grade is integer directly
    if type(job.grade) == 'number' then
        return job.grade
    end
    
    -- QBCore: grade is object with level property
    if type(job.grade) == 'table' and job.grade.level then
        return job.grade.level
    end
    
    return 0
end

-- Helper: Get gang grade value (same logic as job)
local function GetGangGradeValue(gang)
    if not gang or not gang.grade then return 0 end
    
    -- QBox: grade is integer directly
    if type(gang.grade) == 'number' then
        return gang.grade
    end
    
    -- QBCore: grade is object with level property
    if type(gang.grade) == 'table' and gang.grade.level then
        return gang.grade.level
    end
    
    return 0
end

-- Helper: Get job grade name (for label)
local function GetJobGradeName(job)
    if not job or not job.grade then return 'Unknown' end
    
    -- QBox: grade is integer, need to get name from job grades
    if type(job.grade) == 'number' then
        return 'Grade ' .. tostring(job.grade)
    end
    
    -- QBCore: grade is object with name property
    if type(job.grade) == 'table' and job.grade.name then
        return job.grade.name
    end
    
    return 'Unknown'
end

LoadFramework = function()
    local detected = ZlomaCore.DetectFramework()
    if detected == FrameworkType and Framework then
        frameworkReady = true
        return true
    end

    Framework = nil
    FrameworkType = detected
    frameworkReady = false
    ZlomaCore.Cache.Framework = detected
    if not detected then return false end

    local success, err = xpcall(function()
        if detected == 'ESX' then
            local exportSuccess, result = pcall(function()
                return exports['es_extended']:getSharedObject()
            end)

            if exportSuccess and result then
                Framework = result
            else
                TriggerEvent('esx:getSharedObject', function(object)
                    Framework = object
                end)
            end
        elseif detected == 'QBCore' then
            Framework = exports['qb-core']:GetCoreObject()
        elseif detected == 'QBox' then
            Framework = exports.qbx_core
        end

        if not Framework then error(('Could not load %s object'):format(detected)) end
    end, debug.traceback)

    if not success then
        Framework = nil
        FrameworkType = nil
        frameworkReady = false
        ZlomaCore.Cache.Framework = nil
        print(('^1[ZLOMA CORE ERROR]^0 Framework initialization failed:\n%s'):format(err))
        return false
    end

    frameworkReady = true
    TriggerEvent('zloma_core:server:FrameworkReady', FrameworkType)
    print(('^2[ZLOMA CORE]^0 Framework adapter ready: %s'):format(FrameworkType))
    ZlomaCore.Debug(('%s Framework loaded'):format(detected))
    return true
end

-- Initialize framework on resource start.
CreateThread(function()
    -- Providers such as zloma_banking and zloma_keys declare zloma_core as a
    -- dependency. Allow FiveM to start those dependent resources before the
    -- first detection banner is generated.
    Wait(ZlomaCore.Config.Timeouts.InitWait or 500)
    ZlomaCore.Initialize()
    local startup = ZlomaCore.Config.FrameworkStartup or {}
    local timeout = math.max(0, tonumber(startup.TimeoutMs) or 15000)
    local retry = math.max(50, tonumber(startup.RetryMs) or 250)
    local deadline = GetGameTimer() + timeout

    repeat
        if LoadFramework() then return end
        Wait(retry)
    until GetGameTimer() >= deadline

    if not LoadFramework() then
        print(('^1[ZLOMA CORE ERROR]^0 No supported framework became ready within %sms. Ensure es_extended, qbx_core/qbx-core, or qb-core starts before zloma_core.')
            :format(timeout))
    end
end)

local function IsFrameworkResource(resourceName)
    return resourceName == 'es_extended' or resourceName == 'qb-core'
        or resourceName == 'qbx_core' or resourceName == 'qbx-core'
end

AddEventHandler('onResourceStart', function(resourceName)
    if not IsFrameworkResource(resourceName) then return end
    CreateThread(function()
        Wait(0)
        if LoadFramework() then
            ZlomaCore.Cache.Society = ZlomaCore.DetectSociety()
            print(('^2[ZLOMA CORE]^0 Framework provider refresh: Framework: %s | Society: %s')
                :format(FrameworkType or '^1NONE DETECTED^0', ZlomaCore.Cache.Society or '^1NONE DETECTED^0'))
            if RestoreUsableItems then RestoreUsableItems() end
        end
    end)
end)

-- `zloma_banking` and `zloma_keys` depend on this resource, so FiveM starts
-- them after the initial scan in ZlomaCore.Initialize(). Refresh the affected
-- caches once those providers are actually running instead of leaving the
-- startup banner with a stale "NONE DETECTED" result.
local function RefreshLateStartingProviders(resourceName)
    if resourceName ~= 'zloma_banking' and resourceName ~= 'zloma_keys' and resourceName ~= 'esx_addonaccount' then return end

    CreateThread(function()
        -- Let the provider finish its startup and register exports first.
        Wait(0)

        if resourceName == 'zloma_banking' or resourceName == 'esx_addonaccount' then
            ZlomaCore.Cache.Billing = ZlomaCore.DetectBilling()
            ZlomaCore.Cache.Society = ZlomaCore.DetectSociety()
            print(('^2[ZLOMA CORE]^0 Provider detected after startup: Billing: %s | Society: %s')
                :format(ZlomaCore.Cache.Billing or '^1NONE DETECTED^0', ZlomaCore.Cache.Society or '^1NONE DETECTED^0'))
        else
            ZlomaCore.Cache.Keys = ZlomaCore.DetectKeys()
            print(('^2[ZLOMA CORE]^0 Provider detected after startup: Keys: %s')
                :format(ZlomaCore.Cache.Keys or '^1NONE DETECTED^0'))
        end
    end)
end

AddEventHandler('onResourceStart', RefreshLateStartingProviders)

AddEventHandler('onResourceStop', function(resourceName)
    local stoppedActiveFramework = (FrameworkType == 'ESX' and resourceName == 'es_extended')
        or (FrameworkType == 'QBCore' and resourceName == 'qb-core')
        or (FrameworkType == 'QBox' and (resourceName == 'qbx_core' or resourceName == 'qbx-core'))
    if not stoppedActiveFramework then return end

    Framework = nil
    FrameworkType = nil
    frameworkReady = false
    ZlomaCore.Cache.Framework = nil
    registeredUsableItems = {}

    CreateThread(function()
        Wait(0)
        if LoadFramework() and RestoreUsableItems then RestoreUsableItems() end
    end)
end)

-- EXPORT: GetPlayer(source) - Returns unified player object
-- Returns: Player object or nil if not found
exports('GetPlayer', function(source, maybeSource)
    if type(source) == 'table' then
        source = maybeSource
    end
    source = tonumber(source) or source
    if (not FrameworkType or not Framework) and not LoadFramework() then
        ZlomaCore.Warn("Framework", "GetPlayer")
        return nil
    end

    local player = nil

    if FrameworkType == 'ESX' then
        player = Framework.GetPlayerFromId(source)
    elseif FrameworkType == 'QBCore' then
        player = Framework.Functions.GetPlayer(source)
    elseif FrameworkType == 'QBox' then
        player = exports.qbx_core:GetPlayer(source)
    end

    if not player then
        ZlomaCore.Debug(string.format("Player %s not found in framework", source))
    end

    return player
end)

-- EXPORT: GetPlayerMoney(source, account) - Get player money from specific account
-- Returns: Money amount or 0 if account not found
exports('GetPlayerMoney', function(source, account)
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetPlayerMoney")
        return 0
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return 0 end

    account = account or 'cash' -- Default to cash if not specified

    if FrameworkType == 'ESX' then
        local accountName = account == 'cash' and 'money' or account
        local acc = player.getAccount(accountName)
        return acc and acc.money or 0
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local accountName = account == 'cash' and 'cash' or account
        return player.PlayerData.money[accountName] or 0
    end

    return 0
end)

-- EXPORT: RemoveMoney(source, amount, account) - Remove money from player
-- Returns: true if successful, false otherwise
exports('RemoveMoney', function(source, amount, account)
    if type(amount)~='number' or amount~=amount or amount<0 or amount==math.huge or (account~=nil and (type(account)~='string' or #account>64)) then return false end
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "RemoveMoney")
        return false
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return false end

    account = account or 'cash'

    if FrameworkType == 'ESX' then
        local accountName = account == 'cash' and 'money' or account
        local accountData=player.getAccount(accountName)
        if not accountData or (tonumber(accountData.money) or 0)<amount then return false end
        player.removeAccountMoney(accountName, amount)
        ZlomaCore.Debug(string.format("Removed $%s from %s account (Player %s)", amount, accountName, source))
        return true
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local accountName = account == 'cash' and 'cash' or account
        local removed = player.Functions.RemoveMoney(accountName, amount)
        if removed then
            ZlomaCore.Debug(string.format("Removed $%s from %s account (Player %s)", amount, accountName, source))
        end
        return removed == true
    end

    return false
end)

-- EXPORT: AddMoney(source, amount, account) - Add money to player
-- Returns: true if successful, false otherwise
exports('AddMoney', function(source, amount, account)
    if type(amount)~='number' or amount~=amount or amount<0 or amount==math.huge or (account~=nil and (type(account)~='string' or #account>64)) then return false end
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "AddMoney")
        return false
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return false end

    account = account or 'cash'

    if FrameworkType == 'ESX' then
        local accountName = account == 'cash' and 'money' or account
        player.addAccountMoney(accountName, amount)
        ZlomaCore.Debug(string.format("Added $%s to %s account (Player %s)", amount, accountName, source))
        return true
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local accountName = account == 'cash' and 'cash' or account
        local added = player.Functions.AddMoney(accountName, amount)
        if added then
            ZlomaCore.Debug(string.format("Added $%s to %s account (Player %s)", amount, accountName, source))
        end
        return added == true
    end

    return false
end)

-- EXPORT: GetPlayerJob(source) - Get player job information
-- Returns: {name = string, grade = number, label = string} or nil
exports('GetPlayerJob', function(source, maybeSource)
    if type(source) == 'table' then source = maybeSource end
    source = tonumber(source) or source
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetPlayerJob")
        return nil
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return nil end

    if FrameworkType == 'ESX' then
        local job = player.getJob()
        return {
            name       = job.name,
            grade      = job.grade,
            label      = job.label,
            grade_name  = job.grade_name or ('Grade ' .. tostring(job.grade)),
            grade_label = job.grade_label or job.grade_name or ('Grade ' .. tostring(job.grade))
        }
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local job = player.PlayerData.job
        -- grade is a table { level, name, ... } for both QBCore and QBox server-side PlayerData
        local gradeLevel = GetJobGradeValue(job)
        local gradeName  = GetJobGradeName(job)
        return {
            name       = job.name,
            grade      = gradeLevel,
            label      = job.label,
            grade_name  = gradeName,
            grade_label = gradeName
        }
    end

    return nil
end)

-- EXPORT: GetPlayerGang(source) - Get player gang information (QBCore/QBox only)
-- Returns: {name = string, grade = number, label = string} or nil
exports('GetPlayerGang', function(source, maybeSource)
    if type(source) == 'table' then source = maybeSource end
    source = tonumber(source) or source
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetPlayerGang")
        return nil
    end

    if FrameworkType == 'ESX' then
        ZlomaCore.Debug("ESX does not support gangs - returning nil")
        return nil
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return nil end

    if FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local gang = player.PlayerData.gang
        if gang then
            return {
                name = gang.name,
                grade = GetGangGradeValue(gang),  -- Uses helper for QBCore/QBox compatibility
                label = gang.label
            }
        end
    end

    return nil
end)

-- EXPORT: GetIdentifier(source) - Get player identifier
-- Returns: Identifier string or nil
exports('GetIdentifier', function(source, maybeSource)
    if type(source) == 'table' then
        source = maybeSource
    end
    source = tonumber(source) or source
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetIdentifier")
        return nil
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return nil end

    if FrameworkType == 'ESX' then
        return player.identifier
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        return player.PlayerData.citizenid
    end

    return nil
end)

-- EXPORT: GetCharacterName(identifier) - Get player's character name from identifier
-- Returns: Full name string or nil
exports('GetCharacterName', function(identifier)
    if not identifier then return nil end

    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetCharacterName")
        return nil
    end

    if FrameworkType == 'ESX' then
        -- ESX: Query users table for firstname + lastname
        local result = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', { identifier })
        if result then
            local first = result.firstname or ''
            local last = result.lastname or ''
            local fullName = (first .. ' ' .. last):match('^%s*(.-)%s*$')
            if fullName and fullName ~= '' then
                return fullName
            end
        end
        return identifier
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        -- QBCore/QBox: Query players table for charinfo
        local result = MySQL.single.await('SELECT charinfo FROM players WHERE citizenid = ?', { identifier })
        if result and result.charinfo then
            local charinfo = json.decode(result.charinfo)
            if charinfo then
                local first = charinfo.firstname or ''
                local last = charinfo.lastname or ''
                local fullName = (first .. ' ' .. last):match('^%s*(.-)%s*$')
                if fullName and fullName ~= '' then
                    return fullName
                end
            end
        end
        return identifier
    end

    return nil
end)

-- EXPORT: GetPlayerFromIdentifier(identifier) - Get online player source by identifier
-- Returns: Player source or nil if not online
exports('GetPlayerFromIdentifier', function(identifier)
    if not identifier then return nil end

    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetPlayerFromIdentifier")
        return nil
    end

    if FrameworkType == 'ESX' then
        local xPlayer = Framework.GetPlayerFromIdentifier(identifier)
        return xPlayer and xPlayer.source or nil
    elseif FrameworkType == 'QBCore' then
        local Player = Framework.Functions.GetPlayerByCitizenId(identifier)
        return Player and Player.PlayerData.source or nil
    elseif FrameworkType == 'QBox' then
        local Player = exports.qbx_core:GetPlayerByCitizenId(identifier)
        return Player and Player.PlayerData.source or nil
    end

    return nil
end)

-- EXPORT: IsAdmin(source, groups) - Check if player has admin permissions
-- source: Player server ID
-- groups: Optional table of group names to check (e.g., {'admin', 'superadmin', 'owner'})
--         If not provided, defaults to {'admin', 'superadmin'} for ESX
-- strictGroups: Optional true disables broad command/admin/god fallbacks when
-- explicit groups are supplied. Existing two-argument callers retain behavior.
-- Returns: true if admin, false otherwise
exports('IsAdmin', function(source, groups, maybeGroups, maybeStrictGroups)
    local strictGroups = maybeGroups
    if type(source) == 'table' then
        source = groups
        groups = maybeGroups
        strictGroups = maybeStrictGroups
    end
    source = tonumber(source) or source

    if not FrameworkType then
        ZlomaCore.Warn("Framework", "IsAdmin")
        return false
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return false end

    if FrameworkType == 'ESX' then
        -- ESX: Check player's group against provided groups or defaults
        local allowedGroups = groups or { 'admin', 'superadmin' }
        local playerGroup = nil

        -- Safely get player group
        if player.getGroup then
            playerGroup = player.getGroup()
        end

        ZlomaCore.Debug(string.format("IsAdmin check - Source: %s, PlayerGroup: '%s', AllowedGroups: %s",
            tostring(source), tostring(playerGroup), json.encode(allowedGroups)))

        if playerGroup then
            for _, group in ipairs(allowedGroups) do
                if playerGroup == group then
                    return true
                end
            end
        end

        if strictGroups == true then return false end

        -- Fallback: Native Ace Permission Check (txAdmin, server.cfg based permissions)
        if IsPlayerAceAllowed(source, 'command') then
            ZlomaCore.Debug(string.format("IsAdmin - Player %s passed via Ace permission fallback", source))
            return true
        end

        return false
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        -- QBCore/QBox: Check permissions against provided groups
        -- Uses helper function for QBox export compatibility
        if groups then
            for _, group in ipairs(groups) do
                if HasPermission(source, group) then
                    return true
                end
            end
        end

        if strictGroups == true then return false end

        -- Fallback 1: Standard QBCore/QBox admin/god check
        if HasPermission(source, 'admin') or HasPermission(source, 'god') then
            return true
        end

        -- Fallback 2: Native Ace Permission Check
        -- This covers cases where framework permissions aren't syncing but the player has Ace access (txAdmin, etc.)
        if IsPlayerAceAllowed(source, 'command') then
            return true
        end

        return false
    end

    return false
end)


-- Server callback: Check if player is admin (for client-side calls)
if lib and lib.callback then
    lib.callback.register('zloma_core:isAdmin', function(source, groups)
        return exports['zloma_core']:IsAdmin(source, groups)
    end)
end

-- Server callback: Check if player has vehicle keys (for qb-vehiclekeys client-side)
lib.callback.register('zloma_core:hasVehicleKeys', function(source, plate)
    if not plate then return false end
    -- Use zloma_core unified GetPlayer - works for ESX, QBCore, and QBox
    local success, result = pcall(function()
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        -- QBCore / QBox: check items for vehiclekey with matching plate
        if FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
            local items = Player.PlayerData.items
            for _, item in pairs(items or {}) do
                if item.name == 'vehiclekey' and item.info and item.info.plate == plate then
                    return true
                end
            end
        end
        -- ESX does not store keys server-side; return false (client-side keys check not applicable)
        return false
    end)
    return success and result or false
end)

-- EXPORT: Notify(source, message, type, duration) - Send notification to client
-- Server-side wrapper that triggers client notification
-- Supports both:
--   Notify(source, 'message', 'type', duration)
--   Notify(source, { title=..., description=..., type=..., duration=... })
exports('Notify', function(source, message, notifyType, duration)
    if type(source) ~= 'number' or source <= 0 or GetPlayerName(source) == nil then
        print('[zloma_core] Cannot notify server console')
        return false
    end

    duration = math.min(30000, math.max(500, tonumber(duration) or 5000))

    local payload
    if type(message) == 'table' then
        payload = {
            title = type(message.title) == 'string' and message.title:sub(1, 128) or nil,
            description = type(message.description) == 'string' and message.description:sub(1, 512) or '',
            type = type(message.type) == 'string' and message.type:sub(1, 32) or 'inform',
            duration = math.min(30000, math.max(500, tonumber(message.duration) or duration))
        }
    else
        payload = {
            title = nil,
            description = tostring(message or ''):sub(1, 512),
            type = type(notifyType) == 'string' and notifyType:sub(1, 32) or 'inform',
            duration = duration
        }
    end

    TriggerClientEvent('zloma_core:notify', source, payload)
    return true
end)

-- Server callback: Get player job (for client-side calls)
lib.callback.register('zloma_core:getPlayerJob', function(source)
    return exports['zloma_core']:GetPlayerJob(source)
end)

-- Server callback: Get player gang (for client-side calls)
lib.callback.register('zloma_core:getPlayerGang', function(source)
    return exports['zloma_core']:GetPlayerGang(source)
end)

-- ============================================================================
-- VEHICLE KEYS (Server-side wrappers)
-- ============================================================================

-- EXPORT: GiveVehicleKeys(source, plate) - Give vehicle keys from server side
-- Supports both dot syntax and colon syntax: exports.zloma_core:GiveVehicleKeys(...) or exports.zloma_core.GiveVehicleKeys(...)
exports('GiveVehicleKeys', function(source, plate, maybePlate)
    if type(source) == 'table' then
        source = plate
        plate = maybePlate
    end

    source = tonumber(source)
    if type(plate) == 'string' then
        plate = plate:gsub('^%s*(.-)%s*$', '%1'):upper()
    elseif plate ~= nil then
        plate = tostring(plate):gsub('^%s*(.-)%s*$', '%1'):upper()
    end

    if not source or GetPlayerName(source) == nil or type(plate) ~= 'string' or plate == '' or #plate > 16 then
        print('[zloma_core] GiveVehicleKeys requires source and plate')
        return false
    end

    -- Direct authoritative server-side key grant if zloma_keys is running
    if GetResourceState('zloma_keys') == 'started' then
        pcall(function()
            if exports['zloma_keys'] then
                if exports['zloma_keys'].GiveKeyToPlayer then
                    exports['zloma_keys']:GiveKeyToPlayer(source, plate)
                end
                if exports['zloma_keys'].AuthorizeKeyRequest then
                    exports['zloma_keys']:AuthorizeKeyRequest(source, plate)
                end
            end
        end)
    end

    TriggerClientEvent('zloma_core:client:giveKeys', source, plate)
    return true
end)

-- EXPORT: RemoveVehicleKeys(source, plate) - Remove vehicle keys from server side
exports('RemoveVehicleKeys', function(source, plate, maybePlate)
    if type(source) == 'table' then
        source = plate
        plate = maybePlate
    end

    source = tonumber(source)
    if type(plate) == 'string' then
        plate = plate:gsub('^%s*(.-)%s*$', '%1'):upper()
    elseif plate ~= nil then
        plate = tostring(plate):gsub('^%s*(.-)%s*$', '%1'):upper()
    end

    if not source or GetPlayerName(source) == nil or type(plate) ~= 'string' or plate == '' or #plate > 16 then
        print('[zloma_core] RemoveVehicleKeys requires source and plate')
        return false
    end

    if GetResourceState('zloma_keys') == 'started' then
        pcall(function()
            if exports['zloma_keys'] and exports['zloma_keys'].RemoveKeyFromPlayer then
                exports['zloma_keys']:RemoveKeyFromPlayer(source, plate)
            end
        end)
    end

    TriggerClientEvent('zloma_core:client:removeKeys', source, plate)
    return true
end)

-- ============================================================================
-- JOB MANAGEMENT FUNCTIONS
-- ============================================================================

-- EXPORT: SetPlayerJob(source, jobName, grade) - Set player's job
-- Returns: true if successful, false otherwise
exports('SetPlayerJob', function(source, jobName, grade)
    if not source or not jobName then return false end
    grade = grade or 0

    if not FrameworkType then
        ZlomaCore.Warn("Framework", "SetPlayerJob")
        return false
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return false end

    if FrameworkType == 'ESX' then
        player.setJob(jobName, grade)
        ZlomaCore.Debug(string.format("Set player %s job to %s grade %s", source, jobName, grade))
        return true
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        player.Functions.SetJob(jobName, grade)
        ZlomaCore.Debug(string.format("Set player %s job to %s grade %s", source, jobName, grade))
        return true
    end

    return false
end)

-- EXPORT: GetAllJobs() - Get all available jobs from framework
-- Returns: Table of jobs or empty table
exports('GetAllJobs', function()
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetAllJobs")
        return {}
    end

    if FrameworkType == 'ESX' then
        local jobs = Framework.GetJobs()
        return jobs or {}
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        return GetAllFrameworkJobs()  -- Uses helper for QBCore/QBox compatibility
    end

    return {}
end)

-- EXPORT: GetAllGangs() - Get all available gangs from framework (QBCore/QBox only)
-- Returns: Table of gangs or empty table
exports('GetAllGangs', function()
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetAllGangs")
        return {}
    end

    if FrameworkType == 'ESX' then
        ZlomaCore.Debug("ESX does not support gangs - returning empty table")
        return {}
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        return GetAllFrameworkGangs()  -- Uses helper for QBCore/QBox compatibility
    end

    return {}
end)

-- EXPORT: GetJobGrades(jobName) - Get grades for a specific job
-- Returns: Table of grades or empty table
exports('GetJobGrades', function(jobName)
    if not jobName then return {} end

    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetJobGrades")
        return {}
    end

    if FrameworkType == 'ESX' then
        local jobs = Framework.GetJobs()
        if jobs and jobs[jobName] then
            return jobs[jobName].grades or {}
        end
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local jobs = GetAllFrameworkJobs()  -- Uses helper for QBCore/QBox compatibility
        if jobs and jobs[jobName] then
            return jobs[jobName].grades or {}
        end
    end

    return {}
end)

-- EXPORT: GetGangGrades(gangName) - Get grades for a specific gang.
-- ESX has no gang definition, so it intentionally returns an empty table.
exports('GetGangGrades', function(gangName)
    if not gangName then return {} end

    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetGangGrades")
        return {}
    end

    if FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local gangs = GetAllFrameworkGangs()
        if gangs and gangs[gangName] then
            return gangs[gangName].grades or {}
        end
    end

    return {}
end)

-- EXPORT: GetOnlinePlayers() - Get all online players with basic info
-- Returns: Table of {source, identifier, name, job}
exports('GetOnlinePlayers', function()
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetOnlinePlayers")
        return {}
    end

    local players = {}

    if FrameworkType == 'ESX' then
        local xPlayers = Framework.GetExtendedPlayers()
        for _, xPlayer in pairs(xPlayers) do
            local job = xPlayer.getJob()
            -- xPlayer.getName() returns the player's FiveM/Steam network name, NOT the character name.
            -- ESX Legacy stores character name via xPlayer.get('firstName') / xPlayer.get('lastName').
            local firstName = ''
            local lastName  = ''
            local ok, r1 = pcall(function() return xPlayer.get('firstName') end)
            if ok and r1 then firstName = r1 end
            local ok2, r2 = pcall(function() return xPlayer.get('lastName') end)
            if ok2 and r2 then lastName = r2 end
            local charName = (firstName ~= '' or lastName ~= '')
                and (firstName .. ' ' .. lastName)
                or GetPlayerName(xPlayer.source) or xPlayer.identifier
            table.insert(players, {
                source = xPlayer.source,
                identifier = xPlayer.identifier,
                name = charName,
                job = {
                    name = job.name,
                    grade = job.grade,
                    label = job.label,
                    gradeLabel = job.grade_label
                }
            })
        end
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local qbPlayers = GetFrameworkPlayers()  -- Uses helper for QBCore/QBox compatibility
        for _, playerId in ipairs(qbPlayers) do
            local player = exports['zloma_core']:GetPlayer(playerId)  -- Uses our unified GetPlayer
            if player then
                local job = player.PlayerData.job
                local charinfo = player.PlayerData.charinfo
                table.insert(players, {
                    source = playerId,
                    identifier = player.PlayerData.citizenid,
                    name = charinfo.firstname .. ' ' .. charinfo.lastname,
                    job = {
                        name = job.name,
                        grade = GetJobGradeValue(job),  -- Uses helper for QBCore/QBox compatibility
                        label = job.label,
                        gradeLabel = GetJobGradeName(job)  -- Uses helper for grade name
                    }
                })
            end
        end
    end

    return players
end)

-- EXPORT: GetPlayerGroup(source) - Get player's permission group
-- Returns: Group name string or 'user'
exports('GetPlayerGroup', function(source)
    if not source then return 'user' end

    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetPlayerGroup")
        return 'user'
    end

    local player = exports['zloma_core']:GetPlayer(source)
    if not player then return 'user' end

    if FrameworkType == 'ESX' then
        return player.getGroup() or 'user'
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        -- QBCore/QBox uses ace permissions, return highest permission
        -- Uses helper function for QBox export compatibility
        if HasPermission(source, 'god') then return 'god' end
        if HasPermission(source, 'admin') then return 'admin' end
        if HasPermission(source, 'mod') then return 'mod' end
        return 'user'
    end

    return 'user'
end)

-- Server callbacks for society money
lib.callback.register('zloma_core:getSocietyMoney', function(source, jobName)
    if type(jobName) ~= 'string' or jobName == '' or #jobName > 64 then return 0 end

    local playerJob = exports['zloma_core']:GetPlayerJob(source)
    local isAdmin = exports['zloma_core']:IsAdmin(source)
    if not isAdmin and (not playerJob or playerJob.name ~= jobName) then return 0 end

    return exports['zloma_core']:GetSocietyMoney(jobName)
end)

lib.callback.register('zloma_core:getJobGrades', function(source, jobName)
    if type(jobName) ~= 'string' or jobName == '' or #jobName > 64 then return {} end

    local playerJob = exports['zloma_core']:GetPlayerJob(source)
    local isAdmin = exports['zloma_core']:IsAdmin(source)
    if not isAdmin and (not playerJob or playerJob.name ~= jobName) then return {} end

    return exports['zloma_core']:GetJobGrades(jobName)
end)

lib.callback.register('zloma_core:getOnlinePlayers', function(source)
    if not exports['zloma_core']:IsAdmin(source) then return {} end
    return exports['zloma_core']:GetOnlinePlayers()
end)

-- EXPORT: CreateUseableItem(item, callback) - Register usable item
-- callback(source, item, ...)
local function DispatchUsableItem(item, source, itemData, ...)
    local record = usableItemCallbacks[item]
    if not record then return end
    local extraArguments = table.pack(...)

    local success, err = xpcall(function()
        return record.callback(source, itemData, table.unpack(extraArguments, 1, extraArguments.n))
    end, debug.traceback)

    if not success then
        print(('^1[ZLOMA CORE ERROR]^0 Usable item "%s" callback owned by "%s" failed:\n%s')
            :format(item, record.owner, err))
    end
end

local function RegisterUsableItemWithFramework(item)
    if registeredUsableItems[item] then return true end
    local function dispatcher(source, itemData, ...)
        DispatchUsableItem(item, source, itemData, ...)
    end

    local success, err = xpcall(function()
        if FrameworkType == 'ESX' then
            Framework.RegisterUsableItem(item, dispatcher)
        elseif FrameworkType == 'QBCore' then
            Framework.Functions.CreateUseableItem(item, dispatcher)
        elseif FrameworkType == 'QBox' then
            exports.qbx_core:CreateUseableItem(item, dispatcher)
        else
            error(('Unsupported framework %s'):format(tostring(FrameworkType)))
        end
    end, debug.traceback)

    if not success then
        print(('^1[ZLOMA CORE ERROR]^0 Could not register usable item "%s":\n%s'):format(item, err))
        return false
    end

    registeredUsableItems[item] = true
    return true
end

RestoreUsableItems = function()
    for item in pairs(usableItemCallbacks) do
        RegisterUsableItemWithFramework(item)
    end
end

exports('CreateUseableItem', function(item, callback)
    if type(item) ~= 'string' or item == '' or #item > 128 or type(callback) ~= 'function' then
        return false
    end

    if (not FrameworkType or not Framework) and not LoadFramework() then
        ZlomaCore.Warn("Framework", "CreateUseableItem")
        return false
    end

    local previous = usableItemCallbacks[item]
    usableItemCallbacks[item] = {
        callback = callback,
        owner = GetInvokingResource() or GetCurrentResourceName()
    }

    -- Frameworks generally do not expose an unregister API. Register one stable
    -- core-owned dispatcher, then only replace the resource-owned callback record.
    if RegisterUsableItemWithFramework(item) then return true end

    usableItemCallbacks[item] = previous
    return false
end)

AddEventHandler('onResourceStop', function(resourceName)
    for item, record in pairs(usableItemCallbacks) do
        if record.owner == resourceName then
            usableItemCallbacks[item] = nil
        end
    end
end)

-- EXPORT: GetOfflinePlayerJob(identifier) - Get offline player's job data
-- Returns: {name = string, grade = number, label = string} or nil
exports('GetOfflinePlayerJob', function(identifier)
    if not identifier then return nil end
    
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "GetOfflinePlayerJob")
        return nil
    end
    
    if FrameworkType == 'ESX' then
        local result = MySQL.single.await('SELECT job, job_grade FROM users WHERE identifier = ?', {identifier})
        if result then
            -- Framework.Jobs does NOT exist in ESX Legacy — use Framework.GetJobs() function
            local jobLabel = 'Unknown'
            local ok, jobs = pcall(function() return Framework.GetJobs() end)
            if ok and jobs and jobs[result.job] then
                jobLabel = jobs[result.job].label or 'Unknown'
            end
            
            return {
                name = result.job,
                grade = result.job_grade or 0,
                label = jobLabel
            }
        end
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        local result = MySQL.single.await([[
            SELECT JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) as jobName,
                   JSON_UNQUOTE(JSON_EXTRACT(job, '$.label')) as jobLabel,
                   JSON_EXTRACT(job, '$.grade.level') as grade
            FROM players 
            WHERE citizenid = ?
        ]], {identifier})
        
        if result then
            return {
                name = result.jobName,
                grade = tonumber(result.grade) or 0,
                label = result.jobLabel or 'Unknown'
            }
        end
    end
    
    return nil
end)

-- EXPORT: SetOfflinePlayerJob(identifier, job, grade) - Set offline player's job
-- Returns: true if successful, false otherwise
exports('SetOfflinePlayerJob', function(identifier, jobName, grade)
    if not identifier or not jobName then return false end
    
    if not FrameworkType then
        ZlomaCore.Warn("Framework", "SetOfflinePlayerJob")
        return false
    end
    
    grade = grade or 0
    
    if FrameworkType == 'ESX' then
        local affected = MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {
            jobName, grade, identifier
        })
        return affected and affected > 0
    elseif FrameworkType == 'QBCore' or FrameworkType == 'QBox' then
        -- Fetch all jobs from framework (QBCore: Shared.Jobs, QBox: exports.qbx_core:GetJobs())
        -- NOTE: grades are keyed as STRINGS (e.g. "0", "1") in both QBCore and QBox
        local allJobs = GetAllFrameworkJobs()
        local jobData = allJobs and allJobs[jobName]
        local gradeKey = tostring(grade)
        local gradeData = jobData and jobData.grades and jobData.grades[gradeKey]

        -- Build a complete job object (same structure QBCore/QBox stores in DB)
        -- This avoids JSON_SET leaving stale fields (payment, isboss, type, onduty)
        local currentRow = MySQL.single.await('SELECT job FROM players WHERE citizenid = ?', { identifier })
        local currentJob = currentRow and json.decode(currentRow.job) or {}

        local newJob = {
            name    = jobName,
            label   = jobData and jobData.label or 'Unknown',
            onduty  = currentJob.onduty or false,
            type    = jobData and jobData.type or 'none',
            grade   = {
                name    = gradeData and gradeData.name or ('Grade ' .. grade),
                level   = grade,
                payment = gradeData and gradeData.payment or 0,
                isboss  = gradeData and gradeData.isboss or false
            }
        }

        local affected = MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', {
            json.encode(newJob), identifier
        })
        return affected and affected > 0
    end
    
    return false
end)

-- ============================================================================
-- SOCIETY MONEY FUNCTIONS
-- ============================================================================
-- Unified interface for 19+ banking/society systems
-- Uses ZlomaCore.Cache.Society for auto-detection
-- ============================================================================

local SocietyType = nil

local function ResolveSocietyType()
    local detected = ZlomaCore.DetectSociety()
    if detected ~= SocietyType then
        SocietyType = detected
        ZlomaCore.Cache.Society = detected
        ZlomaCore.Debug(('Society detection refreshed: %s'):format(detected or 'none'))
    end

    return SocietyType
end

-- Initialize society detection
CreateThread(function()
    Wait(0)
    SocietyType = ResolveSocietyType()
    
    if SocietyType then
        ZlomaCore.Debug(string.format("Society/Banking system loaded: %s", SocietyType))
    else
        ZlomaCore.Debug("No society/banking system detected. Society functions will use fallbacks.")
    end
end)

-- EXPORT: GetSocietyMoney(jobName) - Get society/organization account balance
-- jobName: The job/org identifier (e.g., 'police', 'ambulance')
-- Returns: Money amount (number) or 0
exports('GetSocietyMoney', function(jobName)
    if type(jobName) ~= 'string' or jobName == '' or #jobName > 64 then return 0 end
    ResolveSocietyType()
    
    if not SocietyType then
        ZlomaCore.Debug("GetSocietyMoney: No society system detected")
        return 0
    end
    
    local success, result = pcall(function()
        if SocietyType == 'zloma_banking' then
            return exports['zloma_banking']:GetSocietyMoney(jobName)

        elseif SocietyType == 'esx_addonaccount' then
            local account = exports['esx_addonaccount']:GetSharedAccount(('society_%s'):format(jobName))
            if account and type(account.refresh)=='function' then account.refresh() end
            return account and account.money or 0
        
        elseif SocietyType == 'qb-banking' then
            local account = exports['qb-banking']:GetAccount(jobName)
            return account and account.account_balance or 0
        
        elseif SocietyType == 'Renewed-Banking' then
            return exports['Renewed-Banking']:getAccountMoney(jobName) or 0
        
        elseif SocietyType == 'okokBanking' then
            return exports['okokBanking']:GetAccount(jobName) or 0
        
        elseif SocietyType == 'fd_banking' then
            local account = exports['fd_banking']:GetAccount(jobName)
            return account and account.account_balance or 0
        
        elseif SocietyType == 'qs-banking' then
            return exports['qs-banking']:GetAccountBalance(jobName) or 0
        
        elseif SocietyType == 'p_banking' then
            return exports['p_banking']:getAccountMoney(jobName) or 0
        
        elseif SocietyType == 'crm-banking' then
            return exports['crm-banking']:getSocietyMoney(jobName) or 0
        
        elseif SocietyType == 'wasabi_banking' then
            return exports['wasabi_banking']:GetAccountBalance(jobName, 'society') or 0
        
        elseif SocietyType == 'RxBanking' then
            local data = exports['RxBanking']:GetSocietyAccount(jobName)
            if data then
                return type(data) == 'number' and data or (data.money or data.balance or 0)
            end
            return 0
        
        elseif SocietyType == 'kartik-banking' then
            return exports['kartik-banking']:GetAccountMoney(jobName) or 0
        
        elseif SocietyType == 'snipe-banking' then
            return exports['snipe-banking']:GetAccountBalance(jobName) or 0
        
        elseif SocietyType == 'tgg-banking' then
            return exports['tgg-banking']:GetSocietyAccountMoney(jobName) or 0
        
        elseif SocietyType == 'nfs-banking' then
            return exports['nfs-banking']:getAccountMoney(jobName) or 0
        
        elseif SocietyType == 'nfs-billing' then
            return exports['nfs-billing']:getSocietyBalance(jobName) or 0
        
        elseif SocietyType == 'sd-multijob' then
            return exports['sd-multijob']:getSocietyBalance(jobName) or 0
        
        elseif SocietyType == 'nass_bossmenu' then
            return exports['nass_bossmenu']:getAccount(jobName) or 0
        
        elseif SocietyType == 'vms_bossmenu' then
            local account = exports['vms_bossmenu']:getSociety(jobName)
            return account and account.balance or 0
        
        elseif SocietyType == 'xnr-bossmenu' then
            local account = exports['xnr-bossmenu']:getSociety(jobName)
            return account and account.balance or 0
        end
        
        return 0
    end)
    
    if success then
        return result or 0
    else
        ZlomaCore.Debug(string.format("GetSocietyMoney failed for %s: %s", jobName, tostring(result)))
        return 0
    end
end)

-- EXPORT: AddSocietyMoney(jobName, amount) - Add money to society account
-- jobName: The job/org identifier
-- amount: Amount to add
-- Returns: true if successful, false otherwise
local function AddSocietyMoney(jobName, amount)
    if type(jobName) ~= 'string' or jobName == '' or #jobName > 64
        or type(amount) ~= 'number' or amount ~= amount or amount <= 0 or amount == math.huge then
        return false
    end
    ResolveSocietyType()
    
    if not SocietyType then
        ZlomaCore.Debug("AddSocietyMoney: No society system detected")
        return false
    end
    
    local success, result = pcall(function()
        if SocietyType == 'zloma_banking' then
            return exports['zloma_banking']:AddSocietyMoney(jobName, amount)

        elseif SocietyType == 'esx_addonaccount' then
            local account = exports['esx_addonaccount']:GetSharedAccount(('society_%s'):format(jobName))
            if account then
                return account.addMoney(amount) ~= false
            end
            return false
        
        elseif SocietyType == 'qb-banking' then
            return exports['qb-banking']:AddMoney(jobName, amount)
        
        elseif SocietyType == 'Renewed-Banking' then
            return exports['Renewed-Banking']:addAccountMoney(jobName, amount)
        
        elseif SocietyType == 'okokBanking' then
            exports['okokBanking']:AddMoney(jobName, amount)
            return true
        
        elseif SocietyType == 'fd_banking' then
            return exports['fd_banking']:AddMoney(jobName, amount)
        
        elseif SocietyType == 'qs-banking' then
            return exports['qs-banking']:AddMoney(jobName, amount)
        
        elseif SocietyType == 'p_banking' then
            return exports['p_banking']:addAccountMoney(jobName, amount)
        
        elseif SocietyType == 'crm-banking' then
            return exports['crm-banking']:addSocietyMoney(jobName, amount)
        
        elseif SocietyType == 'wasabi_banking' then
            return exports['wasabi_banking']:AddMoney('society', jobName, amount)
        
        elseif SocietyType == 'RxBanking' then
            return exports['RxBanking']:AddSocietyMoney(jobName, amount)
        
        elseif SocietyType == 'kartik-banking' then
            return exports['kartik-banking']:AddAccountMoney(jobName, amount)
        
        elseif SocietyType == 'snipe-banking' then
            return exports['snipe-banking']:AddMoneyToAccount(jobName, amount)
        
        elseif SocietyType == 'tgg-banking' then
            return exports['tgg-banking']:AddSocietyMoney(jobName, amount)
        
        elseif SocietyType == 'nfs-banking' then
            return exports['nfs-banking']:addAccountMoney(jobName, amount)
        
        elseif SocietyType == 'nfs-billing' then
            exports['nfs-billing']:depositSociety(jobName, amount)
            return true
        
        elseif SocietyType == 'sd-multijob' then
            return exports['sd-multijob']:addSocietyDeposit(nil, jobName, amount, 'bank')
        
        elseif SocietyType == 'nass_bossmenu' then
            exports['nass_bossmenu']:addMoney(jobName, amount)
            return true
        
        elseif SocietyType == 'vms_bossmenu' then
            local res = nil
            exports['vms_bossmenu']:addMoney(jobName, amount, function(s) res = s end)
            local timeout = 50
            while res == nil and timeout > 0 do
                Wait(10)
                timeout = timeout - 1
            end
            return res or false
        
        elseif SocietyType == 'xnr-bossmenu' then
            return exports['xnr-bossmenu']:addMoney(jobName, amount)
        end
        
        return false
    end)
    
    if success and result then
        ZlomaCore.Debug(string.format("Added $%d to society %s via %s", amount, jobName, SocietyType))
        return true
    else
        ZlomaCore.Debug(string.format("AddSocietyMoney failed for %s: %s", jobName, tostring(result)))
        return false
    end
end

-- EXPORT: RemoveSocietyMoney(jobName, amount) - Remove money from society account
-- jobName: The job/org identifier
-- amount: Amount to remove
-- Returns: true if successful, false otherwise
local function RemoveSocietyMoney(jobName, amount)
    if type(jobName) ~= 'string' or jobName == '' or #jobName > 64
        or type(amount) ~= 'number' or amount ~= amount or amount <= 0 or amount == math.huge then
        return false
    end
    ResolveSocietyType()
    
    if not SocietyType then
        ZlomaCore.Debug("RemoveSocietyMoney: No society system detected")
        return false
    end
    
    local success, result = pcall(function()
        if SocietyType == 'zloma_banking' then
            return exports['zloma_banking']:RemoveSocietyMoney(jobName, amount)

        elseif SocietyType == 'esx_addonaccount' then
            local account = exports['esx_addonaccount']:GetSharedAccount(('society_%s'):format(jobName))
            if account then
                if type(account.refresh)=='function' then account.refresh() end
                if (tonumber(account.money) or 0)<amount then return false end
                return account.removeMoney(amount) ~= false
            end
            return false
        
        elseif SocietyType == 'qb-banking' then
            return exports['qb-banking']:RemoveMoney(jobName, amount)
        
        elseif SocietyType == 'Renewed-Banking' then
            return exports['Renewed-Banking']:removeAccountMoney(jobName, amount)
        
        elseif SocietyType == 'okokBanking' then
            exports['okokBanking']:RemoveMoney(jobName, amount)
            return true
        
        elseif SocietyType == 'fd_banking' then
            return exports['fd_banking']:RemoveMoney(jobName, amount)
        
        elseif SocietyType == 'qs-banking' then
            return exports['qs-banking']:RemoveMoney(jobName, amount)
        
        elseif SocietyType == 'p_banking' then
            return exports['p_banking']:removeAccountMoney(jobName, amount)
        
        elseif SocietyType == 'crm-banking' then
            return exports['crm-banking']:removeSocietyMoney(jobName, amount)
        
        elseif SocietyType == 'wasabi_banking' then
            return exports['wasabi_banking']:RemoveMoney('society', jobName, amount)
        
        elseif SocietyType == 'RxBanking' then
            return exports['RxBanking']:RemoveSocietyMoney(jobName, amount)
        
        elseif SocietyType == 'kartik-banking' then
            return exports['kartik-banking']:RemoveAccountMoney(jobName, amount)
        
        elseif SocietyType == 'snipe-banking' then
            return exports['snipe-banking']:RemoveMoneyFromAccount(jobName, amount)
        
        elseif SocietyType == 'tgg-banking' then
            return exports['tgg-banking']:RemoveSocietyMoney(jobName, amount)
        
        elseif SocietyType == 'nfs-banking' then
            return exports['nfs-banking']:removeAccountMoney(jobName, amount)
        
        elseif SocietyType == 'nfs-billing' then
            exports['nfs-billing']:withdrawSociety(jobName, amount)
            return true
        
        elseif SocietyType == 'sd-multijob' then
            return exports['sd-multijob']:withdrawSocietyFunds(nil, jobName, amount, 'bank')
        
        elseif SocietyType == 'nass_bossmenu' then
            return exports['nass_bossmenu']:removeMoney(jobName, amount)
        
        elseif SocietyType == 'vms_bossmenu' then
            local res = nil
            exports['vms_bossmenu']:removeMoney(jobName, amount, function(s) res = s end)
            local timeout = 50
            while res == nil and timeout > 0 do
                Wait(10)
                timeout = timeout - 1
            end
            return res or false
        
        elseif SocietyType == 'xnr-bossmenu' then
            return exports['xnr-bossmenu']:removeMoney(jobName, amount)
        end
        
        return false
    end)
    
    if success and result then
        ZlomaCore.Debug(string.format("Removed $%d from society %s via %s", amount, jobName, SocietyType))
        return true
    else
        ZlomaCore.Debug(string.format("RemoveSocietyMoney failed for %s: %s", jobName, tostring(result)))
        return false
    end
end

local societyMutationLocks={}
local function societyMutation(fn,job,amount)
    if type(job)~='string' or societyMutationLocks[job] then return false end
    societyMutationLocks[job]=true
    local ok,result=xpcall(function() return fn(job,amount) end,debug.traceback)
    societyMutationLocks[job]=nil
    if not ok then print('[zloma_core] [ERROR] Society mutation failed: '..tostring(result)); return false end
    return result
end
exports('AddSocietyMoney',function(job,amount) return societyMutation(AddSocietyMoney,job,amount) end)
exports('RemoveSocietyMoney',function(job,amount) return societyMutation(RemoveSocietyMoney,job,amount) end)

-- EXPORT: GetSocietySystem() - Get detected society/banking system name
-- Returns: string or nil
exports('GetSocietySystem', function()
    return ResolveSocietyType()
end)
