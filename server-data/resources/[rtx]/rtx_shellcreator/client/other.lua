function IsPlayerDeadRTX()
	local peddata = PlayerPedId()

	if IsEntityDead(peddata) or IsPedDeadOrDying(peddata, true) then
		return true
	end

	local statedata = LocalPlayer.state

	if statedata.isDead == true or statedata.dead == true or statedata.isLaststand == true or statedata.inlaststand == true then
		return true
	end

	return false
end

AddEventHandler("esx:onPlayerDeath", function()
	TriggerEvent("rtx_shellcreator:client:playerDied")
end)

AddEventHandler("baseevents:onPlayerDied", function()
	TriggerEvent("rtx_shellcreator:client:playerDied")
end)

AddEventHandler("baseevents:onPlayerKilled", function()
	TriggerEvent("rtx_shellcreator:client:playerDied")
end)

RegisterNetEvent("hospital:client:SetDeathStatus", function(isdeaddata)
	if isdeaddata == true then
		TriggerEvent("rtx_shellcreator:client:playerDied")
	end
end)

RegisterNetEvent("hospital:client:SetLaststandStatus", function(laststanddata)
	if laststanddata == true then
		TriggerEvent("rtx_shellcreator:client:playerDied")
	end
end)

function AllowedToolkit()
	if IsPlayerDeadRTX() or IsPauseMenuActive() or LocalPlayer.state.invOpen == true then
		return false
	end

	return true
end

function Notify(textdata, titledata, typedata)
	if Config.Notifications == "rtx" then
		SendNUIMessage({
			message = "NotifyShow",
			title = titledata or ToolkitText("notify_title"),
			text = textdata or "",
			type = typedata or "info",
			timeout = 5000
		})

		return
	end

	exports["rtx_notify"]:Notify(titledata or ToolkitText("notify_title"), textdata, 5000, typedata or "info")
end

function HideHudRTX()
	DisplayRadar(false)
	TriggerEvent("rtx_shellcreator:client:hideHud")
end

function ShowHudRTX()
	DisplayRadar(true)
	TriggerEvent("rtx_shellcreator:client:showHud")
end

function OnShellEnteredRTX(shelliddata)
	TriggerEvent("rtx_shellcreator:client:shellEntered", shelliddata)
end

function OnShellLeftRTX(shelliddata)
	TriggerEvent("rtx_shellcreator:client:shellLeft", shelliddata)
end

function SetWeatherSyncRTX(pausedata)
	if GetResourceState("qb-weathersync") == "started" then
		TriggerEvent(pausedata and "qb-weathersync:client:DisableSync" or "qb-weathersync:client:EnableSync")
	end

	if GetResourceState("cd_easytime") == "started" then
		TriggerEvent("cd_easytime:PauseSync", pausedata)
	end

	if GetResourceState("vSync") == "started" then
		TriggerEvent("vSync:toggle", not pausedata)
	end

	if GetResourceState("Renewed-Weathersync") == "started" then
		LocalPlayer.state:set("syncWeather", not pausedata, false)
	end
end

function SetDesignerWeaponRTX(statedata)
	if GetResourceState("ox_inventory") == "started" then
		pcall(function()
			exports.ox_inventory:weaponWheel(statedata)
		end)
	end

	if GetResourceState("qb-inventory") == "started" or GetResourceState("ps-inventory") == "started" or GetResourceState("lj-inventory") == "started" then
		pcall(function()
			LocalPlayer.state:set("inv_busy", statedata, true)
		end)
	end

	TriggerEvent("rtx_shellcreator:client:designerWeapon", statedata)
end
