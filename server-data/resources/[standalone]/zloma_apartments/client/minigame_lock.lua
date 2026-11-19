-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- While a break-in minigame runs: no inventory (ox_inventory's invBusy /
-- invHotkeys), and optionally every game control blocked except push to talk.
-- Minigames read their own keys with IsDisabledControl*, so they still work.
-- Nested calls are counted, so the lock lifts only when the last one ends.
local depth, blockControls = 0, false

local function setInventory(locked)
    LocalPlayer.state:set('invBusy', locked, false)
    LocalPlayer.state:set('invHotkeys', not locked, false)
    if locked and GetResourceState('ox_inventory') == 'started' then
        pcall(function() exports.ox_inventory:closeInventory() end)
    end
end

-- controls = true: block every game control for the whole time (door lockpick).
function MinigameLockBegin(controls)
    depth = depth + 1
    if depth == 1 then setInventory(true) end
    if controls and not blockControls then
        blockControls = true
        CreateThread(function()
            while blockControls do
                DisableAllControlActions(0)
                DisableAllControlActions(1)
                DisableAllControlActions(2)
                EnableControlAction(0, 249, true) -- push to talk
                Wait(0)
            end
        end)
    end
end

function MinigameLockEnd(controls)
    if controls then blockControls = false end
    if depth == 0 then return end
    depth = depth - 1
    if depth == 0 then setInventory(false) end
end

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() and depth > 0 then setInventory(false) end
end)
