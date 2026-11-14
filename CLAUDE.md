# Highcrest RP: notes for Claude

Highcrest RP is a semi-serious FiveM roleplay server on **Qbox** with the ox stack (ox_lib, ox_inventory, oxmysql).
The server owner and the lead dev (Rusty) both work in this repo, each with their own Claude.
The project direction is in `docs/HIGHCREST_BRIEF.md`.

## Where things live

- **GitHub**: https://github.com/CrimsonGoddess/Highcrest-rp, branch `main`. This is the source of truth.
- **Live server**: Nodecraft, run with txAdmin. Over SFTP:
  - `server-data/` here is `/servers/highcrest/` on the server, one to one.
  - Server logs: `/servers/default/logs/fxserver.log` (times are in UTC).
- **SFTP login**: `deploy/sftp.txt`, with lines `host=`, `port=`, `user=` and `password=`. It's gitignored, and each person uses their own login.
- **Never read, print or upload** `server-data/secrets.cfg` (license key, database password).
- Load order is in `server-data/server.cfg`. Admin rights are in `server-data/permissions.cfg`.

## Getting changes onto the live server

1. Commit and push to GitHub first. Only what's on GitHub `main` goes to the server.
2. Run `tools\pull-and-upload.ps1 -Preview`, read the list, then run `tools\pull-and-upload.ps1`.
   - It pulls, then uploads only the files that changed since the last upload. The server records the last uploaded commit in `/servers/highcrest/.deployed-commit`, so it works no matter who uploaded last.
   - It never deletes anything. When git moves a resource (for example into `[disabled]`), it moves it on the server too. Any other removed files are listed for a person to decide on.
   - It ends by saying what to restart.
3. Restart: `ensure <resource>` in the txAdmin live console. If a `.cfg` file changed, do a full restart. Players must fully reopen FiveM to get new client files.

Never restart the server while someone is in the middle of testing. Ask first.

Other upload tool: `tools\deploy-nodecraft.ps1`:
- `-Files` takes paths relative to `server-data`. With `-Preview`, it downloads the server's copies into `deploy\remote-check` so you can compare.
- `-Folders` syncs whole folders by size or date. Use it only for things that aren't in git.

### Never do these on the server
- **Never sync with delete**, and never "mirror" a folder. Many things live only on the server:
  - `[clothing]`, `[cars]` (the HighCrest_Imports pack, its own repo), `nn_appearance` (only its `shared/config.lua` is in git), the RFC maps and the `[rtx]` resources
  - files the server writes itself:
    - `highcrest_handling/handling.meta` and `entries.json`
    - `Renewed-Banking/atm_placements.json`
    - `rtx_shellcreator/data/` and `rtx_custom_*`
    - `uz_AutoShot/shots/`, `yarn.lock` and `.yarn.installed`
- **Never upload local copies** of those server-written files.
- Before overwriting a file on the server that isn't covered by the script, compare the server's copy with the old git version. Someone may have changed it live.

## Rules for the server

- **No map blips for anything illegal**: dealers, fences, crime shops, money wash, heist or mission starts, crafting benches. When installing crime scripts, turn those blips off. Temporary blips for a player's active job are fine.
- **Never trust the client** with money, items or permissions. Rewards are given server-side and checked there.
- **`dependencies` must only list resources that clients download.** A server-only resource listed there stops every client from loading it, so nobody can join.
- **New SQL tables use `utf8mb4_unicode_ci`.** The database defaults to `utf8mb4_uca1400_ai_ci`, and joins with `players` fail. Script SQL goes in `[custom]/highcrest_sql`, which runs each listed file once.
- **Replaced resources move to `resources/[disabled]`** (use `git mv`; the upload script moves them on the server too). Don't delete them.
- **Bought scripts go in `resources/[scripts]`.** Check them for `.fxap` and for anti-leak traps before installing. The `Scripts/doors_creator` copy has sabotage traps; never install it.
- **Check items when changing `ox_inventory/data/items.lua`.** Compare item names against the old version: dropping items such as money, markedbills or lockpick breaks other scripts.
- **NUI pages built with Mantine, or any dark color-scheme**, need `:root, html, body, #root { color-scheme: normal !important; background: transparent !important; }`. Without it, FiveM paints a solid grey screen over the game.
- **Client `RegisterCommand(..., true)` is blocked in production mode**, even for admins. Register the command unrestricted and check the ACE on the server.
- **`sete_le` (traffic mod) crashes GTA** (`sp_manifest.ymt`, ERR_STR_PACK_2). It stays in `[disabled]`.
- **Clothing packs**: don't remove or reorder pieces in a built pack, because saved outfits shift. Use a blank placeholder instead.

## Working with the team

- When you ask someone to go somewhere in game, give a copy-paste `/tp x y z` line with z at or just above the ground.
- **Discord changelog**: add player-facing entries to `docs/changelog-pending.md`.
  - Use short "Added / Changed / Fixed" bullets.
  - Say "Custom" for anything we built ourselves, and name the script for bought ones.
  - Show the text and wait for an explicit "post it" before running `tools\post-changelog.ps1 -File docs\changelog-pending.md`.
  - After posting, move the entries to `docs/CHANGELOG.md` and reset the pending file.
  - The webhook lives in `deploy\discord-changelog.txt`, which is not in git.
- Two Claudes work in this repo: run `git pull` before starting, and push when done, so neither overwrites the other.
