local QBCore = exports['qb-core']:GetCoreObject()


local heistStarted = false
local isIplLoaded = false
local c4Triggered = false

Trolleys = {
	{ item = "cash", coords = vector4(5.061, -680.50, 15.13,0), trolleyCoords = vector3(6.29, -674.26, 16.13), Heading = 159.82, isMoney = true, quantity = 0, looted = false },
	{ item = "cash", coords = vector4(6.32, -674.99, 15.13,0), trolleyCoords = vector3(6.29, -674.26, 16.13), Heading = 180.25, isMoney = true, quantity = 0, looted = false },
	{ item = "cash", coords = vector4(-6.13, -676.20, 15.13,0), trolleyCoords = vector3(-2.15, -668.63, 16.13), Heading = 339.82, isMoney = true, quantity = 0, looted = false },
	{ item = "cash", coords = vector4(-3.97, -671.06, 15.13,0), trolleyCoords = vector3(-2.15, -668.63, 16.13), Heading = 159.82, isMoney = true, quantity = 0, looted = false },
	{ item = "cash", coords = vector4(-0.89, -658.78, 15.13,0), trolleyCoords = vector3(-0.89, -658.78, 15.13), Heading = 159.82, isMoney = true, quantity = 0, looted = false },
	{ item = "cash", coords = vector4(10.55, -663.32, 15.13,0), trolleyCoords = vector3(-0.89, -658.78, 15.13), Heading = 159.82, isMoney = true, quantity = 0, looted = false },
	
}

CellGates = {
	{ coords = vector4(-1.25, -671.9, 16.13, 66.04), requiredItem = Config.ThermiteItem, objCoords = vector3(-1.38, -672.57, 16.13), pedHeading = 67.61,	ptxCoords = vector3(-1.52, -671.52, 16.13), doorName = "union-10"  },
	{ coords = vector4(3.59, -673.74, 16.13, 238.31), requiredItem = Config.ThermiteItem, objCoords = vector3(3.71, -674.36, 16.13), pedHeading = 251.93, ptxCoords = vector3(3.73, -673.35, 16.13), doorName = "union-11"  },
	{ coords = vector4(2.0, -679.08, 16.16, 331.09), requiredItem = Config.ThermiteItem, objCoords = vector3(1.67, -679.91, 16.13), pedHeading = 251.93, ptxCoords = vector3(1.73, -678.98, 15.98), doorName = "union-12"  },
	{ coords = vector4(-2.94, -677.48, 16.13, 65.0), requiredItem = Config.ThermiteItem, objCoords = vector3(-3.43, -678.14, 16.13), pedHeading = 67.61, ptxCoords = vector3(-3.4, -677.1, 16.13), doorName = "union-13"  },
	{ coords = vector4(-0.38, -662.94, 16.13, 150.41), requiredItem = Config.ThermiteItem, objCoords = vector3(-0.19, -662.54, 16.13), pedHeading =150.41, ptxCoords = vector3(-0.19, -661.47, 16.13), doorName = "union-14"  },
	{ coords = vector4(9.27, -666.09, 16.13, 65.0), requiredItem = Config.ThermiteItem, objCoords = vector3(9.16, -665.95, 16.13), pedHeading = 150.41, ptxCoords = vector3(9.13, -664.79, 16.22), doorName = "union-15"  },
}

BlowDoors = {
	{ coords = vector4(8.21, -661.95, 16.13, 245.0)},
	{ coords = vector4(2.58, -661.65, 16.13, 65.0)},

}

