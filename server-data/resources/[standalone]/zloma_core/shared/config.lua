-- ZLOMA CORE - Shared Configuration & Auto-Detection
-- Auto-detects all systems at runtime - no manual configuration needed
-- Customer-friendly: Works out of the box with any combination of systems

ZlomaCore = {}
ZlomaCore.Config = {}

-- Detected systems (cached at runtime)
ZlomaCore.Cache = {
    Framework = nil,
    Inventory = nil,
    Billing = nil,
    Notification = nil,
    Appearance = nil,
    Keys = nil,
    Dispatch = nil,
    Target = nil,
    Fuel = nil,
    Society = nil  -- Society/Banking system cache
}

-- Debug mode (set to true for detailed console logs)
ZlomaCore.Config.Debug = false

-- ======================================================
-- TIMEOUT CONFIGURATION
-- Centralized timeout values for easy adjustment
-- ======================================================
ZlomaCore.Config.Timeouts = {
    CallbackDefault = 5000,   -- Default callback timeout (ms)
    InitWait = 500,           -- Wait time for system initialization (ms)
    DetectionWait = 200,      -- Wait time for detection loops (ms)
    PollingInterval = 50      -- Polling interval for callbacks (ms)
}

ZlomaCore.Config.DependencyRecovery = {
    -- Deprecated compatibility block. zloma_core no longer starts/restarts
    -- unrelated resources; use server.cfg dependency ordering instead.
    Enabled = false,
    RetryDelay = 1000,
    RetryCount = 5,
    RestartResources = {
        'zloma_keys'
    }
}

-- ======================================================
-- SECURITY / NETWORK INPUT LIMITS
-- ======================================================
ZlomaCore.Config.Security = {
    CallbackRateLimitMs = 100,
    EnableLegacyClientBillingEvent = false,
    BillingMaxAmount = 1000000,
    BillingMaxDistance = 10.0,
    BillingEventCooldownMs = 1000
}

-- ======================================================
-- MANUAL CONFIGURATION (Advanced Users)
-- Set to 'auto' for automatic detection, or specify exact system name
-- ======================================================
ZlomaCore.Config.Manual = {
    Framework = 'auto',    -- 'auto', 'ESX', 'QBCore', 'QBox'
    Inventory = 'auto',    -- 'auto', 'ox_inventory', 'qb-inventory', 'qs-inventory', 'ps-inventory', 'codem-inventory', 'tgiann-inventory', 'origen-inventory', 'core_inventory', 'ak47_inventory', 'jaksam_inventory', 'jpr-inventory', 'S-Inventory'
    Billing = 'auto',      -- 'auto', 'zloma_banking', 'okokBilling', 'okok_billing', 'esx_billing', 'qb-billing'
    Notification = 'auto', -- 'auto', 'ox_lib', 'mythic', 't-notify', 'okok', 'esx_notify', 'QBCore', 'ESX', 'wasabi_notify', 'fl-notify', 'brutal_notify', 'is_ui', 'lation_ui', 'g-notifications', 'vms_notifyv2', 'wasabi_uikit'
    Appearance = 'auto',   -- 'auto', 'illenium-appearance', 'qs-appearance', 'crm-appearance', 'qb-clothing', 'rcore_clothing', 'tgiann-clothing', 'p_appearance', 'esx_skin'
    Keys = 'auto',         -- 'auto', 'zloma_keys', 'qb-vehiclekeys', 'wasabi_carlock', 'cd_garage', 'jaksam', 'Renewed-Vehiclekeys', 'MrNewbVehicleKeys', 'qbx_vehiclekeys', 'qs-vehiclekeys', 'tgiann-hotwire', 'ak47_vehiclekeys', 'ak47_qb_vehiclekeys', 'mk_vehiclekeys', 'filo_vehiclekey', 'is_carkeys', 'LifeSaver_KeySystem', 'brutal_carkeys', 'ic3d_vehiclekeys', 'mm_carkeys', 'rd_vehiclekeys', 'p_carkeys'
    Dispatch = 'auto',     -- 'auto', 'ps-dispatch', 'piotreq_gpt', 'cd_dispatch', 'cd_dispatch3d', 'qs-dispatch', 'tk_dispatch', 'rcore_dispatch', 'lb-tablet', 'kartik-mdt', 'origen_police', 'none'
    Target = 'auto',       -- 'auto', 'ox_target', 'qb-target', 'qtarget'
    Fuel = 'auto',         -- 'auto', 'lc_fuel', 'qb-fuel', 'LegacyFuel', 'ox_fuel', 'lj-fuel', 'ps-fuel', 'cdn-fuel', 'Renewed-Fuel', 'okokGasStation', 'qs-fuelstations', 'rcore_fuel', 'x-fuel', 'stg-fuel', 'ti_fuel', 'esx-sna-fuel', 'ND_Fuel', 'myFuel'
    -- Auto: ESX uses esx_addonaccount; QBCore/QBox use the normal provider
    -- order (zloma_banking is first). Set a provider explicitly to override.
    Society = 'auto'       -- 'auto', 'zloma_banking', 'esx_addonaccount', 'qb-banking', 'okokBanking', 'wasabi_banking', 'qs-banking', 'Renewed-Banking', 'RxBanking', 'nfs-billing', 'crm-banking', 'kartik-banking', 'snipe-banking', 'tgg-banking', 'fd_banking', 'vms_bossmenu', 'xnr-bossmenu', 'nass_bossmenu', 'sd-multijob', 'p_banking'
}

