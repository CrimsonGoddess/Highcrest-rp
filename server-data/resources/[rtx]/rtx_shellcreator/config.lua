-- ================================================================================================
--
--  RTX SHELL CREATOR
--
--  Build your own shells right in your server. Draw the rooms on a floor plan, add doors, windows,
--  stairs, kitchens, bathrooms and furniture, watch the shell build itself live in the game and walk
--  through it. When it is done, one click turns it into a ready resource: a shell (one model with its
--  collision and textures) or a real MLO, with the furniture and the points for your housing script.
--
--  WHO CAN USE IT
--
--    Only admins. Who is an admin is decided in IsAdminRTX in server/other.lua: an ACE, the groups
--    of your framework and single players by identifier, see section 3. Normal players only ever see
--    the shells you make live or permanent.
--
--  WHERE EVERYTHING ELSE LIVES
--
--    language/en.lua        every line of text, the interface included
--    client/other.lua       notifications, death check, HUD hooks, weather sync -- open source
--    server/other.lua       framework, admin checks, logs, hooks for your own scripts -- open source
--    custom/                your own wall, floor and ceiling textures (any PNG, up to 200)
--    data/                  every shell you build, written by the server
--
-- ================================================================================================

Config = {}


-- ================================================================================================
--  1. FRAMEWORK
--
--  Used only to know who is an admin (ESX groups, QBCore permissions, QBox ACE permissions) and to read a player's name.
-- ================================================================================================

Config.Framework = "qbox" -- "esx", "qbcore", "qbox" or "standalone"

Config.ESXFramework = {
	newversion = true, -- false only for an ESX old enough to hand the shared object out through an event
	getsharedobject = "esx:getSharedObject", -- The event above, used only when newversion is false
	resourcename = "es_extended" -- Name of your ESX resource folder
}

Config.QBCoreFrameworkResourceName = "qb-core" -- Name of your QBCore resource folder. QBox is found by itself as qbx_core, set Config.Framework = "qbox"


-- ================================================================================================
--  2. LANGUAGE & INTERFACE
-- ================================================================================================

Config.Language = "English" -- Language of the notifications and the whole interface. Every text lives in language/<code>.lua
-- English, German, Spanish, French, Czech, Polish, Portuguese, Italian, Russian, Turkish, Korean, Dutch, Chinese,
-- Romanian, Hungarian, Thai, Japanese, Arabic

Config.InterfaceColor = "#C8102E" -- The accent colour of the whole interface, in HEX

Config.Notifications = "rtx" -- Which notifications are used. "rtx" = the ones built into this interface.
-- Anything else and Notify() in client/other.lua is called, put your own notification system in there

Config.InterfaceScale = 1.0 -- Size of the whole interface. 0.85 for small screens, 1.15 for 4K


-- ================================================================================================
--  3. ADMINS
--
--  A player can open the shell creator when ANY of these is true. The check runs on the server every time.
--    - he has the ACE below. In server.cfg:  add_ace group.admin rtxshellcreator.admin allow
--    - his ESX group / QBCore permission / QBox ACE permission is in Config.Admins.groups
--    - one of his identifiers is in Config.Admins.identifiers
--  Change IsAdminRTX in server/other.lua for anything else (a job, a Discord role, your own system).
-- ================================================================================================

Config.AdminAce = "rtxshellcreator.admin" -- ACE that opens the shell creator

Config.Admins = {
	groups = {"admin", "superadmin", "god"}, -- ESX groups / QBCore permissions / QBox ACE permissions that open the shell creator
	identifiers = {} -- Single players, for example {"license:1234abcd..."}. Any identifier works: "license:...", "steam:...", "discord:...",
	-- the ESX identifier, the QBCore citizenid, or just the part after the colon
}


-- ================================================================================================
--  4. COMMANDS & KEYS
--
--  Keys are key mappings, so every admin can set or change them in Settings > Key Bindings > FiveM.
--  What is written here is only the default a new player gets. "" = no default key, each admin can still set his own.
-- ================================================================================================

Config.Commands = {
	open = "shellcreator", -- Opens the shell creator
	shelldebug = "shelldebug", -- Check of the shell you are in: how many parts are spawned, missing or still loading, and shows the invisible collisions for 20 seconds
	shelltest = "shelltest" -- Render check: takes a few pictures of the shell from where you stand and saves them for support
}

Config.Keys = {
	open = "" -- Opens the shell creator, for example "F6"
}


-- ================================================================================================
--  5. FREE CAMERA & GIZMO
--
--  The editor flies a free camera over the shell. Hold the right mouse button to look around and
--  fly with W A S D, SPACE up, SHIFT down. Furniture is moved and turned with the gizmo.
-- ================================================================================================

