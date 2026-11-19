# ZLOMA CORE

**Universal Framework Wrapper for FiveM**

Unified interface for ESX, QBCore, and QBox with automatic detection and graceful fallbacks. Drop it in, start your server — everything just works.

> Full documentation: [zloma-scripts.gitbook.io](https://zloma-scripts.gitbook.io)

---

## Features

- **Framework Agnostic** — ESX, QBCore, QBox (including full QBox export-based API)
- **100+ Supported Systems** — Auto-detected at runtime, zero config needed
- **Graceful Fallbacks** — Missing optional systems trigger warnings, never crashes
- **Open Source** — Easy to extend with new system support

### Supported Systems

| Category | Count | Examples |
|----------|-------|---------|
| Framework | 3 | ESX, QBCore, QBox |
| Inventory | 12 | ox_inventory, qb-inventory, qs-inventory, ps-inventory, tgiann-inventory, origen-inventory... |
| Notification | 15 | ox_lib, wasabi_notify, fl-notify, brutal_notify, mythic_notify, t-notify, okokNotify... |
| Appearance | 8 | illenium-appearance, qs-appearance, crm-appearance, qb-clothing, rcore_clothing... |
| Keys | 21 | Renewed-Vehiclekeys, qb-vehiclekeys, wasabi_carlock, qbx_vehiclekeys, MrNewbVehicleKeys... |
| Dispatch | 10 | ps-dispatch, piotreq_gpt, cd_dispatch, qs-dispatch, tk_dispatch... |
| Fuel | 16 | lc_fuel, LegacyFuel, ox_fuel, Renewed-Fuel, cdn-fuel, ps-fuel... |
| Society/Banking | 19 | zloma_banking, esx_addonaccount, qb-banking, okokBanking, Renewed-Banking... |
| Billing | 4 | zloma_banking, okokBilling, esx_billing, qb-billing |
| Target | 3 | ox_target, qb-target, qtarget |

Full list of supported systems is maintained in `shared/provider_catalog.lua`.

Society routing follows the active framework while the setting is `auto`:

- **ESX:** `esx_addonaccount` is the sole society source (`society_<job>`).
  `zloma_banking` can remain active for its UI and billing without creating a
  second ESX company ledger.
- **QBCore/QBox:** `zloma_banking` remains the default society provider and
  owns its internal job/gang organization ledger.

Billing is selected independently and still uses `zloma_banking` when present.

## Project structure

Core modules are grouped by domain. Dispatch, billing, fuel, notifications, and
appearance use provider registries and feature-local `providers/` directories;
their facades keep the public exports unchanged. The remaining domains already
use feature-local `init.lua` entrypoints and retain their existing API.

---

## Installation

### Dependencies
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)

### Setup

1. Place `zloma_core` in your resources folder
2. Add to `server.cfg` **before** any scripts that use it:

```cfg
ensure ox_lib
ensure oxmysql
ensure qb-core       # or qbx_core
ensure ox_inventory # selected inventory backend
ensure ox_target    # selected target backend
ensure zloma_core
ensure zloma_garages  # or any other zloma script
```

For ESX, use this order instead:

```cfg
ensure es_extended
ensure esx_addonaccount
ensure zloma_core
ensure zloma_banking
ensure zloma_bossmenu
```

Framework/inventory/target backends must start before `zloma_core`; scripts that use the core start after it. The core no longer attempts to start or restart unrelated resources automatically.

The legacy client-triggered billing event is disabled by default. Keep billing server-authoritative through `SendBill`, or explicitly configure the guarded compatibility event in `ZlomaCore.Config.Security`.

3. Restart your server — done.

On startup you'll see the detection output:
```
========================================
ZLOMA CORE v1.1.0 - System Detection
========================================
Framework: QBCore
Inventory: ox_inventory
Notification: ox_lib
Keys: Renewed-Vehiclekeys
Dispatch: ps-dispatch
Target: ox_target
Fuel: lc_fuel
Society: qb-banking
Billing: okokBilling
========================================
```

---

## Quick Start

### Server-Side

```lua
local Core = exports['zloma_core']

-- Player data
local job = Core:GetPlayerJob(source)
local money = Core:GetPlayerMoney(source, 'cash')
local identifier = Core:GetIdentifier(source)

-- Money
Core:AddMoney(source, 500, 'bank')
Core:RemoveMoney(source, 100, 'cash')

-- Inventory
Core:AddItem(source, 'phone', 1, {battery = 100})
Core:RemoveItem(source, 'lockpick', 1)
local has = Core:HasItem(source, 'water', 2)

-- Billing
Core:SendBill(source, targetId, 500, 'Repair Invoice', 'mechanic')
```

### Client-Side

