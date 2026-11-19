<p align="center">
  <img src="https://github.com/ZlomaScripts/zloma_apartments/releases/download/v0.2.1-beta.1/cover.png" alt="zloma_apartments" width="100%">
</p>

<h1 align="center">zloma_apartments</h1>

<p align="center">
  <strong>A place to live. Something to protect. A city to build.</strong><br>
  Free, open-source apartments for FiveM · ESX / QBCore / QBox
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-PUBLIC%20BETA-d69762?style=flat-square" alt="Status: public beta">
  <img src="https://img.shields.io/badge/version-0.2.1--beta.1-303846?style=flat-square" alt="Version 0.2.1-beta.1">
  <img src="https://img.shields.io/badge/license-GPL--3.0-303846?style=flat-square" alt="License: GPL-3.0">
  <img src="https://img.shields.io/badge/languages-EN%20%2F%20HR-303846?style=flat-square" alt="English and Croatian">
</p>

<p align="center">
  <a href="https://github.com/ZlomaScripts/zloma_apartments/releases"><strong>Download</strong></a> ·
  <a href="https://zloma-scripts.gitbook.io/zloma_apartments"><strong>Documentation</strong></a> ·
  <a href="https://discord.gg/ccAz3NJGCt"><strong>Discord</strong></a> ·
  <a href="https://github.com/ZlomaScripts/zloma_apartments/issues"><strong>Report a bug</strong></a>
</p>

> [!WARNING]
> **This is a beta. Bugs are definitely present.** Expect unfinished behavior, rough edges and changes between updates. This is not a stable release or a promise of bug-free gameplay. Test on a development server and back up your database before installing or updating. Please report reproducible issues so the resource can improve.

Rent a room for the day, sign a longer contract or buy your own place. Share it
with a roommate, upgrade the locks and keep your belongings behind a PIN-protected
safe. On the other side of the door: physical lockpicking, safe cracking and alarm
hacking give break-ins their own gameplay.