Config.Freecam = {
	speed = 8.0, -- Flying speed in metres per second at the middle of the speed slider
	fast = 4.0, -- Speed times this while CTRL is held
	sensitivity = 8.0, -- How fast the mouse turns the camera
	fov = 55.0, -- Field of view of the free camera
	maxdistance = 0.0 -- How far the camera may fly from where you opened it, in metres. 0 = no limit
}

Config.Gizmo = {
	movestep = 0.05, -- Snap of the move gizmo at step 1 of the slider, in metres
	rotatestep = 5.0 -- Snap of the rotate gizmo at step 1 of the slider, in degrees
}


-- ================================================================================================
--  6. SHELLS
--
--  Shells are built high in the sky (below), with the walls, floors, doors and windows of the
--  building kit in rtx_shellcreator_assets. "Finish" turns a shell into a ready resource:
--  a shell (ONE model with its collision and textures) or a real MLO placed where you stand, with
--  the furniture as a list for your housing script.
--
--  INSIDE A SHELL
--  Players inside a shell always get the time and the weather below, never rain or flickering
--  lights, and their own time and weather come back the moment they leave.
-- ================================================================================================

Config.Shells = {
	buildzone = vector3(1700.0, 4400.0, 1500.0), -- Where shells are built: high in the sky above the Grapeseed fields, out of everyone's way, and away from the build area of the RTX Toolkit, so both can run on one server.
	-- Shells hang in the air there with full daylight. Change it only if another script uses this place
	spacing = 80.0, -- Distance between two shells being built at the same time
	columns = 10, -- Shells per row in the build area before a new row starts
	budget = 800, -- Most furniture one shell may have. The checks say what to remove when it is more
	maxparts = 2600, -- Most building parts spawned at once while you build or walk a shell. The floor you work on comes first,
	-- then the floors next to it. For big shells add  increase_pool_size "Object" 2000  to your server.cfg and set 4000
	insidehour = 21, -- Hour inside every shell, 0 to 23
	insideweather = "EXTRASUNNY", -- Weather inside every shell. No rain, no snow, no thunder
	streamdistance = 120.0, -- A live shell is spawned for a player closer than this, in metres
	coeditors = true, -- true = other admins can build in the same shell at the same time
	sounds = true, -- true = soft sounds when you build, paint, place and remove things in the editor.
	-- Every builder can mute them with the speaker button in the editor top bar
	soundvolume = 0.6, -- Volume of those sounds, 0.0 to 1.0
	customtextures = { -- Your own wall, floor and ceiling textures. Put square PNG files (512 or 1024 px, one tile = 1 metre)
		-- into rtx_shellcreator/custom/ and restart the resource. Any file name with letters, numbers, _ and - works, up to 200 files.
		-- They show up in the paint palette under "Own textures", one shell can use 6 of them at the same time.
		-- The editor shows the file name. A nicer name can be set here, by file name without .png:
		-- brick_mine = "My red brick",
		-- ["tiles-blue"] = "Blue tiles"
	}
}

Config.HousingExport = "lua" -- Which housing script the "Export" button shows first.
-- "rtx_housing", "ps-housing", "vms_housing", "qb-interior", "esx_property", "loaf_housing", "nolag_properties", "bcs_housing",
-- "RxHousing", "lua" (a plain Lua table) or "json". All of them are always in the export window


-- ================================================================================================
--  7. INSTALLING RESOURCES
--
--  A finished shell is installed on this server as a ready resource with one click.
--  This is where those resources go.
-- ================================================================================================

Config.Install = {
	folder = "[rtx]", -- Folder inside resources/ where the shell creator installs. It is made when it is missing.
	-- Only resources the shell creator made itself are ever replaced there, never anything else of yours
	autostart = true, -- true = an installed resource is started at once (refresh + ensure). Walk mode needs the same. In server.cfg:
	-- add_ace resource.rtx_shellcreator command.refresh allow
	-- add_ace resource.rtx_shellcreator command.ensure allow
	-- add_ace resource.rtx_shellcreator command.start allow
	-- add_ace resource.rtx_shellcreator command.stop allow
	maxupload = 400, -- Largest resource that can be installed at once, in MB
	collections = { -- With "Add to a collection" ticked, finished shells and MLOs go into one shared resource each instead of one resource per shell
		shells = "rtx_custom_shells", -- Name of the collection resource for shells
		mlos = "rtx_custom_mlos" -- Name of the collection resource for MLOs
	}
}


-- ================================================================================================
--  8. COMMUNITY SHELLS
--
--  The "Publish" button sends a shell (its share code, a picture and its name) to the RTX community
--  shell library. RTX Development checks it first, then anyone can copy it into their shell creator.
-- ================================================================================================

Config.Community = {
	enabled = true, -- false = the Publish button is switched off
	server = "" -- Server name shown with your shells. "" = sv_projectName or sv_hostname from your server.cfg
}