CreateThread(function()
	for k, v in pairs(Trolleys) do
		exports['qtarget']:AddBoxZone("MVUNION_TROLLEYS_" .. k, v.coords, 0.85, 0.85, {
		  name = "MVUNION_TROLLEYS_" .. k,
		  debugPoly = false,
		  minZ = v.coords.z - 1.99,
		  maxZ = v.coords.z + 0.99,
		}, {
		  options = {
			{
			  icon = "fas fa-dollar",
			  label = Config.Lang["rob"],
			  action = function()
				if v.isMoney then
					if not v.looted then
						TriggerEvent("union:client:loottrolley", v.Heading, v.coords, k)
					else
						QBCore.Functions.Notify(Config.Lang["robbed"], "error")
					end

				end
			  end
			},
		  },
		  distance = 1.0
		})
	end

	for k, v in pairs(BlowDoors) do
		exports['qtarget']:AddBoxZone("madblowdoor" .. k, v.coords, 1, 1, {
		  name = "madblowdoor" .. k,
		  debugPoly = false,
		  minZ = v.coords.z - 1.99,
		  maxZ = v.coords.z + 0.99,
		}, {
		  options = {
			{
			  icon = "fas fa-bomb",
			  label = Config.Lang["explode"],
			  action = function()
				local result = QBCore.Functions.HasItem(Config.C4Item)
				if result then
					ArrombarCells(v.coords)
				else
					QBCore.Functions.Notify(Config.Lang["noitem"])
				end
			  end
			},
		  },
		  distance = 1.0
		})
	end

	for k, v in pairs(CellGates) do
		exports['qtarget']:AddBoxZone("MVUNION_CELLGATES_" .. k, v.coords, 1.50, 1.50, {
		  name = "MVUNION_CELLGATES_" .. k,
		  debugPoly = false,
		  minZ = v.coords.z - 1.99,
		  maxZ = v.coords.z + 0.99,
		}, {
		  options = {
			{
			  icon = "fas fa-bomb",
			  label = Config.Lang["usethermite"],
			--   item = v.requiredItem,
			  action = function()
				if QBCore.Functions.HasItem(v.requiredItem) then
					ArrombarPorta(vector4(v.objCoords, v.pedHeading), v.ptxCoords, v.doorName)
				else
					QBCore.Functions.Notify(Config.Lang["noitem"], "error")
				end
			  end
			},
		  },
		  distance = 1.0
		})
	end


	if Config.UseVaultDoor then
		exports['qtarget']:AddCircleZone("vault", vector3(-3.36, -685.14, 16.13), 1.5, {
			name ="vault",
			useZ = true,
			--debugPoly=true
			}, {
				options = {
					{
						event = "union:client:c4vault",
						icon = "fas fa-bomb",
						label = Config.Lang["usec4"],
					},
				},
				job = {"all"},
				distance = 2.1
		}) 

			
		exports['qtarget']:AddCircleZone("elevator", vector3(2.17, -704.57, 16.13), 1.5, {
			name ="elevator",
			useZ = true,
			--debugPoly=true
			}, {
				options = {
					{
						event = "union:client:elevator",
						icon = "fas fa-arrow-up",
						label = Config.Lang["useelev"],
					},
				},
				job = {"all"},
				distance = 2.1
		}) 
	end


end)

RegisterNetEvent('union:client:elevator')
AddEventHandler('union:client:elevator', function()
    local ped = PlayerPedId()
	QBCore.Functions.Progressbar('Changeme', Config.Lang["elev"], 8000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true
		}, {
		animDict = "anim@apt_trans@elevator",
        anim = "elev_1",
        flags = 16,
		}, {}, {}, function()
			
			DoScreenFadeOut(500)
			Wait(1000)
			SetEntityCoords(ped, vector3(10.57, -670.93, 33.45))
			SetEntityHeading(ped, 2.11)
			Wait(1000)
			DoScreenFadeIn(600)
		end, function()
			-- This code runs if the progress bar gets cancelled
	end)
	
end)

RegisterNetEvent('union:client:syncloot')
AddEventHandler('union:client:syncloot', function(i)
    Trolleys[i].looted = true
end)


function ArrombarPorta(thermiteCoords, particleCoords, door)

	TriggerServerEvent("union:server:removethermite")
	RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end
    local ped = PlayerPedId()
	SetEntityHeading(ped, thermiteCoords.w)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
    local bagscene = NetworkCreateSynchronisedScene(vector3(thermiteCoords.x, thermiteCoords.y, thermiteCoords.z), rotx, roty, rotz + 1.1, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), vector3(thermiteCoords.x, thermiteCoords.y, thermiteCoords.z),  true,  true, false)
    SetEntityCollision(bag, false, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.2, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(bagscene)
	QBCore.Functions.Progressbar('Changeme', Config.Lang["thermite"], 3500, false, false, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true
		}, {}, {}, {}, function()
			-- This code runs if the progress bar completes successfully
		end, function()
			-- This code runs if the progress bar gets cancelled
	end)
    Citizen.Wait(1500)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x-1, y, z + 0.3,  true,  true, true)
    SetEntityCollision(bomba, false, true)
    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    Citizen.Wait(2000)
    DeleteObject(bag)
    DetachEntity(bomba, 1, 1)
    FreezeEntityPosition(bomba, true)
    TriggerServerEvent("union:server:particleserver", particleCoords)
    NetworkStopSynchronisedScene(bagscene)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
    Citizen.Wait(5000)
    ClearPedTasks(ped)
    DeleteObject(bomba)
    TriggerServerEvent('mad-union:server:door', door, false) -- Highcrest: ox_doorlock