For server owners, the building creator and furniture editor live in game.
Start with Floky's WiWang Hotel preset or set up your own building. Framework,
inventory and target integration goes through [zloma_core](https://github.com/ZlomaScripts);
actual compatibility depends on the providers configured there.

<p align="center">
  <a href="https://youtu.be/JAb7ezpvuAM"><img src="https://github.com/ZlomaScripts/zloma_apartments/releases/download/v0.2.1-beta.1/gameplay-preview.gif" alt="Gameplay preview: reception, safe, alarm cable, building editor" width="720"></a><br>
  <sub><a href="https://youtu.be/JAb7ezpvuAM">▶ Watch the full showcase on YouTube</a></sub>
</p>

| Room browser | My apartment |
| --- | --- |
| <img src="https://github.com/ZlomaScripts/zloma_apartments/releases/download/v0.2.1-beta.1/room-browser.png" alt="Reception room browser"> | <img src="https://github.com/ZlomaScripts/zloma_apartments/releases/download/v0.2.1-beta.1/my-apartment.png" alt="Apartment dashboard"> |
| **Security upgrades** | **Building creator** |
| <img src="https://github.com/ZlomaScripts/zloma_apartments/releases/download/v0.2.1-beta.1/security.png" alt="Security tab with lock and alarm levels"> | <img src="https://github.com/ZlomaScripts/zloma_apartments/releases/download/v0.2.1-beta.1/building-creator.png" alt="In-game building creator"> |

## Features

- **Rent, contract or buy.** Daily rent is charged from the bank. A contract is
  paid up front for N days. Each building decides which options it offers.
- **Native door locks.** Owner and roommate press `E` at the door; everyone can
  knock with `G`. Normal unlocks auto-lock after 10 seconds; picked doors remain
  unlocked until residents manually lock them or the resource/server restarts.
- **Roommate.** One per apartment, picked from players standing next to the owner.
- **Safe, two modes.** `character`: the safe belongs to the character and moves
  with them. `apartment`: the safe belongs to the room, items stay when the tenant
  leaves and the next tenant sets a new PIN. Three sizes, protected by a PIN
  (hashed in the database). Anyone at the safe can enter its PIN. Only the owner
  changes the PIN and buys upgrades.
- **Lockpicking.** Break into a locked apartment door (`H`) or a safe (target),
  with an optional item (`lockpick` by default) and a minigame: ox_lib skill
  checks, or a real wafer lock on the door itself, picked with a Lishi pick by
  feel (made by TR Scripts). The owner is alerted. Works in both safe modes.
- **Alarms.** Higher door and safe levels can have an alarm: a break-in calls
  the police (zloma_core dispatch) and tells the owner, unless the alarm is
  hacked first (with a `hacking_device`). Door and safe alarms have an optional physical
  panel and cable connection scene (see Alarms below).
- **Security upgrades.** A Security tab where the owner buys stronger door and
  safe locks (1-10 levels each, separately). Each level can use a different or
  harder minigame. Prices can differ per building.
- **In-game building creator** (`/apartmentadmin`). Set the receptionist, aim at
  each room door, place the safes, measure the floor height. Done.
- **Furniture editor.** Build a furniture set once, place it in a room, copy a
  whole floor to every other floor.
- **WiWang Hotel built in.** 380 furnished rooms, ready the moment you start.
- English and Croatian. English is the default.

## Requirements

| Resource | |
|---|---|
| [ox_lib](https://github.com/overextended/ox_lib) | required |
| [oxmysql](https://github.com/overextended/oxmysql) | required |
| [zloma_core](https://github.com/ZlomaScripts) | required, any supported framework / inventory / target |
| [WiWang Hotel by Floky](https://github.com/uFLOKY/wiwang_hotel) | required for the built-in hotel (free) |

## Setup & reference

For the full guide, visit the [documentation](https://zloma-scripts.gitbook.io/zloma_apartments).
The bundled installation and technical notes are also available below.

<details>
<summary><strong>Installation, administration, configuration & developer notes</strong></summary>

## Installation

1. Download [WiWang Hotel](https://github.com/uFLOKY/wiwang_hotel) and put `map_wiwang_hotel` in your resources.
2. Download the **installable ZIP asset** from GitHub Releases and put its `zloma_apartments` folder in your resources. GitHub source archives require building the UI first.
3. `server.cfg`, in this order:

```cfg
ensure oxmysql
ensure ox_lib
ensure zloma_core
ensure map_wiwang_hotel
ensure zloma_apartments
```

4. Start the server. Tables are created automatically on the first start and the
   WiWang furniture is installed once. All tables and compatible legacy migrations are managed by Lua through oxmysql; no SQL file needs importing.

5. Optional: copy `wiwang_patch/map_wiwang_hotel/ipl.lua` over the same file in
   your `map_wiwang_hotel` folder (overwrite). It is Floky's original `ipl.lua`
   with two added lines that tell apartments the elevator is switching floors, so
   doors and furniture are cleaned up instantly. Without it everything still works;
   apartments notices the switch within half a second.

Not running WiWang? Set `Config.WiWang = false` and create your own building.

## Admin

`/apartmentadmin` opens the admin panel. Who is admin is set in `config.lua`:

```lua
Config.AdminGroups = { 'admin', 'superadmin', 'god' }
```

ESX: the player's group. QBCore/QBox: the permission. Only these groups count.

### Create a building

1. **New building**, type an ID (`sunset_motel`) and a name.
2. **Reception:** stand where the receptionist should stand, facing the counter, press E.
3. **Room doors:** go to the lowest floor. For each room, aim at the door and press
   E. The first door also records the floor height and the door model. A room
   without a door object: press G to use your position (knocking only, no lock).
   Rooms are numbered 101, 102, ... in the order you add them.
4. **Safe:** press "Safe" next to a room, place the ghost safe, press E.
5. **Floors:** one floor? Done. More floors: set the count, then press
   "Measure floor height" and stand on floor 2 at the same spot. Upper floors
   copy the lowest floor: room 101 becomes 201, 301, ...
6. Prices, blip, **Save**. The building appears for every player at once.

Buildings are stored in the database (`zloma_apartment_hotels`). Built-in
buildings can be edited the same way; "Reset to built-in" removes your changes.
A room that is rented or owned cannot be removed, and a building with tenants
cannot be deleted. "Free room" in the panel removes a tenant.

### Furnish rooms

1. Admin panel, **Furniture** tab. Pick the building and room, press **Go**.
2. **Move anchor to me**, then add furniture from the catalog. Drag the X/Y/Z
   handles or the ring, or type values. Right mouse + WASD moves the camera.
3. **Save set** with a name, then **Save to room**.
4. Same layout in another room: load the set, move/rotate the whole set, save to
   that room. Mirrored rooms need their own set.
5. **Copy floors** copies every furnished room of one floor to other floors,
   using the building floor height.

Furniture is spawned locally, only on the player's floor and within 18 m.

## Room photos

The room preview supports a shared building photo and an optional override for an exact room number. WiWang uses `https://i.imgur.com/LLmvFYq.jpeg` by default. That built-in photo is bundled locally in the UI, so it also works when Imgur hotlinking is unavailable in FiveM. Custom photo URLs still load directly.

In `/apartmentadmin`, edit a building: set **Default room image URL** in Basic Info, then choose a room and its URL under **Room photos** in the Floors step. An empty room URL inherits the building image. Save the building to apply. URLs must be direct HTTPS image links; unavailable images show the room icon instead.

The definition fields are `imageUrl` and `roomImages = { ['101'] = 'https://...' }`. These settings are stored with the building in the existing database JSON; no SQL migration is needed.

## Configuration

Everything is in `config.lua`: payment account, grace period, door keys, knocking
limits, roommate distance, safe sizes and prices, defaults for new buildings,
furniture limits.

**Rent.** Daily rent is charged while the tenant is online; missed days are
charged together when they come back. If rent stays unpaid for
`Config.GracePeriodDays` (default 3) the room is released. Due dates are stored
in the database, so restarts do not reset this. Players who are away for longer
should sign a contract or buy.

### Safe mode

`Config.Safe.Mode = 'character'` (default): one safe per character. Contents,
size and lock level go with the character to every apartment.

`Config.Safe.Mode = 'apartment'`: one safe per room. When the tenant leaves,
the items stay and the PIN is cleared. The next tenant sets their own PIN and
finds whatever was left behind.

### Lockpicking

`Config.Doors.Lockpick` and `Config.Safe.Lockpick` turn lockpicking on/off
separately. `Item` is the item needed (`nil` = none), `RemoveItemOnFail` breaks
it on a failed attempt and `Cooldown` is seconds between attempts. The
`[H] Lockpick` prompt and the safe's "Crack Safe" option only show when the
player has the item. Residents can't break into their own door or safe. The
owner only hears about a break-in when the lock has an alarm (see Alarms). A successful door lockpick unlocks the door
until it locks itself again; a successful safe lockpick opens the safe once.
`server/customization.lua` has `OnLockpickStart`/`OnLockpickFinish`/`OnAlarm`
hooks.

### Security upgrades and minigames

`Config.Security` lists the levels for `Door` and `Safe` (1-10 each). Level 1
comes with the apartment. Every level names a minigame and a difficulty:

```lua
Door = {
    [1] = { label = 'Standard lock',  game = 'lockpick', difficulty = 'hard',  price = 0 },
    [2] = { label = 'Reinforced lock', game = 'lockpick', difficulty = 'ultra', price = 15000 },
    [3] = { label = 'Electronic lock', game = 'tr_lockpick', difficulty = 'expert',  price = 35000 },
},
```

The games and difficulties are defined in `config_minigame.lua` (ox_lib skill
checks by default). That file explains how to make a game harder or easier and
how to add another resource's minigame. Prices in `config.lua` are defaults; in
the admin panel (step "Prices") each building can have its own prices.

If a level names a game or difficulty that does not exist, the server prints
the error, turns security upgrades off and shows the error in the admin panel.
Lockpicking keeps working with the `Lockpick.Minigame` settings.
`Config.Security.Enabled = false` removes the Security tab.

### Alarms

A door or safe level with `alarm = true` has an alarm, and so does every level
above it (they take over its `alarm_*` settings unless they set their own).
Door and safe alarms are separate:

```lua
[3] = { label = 'Electronic lock', game = 'tr_lockpick', difficulty = 'expert', price = 35000,
        alarm = true, alarm_game = 'hacking', alarm_difficulty = 'medium', alarm_item = 'hacking_device' },
[4] = { label = 'Smart lock', game = 'tr_lockpick', difficulty = 'expert', price = 60000,
        alarm_game = 'hacking5' },  -- still alarmed, with a harder panel
```

When someone lockpicks an alarmed door or safe (whether the pick works or not)
or fails to hack its alarm (`DispatchOnHackFail`):

- the police get a dispatch through zloma_core (`SendDispatchAlert`, settings
  in `Config.Security.Alarm.Dispatch`), at the door or the safe;
- the owner and roommate get an ox_lib notification (`NotifyOwner`).

With `Config.Security.Alarm.Panel.Enabled = true` (default), occupied apartments
with an alarm-equipped door have a physical panel. Carry the configured
`alarm_item`, target **Hack alarm**, then hold the connector with left click and
release it at the glowing port. The custom m61 handheld (from
`m26_1_prop_m61_hackdevice_01b`) has a permanently attached USB cable and displays HR/EN instructions,
terminal connection progress. Connecting alone never disables an alarm. Once connected, the device
screen shows **START HACK**: the camera locks onto the screen and the hack is
played there with the mouse, in stages from `device_hack` in
`config_minigame.lua` (signal sync, memory pattern, PIN crack; difficulty per
lock level). `Config.Security.Alarm.Hack` sets the allowed mistakes
(`Strikes`), when the police are called (`DispatchOnFail`,
`FailsBeforeDispatch`, `FailMemorySeconds`), whether Esc may stop it
(`AllowCancel`, `CancelCountsAsFail`) and when the item is used up
(`RemoveItem.OnSuccess / OnFail / OnCancel`). A successful hack keeps the
alarm off until residents reactivate it; the server checks the result.

The player holds the device in both hands (`Panel.Hold`: animation, hand bone,
offset, rotation) and is moved so the device's cable socket sits at
`Hold.socketTarget` below the panel. With `Config.Debug = true`,
`/apartment_alarm_hold` lets you move the device in the hand live (W/S A/D Q/E,
Shift rotates, Ctrl fine, Enter prints the values to F8). `Panel.CableScale`
is the shortest cable; it is always lengthened to leave slack between the held
device and the port (Debug prints a note).
`Panel.Camera` looks from under the player's chin at the panel and the device; it leans towards the mouse and the mouse wheel zooms in. Panel props exist only
within `Panel.StreamDistance` on the same floor, and their live screens (DUI)
run only within `Panel.ScreenDistance`; further away the panel shows its
built-in texture. The device screen runs only during the hack.

In `/apartmentadmin`, edit a building and open **Floors → Door alarm panels**.
Choose an apartment, place the panel manually or use automatic placement.
The custom `zloma_alarm_panel` has a real LCD material and raised polygon ZLOMA branding;
see [custom panel build notes](https://zloma-scripts.gitbook.io/zloma_apartments).
Manual controls: WASD moves across the wall, scroll changes depth, Q/E rotates
yaw, Shift+Q/E pitch, Alt+Q/E roll; Ctrl makes fine adjustments. Enter accepts,
Escape cancels. Save the building to persist changes. Copy a room layout to
all floors with the matching-rooms button, then override individual apartments
as needed. See [implementation and validation notes](https://zloma-scripts.gitbook.io/zloma_apartments).

Safe alarms require a medium or larger capacity (`Config.Safe.AlarmMinCapacity = 2`)
and an alarm-bearing safe security upgrade (default level 3). They use the same
physical USB scene, with independent `safe_device_hack` stages (default easy)
and `Alarm.SafeHack` overrides. The panel is mounted on the safe door and follows
its opening animation. See [custom safe build and controls](https://zloma-scripts.gitbook.io/zloma_apartments).
Set `Panel.Enabled = false` to restore
the legacy `[J] Hack alarm` door flow. In legacy mode, successful hacking keeps
the target quiet until resident reactivation; options also appear
on locks without alarms to hide their presence. If `alarm_item` does not exist
in the inventory, that level's alarm is off. Alarm minigames are defined in
`config_minigame.lua`.

**Your own notification (phone, etc.).** Another resource can take over the
owner notification:

```lua
exports.zloma_apartments:RegisterAlarmNotifier(function(target, identifier, info)
    -- target: the owner/roommate's server id. info = { hotel, hotelLabel, room,
    -- kind = 'door' | 'safe', reason = 'picked' | 'failed' | 'hack_failed', coords }
    exports['your-phone']:SendNotification(target, { title = 'Alarm', message = 'Room ' .. info.room })
    return true -- handled: no ox_lib notification
end)
```

Returning `false` keeps the ox_lib notification as well. The same works in
`server/customization.lua` (`Customization.OnAlarmOwner`), and every alarm also
fires the server event `zloma_apartments:alarm` (`source, info`) and the
`OnAlarm` hook.

**Testing alone.** With `Config.Debug = true` no items are needed or used up,
there are no cooldowns, and residents can break into their own door and safe
(and get their own alarm notification). Turn it off on a live server.

### Safe cracking

`game = 'safecrack'` (default for every safe level) turns the real 3D dial on
`zloma_safe`, with its own camera (wheel zoom). The safe has animated hinged
doors, a gray frame and polygon ZLOMA branding inside and outside. Turn
it with **A / D** until a pin drops (you hear a click), press **W** to set it,
then turn the other way for the next number. Pressing W off the number, or
**S**, gives up. `pins` per difficulty in `config_minigame.lua` (easy 2 to
expert 6; level 1 starts at `hard`, 4 numbers). Based on
[pd-safe](https://github.com/VHall1/pd-safe) by Victor Hall (MIT).

### Door lockpick (wafer lock)

`game = 'tr_lockpick'` (all default door levels) plays TR Scripts' wafer
lockpick on the door: the player steps up to the lock, the camera moves in and
a Lishi-style pick goes into a real wafer lock.

- **RMB** (hold): light turning tension. Letting go drops every set wafer.
- **Scroll** or **A / D**: move the pick to the next wafer.
- **LMB** (hold) + push the mouse up: lift the wafer under the hook.

One wafer binds at a time. Lift it slowly until it clicks. Lifting too far
oversets it, pushing too hard bends the pick: `Config.DoorPick.maxStrikes`
bends and it snaps. The server holds the lock and checks every click, so a
modified client can't skip it, and the door only opens when the server saw the
lock picked.

How hard each difficulty is (wafers, how much overset is forgiven, how stiff)
is in `config_minigame.lua`. Placement on the door, camera, strikes and time
limits are in `Config.DoorPick`. The lock is placed on the door from the door
model's size, which fits most doors roughly. To fit a model exactly set
`devMode = true`, pick the door and move the lock with the arrows and Q / E
(Shift: 1 mm); every press prints the line for `Config.DoorPick.doorFits` in
F8. `/apartment_doorpick_rig` prints it for the door in front of you.

## Languages

`Config.Locale = 'en'` (default) or `'hr'`. All texts, including the UI and the
admin panel, are in `locales/<lang>.lua`. To add a language, copy `en.lua`,
rename `Locales.en` and translate. Missing keys fall back to English.

## For developers

Server exports:

```lua
-- { hotel = 'wiwang', room = 305, status = 'rented'|'owned', role = 'owner'|'roommate' } or nil
exports.zloma_apartments:GetPlayerApartment(source)
-- every building: id, label, floors, roomsPerFloor, pricing
exports.zloma_apartments:GetBuildings()
```

`server/customization.lua` has hooks for rent paid, rent failed and knocking,
for example to send a phone message with your phone script. All resource code is open source.

### UI

The player UI is Next.js in `ui/` (`npm ci && npm run build` writes `ui/dist`).
The player menu, building admin and furniture editor are React components in `ui/src`. There is no separate admin page or iframe. Furniture thumbnails live in `ui/public/admin/images` and are copied into `ui/dist` by the build.

## Upgrading from the private BalkanUnity build

Bookings with the old hotel id `main_hotel` are moved to `wiwang` on the first
start. Furniture from the old `zloma_furniture_editor` JSON files is installed
from `data/`. Remove `zloma_furniture_editor` from your server; it is now part
of this resource.


</details>

## Beta feedback

Found something broken? [Open an issue](https://github.com/ZlomaScripts/zloma_apartments/issues)
or join the [Discord](https://discord.gg/ccAz3NJGCt). Include the resource version,
framework and inventory, steps to reproduce, what you expected, what happened,
and relevant F8/server errors. Remove passwords, tokens and personal data from logs.

Automated checks do not cover every map, framework or inventory combination.
The animated safe stash lifecycle currently uses ox_inventory events; equivalent
lifecycle integration with other inventory providers is not verified in this beta.

## Credits

The built-in hotel uses the **WiWang Hotel** MLO by **Floky**:
https://github.com/uFLOKY/wiwang_hotel. It is free and it is great: 20 floors,
380 rooms, with an elevator. Thank you, Floky. Download the map from Floky's
GitHub; only the optional patched `ipl.lua` is included here.

The door lockpick (`tr_lockpick`: its game, 3D props, sounds and the maths
and scene code it runs on) is made by **TR Scripts**, from
[tr_minigames](https://github.com/TR-Scripts67/tr_minigames) and
[tr_core](https://github.com/TR-Scripts67/tr_core), and adapted to apartment
doors here. Thank you, TR Scripts.

The safe cracking minigame is based on
[pd-safe](https://github.com/VHall1/pd-safe) by **Victor Hall** (MIT; complete notice
in `client/safecrack.lua`), with lineage to TimothyDexter's
[FiveM-SafeCrackingMiniGame](https://github.com/TimothyDexter/FiveM-SafeCrackingMiniGame). The doorpick sounds are CC0 recordings from
freesound.org (`ui/public/sounds/doorpick/CREDITS.txt`).

## License

Free and open source under the **GNU General Public License v3.0** (see
[LICENSE](LICENSE)), the [credits above](#credits) and [third-party notices](THIRD_PARTY_NOTICES.md). The door lockpick is adapted from TR Scripts'
tr_minigames and tr_core, which are GPL-3.0 as well.

Safe stash access waits for the opening animation. Closing ox_inventory starts
fast closing, and an authorized reopen reverses the hinge. A picked safe remains
open until its owner/roommate uses and closes the stash; a picked apartment door
bypasses automatic locking until residents lock it. Disabled panels offer resident
**Activate Alarm** targets. See [safe lifecycle notes](https://zloma-scripts.gitbook.io/zloma_apartments).


## Source and installable release

This repository contains `ui/src` and `ui/public`; generated `ui/dist` is ignored.
For a source checkout, run `npm ci --prefix ui` then `npm --prefix ui run build`.
The installable release ZIP contains built `ui/dist` and excludes UI source and
build dependencies. No Node server runs inside FiveM. The full corresponding
source remains public at the matching GitHub tag. See [GitHub Releases](https://github.com/ZlomaScripts/zloma_apartments/releases).

This is a beta; automated tests and local server testing do not cover every map,
framework and inventory combination. The animated stash lifecycle uses
ox_inventory server events; other inventory providers need equivalent lifecycle
integration and are not verified for that behavior in this beta.

### Resource folder name

Install the resource as `zloma_apartments` and use `ensure zloma_apartments`.
Runtime Lua and UI modules check this name and report an error if the folder is
renamed. Browser previews and static UI builds remain available outside FiveM.
The separate WiWang map patch belongs to its map resource and is unaffected.

These checks are editable implementation code, not an additional license term.
GPL modification and redistribution rights, including the ability to edit or
remove these checks while meeting applicable notice obligations, remain intact.


### Automatic database setup

`server/db.lua` creates and validates the eight tables on startup, adds known
legacy columns/indexes and preserves occupied bookings, PIN hashes, safe sizes,
settings and furniture. There is no SQL folder or manual import step. The
configured oxmysql account needs SELECT/INSERT/UPDATE/DELETE plus CREATE/ALTER/INDEX
for first install and upgrades. If migration fails, the resource does not become
ready; fix the reported permission/schema conflict and restart to retry safely.
Supported database families are MySQL and MariaDB through oxmysql, not SQLite,
PostgreSQL or SQL Server. Isolated Lua/database tests passed 2,445 checks across
MySQL 8.0.46 and 8.4.13, and MariaDB 10.11.19, 11.4.13 and 12.3.2,
with three SQL modes per version. These are database integration tests, not a full
FXServer/framework compatibility guarantee. No production database was used.
