--------------------------------
--------------------------------
--- IN HERE YOU WILL FIND EDITS
--------------------------------
--------------------------------



-- Helps reduce ped spawning issues
--[[CreateThread(function()
    while true do
        SetPedDensityMultiplierThisFrame(0.5)
        SetScenarioPedDensityMultiplierThisFrame(0.5, 0.5)
        SetVehicleDensityMultiplierThisFrame(0.5)
        SetRandomVehicleDensityMultiplierThisFrame(0.6)
        SetParkedVehicleDensityMultiplierThisFrame(0.6)
        Wait(0)
    end
end)


-- Disable Spam Punch
--[[Citizen.CreateThread(function()
   while true do
   Citizen.Wait(0)
   DisableControlAction(1, 140, true)
   if not IsPlayerTargettingAnything(PlayerId()) then
   DisableControlAction(1, 141, true)
   DisableControlAction(1, 142, true)
   end
  end
end)]]--


--[[Citizen.CreateThread(function()
while true do
Citizen.Wait(0)
local playerPed = GetPlayerPed(-1)
local playerLocalisation = GetEntityCoords(playerPed)
ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 400.0)
end
end)--]]


-- Helmet armor gone
SetPedConfigFlag(PlayerPedId(), 438, true)