end

function ArrombarVault()
	TriggerServerEvent("union:server:removec4")
	
	RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end
    local ped = PlayerPedId()
    SetEntityHeading(ped, 157.52)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
    local bagscene = NetworkCreateSynchronisedScene(-3.12, -684.92, 16.13, rotx, roty, rotz + 1.1, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), -3.12, -684.92, 16.13,  true,  true, false)
    SetEntityCollision(bag, false, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.2, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(bagscene)
	QBCore.Functions.Progressbar('Changeme', Config.Lang["c4"], 3200, false, false, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true
		}, {}, {}, {}, function()
			-- This code runs if the progress bar completes successfully
		end, function()
			-- This code runs if the progress bar gets cancelled
	end)
    Citizen.Wait(1500)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local bomba = CreateObject(GetHashKey("prop_c4_final_green"), x, y, z + 0.3,  true,  true, true)
    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 5, 5, 5, 0, 0, 0, true, true, false, true, 1, true)
    Wait(1500)
    DeleteObject(bomba)
    local bomba = CreateObject(GetHashKey("prop_c4_final_green"), -3.12, -684.92, 16.13,  true,  true, true)
	SetEntityHeading(bomba,157.52)
    SetEntityCollision(bomba, false, true)
    DeleteEntity(bag)
    Citizen.Wait(2000)
    DetachEntity(bomba, 1, 1)
    FreezeEntityPosition(bomba, true)
    NetworkStopSynchronisedScene(bagscene)
    Citizen.Wait(10000)
	TriggerServerEvent('mad-union:server:door', 'union-vault', false) -- Highcrest: ox_doorlock
	Wait(100)
    TriggerServerEvent("union:server:c4sync")
    ClearPedTasks(ped)
    DeleteObject(bomba)
	SpawnGuards() 
end

RegisterNetEvent('union:client:c4sync')
AddEventHandler('union:client:c4sync', function()
	AddExplosion(-2.84, -684.21, 16.13+0.7, 32, 1500.0, true, false, 2.0)
end)

RegisterNetEvent('union:client:c4syncCells')
AddEventHandler('union:client:c4syncCells', function(coords)
	AddExplosion(coords.x, coords.y, coords.z, 2, 1500.0, true, false, 2.0)
end)

RegisterNetEvent('union:client:c4vault')
AddEventHandler('union:client:c4vault', function()
local result = QBCore.Functions.HasItem(Config.C4Item)

	if result then
		ArrombarVault()
	else
		QBCore.Functions.Notify(Config.Lang["noitem"], "error")
	end

end)




RegisterNetEvent("union:client:ptfxparticle")
AddEventHandler("union:client:ptfxparticle", function(particleCoords)
    local ptfx

    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(1)
    end
        ptfx = particleCoords
    SetPtfxAssetNextCall("scr_ornate_heist")
    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfx, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    Citizen.Wait(4000)
    
    StopParticleFxLooped(effect, 0)
end)


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)



