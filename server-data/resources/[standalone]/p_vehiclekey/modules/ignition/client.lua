-- Ignition: open the car's key slot, keep the engine tied to the key being in it.
local Config = require 'config.shared'

local Ignition = {
    enabled = Config.Ignition and Config.Ignition.enabled or false,
    hotwired = {}, -- vehicles started by hotwiring (no key needed until the engine stops)
}

if not Ignition.enabled then return Ignition end

function Ignition:hasKey(vehicle)
    return Entity(vehicle).state.ignitionKey == true or self.hotwired[vehicle] == true
end

-- key pulled out while driving: engine cuts (unless hotwired)
AddStateBagChangeHandler('ignitionKey', nil, function(bagName, _, value)
    local vehicle = GetEntityFromStateBagName(bagName)

    if vehicle == 0 or vehicle ~= cache.vehicle or cache.seat ~= -1 then return end
    if value or Ignition.hotwired[vehicle] then return end

    SetVehicleEngineOn(vehicle, false, false, true)
end)

-- driver seat gives you this car's ignition slot in your inventory; leaving clears it
lib.onCache('seat', function()
    -- give the server a moment to see the new seat before it checks
    SetTimeout(750, function() TriggerServerEvent('p_vehiclekeys:syncIgnition') end)
end)

return Ignition
