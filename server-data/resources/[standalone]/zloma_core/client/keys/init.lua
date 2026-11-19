-- ZLOMA CORE - Client Keys Wrapper
-- Unified interface for 20+ vehicle key systems
-- Customer-friendly: Version-agnostic, multi-system support with smart fallbacks

local KeysType = nil

local function RefreshKeysDetection(reason)
    ZlomaCore.Cache.Keys = ZlomaCore.DetectKeys()
    KeysType = ZlomaCore.Cache.Keys

    if KeysType then
        ZlomaCore.Debug(string.format('Keys system loaded%s: %s', reason and (' (' .. reason .. ')') or '', KeysType))
    else
        print('^3[ZLOMA WARNING]^0 No keys system detected. Key functions will not work.')
    end

    return KeysType
end

local function EnsureKeysType(action)
    if KeysType and GetResourceState(KeysType) == 'started' then
        return true
    end

    RefreshKeysDetection(action)
    return KeysType ~= nil
end

-- Initialize keys detection
CreateThread(function()
    Wait(ZlomaCore.Config.Timeouts.DetectionWait or 200) -- Wait for init.lua to finish detection
    RefreshKeysDetection('initial load')
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    CreateThread(function()
        -- Resource-start events can fire before exports are ready. Refresh on
        -- the next tick so a just-started key provider is detectable.
        Wait(0)
        RefreshKeysDetection('resource start: ' .. resourceName)
    end)
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    RefreshKeysDetection('resource stop: ' .. resourceName)
end)

-- ============================================================================
-- ADD NEW KEYS SUPPORT HERE
-- ============================================================================
-- To add support for a new keys system:
-- 1. Add detection in shared/config.lua -> ZlomaCore.DetectKeys()
-- 2. Add the keys name to ZlomaCore.Config.Manual.Keys options
-- 3. Add elseif block in GiveKeys(), RemoveKeys(), HasKeys() below
--
-- Template:
-- elseif KeysType == 'your-keys' then
--     exports['your-keys']:GiveKey(plate)
--     success = true
-- ============================================================================