CreateThread(function()
	RequestModel(Config.PedModel)
	  while not HasModelLoaded(Config.PedModel) do
	  Wait(1)
	end
	  unionguy = CreatePed(2, Config.PedModel, Config.PedLoc.x, Config.PedLoc.y, Config.PedLoc.z, Config.PedLoc.w, false, false) -- change here the cords for the ped 
	  SetPedFleeAttributes(unionguy, 0, 0)
	  SetPedDiesWhenInjured(unionguy, false)
	  TaskStartScenarioInPlace(unionguy, Config.PedScenarioAnim, 0, true)
	  SetPedKeepTask(unionguy, true)
	  SetBlockingOfNonTemporaryEvents(unionguy, true)
	  SetEntityInvincible(unionguy, true)
	  FreezeEntityPosition(unionguy, true)
  
	  Wait(100)
  
	  exports['qtarget']:AddTargetEntity(unionguy, {
        options = {
            { 
                type = "client",
                event = "union:client:start",
                icon = "fas fa-user-secret",
                label = Config.Lang["start"],
                 
            },
        
          },
          distance = 2.0 
      })

end)

RegisterNetEvent('union:client:start')  --policia alterar depois
AddEventHandler('union:client:start', function()

	QBCore.Functions.TriggerCallback("mv-union:server:coolc",function(isCooldown)
		if not isCooldown then
			QBCore.Functions.TriggerCallback('union:server:getCops', function(cops)
				if cops >= Config.PoliceCount then
					TriggerServerEvent("mv-union:server:coolout")
					QBCore.Functions.Notify(Config.Lang["willloc"], "success") 
					Wait(15000)
					QBCore.Functions.Notify(Config.Lang["loc"]) 
					SetNewWaypoint(16.61, -639.65)
					TriggerEvent("mad-union:client:start")
					
				else
					QBCore.Functions.Notify(Config.Lang["nocops"], "error")    
				end
			end)
		else
			QBCore.Functions.Notify(Config.Lang["cooldown"], "error")
		end
	end)

	
end)

-- RegisterCommand("teste", function()
--     TriggerEvent("union:client:start")
-- end)

RegisterNetEvent('mad-union:client:start')
AddEventHandler('mad-union:client:start', function()
	

	exports['qtarget']:AddBoxZone("plant_bomb" , vector3(6.69, -655.61, 16.1), 3, 3, {
		name = "plant_bomb",
		debugPoly = false,
		minZ = 16.1 - 1.99,
		maxZ = 16.1 + 0.99,
	  }, {
		options = {
		  {
			icon = "fas fa-bomb",
			label = Config.Lang["usec4"],
			action = function()
				
					local result2 = QBCore.Functions.HasItem(Config.C4Item)
					if result2 then
						ArrombarParede()
						exports['qtarget']:RemoveZone("plant_bomb")
					else
						QBCore.Functions.Notify(Config.Lang["noitem"])
					end

				
			end
		  },
		},
		distance = 1.5
	  })

			
end)

function ArrombarParede()
	
	TriggerServerEvent("union:server:removec4")
	
	RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end
    local ped = PlayerPedId()

    SetEntityHeading(ped, 157.52)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
    local bagscene = NetworkCreateSynchronisedScene(7.25, -656.12, 16.1, rotx, roty, rotz + 1.1, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), 7.25, -656.12, 16.1,  true,  true, false)

    SetEntityCollision(bag, false, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.2, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    
    NetworkStartSynchronisedScene(bagscene)
	QBCore.Functions.Progressbar('Changeme', Config.Lang["c4"], 3200, false, false, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true
		}, {}, {}, {}, function()
			-- This code runs if the progress bar completes successfully
		end, function()
			-- This code runs if the progress bar gets cancelled
	end)
    Citizen.Wait(1500)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local bomba = CreateObject(GetHashKey("prop_c4_final_green"), x, y, z + 0.3,  true,  true, true)
    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 5, 5, 5, 0, 0, 0, true, true, false, true, 1, true)
    
    Wait(1500)
    
    DeleteObject(bomba)

    local bomba = CreateObject(GetHashKey("prop_c4_final_green"), 7.25, -656.12, 16.1,  true,  true, true)
	SetEntityHeading(bomba,157.52)
    SetEntityCollision(bomba, false, true)
    DeleteEntity(bag)
    Citizen.Wait(2000)
    DetachEntity(bomba, 1, 1)
    FreezeEntityPosition(bomba, true)
    NetworkStopSynchronisedScene(bagscene)
    Citizen.Wait(10000)	
    ClearPedTasks(ped)
    DeleteObject(bomba)

	AlertCops()
	TriggerServerEvent("union:server:c4")
	SpawnMoney()
	RemoveBlip(blip)
	
   
    
end

