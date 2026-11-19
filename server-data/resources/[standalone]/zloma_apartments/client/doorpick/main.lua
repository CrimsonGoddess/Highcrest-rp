-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Starts the door lockpick (config_minigame.lua, game 'tr_lockpick').
-- DoorPickPlay({ coords, model, entity? }) -> true when the lock was picked.
-- The server side (server/doorpick.lua) holds the lock and checks every click.
local cfg = Config.DoorPick
local busy = false

local function findDoor(ctx)
    if ctx.entity and DoesEntityExist(ctx.entity) then return ctx.entity end
    local c, model = ctx.coords, ctx.model
    if not c or not model then return nil end
    local door = GetClosestObjectOfType(c.x + 0.0, c.y + 0.0, c.z + 0.0, 2.0, model, false, false, false)
    return door ~= 0 and door or nil
end

local function notify(key, kind) ClientBridge.notify(_L('dp_' .. key), kind or 'error') end

function DoorPickPlay(ctx)
    if busy or type(ctx) ~= 'table' then return false end
    local door = findDoor(ctx)
    if not door then
        notify('no_lock')
        return false
    end

    busy = true
    -- Only the lockpick's own keys (and push to talk) for the whole attempt, no inventory.
    MinigameLockBegin(true)
    local ok, result = pcall(function()
        local started, data = lib.callback.await('zloma_apartments:dp_start', false)
        if not started then
            notify(data or 'try_again')
            return nil
        end
        return DoorPick.run(door, data)
    end)
    busy = false
    MinigameLockEnd(true)

    if not ok then
        print(('^1[zloma_apartments]^0 door lockpick: %s'):format(result))
        return false
    end
    if result == 'opened' then return true end
    if result == 'failed' then
        notify('failed')
    elseif result == 'cancelled' then
        notify('cancelled', 'info')
    elseif result then
        notify(result)
    end
    return false
end

-- /apartment_doorpick_rig (devMode): prints the doorFits line for the door in front of you.
if cfg.devMode then
    RegisterCommand('apartment_doorpick_rig', function()
        local game = DoorPick.current
        local door = game and game.door
        if not door then
            local ped = PlayerPedId()
            local from = GetEntityCoords(ped)
            local to = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
            local ray = StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, 16, ped, 7)
            local _, hit, _, _, entity = GetShapeTestResult(ray)
            door = hit and entity ~= 0 and entity or nil
        end
        if not door then return print('[zloma_apartments] look at a door (or start picking it) first') end
        local line, source = DoorPick.fitLine(GetEntityModel(door))
        print(('[zloma_apartments] this door uses the %s fit. Pick it and move the lock with the arrows, Q / E (Shift: 1 mm).'):format(source))
        print('[zloma_apartments] Config.DoorPick.doorFits: ' .. line)
    end, false)
end
