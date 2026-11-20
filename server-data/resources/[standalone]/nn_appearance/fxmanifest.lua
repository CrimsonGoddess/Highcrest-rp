fx_version "cerulean"
game "gta5"

-- ─────────────────────────────────────────────────────────────────────────────
--  NN Appearance — a custom-UI redesign of illenium-appearance.
--
--  This resource is a derivative work. The Lua / FiveM runtime is
--  "illenium-appearance" by iLLeniumStudios, originally created by snakewiz;
--  only the NUI (the React interface) was rebuilt, by NANO SCRIPTS.
--  Full credit to the original authors.
--
--    Original : https://github.com/iLLeniumStudios/illenium-appearance
--    License  : MIT — Copyright (c) 2021 snakewiz (retained in ./LICENSE)
-- ─────────────────────────────────────────────────────────────────────────────

author "NANO SCRIPTS — UI redesign of illenium-appearance (snakewiz & iLLeniumStudios)"
description "Custom-UI redesign of illenium-appearance, a flexible player customization script for FiveM. Original by iLLeniumStudios (snakewiz), MIT licensed."
repository "https://github.com/SinapsDev/nn_appearance"
version "1.2.3"

provide "illenium-appearance"
nn_uipack "appearance"

lua54 "yes"

escrow_ignore {
  'shared/**/*',
  'locales/*',
  'locales/**/*'
}

-- community_bridge is an OPTIONAL runtime integration (only the clothing-as-items
-- feature uses it), NOT a hard dependency. Declaring it here would deadlock load
-- order: this resource sets `provide "illenium-appearance"`, and community_bridge's
-- clothing module targets illenium-appearance, so a hard dependency creates a
-- cycle. server/items/items.lua waits for community_bridge to start at runtime
-- instead, so no manifest ordering is needed. Install community_bridge to use
-- Config.ClothingItems; otherwise it's safely skipped.

client_scripts {
  "uipack/cl_kit.lua",
  "game/constants.lua",
  "game/util.lua",
  "game/customization.lua",
  "game/nui.lua",
  "client/outfits.lua",
  "client/common.lua",
  "client/zones.lua",
  "client/framework/framework.lua",
  "client/framework/qb/compatibility.lua",
  "client/framework/qb/main.lua",
  "client/framework/qb/migrate.lua",
  "client/framework/esx/compatibility.lua",
  "client/framework/esx/main.lua",
  "client/framework/ox/main.lua",
  "client/target/target.lua",
  "client/target/qb.lua",
  "client/target/ox.lua",
  "client/management/management.lua",
  "client/management/common.lua",
  "client/management/qb.lua",
  "client/management/qbx.lua",
  "client/management/esx.lua",
  "client/radial/radial.lua",
  "client/radial/qb.lua",
  "client/radial/ox.lua",
  "client/stats.lua",
  "client/defaults.lua",
  "client/blips.lua",
  "client/props.lua",
  "client/client.lua",
  "client/items/items.lua",
}

server_scripts {
  "uipack/sv_kit.lua",
  "@oxmysql/lib/MySQL.lua",
  "server/database/database.lua",
  "server/database/jobgrades.lua",
  "server/database/managementoutfits.lua",
  "server/database/playeroutfitcodes.lua",
  "server/database/playeroutfits.lua",
  "server/database/players.lua",
  "server/database/playerskins.lua",
  "server/database/users.lua",
  "server/framework/qb/main.lua",
  "server/framework/qb/migrate.lua",
  "server/framework/esx/main.lua",
  "server/framework/esx/migrate.lua",
  "server/framework/esx/callbacks.lua",
  "server/framework/esx/management.lua",
  "server/framework/ox/main.lua",
  "server/util.lua",
  "server/server.lua",
  "server/permissions.lua",
  "server/items/items.lua",
  "server/updater.lua",
  "uipack/sv_hooks.lua"
}

shared_scripts {
  "shared/config.lua",
  "shared/blacklist.lua",
  "shared/peds.lua",
  "shared/tattoos.lua",
  "shared/theme.lua",
  "shared/framework/framework.lua",
  "shared/framework/esx/util.lua",
  -- locales.lua sets up the table the language files write into, so it has to be
  -- listed before the glob. The glob then loads every language file in locales/,
  -- which is why a new one only has to be dropped into the folder.
  "locales/locales.lua",
  "locales/*.lua",
  "@ox_lib/init.lua",
  "uipack/schema.lua"
}

files {
  "web/dist/index.html",
  "web/dist/assets/*",
  "web/dist/categories/*", -- clothing category tile art (served to the NUI via cfx-nui)
  "branding/*", -- sidebar logo(s); served to the NUI via cfx-nui, never touched by the web build
  "shots/**/*" -- item thumbnail images, served to the NUI via cfx-nui
}

ui_page "web/dist/index.html"

dependency '/assetpacks'