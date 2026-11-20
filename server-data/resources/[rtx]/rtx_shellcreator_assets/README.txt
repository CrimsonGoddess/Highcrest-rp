RTX Shell Creator - README

## DOCUMENTATION

Full installation guide, configuration details and additional tips are available here:
https://rtx-dev.gitbook.io/rtxdev/rtx-shell-creator

Video: https://www.youtube.com/watch?v=EPpvW_mne4Y


Thank you for purchasing rtx_shellcreator.
If you need help, please join our Discord or contact support.

Discord: https://discord.gg/rtxdev
Shop: https://rtx.tebex.io

---

## REQUIREMENTS

Core resources:

* rtx_shellcreator (the shell creator itself)
* rtx_shellcreator_assets (the building kit models: walls, floors, doors, windows, stairs)
  If you own the RTX Toolkit, its rtx_toolkit_assets works too, you don't need both.

Optional:

* screenshot-basic (only for /shelltest, the render check for support)

---

## INSTALLATION

1. Add the resources

* Place rtx_shellcreator_assets and rtx_shellcreator into your resources folder,
  for example resources/[rtx]/

Add to server.cfg:

ensure rtx_shellcreator_assets
ensure rtx_shellcreator

Important:
The models live in their own resource, so rtx_shellcreator can be restarted at any time.
rtx_shellcreator_assets must start first.

2. Permissions

Add to server.cfg:

add_ace group.admin rtxshellcreator.admin allow
add_ace resource.rtx_shellcreator command.refresh allow
add_ace resource.rtx_shellcreator command.ensure allow
add_ace resource.rtx_shellcreator command.start allow
add_ace resource.rtx_shellcreator command.stop allow

The first line gives your admins the shell creator. The other four let it install and start
the shells you finish (and the walk-through preview) at once. Without them everything is
still saved, you only start the resources yourself.

You can also open it to ESX groups / QBCore permissions / QBox ACE permissions and to named
players by identifier, in config.lua section 3 (Config.Admins).

3. Framework setup

Open config.lua, section 1, and set your framework:

* esx              -> Config.Framework = "esx"
* qbcore           -> Config.Framework = "qbcore"
* qbox             -> Config.Framework = "qbox"
* standalone       -> Config.Framework = "standalone"

4. Restart the server

In game type /shellcreator. A key can be set in Config.Keys, and every admin can set his own
in Settings > Key Bindings > FiveM.

---

## FIRST SHELL IN TWO MINUTES

1. /shellcreator, then New shell. Pick Ready layout, House, size M, one bedroom. Create.
2. The shell appears high in the sky above the Grapeseed fields and the editor opens: the
   floor plan on the left, the shell live in the game on the right.
3. Drag walls, click Doors or Windows and put them on a wall, paint rooms with the brush,
   place furniture from the catalogue and turn it with R.
4. Walk through it with the walk button in the top bar.
5. Finish: make it a shell or an MLO, install it with one click and export it for your
   housing script.

---

## HOUSING SCRIPTS

Finish writes the entrance, exit and other points ready for:

rtx_housing, ps-housing, vms_housing, qb-interior, esx_property, loaf_housing,
nolag_properties, bcs_housing, RxHousing, a plain Lua table or JSON

RTX Housing gets the shells added automatically. For the others, paste the entry from the
housing/ folder of the finished resource into your housing config.

---

## YOUR OWN TEXTURES

Put square PNG files (512 or 1024 px, one tile = 1 metre) into rtx_shellcreator/custom/ and
restart the resource. Any file name with letters, numbers, _ and - works, up to 200 files.
They show up in the paint palette under "Own textures", one shell can use 6 of them at the
same time. Nicer names can be set in config.lua (Config.Shells.customtextures).
Finished shells and MLOs bake them in, so players do not need these files.

---

## COMMANDS

/shellcreator   opens the shell creator
/shelldebug     checks the shell you stand in: parts spawned, missing or still loading
/shelltest      takes a few pictures of the shell for support

All of them can be renamed in config.lua section 4.

---

## CONFIGURATION FILES

config.lua             framework, language and interface, admins, commands and keys, free
                       camera and gizmo, shells, housing export, installing resources,
                       community shells
language/*.lua         every line of text, the interface included, in 18 languages - pick
                       one with Config.Language, anything missing falls back to English
client/other.lua       notifications, death check, HUD hooks, weather sync, hooks when a
                       player enters or leaves a shell - open source
server/other.lua       framework, admin check, Discord logs, hooks for your own scripts -
                       open source
custom/                your own wall, floor and ceiling textures
data/                  every shell you build, written by the server

Languages:
English, Czech, German, Spanish, French, Polish, Portuguese, Italian, Russian, Turkish,
Korean, Dutch, Chinese, Romanian, Hungarian, Thai, Japanese, Arabic

---

## UPDATING

Replace the files of rtx_shellcreator and rtx_shellcreator_assets with the new ones, but keep:

* rtx_shellcreator/data/shells/ (all your shells and templates)
* rtx_shellcreator/custom/ (your own textures)
* your config.lua (compare it with the new one, new options are listed in CHANGELOG.txt)

The package has no data/shells/ folder, so copying it over never deletes your shells.

---

## IMPORTANT NOTES

* Keep rtx_shellcreator_assets started before rtx_shellcreator.
* Back up rtx_shellcreator/data/ with your server.
* Finished shells and MLOs need rtx_shellcreator_assets on the server (the doors come from it).
* For very big shells add  increase_pool_size "Object" 2000  to your server.cfg and raise
  Config.Shells.maxparts.
* Streamed models are only picked up by players who connect after the server restart.

---

## LICENSE / TERMS

1. All purchases are non-refundable
2. Each product may be used on one server (test server allowed)
3. Redistribution is strictly prohibited
4. Violation of these rules may result in legal action

(c) 2026 RTX Development. All rights reserved.
