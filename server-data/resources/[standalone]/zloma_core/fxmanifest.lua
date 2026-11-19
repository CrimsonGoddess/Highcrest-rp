fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Zloma'
description 'ZLOMA CORE - Universal framework wrapper for ESX/QBCore/QBox'
version '1.1.7'

dependencies {
    'ox_lib',
    'oxmysql'
}

shared_scripts {
    '@ox_lib/init.lua',

    'shared/config.lua',
    'shared/provider_catalog.lua',
    'shared/detection.lua',
    'shared/adapter_registry.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/version.lua',
    'server/vehicle_catalogue.lua',
    'server/vehicle_policy.lua',
    'server/vehicle_authority.lua',
    -- Dispatch loads shared helpers, individual providers, then its public API.
    'server/dispatch/shared.lua',
    'server/dispatch/ps-dispatch.lua',
    'server/dispatch/cd_dispatch.lua',
    'server/dispatch/qs-dispatch.lua',
    'server/dispatch/tk_dispatch.lua',
    'server/dispatch/rcore_dispatch.lua',
    'server/dispatch/lb-tablet.lua',
    'server/dispatch/kartik-mdt.lua',
    'server/dispatch/piotreq_gpt.lua',
    'server/dispatch/origen_police.lua',
    'server/dispatch/init.lua',
    'server/framework/init.lua',
    'server/durable_money.lua',
    'server/inventory/init.lua',
    'server/billing/registry.lua',
    'server/billing/providers/*.lua',
    'server/billing/init.lua',
    'server/callbacks/init.lua',
    'server/fuel/registry.lua',
    'server/fuel/providers/*.lua',
    'server/fuel/init.lua'
}

client_scripts {
    'client/core/init.lua',      -- Initialize detection FIRST
    'client/appearance/registry.lua',
    'client/appearance/providers/*.lua',
    'client/appearance/init.lua',
    'client/inventory/init.lua', -- Added generic client inventory wrapper
    'client/notifications/registry.lua',
    'client/notifications/providers/*.lua',
    'client/notifications/init.lua',
    'client/keys/init.lua',
    'client/target/init.lua',
    'client/fuel/registry.lua',
    'client/fuel/providers/*.lua',
    'client/fuel/init.lua', -- Fuel system wrapper
    'client/callbacks/init.lua'
}

-- ════════════════════════════════════════════════════════════════════════════════
-- CLIENT EXPORTS (declared for anticheat compatibility)
-- ════════════════════════════════════════════════════════════════════════════════
exports {
    -- client/core/init.lua and client/appearance/init.lua
    'IsAdmin',
    'GetPlayerJob',
    'GetPlayerGang',
    'GetAppearanceSystem',
    'GetCurrentSkin',
    'GetPlayerAppearance',
    'GetPlayerClothing',
    'SetPlayerSkin',
    'SetPlayerAppearance',
    'SetPlayerClothing',
    'OpenWardrobe',
    -- client/inventory/init.lua
    'GetInventory',
    'HasItem',
    -- client/notifications/init.lua
    'Notify',
    'NotifyAdvanced',
    'ShowNotification',
    'ShowTextUI',
    'HideTextUI',
    -- client/keys/init.lua
    'GiveKeys',
    'RemoveKeys',
    'HasKeys',
    -- client/target/init.lua
    'GetTargetSystem',
    'AddEntity',
    'AddBoxZone',
    'AddSphereZone',
    'RemoveEntity',
    'AddGlobalVehicle',
    'RemoveGlobalVehicle',
    'RemoveZone',
    'SetTargetingEnabled',
    -- client/callbacks/init.lua
    'RegisterClientCallback',
    'RemoveClientCallback',
    'TriggerServerCallback',
    -- client/fuel/init.lua
    'GetVehicleFuel',
    'SetVehicleFuel',
    'GetFuelSystem',
    'GetFuel',
    'SetFuel'
}

-- ════════════════════════════════════════════════════════════════════════════════
-- SERVER EXPORTS (declared for anticheat compatibility)
-- ════════════════════════════════════════════════════════════════════════════════
server_exports {
    -- server/framework/init.lua
    'GetFrameworkType',
    'GetPlayer',
    'GetPlayerMoney',
    'RemoveMoney',
    'AddMoney',
    'GetPlayerJob',
    'GetPlayerGang',
    'GetIdentifier',
    'GetCharacterName',
    'GetPlayerFromIdentifier',
    'IsAdmin',
    'Notify',
    'GiveVehicleKeys',
    'RemoveVehicleKeys',
    'GetSocietyMoney',
    'AddSocietyMoney',
    'RemoveSocietyMoney',
    'GetSocietySystem',
    'SetPlayerJob',
    'GetAllJobs',
    'GetAllGangs',
    'GetJobGrades',
    'GetGangGrades',
    'GetOnlinePlayers',
    'GetPlayerGroup',
    'CreateUseableItem',
    'GetOfflinePlayerJob',
    'SetOfflinePlayerJob',
    'GetDispatchSystem',
    'SendDispatchAlert',
    -- server/fuel/init.lua
    'SetVehicleFuel',
    'GetVehicleFuel',
    'GetFuelSystem',
    'GetFuel',
    'SetFuel',
    -- server/billing/init.lua
    'SendBill',
    'GetBills',
    -- server/inventory/init.lua
    'HasItem',
    'GetItemCount',
    'AddItem',
    'RemoveItem',
    'GetInventory',
    'GetItemMetadata',
    'GetInventorySystem',
    'SupportsStashes',
    'CanReadStashItems',
    'RegisterStash',
    'OpenStash',
    'GetStashItems',
    -- server/callbacks/init.lua
    'RegisterCallback',
    'RemoveCallback',
    'TriggerClientCallback'
}

-- Provides unified interface for all zloma scripts
-- Automatically detects and wraps: frameworks, inventories, billing, notifications, keys, targets
-- Version-agnostic and plug-and-play design minimizes support needs
