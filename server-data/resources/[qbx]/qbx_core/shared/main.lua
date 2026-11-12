local qbShared = {}
qbShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
qbShared.Locations = require 'shared.locations'
qbShared.Vehicles = require 'shared.vehicles'
-- Highcrest: add-on cars (Imports & Customs dealership) are kept in their own file.
for model, vehicle in pairs(require 'shared.vehicles_imports') do qbShared.Vehicles[model] = vehicle end
qbShared.Weapons = require 'shared.weapons'

---@type table<number, Vehicle>
qbShared.VehicleHashes = {}

for _, v in pairs(qbShared.Vehicles) do
    qbShared.VehicleHashes[v.hash] = v
end

return qbShared