CreateThread(function()
	while true do
		if heistStarted then
			Wait(10)
			local handle = GetRayfireMapObject(7.25, -656.98, 17.14, 50.0, "des_finale_tunnel")
			local handle2 = GetRayfireMapObject(7.25, -656.98, 17.14, 50.0, "des_finale_vault")
			if #(GetEntityCoords(PlayerPedId()) - vector3(2.69689322, -667.0166, 16.1306286)) < 80 then
				if not isIplLoaded and c4Triggered then
					isIplLoaded = true
					
					local handle = GetRayfireMapObject(7.25, -656.98, 17.14, 50.0, "des_finale_tunnel")
					local handle2 = GetRayfireMapObject(7.25, -656.98, 17.14, 50.0, "des_finale_vault")
					SetStateOfRayfireMapObject(handle, 9)
					Wait(100)
					SetStateOfRayfireMapObject(handle2, 9)
				end
			else
				isIplLoaded = false
			end
			
		end
		Wait(1000)
	end
end)



RegisterNetEvent('c4:sync')
AddEventHandler('c4:sync', function(data)
	
	AddExplosion(7.32, -655.9, 16.09, 2, 1500.0, true, false, 2.0)
	heistStarted = true 
	local handle = GetRayfireMapObject(7.25, -656.98, 17.14, 50.0, "des_finale_tunnel")
	local handle2 = GetRayfireMapObject(7.25, -656.98, 17.14, 50.0, "des_finale_vault")
	Wait(100)
	SetStateOfRayfireMapObject(handle, 4)
	Wait(100)
	SetStateOfRayfireMapObject(handle2, 4)
	Wait(100)	
	SetStateOfRayfireMapObject(handle, 5)
	Wait(100)
	SetStateOfRayfireMapObject(handle2, 5)
	Wait(100)	
	SetStateOfRayfireMapObject(handle, 6)
	Wait(100) 
	SetStateOfRayfireMapObject(handle2, 6)
	Wait(100)
	SetStateOfRayfireMapObject(handle, 7)
	Wait(100)
	SetStateOfRayfireMapObject(handle2, 7)
	Wait(100)
	SetStateOfRayfireMapObject(handle, 8)
	Wait(100)
	SetStateOfRayfireMapObject(handle2, 8)
	Wait(100)
	
		
	Wait(11000)
		
	c4Triggered = true
	
	TriggerEvent("spawn:sync")
	
end)

RegisterNetEvent('spawn:sync')
AddEventHandler('spawn:sync', function(data)
	
	while not PrepareAlarm("BIG_SCORE_HEIST_VAULT_ALARMS") do
		Citizen.Wait(100)
	end
	StartAlarm("BIG_SCORE_HEIST_VAULT_ALARMS", 1)

	Wait(120000)

	StopAlarm("BIG_SCORE_HEIST_VAULT_ALARMS", -1)
										
	
end)


function SpawnMoney()
	RequestModel("hei_prop_hei_cash_trolly_01")
	Citizen.Wait(100)	
	Money1 = CreateObject(269934519, 5.061, -680.50, 15.13, 1, 0, 0) 
	Money2 = CreateObject(269934519, 6.32, -674.99, 15.13, 1, 0, 0) 	
	SetEntityHeading(Money2, 0.67)
	Money3 = CreateObject(269934519, -6.13, -676.20, 15.13, 1, 0, 0) 
	SetEntityHeading(Money3, 180.67)
	Money4 = CreateObject(269934519, -0.89, -658.78, 15.13, 1, 0, 0)
	Money5 = CreateObject(269934519, -3.97, -671.06, 15.13, 1, 0, 0)
	Money6 = CreateObject(269934519, 10.55, -663.32, 15.13, 1, 0, 0)
end



