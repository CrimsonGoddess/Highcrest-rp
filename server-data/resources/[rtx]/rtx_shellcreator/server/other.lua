local LogsRTX = {
	enabled = false,
	webhook = "",
	name = "RTX Shell Creator",
	color = 16738047,
	events = {
		opened = false,
		installed = true,
		published = true,
		deleted = true,
		access = true,
		security = true,
		actions = false
	}
}

if Config.Framework == "esx" then
	if Config.ESXFramework.newversion == true then
		ESX = exports[Config.ESXFramework.resourcename]:getSharedObject()
	else
		TriggerEvent(Config.ESXFramework.getsharedobject, function(obj)
			ESX = obj
		end)
	end
end

if Config.Framework == "qbcore" then
	QBCore = exports[Config.QBCoreFrameworkResourceName]:GetCoreObject()
end

function GetPlayerIdentifierRTX(playersource)
	local playeridentifierdata = ""

	if Config.Framework == "esx" and ESX ~= nil then
		local xPlayer = ESX.GetPlayerFromId(playersource)

		if xPlayer then
			playeridentifierdata = xPlayer.identifier
		end
	elseif Config.Framework == "qbcore" and QBCore ~= nil then
		local xPlayer = QBCore.Functions.GetPlayer(playersource)

		if xPlayer then
			playeridentifierdata = xPlayer.PlayerData.citizenid
		end
	elseif Config.Framework == "qbox" then
		local okdata, xPlayer = pcall(function()
			return exports.qbx_core:GetPlayer(playersource)
		end)

		if okdata and xPlayer and xPlayer.PlayerData then
			playeridentifierdata = xPlayer.PlayerData.citizenid
		end
	end

	if playeridentifierdata == nil or playeridentifierdata == "" then
		playeridentifierdata = GetPlayerIdentifierByType(playersource, "license") or GetPlayerIdentifiers(playersource)[1] or ""
	end

	return playeridentifierdata
end

function GetPlayerNameRTX(playersource)
	if Config.Framework == "esx" and ESX ~= nil then
		local xPlayer = ESX.GetPlayerFromId(playersource)

		if xPlayer and xPlayer.getName then
			local namedata = xPlayer.getName()

			if namedata ~= nil and namedata ~= "" then
				return namedata
			end
		end
	elseif Config.Framework == "qbcore" and QBCore ~= nil then
		local xPlayer = QBCore.Functions.GetPlayer(playersource)

		if xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.charinfo then
			local charinfodata = xPlayer.PlayerData.charinfo

			return tostring(charinfodata.firstname or "") .. " " .. tostring(charinfodata.lastname or "")
		end
	elseif Config.Framework == "qbox" then
		local okdata, xPlayer = pcall(function()
			return exports.qbx_core:GetPlayer(playersource)
		end)

		if okdata and xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.charinfo then
			local charinfodata = xPlayer.PlayerData.charinfo

			return tostring(charinfodata.firstname or "") .. " " .. tostring(charinfodata.lastname or "")
		end
	end

	return GetPlayerName(playersource) or ("#" .. tostring(playersource))
end

function PlayerInGroupsRTX(playersource, groupsdata)
	if type(groupsdata) ~= "table" or #groupsdata == 0 then
		return false
	end

	if Config.Framework == "esx" and ESX ~= nil then
		local xPlayer = ESX.GetPlayerFromId(playersource)

		if xPlayer and xPlayer.getGroup then
			local groupdata = xPlayer.getGroup()

			for idata = 1, #groupsdata do
				if groupsdata[idata] == groupdata then
					return true
				end
			end
		end
	elseif Config.Framework == "qbcore" and QBCore ~= nil then
		for idata = 1, #groupsdata do
			if QBCore.Functions.HasPermission(playersource, groupsdata[idata]) then
				return true
			end
		end
	elseif Config.Framework == "qbox" then
		for idata = 1, #groupsdata do
			if IsPlayerAceAllowed(tostring(playersource), groupsdata[idata]) then
				return true
			end
		end
	end

	return false
