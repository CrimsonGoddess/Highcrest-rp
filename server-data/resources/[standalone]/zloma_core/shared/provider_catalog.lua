-- Canonical provider list. Order is compatibility-sensitive: the first started
-- resource wins, exactly as in the legacy detection chains.
ZlomaCore.ProviderCatalog = {
    Framework = {
        { id = 'ESX', resources = { 'es_extended' } },
        { id = 'QBox', resources = { 'qbx_core', 'qbx-core' } },
        { id = 'QBCore', resources = { 'qb-core' } },
    },
    Inventory = {
        { id = 'ox_inventory' }, { id = 'tgiann-inventory' },
        { id = 'origen-inventory', resources = { 'origen_inventory', 'origen-inventory' } },
        { id = 'qb-inventory' }, { id = 'qs-inventory' }, { id = 'ps-inventory' },
        { id = 'codem-inventory' }, { id = 'core_inventory' }, { id = 'ak47_inventory' },
        { id = 'jaksam_inventory' }, { id = 'jpr-inventory' },
        { id = 'S-Inventory', resources = { 'S-Inventory', 'S-inventory' } },
    },
    Billing = {
        { id = 'zloma_banking' }, { id = 'okokBilling' }, { id = 'okok_billing' },
        { id = 'esx_billing' }, { id = 'qb-billing' },
    },
    Notification = {
        { id = 'ox_lib' }, { id = 'wasabi_notify' }, { id = 'wasabi_uikit' },
        { id = 'fl-notify' }, { id = 'brutal_notify' }, { id = 'is_ui' },
        { id = 'lation_ui' }, { id = 'g-notifications' }, { id = 'vms_notifyv2' },
        { id = 'mythic', resources = { 'mythic_notify' } }, { id = 't-notify' },
        { id = 'okok', resources = { 'okokNotify' } }, { id = 'esx_notify' },
        { id = 'QBCore', resources = { 'qb-core' } }, { id = 'ESX', resources = { 'es_extended' } },
    },
    Appearance = {
        { id = 'illenium-appearance' }, { id = 'qs-appearance' }, { id = 'crm-appearance' },
        { id = 'qb-clothing' }, { id = 'rcore_clothing' }, { id = 'tgiann-clothing' },
        { id = 'p_appearance' }, { id = 'esx_skin' },
    },
    Keys = {
        { id = 'zloma_keys' }, { id = 'Renewed-Vehiclekeys' }, { id = 'MrNewbVehicleKeys' },
        { id = 'qbx_vehiclekeys' }, { id = 'qb-vehiclekeys' }, { id = 'qs-vehiclekeys' },
        { id = 'wasabi_carlock' }, { id = 'cd_garage' },
        { id = 'jaksam', resources = { 'jaksam-vehicles-keys', 'vehicles_keys' } },
        { id = 'tgiann-hotwire' }, { id = 'ak47_vehiclekeys' }, { id = 'ak47_qb_vehiclekeys' },
        { id = 'mk_vehiclekeys' }, { id = 'filo_vehiclekey' },
        { id = 'is_carkeys', resources = { 'is_carkeys', 'is_vehiclekeys' } },
        { id = 'LifeSaver_KeySystem' }, { id = 'brutal_carkeys' }, { id = 'ic3d_vehiclekeys' },
        { id = 'mm_carkeys' }, { id = 'rd_vehiclekeys' }, { id = 'p_carkeys' },
    },
    Dispatch = {
        { id = 'ps-dispatch' }, { id = 'piotreq_gpt' }, { id = 'cd_dispatch' },
        { id = 'cd_dispatch3d' }, { id = 'qs-dispatch' }, { id = 'tk_dispatch' },
        { id = 'rcore_dispatch' }, { id = 'lb-tablet' }, { id = 'kartik-mdt' },
        { id = 'origen_police' },
    },
    Target = {
        { id = 'ox_target' }, { id = 'qb-target' }, { id = 'qtarget' },
    },
    Fuel = {
        { id = 'lc_fuel' }, { id = 'qb-fuel' }, { id = 'LegacyFuel' }, { id = 'ox_fuel' },
        { id = 'lj-fuel' }, { id = 'ps-fuel' }, { id = 'cdn-fuel' }, { id = 'Renewed-Fuel' },
        { id = 'okokGasStation' }, { id = 'qs-fuelstations' }, { id = 'rcore_fuel' },
        { id = 'x-fuel' }, { id = 'stg-fuel' }, { id = 'ti_fuel' }, { id = 'esx-sna-fuel' },
        { id = 'ND_Fuel' }, { id = 'myFuel' },
    },
    Society = {
        { id = 'zloma_banking' }, { id = 'esx_addonaccount' }, { id = 'qb-banking' },
        { id = 'okokBanking' }, { id = 'wasabi_banking' }, { id = 'qs-banking' },
        { id = 'Renewed-Banking' }, { id = 'RxBanking' }, { id = 'crm-banking' },
        { id = 'kartik-banking' }, { id = 'snipe-banking' }, { id = 'tgg-banking' },
        { id = 'fd_banking' }, { id = 'nfs-billing' }, { id = 'p_banking' },
        { id = 'nfs-banking' }, { id = 'vms_bossmenu' }, { id = 'xnr-bossmenu' },
        { id = 'nass_bossmenu', resources = { 'nass_bossmenu', 'nass_bosmenu' } },
        { id = 'sd-multijob' },
    },
}
