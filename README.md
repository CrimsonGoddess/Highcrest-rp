# Highcrest RP

Built on Qbox and the ox stack. See docs\HIGHCREST_BRIEF.md for the project direction.

## Running it

1. Add your license key to `server-data\secrets.cfg`.
   Create one at https://portal.cfx.re/servers/registration-keys
2. Double-click `start-server.bat`. It starts the database, then the server.
3. In FiveM, press F8 and type `connect localhost:30120`.

The database keeps running in the background after the server closes.
Use `stop-database.bat` to stop it.

## Becoming admin

Join once, find your `fivem:` identifier in the server console, then edit `secrets.cfg`:

    add_principal identifier.fivem:YOUR_ID group.admin

## Going public

Both steps are needed for other people to join:

1. Remove `set sv_master1 ""` from `server.cfg` if you want to be on the public server list.
2. Forward port 30120 (TCP and UDP) on your router and allow it through Windows Firewall.

## Where things are

| Path | What it is |
|---|---|
| `server-data\server.cfg` | Main config and resource start order |
| `server-data\secrets.cfg` | License key and database password. Never share this. |
| `server-data\ox.cfg` | Inventory, targeting and UI settings |
| `server-data\resources\[custom]` | Scripts written for this server |
| `server-data\resources\[qbx]`, `[ox]`, `[standalone]`, `[voice]`, `[npwd]` | Third-party scripts |
| `sql\` and `tools\sql-order.txt` | Database scripts, each applied once |
| `tools\recipe.yaml` | The list of third-party scripts to download |

## Features and the scripts behind them

| Feature | Script |
|---|---|
| Inventory and shops | `ox_inventory` |
| Banking | `Renewed-Banking` |
| Paychecks | `qbx_core` (`config\server.lua`, pay rates in `shared\jobs.lua`) |
| Income tax and treasury | `city_economy` (custom) |
| Police and jail | `qbx_police`, `xt-prison` |
| Ambulance and medical | `qbx_ambulancejob`, `qbx_medical` |
| Housing | `qbx_properties` |
| Phone | `npwd` |
| Radio and voice | `mm_radio`, `pma-voice` |
| Emotes and dances | `scully_emotemenu` |
| Clothing | `illenium-appearance` |
| Vehicles | `qbx_vehicleshop`, `qbx_garages`, `qbx_vehiclekeys`, `ox_fuel` |
| Civilian jobs | taxi, bus, trucker, tow, garbage, mechanic, news, vineyard and others |
| Crime | bank, store, jewellery and house robberies, drugs, weed |

## Changes made to third-party scripts

These are lost if you redownload a script, so reapply them afterwards:

- `qbx_core\shared\jobs.lua`: all pay multiplied by 5, and a `government` job added.
- `qbx_ambulancejob\server\main.lua`: waits for `ox_inventory` before registering the EMS armory. Without this it fails at startup.

## Maintenance scripts

    powershell -ExecutionPolicy Bypass -File tools\check-resources.ps1

Checks every script for missing dependencies and missing UI files.

    powershell -ExecutionPolicy Bypass -File tools\setup-database.ps1

Applies any new SQL files listed in `tools\sql-order.txt`.

    powershell -ExecutionPolicy Bypass -File tools\install-resources.ps1

Downloads every script in the recipe again, overwriting changed files. Commit your work first.