RegisterNetEvent('union:client:loottrolley', function(heading, coords, i)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

	local closestObject = QBCore.Functions.GetClosestObject(pos) 
                    LocalPlayer.state:set('inv_busy', true, true) -- Busy
                    TriggerServerEvent("union:server:syncloot", i)
                   
                    
                    local animDict = 'anim@heists@ornate_bank@grab_cash'

                    if GetEntityModel(closestObject) == 269934519 then
                        grabModel = 'hei_prop_heist_cash_pile'
                    elseif trollyModel == 2007413986 then
                        grabModel = 'ch_prop_gold_bar_01a'
                    end

                    RequestAnimDict(animDict)
                    RequestModel('hei_p_m_bag_var22_arm_s')

					while not HasAnimDictLoaded(animDict) and not HasModelLoaded("hei_p_m_bag_var22_arm_s") do
						Citizen.Wait(50)
					end

                    

                    if IsEntityPlayingAnim(closestObject, animDict, "cart_cash_dissapear", 3) then
                        return
                    end
					SetEntityHeading(ped, heading)
					Wait(100)
                    bag = CreateObject(GetHashKey('hei_p_m_bag_var22_arm_s'), pos, true, false, false)


                    scene1 = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z + 0.48, GetEntityRotation(closestObject), 2, true, false, 1065353216, 0, 1.3)
                    NetworkAddPedToSynchronisedScene(ped, scene1, animDict, 'intro', 1.5, -4.0, 1, 16, 1148846080, 0)
                    NetworkAddEntityToSynchronisedScene(bag, scene1, animDict, 'bag_intro', 4.0, -8.0, 1)

                    scene2 = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z+ 0.48, GetEntityRotation(closestObject), 2, true, true, 1065353216, 0, 1.3) 
                    NetworkAddPedToSynchronisedScene(ped, scene2, animDict, 'grab', 1.5, -4.0, 1, 16, 1148846080, 0)
                    NetworkAddEntityToSynchronisedScene(bag, scene2, animDict, 'bag_grab', 4.0, -8.0, 1)
                    NetworkAddEntityToSynchronisedScene(closestObject, scene2, animDict, 'cart_cash_dissapear', 4.0, -8.0, 1)

                    scene3 =  NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z+ 0.48, GetEntityRotation(closestObject), 2, true, false, 1065353216, 0, 1.3)
                    NetworkAddPedToSynchronisedScene(ped, scene3, animDict, 'exit', 1.5, -4.0, 1, 16, 1148846080, 0)
                    NetworkAddEntityToSynchronisedScene(bag, scene3, animDict, 'bag_exit', 4.0, -8.0, 1)

                    NetworkStartSynchronisedScene(scene1)
                    Wait(1750)
                    TriggerEvent('union:client:GrabUnionTrolley', grabModel)
					QBCore.Functions.Progressbar('Changeme', Config.Lang["money"], 39000, false, false, {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true
						}, {}, {}, {}, function()
							-- This code runs if the progress bar completes successfully
						end, function()
							-- This code runs if the progress bar gets cancelled
					end)
                    NetworkStartSynchronisedScene(scene2)
                    Wait(37000)
                    NetworkStartSynchronisedScene(scene3)
                    Wait(2000)
					TriggerServerEvent("union:server:receive")
					

                    local emptyobj = 769923921
                    newTrolly = CreateObject(emptyobj, coords.x, coords.y, coords.z, true, false, false)
                    SetEntityRotation(newTrolly, 0, 0, GetEntityHeading(closestObject), 1, 0)
                    DeleteObject(closestObject)
                    DeleteObject(bag)
                    LocalPlayer.state:set('inv_busy', false, true) -- Not Busy
                
            
end)