```lua
local Core = exports['zloma_core']

-- Notifications
Core:Notify('Engine repaired!', 'success', 5000)
Core:NotifyAdvanced('Garage', 'Vehicle stored', 'info', 5000)

-- Appearance / wardrobe
local appearanceSystem = Core:GetAppearanceSystem()
Core:OpenWardrobe({ title = 'Wardrobe' })

-- Vehicle keys
Core:GiveKeys(plate)
Core:RemoveKeys(plate)
local hasKeys = Core:HasKeys(plate)

-- Fuel
local fuel = Core:GetVehicleFuel(vehicle)
Core:SetVehicleFuel(vehicle, 100.0)

-- Legacy aliases are also available for older Zloma resources.
Core:GetFuel(vehicle)
Core:SetFuel(vehicle, 100.0)

-- Target zones
Core:AddEntity(vehicle, {
    {
        name = 'repair',
        icon = 'fas fa-wrench',
        label = 'Repair Vehicle',
        action = function() end,
        distance = 3.0
    }
})
Core:RemoveZone('zone_name')
```

---

## Configuration

**Default: Auto-detection (recommended)** — no config needed.

For manual override, edit `shared/config.lua`:

```lua
ZlomaCore.Config.Manual = {
    Framework = 'ESX',          -- or 'auto'
    Inventory = 'ox_inventory', -- or 'auto'
    -- ... etc
}
```

Enable debug logging:
```lua
ZlomaCore.Config.Debug = true
```

---

## API Reference

Full API documentation available at [zloma-scripts.gitbook.io](https://zloma-scripts.gitbook.io).

### Server Exports

| Export | Description |
|--------|------------|
| `GetPlayer(source)` | Get framework player object |
| `GetPlayerMoney(source, account)` | Get player money |
| `AddMoney(source, amount, account)` | Add money |
| `RemoveMoney(source, amount, account)` | Remove money |
| `GetPlayerJob(source)` | Get player job info |
| `GetPlayerGang(source)` | Get player gang (QB/QBox) |
| `GetIdentifier(source)` | Get player identifier |
| `GetPlayerGroup(source)` | Get admin group |
| `IsAdmin(source, groups)` | Check admin permissions |
| `GetAllJobs()` | Get all framework jobs |
| `GetAllGangs()` | Get all gangs (QB/QBox) |
| `GetOnlinePlayers()` | Get all online players |
| `HasItem(source, item, count)` | Check inventory |
| `GetItemCount(source, item)` | Get item count |
| `AddItem(source, item, count, metadata)` | Add item |
| `RemoveItem(source, item, count)` | Remove item |
| `SendBill(source, target, amount, reason, society)` | Send bill |
| `GetSocietyMoney(job)` | Get society balance |
| `AddSocietyMoney(job, amount)` | Add to society |
| `RemoveSocietyMoney(job, amount)` | Remove from society |

### Client Exports

| Export | Description |
|--------|------------|
| `Notify(msg, type, duration)` | Show notification |
| `NotifyAdvanced(title, msg, type, duration)` | Show titled notification |
| `GetAppearanceSystem()` | Get detected appearance system |
| `GetCurrentSkin()` | Fetch current skin when supported |
| `SetPlayerSkin(data)` | Apply a full skin payload |
| `SetPlayerClothing(data)` | Apply clothing-only payload |
| `OpenWardrobe(options)` | Open the saved outfits / wardrobe UI |
| `GiveKeys(plate)` | Give vehicle keys |
| `RemoveKeys(plate)` | Remove vehicle keys |
| `HasKeys(plate)` | Check if has keys |
| `AddEntity(entity, options)` | Add target to entity |
| `AddBoxZone(name, coords, options)` | Add box target zone |
| `AddSphereZone(options)` | Add sphere target zone |
| `AddGlobalVehicle(options)` | Add global vehicle target |
| `RemoveGlobalVehicle()` | Remove global vehicle targets owned by the calling resource |
| `RemoveZone(name)` | Remove target zone |
| `SetTargetingEnabled(enabled)` | Toggle targeting when supported |
| `GetVehicleFuel(vehicle)` | Get fuel level |
| `SetVehicleFuel(vehicle, level)` | Set fuel level |

---

## Contributing

ZLOMA CORE is open source — contributions are welcome!

To add support for a new system:

1. Add detection in `shared/config.lua` (e.g. `DetectInventory()`)
2. Add the system name to `Config.Manual` options
3. Implement the wrapper functions in the appropriate file
4. Test on a server with the target system
5. Create a Pull Request

Each file has `ADD NEW ... SUPPORT HERE` comments showing exactly where to add new systems.

---

## ZLOMA Scripts Ecosystem

ZLOMA CORE is the foundation for all Zloma scripts:

| Script | Status |
|--------|--------|
| **zloma_core** | Available |
| **zloma_garages** | Available |
| zloma_keys | Coming Soon |
| zloma_stance | Coming Soon |

---

## Support

- **Discord:** [discord.gg/ccAz3NJGCt](https://discord.gg/ccAz3NJGCt)
- **Documentation:** [zloma-scripts.gitbook.io](https://zloma-scripts.gitbook.io)
- **Issues:** [GitHub Issues](https://github.com/ZlomaScripts/zloma_core/issues)

---

## License

This project is **source-available** — you can use and modify it for your server, but redistribution and reselling are prohibited. See the [LICENSE](LICENSE) file for details.

**Made by Zloma**

## Public server valet / external binding contract

See [PublicValetContract.md](docs/PublicValetContract.md) for the callable server retrieval API, cancellation/result/handoff exports, explicit trusted caller configuration and admin/market creation provenance policy.
