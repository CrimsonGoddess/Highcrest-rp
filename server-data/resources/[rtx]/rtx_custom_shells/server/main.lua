local RESOURCE = GetCurrentResourceName()
local SHELLS = {}
local DEFAULT = nil
local ITEMLIST = json.decode(LoadResourceFile(RESOURCE, "items.json") or "null")

local function AddShellRTX(datadata)
	if type(datadata) == "table" and type(datadata.model) == "string" then
		SHELLS[datadata.model] = datadata
		DEFAULT = DEFAULT or datadata.model
	end
end

if type(ITEMLIST) == "table" then
	for _, itemdata in ipairs(ITEMLIST) do
		AddShellRTX(json.decode(LoadResourceFile(RESOURCE, "items/" .. tostring(itemdata.name) .. "/shell.json") or "null"))
	end
else
	local singledata = json.decode(LoadResourceFile(RESOURCE, "shell.json") or "null") or {}

	singledata.model = singledata.model or RESOURCE
	AddShellRTX(singledata)
end

RegisterNetEvent(RESOURCE .. ":server:door", function(keydata, indexdata, opendata)
	if type(keydata) ~= "string" or #keydata > 64 or type(indexdata) ~= "number" then
		return
	end

	local bucketdata = GetPlayerRoutingBucket(source)

	for _, playerdata in ipairs(GetPlayers()) do
		local iddata = tonumber(playerdata)

		if iddata ~= source and GetPlayerRoutingBucket(iddata) == bucketdata then
			TriggerClientEvent(RESOURCE .. ":client:door", iddata, keydata, indexdata, opendata == true)
		end
	end
end)

RegisterNetEvent(RESOURCE .. ":server:elevator", function(keydata, indexdata, stopdata)
	if type(keydata) ~= "string" or #keydata > 64 or type(indexdata) ~= "number" or type(stopdata) ~= "number" then
		return
	end

	local bucketdata = GetPlayerRoutingBucket(source)

	for _, playerdata in ipairs(GetPlayers()) do
		local iddata = tonumber(playerdata)

		if iddata ~= source and GetPlayerRoutingBucket(iddata) == bucketdata then
			TriggerClientEvent(RESOURCE .. ":client:elevator", iddata, keydata, indexdata, stopdata)
		end
	end
end)

exports("GetShellData", function(modeldata) return SHELLS[type(modeldata) == "string" and modeldata or DEFAULT] end)
exports("GetShells", function() local listdata = {} for modeldata, _ in pairs(SHELLS) do listdata[#listdata + 1] = modeldata end table.sort(listdata) return listdata end)
