Made by Kanikuly (Nina) for RTX Development
https://discord.gg/rtxdev
https://rtx.tebex.io/

Shell rtx_shell_my_shell - made with RTX Shell Creator

This shell is one of the shells in the collection rtx_custom_shells. Its files are in items/rtx_shell_my_shell/ and stream/rtx_shell_my_shell/.
Add "ensure rtx_custom_shells" to your server.cfg once, after rtx_shellcreator_assets (the doors come from it).
Every call below takes the shell name first: 'rtx_shell_my_shell'.

What is inside
- The walls, floors, stairs, built-in kitchens and lights are baked into one model: rtx_shell_my_shell.
- The front door is baked in. The 6 door(s) inside and 0 piece(s) of furniture stay separate objects, so doors swing and furniture
  can be moved by your housing script. They are spawned around the shell by this resource.

With a housing script (RTX Housing, ps-housing, VMS Housing, qb-interior, esx_property, loaf_housing, nolag_properties,
bcs_housing, RxHousing and others)
- Paste the entry from housing/ into your housing config. The script spawns the shell object as usual.
- This resource sees the shell and adds the doors by itself (Config.AutoDoors). The furniture is in
  furniture.json for scripts that import it. Set Config.AutoProps = true to spawn it automatically too.

From your own script (client side)
local id = exports['rtx_custom_shells']:EnterShell('rtx_shell_my_shell', vector3(x, y, z), {heading = 0.0, props = true})
    spawns the shell with doors and furniture, fades the screen and puts the player on the exit point
exports['rtx_custom_shells']:LeaveShell(id, vector3(x, y, z), heading)
    takes the player out and removes everything
local id = exports['rtx_custom_shells']:SpawnShell('rtx_shell_my_shell', vector3(x, y, z), {heading = 0.0, doors = true, props = true})

When your script spawns the shell object itself (entity = its handle, or the coords + heading it used):
local id = exports['rtx_custom_shells']:SpawnFurniture(entity)                 -> furniture placed in the shell creator
local id = exports['rtx_custom_shells']:SpawnDoors(entity)                     -> the inner dynamic doors
local id = exports['rtx_custom_shells']:SpawnBuiltIn(entity, {doors = true, props = true})
local id = exports['rtx_custom_shells']:SpawnFurniture('rtx_shell_my_shell', vector3(x, y, z), 90.0)          -> coords + heading
local id = exports['rtx_custom_shells']:SpawnBuiltIn('rtx_shell_my_shell', vector3(x, y, z), vector3(0.0, 0.0, 90.0))   -> coords + rotation
exports['rtx_custom_shells']:DespawnFurniture(id), DespawnDoors(id), DespawnBuiltIn(id)
The same from any resource, only with the shell entity (the shell creator finds this shell by its model):
local id = exports['rtx_shellcreator']:SpawnBuiltIn(entity)     -> doors and furniture
exports['rtx_shellcreator']:DespawnBuiltIn(id)
or with the shell name and coords: exports['rtx_shellcreator']:SpawnBuiltIn('rtx_shell_my_shell', vector3(x, y, z), heading)

exports['rtx_custom_shells']:DespawnShell(id)
exports['rtx_custom_shells']:GetPointCoords(id, 'exit')      -> coords, heading (also management, wardrobe, storage, cook, sinks, showers)
exports['rtx_custom_shells']:IsInsideShell()                 -> id or false
exports['rtx_custom_shells']:GetShellEntity(id), GetShellDoors(id), GetShellProps(id), GetShellData()
exports['rtx_custom_shells']:SetDoorOpen(id, door, true), SetDoorLocked(id, door, true)
Server side: exports['rtx_custom_shells']:GetShellData('rtx_shell_my_shell')

The front door is baked into the shell, use your housing exit there. The doors inside are dynamic GTA
doors and swing open when you walk through them. Garage doors open with E (Config.DoorKey) and are shared
with the players in the same routing bucket (Config.SyncDoors).
Elevators are real: call the cabin with E at the doors, inside choose the floor with the arrows or the mouse wheel and press E. The cabin moves
with you and the other players in the same routing bucket see it move too (Config.SyncElevators).
If doors do not swing, add this line to your server.cfg: setr game_enableDynamicDoorCreation "true"