-- EXPORT: GiveKeys(plate, vehicleEntity) - Give vehicle keys to player
-- plate: Vehicle plate number
-- vehicleEntity: (Optional) Vehicle entity to get model/label from
-- Returns: true if successful, false otherwise
exports('GiveKeys', function(plate, vehicleEntity)
    if not plate then
        print("^1[ZLOMA ERROR]^0 GiveKeys - Plate is required")
        return false
    end

    if not EnsureKeysType('GiveKeys') then
        ZlomaCore.Warn("Keys", "GiveKeys")
        return false
    end

    local success = false

    if KeysType == 'zloma_keys' then
        local vehicle = vehicleEntity
        
        -- If no vehicle provided, try to find it
        if not vehicle or not DoesEntityExist(vehicle) then
            vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            
            if vehicle == 0 then
                -- Search for vehicle by plate in nearby area
                local coords = GetEntityCoords(PlayerPedId())
                local nearbyVehicles = GetGamePool('CVehicle')
                local normalizedPlate = plate:gsub('^%s*(.-)%s*$', '%1'):upper()
                
                for _, veh in ipairs(nearbyVehicles) do
                    if DoesEntityExist(veh) then
                        local vehPlate = GetVehicleNumberPlateText(veh)
                        if vehPlate then
                            vehPlate = vehPlate:gsub('^%s*(.-)%s*$', '%1'):upper()
                            if vehPlate == normalizedPlate then
                                vehicle = veh
                                break
                            end
                        end
                    end
                end
            end
        end
        
        local model = 0
        local label = plate -- Fallback to plate if no vehicle found
        
        if vehicle and DoesEntityExist(vehicle) then
            model = GetEntityModel(vehicle)
            local displayName = GetDisplayNameFromVehicleModel(model)
            if displayName and displayName ~= '' and displayName ~= 'CARNOTFOUND' then
                label = GetLabelText(displayName)
                if not label or label == 'NULL' or label == '' then
                    label = displayName
                end
            end
        end
        
        exports['zloma_keys']:GiveKey(vehicle, plate, model, label)
        success = true
        ZlomaCore.Debug(string.format("zloma_keys: Gave keys for plate %s (label: %s)", plate, label))
    
    elseif KeysType == 'Renewed-Vehiclekeys' then
        exports['Renewed-Vehiclekeys']:addKey(plate)
        success = true
        ZlomaCore.Debug(string.format("Renewed-Vehiclekeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'MrNewbVehicleKeys' then
        exports.MrNewbVehicleKeys:GiveKeysByPlate(plate)
        success = true
        ZlomaCore.Debug(string.format("MrNewbVehicleKeys: Gave keys for plate %s", plate))
        
    elseif KeysType == 'qb-vehiclekeys' then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
        success = true
        ZlomaCore.Debug(string.format("qb-vehiclekeys: Gave keys for plate %s", plate))
        
    elseif KeysType == 'wasabi_carlock' then
        exports.wasabi_carlock:GiveKey(plate)
        success = true
        ZlomaCore.Debug(string.format("wasabi_carlock: Gave keys for plate %s", plate))
        
    elseif KeysType == 'cd_garage' then
        TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:GetPlate(plate))
        success = true
        ZlomaCore.Debug(string.format("cd_garage: Gave keys for plate %s", plate))
        
    elseif KeysType == 'jaksam' then
        TriggerServerEvent('vehicles_keys:selfGiveVehicleKeys', plate)
        success = true
        ZlomaCore.Debug(string.format("jaksam: Gave keys for plate %s", plate))
    
    elseif KeysType == 'qbx_vehiclekeys' then
        local vehicle = vehicleEntity
        if vehicle and DoesEntityExist(vehicle) and NetworkGetEntityIsNetworked(vehicle) then
            TriggerServerEvent('qbx_vehiclekeys:server:hotwiredVehicle', NetworkGetNetworkIdFromEntity(vehicle))
        end
        success = true
        ZlomaCore.Debug(string.format("qbx_vehiclekeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'qs-vehiclekeys' then
        local vehicle = vehicleEntity
        local model = ''
        if vehicle and DoesEntityExist(vehicle) then
            model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        end
        exports['qs-vehiclekeys']:GiveKeys(plate, model, true)
        success = true
        ZlomaCore.Debug(string.format("qs-vehiclekeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'tgiann-hotwire' then
        exports['tgiann-hotwire']:GiveKeyPlate(plate, true)
        success = true
        ZlomaCore.Debug(string.format("tgiann-hotwire: Gave keys for plate %s", plate))
    
    elseif KeysType == 'ak47_vehiclekeys' then
        local isLocal = vehicleEntity and not NetworkGetEntityIsNetworked(vehicleEntity) or false
        exports['ak47_vehiclekeys']:GiveKey(plate, isLocal)
        success = true
        ZlomaCore.Debug(string.format("ak47_vehiclekeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'ak47_qb_vehiclekeys' then
        local isLocal = vehicleEntity and not NetworkGetEntityIsNetworked(vehicleEntity) or false
        exports['ak47_qb_vehiclekeys']:GiveKey(plate, isLocal)
        success = true
        ZlomaCore.Debug(string.format("ak47_qb_vehiclekeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'mk_vehiclekeys' then
        local vehicle = vehicleEntity
        if vehicle and DoesEntityExist(vehicle) then
            if NetworkGetEntityIsNetworked(vehicle) then
                exports['mk_vehiclekeys']:AddKey(vehicle)
            else
                -- Local-only preview entities are not authoritative gameplay
                -- vehicles and must not replicate client-authored key state.
                Entity(vehicle).state:set('Keys', {LocalPlayer.state.mk_identifier}, false)
            end
        end
        success = true
        ZlomaCore.Debug(string.format("mk_vehiclekeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'filo_vehiclekey' then
        exports.filo_vehiclekey:GiveKeys(plate)
        success = true
        ZlomaCore.Debug(string.format("filo_vehiclekey: Gave keys for plate %s", plate))
    
    elseif KeysType == 'is_carkeys' then
        exports['is_vehiclekeys']:GiveKey(plate)
        success = true
        ZlomaCore.Debug(string.format("is_carkeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'LifeSaver_KeySystem' then
        local vehicle = vehicleEntity
        local model = plate
        if vehicle and DoesEntityExist(vehicle) then
            model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        end
        exports['LifeSaver_KeySystem']:AddCarkey(plate, model)
        success = true
        ZlomaCore.Debug(string.format("LifeSaver_KeySystem: Gave keys for plate %s", plate))
    
    elseif KeysType == 'brutal_carkeys' then
        exports.brutal_keys:addVehicleKey(plate, 'car')
        success = true
        ZlomaCore.Debug(string.format("brutal_carkeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'ic3d_vehiclekeys' then
        exports.ic3d_vehiclekeys:ClientInventoryKeys('add', plate)
        success = true
        ZlomaCore.Debug(string.format("ic3d_vehiclekeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'mm_carkeys' then
        exports.mm_carkeys:GiveKeyItem(plate, vehicleEntity)
        success = true
        ZlomaCore.Debug(string.format("mm_carkeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'rd_vehiclekeys' then
        TriggerServerEvent('rd_vehiclekeys:server:GiveKeys', plate)
        success = true
        ZlomaCore.Debug(string.format("rd_vehiclekeys: Gave keys for plate %s", plate))
    
    elseif KeysType == 'p_carkeys' then
        TriggerServerEvent('p_carkeys:CreateKeys', plate)
        success = true
        ZlomaCore.Debug(string.format("p_carkeys: Gave keys for plate %s", plate))
    end

    return success
end)

-- EXPORT: RemoveKeys(plate) - Remove vehicle keys from player
-- plate: Vehicle plate number
-- Returns: true if successful, false otherwise
exports('RemoveKeys', function(plate)
    if not plate then
        print("^1[ZLOMA ERROR]^0 RemoveKeys - Plate is required")
        return false
    end

    if not EnsureKeysType('RemoveKeys') then
        ZlomaCore.Warn("Keys", "RemoveKeys")
        return false
    end

    local success = false

    if KeysType == 'zloma_keys' then
        exports['zloma_keys']:RemoveKey(plate)
        success = true
        ZlomaCore.Debug(string.format("zloma_keys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'Renewed-Vehiclekeys' then
        exports['Renewed-Vehiclekeys']:removeKey(plate)
        success = true
        ZlomaCore.Debug(string.format("Renewed-Vehiclekeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'MrNewbVehicleKeys' then
        exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate)
        success = true
        ZlomaCore.Debug(string.format("MrNewbVehicleKeys: Removed keys for plate %s", plate))
        
    elseif KeysType == 'qb-vehiclekeys' then
        -- qb-vehiclekeys does not have a remove keys function
        success = true
        ZlomaCore.Debug(string.format("qb-vehiclekeys: RemoveKeys not natively supported for plate %s", plate))
        
    elseif KeysType == 'wasabi_carlock' then
        exports.wasabi_carlock:RemoveKey(plate)
        success = true
        ZlomaCore.Debug(string.format("wasabi_carlock: Removed keys for plate %s", plate))
        
    elseif KeysType == 'cd_garage' then
        TriggerEvent('cd_garage:RemoveKeys', exports['cd_garage']:GetPlate(plate))
        success = true
        ZlomaCore.Debug(string.format("cd_garage: Removed keys for plate %s", plate))
        
    elseif KeysType == 'jaksam' then
        -- Jaksam doesn't have native remove function, workaround via server
        TriggerServerEvent('vehicles_keys:selfRemoveKeys', plate)
        success = true
        ZlomaCore.Debug(string.format("jaksam: Attempted to remove keys for plate %s", plate))
    
    elseif KeysType == 'qbx_vehiclekeys' then
        -- qbx_vehiclekeys does not have a remove keys function
        success = true
        ZlomaCore.Debug(string.format("qbx_vehiclekeys: RemoveKeys not supported for plate %s", plate))
    
    elseif KeysType == 'qs-vehiclekeys' then
        local vehicle = nil
        local nearbyVehicles = GetGamePool('CVehicle')
        local normalizedPlate = plate:gsub('^%s*(.-)%s*$', '%1'):upper()
        for _, veh in ipairs(nearbyVehicles) do
            if DoesEntityExist(veh) then
                local vehPlate = GetVehicleNumberPlateText(veh)
                if vehPlate and vehPlate:gsub('^%s*(.-)%s*$', '%1'):upper() == normalizedPlate then
                    vehicle = veh
                    break
                end
            end
        end
        local model = vehicle and GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)) or ''
        exports['qs-vehiclekeys']:RemoveKeys(plate, model)
        success = true
        ZlomaCore.Debug(string.format("qs-vehiclekeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'tgiann-hotwire' then
        -- tgiann-hotwire does not have a remove keys function
        success = true
        ZlomaCore.Debug(string.format("tgiann-hotwire: RemoveKeys not supported for plate %s", plate))
    
    elseif KeysType == 'ak47_vehiclekeys' then
        exports['ak47_vehiclekeys']:RemoveKey(plate, false)
        success = true
        ZlomaCore.Debug(string.format("ak47_vehiclekeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'ak47_qb_vehiclekeys' then
        exports['ak47_qb_vehiclekeys']:RemoveKey(plate, false)
        success = true
        ZlomaCore.Debug(string.format("ak47_qb_vehiclekeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'mk_vehiclekeys' then
        -- mk_vehiclekeys needs the vehicle entity for remove
        local vehicle = nil
        local nearbyVehicles = GetGamePool('CVehicle')
        local normalizedPlate = plate:gsub('^%s*(.-)%s*$', '%1'):upper()
        for _, veh in ipairs(nearbyVehicles) do
            if DoesEntityExist(veh) then
                local vehPlate = GetVehicleNumberPlateText(veh)
                if vehPlate and vehPlate:gsub('^%s*(.-)%s*$', '%1'):upper() == normalizedPlate then
                    vehicle = veh
                    break
                end
            end
        end
        if vehicle then
            if NetworkGetEntityIsNetworked(vehicle) then
                exports['mk_vehiclekeys']:RemoveKey(vehicle)
            else
                Entity(vehicle).state:set('Keys', {}, false)
            end
        end
        success = true
        ZlomaCore.Debug(string.format("mk_vehiclekeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'filo_vehiclekey' then
        exports.filo_vehiclekey:RemoveKeys(plate)
        success = true
        ZlomaCore.Debug(string.format("filo_vehiclekey: Removed keys for plate %s", plate))
    
    elseif KeysType == 'is_carkeys' then
        exports['is_vehiclekeys']:RemoveKey(plate)
        success = true
        ZlomaCore.Debug(string.format("is_carkeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'LifeSaver_KeySystem' then
        local vehicle = nil
        local nearbyVehicles = GetGamePool('CVehicle')
        local normalizedPlate = plate:gsub('^%s*(.-)%s*$', '%1'):upper()
        for _, veh in ipairs(nearbyVehicles) do
            if DoesEntityExist(veh) then
                local vehPlate = GetVehicleNumberPlateText(veh)
                if vehPlate and vehPlate:gsub('^%s*(.-)%s*$', '%1'):upper() == normalizedPlate then
                    vehicle = veh
                    break
                end
            end
        end
        local model = vehicle and GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)) or plate
        exports['LifeSaver_KeySystem']:RemoveCarkey(plate, model)
        success = true
        ZlomaCore.Debug(string.format("LifeSaver_KeySystem: Removed keys for plate %s", plate))
    
    elseif KeysType == 'brutal_carkeys' then
        exports.brutal_keys:removeKey(plate, true)
        success = true
        ZlomaCore.Debug(string.format("brutal_carkeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'ic3d_vehiclekeys' then
        exports.ic3d_vehiclekeys:ClientInventoryKeys('remove', plate)
        success = true
        ZlomaCore.Debug(string.format("ic3d_vehiclekeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'mm_carkeys' then
        exports.mm_carkeys:RemoveKeyItem(plate)
        success = true
        ZlomaCore.Debug(string.format("mm_carkeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'rd_vehiclekeys' then
        TriggerServerEvent('rd_vehiclekeys:server:RemoveKeys', plate)
        success = true
        ZlomaCore.Debug(string.format("rd_vehiclekeys: Removed keys for plate %s", plate))
    
    elseif KeysType == 'p_carkeys' then
        TriggerServerEvent('p_carkeys:RemoveKeys', plate)
        success = true
        ZlomaCore.Debug(string.format("p_carkeys: Removed keys for plate %s", plate))
    end

    return success
end)

-- EXPORT: HasKeys(plate) - Check if player has keys for vehicle
-- plate: Vehicle plate number
-- Returns: true/false or nil if system doesn't support checking
exports('HasKeys', function(plate)
    if not plate then
        print("^1[ZLOMA ERROR]^0 HasKeys - Plate is required")
        return false
    end

    if not EnsureKeysType('HasKeys') then
        ZlomaCore.Warn("Keys", "HasKeys")
        return false
    end

    if KeysType == 'zloma_keys' then
        return exports['zloma_keys']:HasKey(plate)
    
    elseif KeysType == 'Renewed-Vehiclekeys' then
        return exports['Renewed-Vehiclekeys']:hasKey(plate)
    
    elseif KeysType == 'MrNewbVehicleKeys' then
        return exports.MrNewbVehicleKeys:HasKeysByPlate(plate)
        
    elseif KeysType == 'qb-vehiclekeys' then
        -- QB stores keys in player metadata, requires callback
        local hasKeys = lib.callback.await('zloma_core:hasVehicleKeys', false, plate)
        return hasKeys or false
        
    elseif KeysType == 'wasabi_carlock' then
        return exports.wasabi_carlock:HasKey(plate)
        
    elseif KeysType == 'cd_garage' then
        -- CD Garage has HasKeys export
        return exports['cd_garage']:HasKeys(plate)
        
    elseif KeysType == 'jaksam' then
        -- Jaksam requires server callback
        ZlomaCore.Debug("jaksam HasKeys requires server callback (not implemented)")
        return nil
    
    elseif KeysType == 'filo_vehiclekey' then
        return exports.filo_vehiclekey:HasKey(plate)
    
    elseif KeysType == 'is_carkeys' then
        return exports['is_vehiclekeys']:HasKey(plate)
    
    elseif KeysType == 'ak47_vehiclekeys' then
        return exports['ak47_vehiclekeys']:HasKey(plate)
    
    elseif KeysType == 'ak47_qb_vehiclekeys' then
        return exports['ak47_qb_vehiclekeys']:HasKey(plate)
    
    elseif KeysType == 'brutal_carkeys' then
        return exports.brutal_keys:hasKey(plate)
    end

    -- Many key systems don't have a HasKeys export - return nil to indicate unknown
    return nil
end)

-- Client events for server-triggered key actions
RegisterNetEvent('zloma_core:client:giveKeys', function(plate)
    if source ~= 65535 or type(plate) ~= 'string' or plate == '' or #plate > 16 then return end
    exports['zloma_core']:GiveKeys(plate)
end)

RegisterNetEvent('zloma_core:client:removeKeys', function(plate)
    if source ~= 65535 or type(plate) ~= 'string' or plate == '' or #plate > 16 then return end
    exports['zloma_core']:RemoveKeys(plate)
end)