RegisterNetEvent('union:client:GrabUnionTrolley', function(grabModel)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local grabModel = GetHashKey(grabModel)

    RequestModel(grabModel)
    local grabObject = CreateObject(grabModel, pos, true)

    FreezeEntityPosition(grabObject, true)
    SetEntityInvincible(grabObject, true)
    SetEntityNoCollisionEntity(grabObject, ped)
    SetEntityVisible(grabObject, false, false)
    AttachEntityToEntity(grabObject, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
    local Looting = GetGameTimer()

    CreateThread(function()
        while GetGameTimer() - Looting < 37000 do
            Wait(1)
            DisableControlAction(0, 73, true)
            if HasAnimEventFired(ped, GetHashKey('CASH_APPEAR')) then
                if not IsEntityVisible(grabObject) then
                    SetEntityVisible(grabObject, true, false)
                end
            end
            if HasAnimEventFired(ped, GetHashKey('RELEASE_CASH_DESTROY')) then
                if IsEntityVisible(grabObject) then
                    SetEntityVisible(grabObject, false, false)
                end
            end
        end
        DeleteObject(grabObject)
    end)
end)


unionguards = {
    ['npcguards1'] = {}
}

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function SpawnGuards()
    local ped = PlayerPedId()

    SetPedRelationshipGroupHash(ped, `PLAYER`)
    AddRelationshipGroup('npcguards1')

    for k, v in pairs(Config['unionguards']['npcguards1']) do
        loadModel(v['model'])
        ped = CreatePed(26, GetHashKey(v['model']), v['coords'], v['heading'], true, true)
        NetworkRegisterEntityAsNetworked(ped)
        networkID = NetworkGetNetworkIdFromEntity(ped)
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetPedRandomComponentVariation(ped, 0)
        SetPedRandomProps(ped)
        SetEntityAsMissionEntity(ped)
        SetEntityVisible(ped, true)
        SetPedRelationshipGroupHash(ped, `npcguards1`)
        SetPedAccuracy(ped, 75)
        SetPedArmour(ped, 100)
        SetPedCanSwitchWeapon(ped, true)
        SetPedDropsWeaponsWhenDead(ped, false)
        SetPedFleeAttributes(ped, 0, false)
        GiveWeaponToPed(ped, Config.PedWeapon, 255, false, false)
        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(ped, 10.0, 10.0, 1)
        end
    end


    SetRelationshipBetweenGroups(0, `npcguards1`, `npcguards1`)
    SetRelationshipBetweenGroups(5, `npcguards1`, `PLAYER`)
    SetRelationshipBetweenGroups(5, `PLAYER`, `npcguards1`)
end

function ArrombarCells(coords)
	
	TriggerServerEvent("union:server:removec4")
	
	RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end
    local ped = PlayerPedId()

    SetEntityHeading(ped, coords.w)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
    local bagscene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotx, roty, rotz + 1.1, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), coords.x, coords.y, coords.z,  true,  true, false)

    SetEntityCollision(bag, false, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.2, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    
    NetworkStartSynchronisedScene(bagscene)
	QBCore.Functions.Progressbar('Changeme', Config.Lang["c4"], 3200, false, false, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true
		}, {}, {}, {}, function()
			-- This code runs if the progress bar completes successfully
		end, function()
			-- This code runs if the progress bar gets cancelled
	end)
    Citizen.Wait(1500)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local bomba = CreateObject(GetHashKey("prop_c4_final_green"), x, y, z + 0.3,  true,  true, true)
    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 5, 5, 5, 0, 0, 0, true, true, false, true, 1, true)
    
    Wait(1500)
    
    DeleteObject(bomba)

    local bomba = CreateObject(GetHashKey("prop_c4_final_green"), coords.x, coords.y, coords.z,  true,  true, true)
	SetEntityHeading(bomba, coords.w)
    SetEntityCollision(bomba, false, true)
    DeleteEntity(bag)
    Citizen.Wait(2000)
    DetachEntity(bomba, 1, 1)
    FreezeEntityPosition(bomba, true)
    NetworkStopSynchronisedScene(bagscene)
    Citizen.Wait(10000)	
    ClearPedTasks(ped)
    DeleteObject(bomba)  
	TriggerServerEvent("union:server:c4syncCells", coords)
    
end



RegisterNetEvent('mv-union:client:clear')
AddEventHandler('mv-union:client:clear', function()
	for k, v in pairs(Trolleys) do
		Trolleys[k].looted = false
		object = GetClosestObjectOfType(v.coords.x, v.coords.y, v.coords.z, 1.0, 769923921, 0, 0, 0)
		DeleteObject(object)
		
	end
	for k, v in pairs(CellGates) do
		TriggerServerEvent('mad-union:server:door', v.doorName, true) -- Highcrest: ox_doorlock
	end
	DeleteObject(Money1)
	DeleteObject(Money2)
	DeleteObject(Money3)
	DeleteObject(Money4)
	DeleteObject(Money5)
	DeleteObject(Money6)
	heistStarted = false
	isIplLoaded = false
	c4Triggered = false
	TriggerServerEvent('mad-union:server:door', 'union-vault', true) -- Highcrest: ox_doorlock 
end)