-- ps-dispatch v2 validates codeName against its Config.Dispatch entries. Add this
-- key there (or change this value to an existing entry) when using ps-dispatch v2.
-- The legacy ps-dispatch v1 (dispatch:server:notify) is detected automatically
-- and needs no entry.
ZlomaCore.Config.Dispatch = {
    PsCodeName = 'customAlert'
}

-- Framework resources are occasionally started in the same server tick as
-- zloma_core. Retry before reporting a real configuration error instead of
-- caching a false negative during resource startup.
ZlomaCore.Config.FrameworkStartup = {
    TimeoutMs = 15000,
    RetryMs = 250,
}

-- ======================================================
-- PROVIDER DETECTION
-- Provider order and resource aliases are maintained in shared/provider_catalog.lua.
-- Detection functions are defined in shared/detection.lua after this configuration.
-- ======================================================

-- Initialize detection on resource start
function ZlomaCore.Initialize()
    ZlomaCore.Cache.Framework = ZlomaCore.DetectFramework()
    ZlomaCore.Cache.Inventory = ZlomaCore.DetectInventory()
    ZlomaCore.Cache.Billing = ZlomaCore.DetectBilling()
    ZlomaCore.Cache.Notification = ZlomaCore.DetectNotification()
    ZlomaCore.Cache.Appearance = ZlomaCore.DetectAppearance()
    ZlomaCore.Cache.Keys = ZlomaCore.DetectKeys()
    ZlomaCore.Cache.Dispatch = ZlomaCore.DetectDispatch()
    ZlomaCore.Cache.Target = ZlomaCore.DetectTarget()
    ZlomaCore.Cache.Fuel = ZlomaCore.DetectFuel()
    ZlomaCore.Cache.Society = ZlomaCore.DetectSociety()

    -- Console output
    local _ver = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '0.0.0'
    print("^2========================================^0")
    print("^2ZLOMA CORE v" .. _ver .. " - System Detection^0")
    print("^2========================================^0")
    local frameworkStatus = ZlomaCore.Cache.Framework or "^3PENDING (startup retry)^0"
    print(string.format("^3Framework:^0 %s", frameworkStatus))
    print(string.format("^3Inventory:^0 %s", ZlomaCore.Cache.Inventory or "^1NONE DETECTED^0"))
    print(string.format("^3Billing:^0 %s", ZlomaCore.Cache.Billing or "^1NONE DETECTED^0"))
    print(string.format("^3Notification:^0 %s", ZlomaCore.Cache.Notification or "^1NONE DETECTED^0"))
    print(string.format("^3Appearance:^0 %s", ZlomaCore.Cache.Appearance or "^1NONE DETECTED^0"))
    print(string.format("^3Keys:^0 %s", ZlomaCore.Cache.Keys or "^1NONE DETECTED^0"))
    print(string.format("^3Dispatch:^0 %s", ZlomaCore.Cache.Dispatch or "^1NONE DETECTED^0"))
    print(string.format("^3Target:^0 %s", ZlomaCore.Cache.Target or "^1NONE DETECTED^0"))
    print(string.format("^3Fuel:^0 %s", ZlomaCore.Cache.Fuel or "^1NONE DETECTED^0"))
    print(string.format("^3Society:^0 %s", ZlomaCore.Cache.Society or "^1NONE DETECTED^0"))
    print("^2========================================^0")
end

-- Utility: Safe print with debug check
function ZlomaCore.Debug(message)
    if ZlomaCore.Config.Debug then
        print("^5[ZLOMA DEBUG]^0 " .. message)
    end
end

-- Utility: Warning message for missing systems
function ZlomaCore.Warn(system, action)
    print(string.format("^3[ZLOMA WARNING]^0 %s not detected - %s action skipped", system, action))
end