end

function PlayerHasIdentifierRTX(playersource, identifiersdata)
	if type(identifiersdata) ~= "table" or #identifiersdata == 0 then
		return false
	end

	local owneddata = {}
	local frameworkdata = GetPlayerIdentifierRTX(playersource)

	if frameworkdata ~= nil and frameworkdata ~= "" then
		owneddata[frameworkdata] = true
	end

	for _, identifierdata in ipairs(GetPlayerIdentifiers(playersource) or {}) do
		owneddata[identifierdata] = true
		owneddata[string.gsub(identifierdata, "^[^:]+:", "")] = true
	end

	for idata = 1, #identifiersdata do
		if owneddata[identifiersdata[idata]] == true then
			return true
		end
	end

	return false
end

function IsAdminRTX(playersource)
	if playersource == nil or tonumber(playersource) == nil or tonumber(playersource) <= 0 then
		return false
	end

	if IsPlayerAceAllowed(tostring(playersource), Config.AdminAce or "rtxshellcreator.admin") then
		return true
	end

	if PlayerHasIdentifierRTX(playersource, (Config.Admins or {}).identifiers) then
		return true
	end

	return PlayerInGroupsRTX(playersource, (Config.Admins or {}).groups or {})
end

function RevivePlayerRTX(playersource)
	if Config.Framework == "esx" and GetResourceState("esx_ambulancejob") == "started" then
		TriggerClientEvent("esx_ambulancejob:revive", playersource)
	elseif Config.Framework == "qbcore" and GetResourceState("qb-ambulancejob") == "started" then
		TriggerClientEvent("hospital:client:Revive", playersource)
	elseif Config.Framework == "qbox" and GetResourceState("qbx_medical") == "started" then
		TriggerClientEvent("qbx_medical:client:playerRevived", playersource)
	else
		TriggerClientEvent("rtx_shellcreator:client:playerRevive", playersource)
	end
end

function SendLogRTX(kinddata, titledata, descriptiondata, colordata)
	if LogsRTX.enabled ~= true or (LogsRTX.webhook or "") == "" then
		return
	end

	if kinddata ~= nil and LogsRTX.events[kinddata] ~= true then
		return
	end

	PerformHttpRequest(LogsRTX.webhook, function() end, "POST", json.encode({
		username = LogsRTX.name or "RTX Shell Creator",
		embeds = {{
			title = titledata,
			description = descriptiondata,
			color = colordata or LogsRTX.color,
			footer = {text = os.date("%Y-%m-%d %H:%M:%S")}
		}}
	}), {["Content-Type"] = "application/json"})
end

function OnToolkitOpenedRTX(playersource)
	SendLogRTX("opened", "Shell creator opened", string.format("**%s** (%s) opened the shell creator.", GetPlayerNameRTX(playersource), playersource))
end

function OnResourceInstalledRTX(resourcename, filescount, fromdata)
	TriggerEvent("rtx_shellcreator:server:installed", resourcename, filescount, fromdata)
	SendLogRTX("installed", "Resource installed", string.format("`%s` (%s files) from %s.", resourcename, filescount, tostring(fromdata)))
end

function OnPublishedRTX(playersource, kinddata, namedata)
	TriggerEvent("rtx_shellcreator:server:published", playersource, kinddata, namedata)
	SendLogRTX("published", "Published", string.format("**%s** published the %s `%s`.", GetPlayerNameRTX(playersource), tostring(kinddata), tostring(namedata)))
end

AddEventHandler("rtx_shellcreator:server:installed", function(resourcename, filescount, fromdata)
end)

AddEventHandler("rtx_shellcreator:server:published", function(playersource, kinddata, namedata)
end)

function LogDeletedRTX(playersource, countdata)
	SendLogRTX("deleted", "Deleted", string.format("**%s** (%s) deleted %s entities with the delete tool.", GetPlayerNameRTX(playersource), playersource, countdata))
end
