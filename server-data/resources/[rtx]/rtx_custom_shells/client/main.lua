local RESOURCE = GetCurrentResourceName()
local SHELLS = {}
local HASHES = {}
local DEFAULT = nil
local INSTANCES = {}
local NEXTID = 0

local function AddShellRTX(datadata)
	if type(datadata) ~= "table" or type(datadata.model) ~= "string" then
		return
	end

	SHELLS[datadata.model] = datadata
	HASHES[GetHashKey(datadata.model)] = datadata.model
	DEFAULT = DEFAULT or datadata.model
end

local ITEMLIST = json.decode(LoadResourceFile(RESOURCE, "items.json") or "null")

if type(ITEMLIST) == "table" then
	for _, itemdata in ipairs(ITEMLIST) do
		AddShellRTX(json.decode(LoadResourceFile(RESOURCE, "items/" .. tostring(itemdata.name) .. "/shell.json") or "null"))
	end
else
	local singledata = json.decode(LoadResourceFile(RESOURCE, "shell.json") or "null") or {}

	singledata.model = singledata.model or RESOURCE
	AddShellRTX(singledata)
end

local function ShellOfRTX(modeldata)
	return SHELLS[modeldata or DEFAULT]
end

local function LoadModelRTX(hashdata)
	if not IsModelInCdimage(hashdata) then
		return false
	end

	RequestModel(hashdata)

	local untildata = GetGameTimer() + 10000

	while not HasModelLoaded(hashdata) and GetGameTimer() < untildata do
		Wait(0)
	end

	return HasModelLoaded(hashdata)
end

local function WorldRTX(instancedata, xdata, ydata, zdata)
	local angledata = math.rad(instancedata.heading)
	local cosdata, sindata = math.cos(angledata), math.sin(angledata)

	return vector3(instancedata.coords.x + xdata * cosdata - ydata * sindata, instancedata.coords.y + xdata * sindata + ydata * cosdata, instancedata.coords.z + zdata)
end

local function KeyRTX(coordsdata)
	return string.format("%.1f_%.1f_%.1f", coordsdata.x, coordsdata.y, coordsdata.z)
end

local function PlaceGarageRTX(itemdata)
	local angledata = math.rad(itemdata.heading)
	local rightdata = vector3(math.cos(angledata), math.sin(angledata), 0.0)
	local forwarddata = vector3(-math.sin(angledata), math.cos(angledata), 0.0)
	local sxdata = itemdata.data.sx or 1.0
	local szdata = itemdata.data.sz or 1.0
	local atdata = itemdata.base + vector3(0.0, 0.0, itemdata.lift)

	SetEntityMatrix(itemdata.entity, forwarddata.x, forwarddata.y, forwarddata.z, rightdata.x * sxdata, rightdata.y * sxdata, 0.0, 0.0, 0.0, szdata, atdata.x, atdata.y, atdata.z)
end

local LIFT = {}

function LIFT.World(itemdata, lxdata, lydata, lzdata)
	local angledata = math.rad(itemdata.heading)
	local cosdata, sindata = math.cos(angledata), math.sin(angledata)

	return vector3(itemdata.centre.x + lxdata * cosdata - lydata * sindata, itemdata.centre.y + lxdata * sindata + lydata * cosdata, itemdata.centre.z + lzdata)
end

function LIFT.Local(itemdata, coordsdata)
	local angledata = -math.rad(itemdata.heading)
	local dxdata, dydata = coordsdata.x - itemdata.centre.x, coordsdata.y - itemdata.centre.y

	return dxdata * math.cos(angledata) - dydata * math.sin(angledata), dxdata * math.sin(angledata) + dydata * math.cos(angledata), coordsdata.z - itemdata.centre.z
end

function LIFT.Load(modeldata)
	local hashdata = GetHashKey(modeldata)

	if not IsModelInCdimage(hashdata) then
		return nil
	end

	RequestModel(hashdata)

	local untildata = GetGameTimer() + 5000

	while not HasModelLoaded(hashdata) and GetGameTimer() < untildata do
		Wait(0)
	end

	if not HasModelLoaded(hashdata) then
		return nil
	end

	return hashdata
end

function LIFT.Object(itemdata, modeldata, lxdata, lydata, lzdata, turndata)
	if not itemdata.alive then
		return nil
	end

	local hashdata = LIFT.Load(modeldata)

	if hashdata == nil or not itemdata.alive then
		return nil
	end

	local atdata = LIFT.World(itemdata, lxdata, lydata, lzdata)
	local entitydata = CreateObjectNoOffset(hashdata, atdata.x, atdata.y, atdata.z, false, false, false)

	if entitydata == nil or entitydata == 0 then
		return nil
	end

	FreezeEntityPosition(entitydata, true)
	SetEntityRotation(entitydata, 0.0, 0.0, (itemdata.heading + (turndata or 0.0)) % 360.0, 2, false)
	itemdata.entities[#itemdata.entities + 1] = entitydata

	return entitydata
end

function LIFT.Put(itemdata, entitydata, lxdata, lydata, lzdata, turndata)
	if entitydata == nil or not DoesEntityExist(entitydata) then
		return
	end

	local atdata = LIFT.World(itemdata, lxdata, lydata, lzdata)

	SetEntityCoordsNoOffset(entitydata, atdata.x, atdata.y, atdata.z, false, false, false)
	SetEntityRotation(entitydata, 0.0, 0.0, (itemdata.heading + (turndata or 0.0)) % 360.0, 2, false)
end

function LIFT.Scaled(itemdata, entitydata, lxdata, lydata, lzdata, turndata, scaledata)
	if entitydata == nil or not DoesEntityExist(entitydata) then
		return
	end

	local atdata = LIFT.World(itemdata, lxdata, lydata, lzdata)
	local angledata = math.rad((itemdata.heading + (turndata or 0.0)) % 360.0)
	local cosdata, sindata = math.cos(angledata), math.sin(angledata)

	SetEntityMatrix(entitydata, -sindata * scaledata, cosdata * scaledata, 0.0, cosdata * scaledata, sindata * scaledata, 0.0, 0.0, 0.0, scaledata, atdata.x, atdata.y, atdata.z)
end

function LIFT.Remove(itemdata, entitydata)
	if entitydata ~= nil and DoesEntityExist(entitydata) then
		SetEntityAsMissionEntity(entitydata, true, true)
		DeleteEntity(entitydata)
	end

	for indexdata = #itemdata.entities, 1, -1 do
		if itemdata.entities[indexdata] == entitydata then
			table.remove(itemdata.entities, indexdata)
		end
	end
end

function LIFT.Name(itemdata, suffixdata)
	return itemdata.base .. "_e" .. itemdata.index .. suffixdata
end

function LIFT.Leaves(itemdata, leavesdata, opendata, fastydata, slowydata, zdata)
	local layoutdata = itemdata.layout
	local doordata = layoutdata.door
	local leafdata = layoutdata.leaf
	local fastdata = opendata * doordata / 2.0
	local slowdata = opendata * doordata / 4.0

	LIFT.Put(itemdata, leavesdata[1], -leafdata - fastdata, fastydata, zdata, 0.0)
	LIFT.Put(itemdata, leavesdata[2], -doordata / 2.0 - 0.016 - slowdata, slowydata, zdata, 0.0)
	LIFT.Put(itemdata, leavesdata[3], fastdata, fastydata, zdata, 0.0)
	LIFT.Put(itemdata, leavesdata[4], doordata / 2.0 + 0.016 - leafdata + slowdata, slowydata, zdata, 0.0)
end

function LIFT.Cabin(itemdata)
	local layoutdata = itemdata.layout

	LIFT.Put(itemdata, itemdata.cabin, 0.0, 0.0, itemdata.z, 0.0)
	LIFT.Leaves(itemdata, itemdata.car, itemdata.caropen, layoutdata.carB, layoutdata.carA, itemdata.z)
	LIFT.Put(itemdata, itemdata.cabdigit, -0.06, layoutdata.cy0 + 0.045, itemdata.z + layoutdata.CH - 0.095, 180.0)
	LIFT.Put(itemdata, itemdata.cabarrow, 0.1, layoutdata.cy0 + 0.045, itemdata.z + layoutdata.CH - 0.095, 180.0)
	LIFT.Scaled(itemdata, itemdata.copdigit, layoutdata.copX - layoutdata.copW / 2.0, layoutdata.cy0 + 0.0385, itemdata.z + (layoutdata.copDZ or 1.534), 180.0, 0.6)

	local buttondata = itemdata.litstop ~= nil and layoutdata.buttons and layoutdata.buttons[itemdata.litstop] or nil

	if buttondata ~= nil then
		LIFT.Put(itemdata, itemdata.lit, buttondata[1], layoutdata.cy0 + 0.038, itemdata.z + buttondata[2], 180.0)
	end
end

function LIFT.Cop(itemdata, stopdata)
	local layoutdata = itemdata.layout

	if (layoutdata.copW or 0.0) < 0.16 or itemdata.copshown == stopdata then
		return
	end

	itemdata.copshown = stopdata
	LIFT.Remove(itemdata, itemdata.copdigit)
	itemdata.copdigit = LIFT.Object(itemdata, LIFT.Name(itemdata, "n" .. stopdata), layoutdata.copX - layoutdata.copW / 2.0, layoutdata.cy0 + 0.0385, itemdata.z + (layoutdata.copDZ or 1.534), 180.0)
	LIFT.Scaled(itemdata, itemdata.copdigit, layoutdata.copX - layoutdata.copW / 2.0, layoutdata.cy0 + 0.0385, itemdata.z + (layoutdata.copDZ or 1.534), 180.0, 0.6)
end

function LIFT.Lit(itemdata, stopdata)
	if itemdata.litstop == stopdata then
		return
	end

	itemdata.litstop = stopdata
	LIFT.Remove(itemdata, itemdata.lit)
	itemdata.lit = nil

	local layoutdata = itemdata.layout
	local buttondata = stopdata ~= nil and layoutdata.buttons and layoutdata.buttons[stopdata] or nil

	if buttondata ~= nil then
		itemdata.lit = LIFT.Object(itemdata, LIFT.Name(itemdata, "p" .. stopdata), buttondata[1], layoutdata.cy0 + 0.038, itemdata.z + buttondata[2], 180.0)
	end
end

function LIFT.Call(itemdata, stopdata, ondata)
	local gatedata = itemdata.gates[stopdata]

	if gatedata == nil then
		return
	end

	LIFT.Remove(itemdata, gatedata.call)
	gatedata.call = nil

	if not ondata then
		return
	end

	local countdata = #itemdata.gates
	local updata = stopdata == 1 or (stopdata ~= countdata and itemdata.stop < stopdata)
	local zdata = (stopdata == 1 or stopdata == countdata) and 1.1 or (updata and 1.152 or 1.048)

	gatedata.call = LIFT.Object(itemdata, LIFT.Name(itemdata, updata and "u" or "w"), itemdata.layout.callX or (itemdata.layout.door / 2.0 + 0.27), -itemdata.layout.hd - 0.018, gatedata.z + zdata, 0.0)
end

function LIFT.Gate(itemdata, gatedata)
	LIFT.Leaves(itemdata, gatedata.leaves, gatedata.open, itemdata.layout.landA, itemdata.layout.landB, gatedata.z)
end

function LIFT.Show(itemdata, gatedata, showdata)
	if gatedata.shown == showdata then
		return
	end

	gatedata.shown = showdata

	for _, entitydata in ipairs({gatedata.digit, gatedata.arrow}) do
		if entitydata ~= nil and DoesEntityExist(entitydata) then
			SetEntityVisible(entitydata, showdata, false)
		end
	end
end

function LIFT.DisplayZ(itemdata)
	return itemdata.layout.doorH + 0.215
end

function LIFT.Digits(itemdata, floordata)
	if itemdata.shown == floordata then
		return
	end

	itemdata.shown = floordata

	local modeldata = LIFT.Name(itemdata, "n" .. floordata)
	local layoutdata = itemdata.layout

	for _, gatedata in ipairs(itemdata.gates) do
		LIFT.Remove(itemdata, gatedata.digit)
		gatedata.digit = LIFT.Object(itemdata, modeldata, 0.07, -layoutdata.hd - 0.0245, gatedata.z + LIFT.DisplayZ(itemdata), 0.0)
		gatedata.shown = nil
	end

	LIFT.Remove(itemdata, itemdata.cabdigit)
	itemdata.cabdigit = LIFT.Object(itemdata, modeldata, -0.06, layoutdata.cy0 + 0.045, itemdata.z + layoutdata.CH - 0.095, 180.0)

end

function LIFT.Arrows(itemdata, directiondata)
	if itemdata.direction == directiondata then
		return
	end

	itemdata.direction = directiondata

	local layoutdata = itemdata.layout

	for _, gatedata in ipairs(itemdata.gates) do
		LIFT.Remove(itemdata, gatedata.arrow)
		gatedata.arrow = nil
	end

	LIFT.Remove(itemdata, itemdata.cabarrow)
	itemdata.cabarrow = nil

	if directiondata == nil then
		return
	end

	local modeldata = LIFT.Name(itemdata, directiondata > 0 and "a" or "b")

	for _, gatedata in ipairs(itemdata.gates) do
		gatedata.arrow = LIFT.Object(itemdata, modeldata, -0.11, -layoutdata.hd - 0.0245, gatedata.z + LIFT.DisplayZ(itemdata), 0.0)
		gatedata.shown = nil
	end

	itemdata.cabarrow = LIFT.Object(itemdata, modeldata, 0.1, layoutdata.cy0 + 0.045, itemdata.z + layoutdata.CH - 0.095, 180.0)
end

LIFT.sound = {enabled = true, volume = 0.8, distance = 24.0}

function LIFT.Mix(atdata, volumedata)
	local camdata = GetFinalRenderedCamCoord()
	local rotdata = GetFinalRenderedCamRot(2)
	local maxdata = LIFT.sound.distance or 24.0
	local distancedata = #(camdata - atdata)

	if distancedata >= maxdata then
		return 0.0, 0.0
	end

	local falloffdata = 1.0 - distancedata / maxdata
	local yawdata = math.rad(rotdata.z)
	local dxdata, dydata = atdata.x - camdata.x, atdata.y - camdata.y
	local lengthdata = math.sqrt(dxdata * dxdata + dydata * dydata)
	local pandata = 0.0

	if lengthdata > 0.25 then
		pandata = math.max(-1.0, math.min(1.0, (dxdata * math.cos(yawdata) + dydata * math.sin(yawdata)) / lengthdata)) * 0.75 * math.min(1.0, lengthdata / 1.5)
	end

	return volumedata * falloffdata * falloffdata * (LIFT.sound.volume or 0.8), pandata
end

function LIFT.Muffle(itemdata, zdata, cabindata)
	local coordsdata = GetEntityCoords(PlayerPedId())

	if cabindata then
		if LIFT.Inside(itemdata, coordsdata) then
			return 0.0
		end

		local landingdata = LIFT.Landing(itemdata, coordsdata)
		local gatedata = landingdata ~= nil and itemdata.gates[landingdata] or nil

		if gatedata ~= nil and math.abs(gatedata.z - zdata) < 1.2 then
			return 0.5 - 0.45 * gatedata.open
		end

		return 0.85
	end

	local _, _, lzdata = LIFT.Local(itemdata, coordsdata)
	local apartdata = math.abs(lzdata - 1.0 - zdata)

	if apartdata < 1.6 then
		return 0.0
	end

	return math.min(0.9, 0.55 + apartdata * 0.06)
end

function LIFT.Play(itemdata, namedata, lxdata, lydata, floordata, heightdata, volumedata, cabindata)
	if not LIFT.sound.enabled then
		return
	end

	local atdata = LIFT.World(itemdata, lxdata, lydata, floordata + heightdata)
	local vdata, pdata = LIFT.Mix(atdata, volumedata or 1.0)

	if vdata < 0.01 then
		return
	end

	SendNUIMessage({message = "RTXLiftSound", play = {n = namedata, v = vdata, p = pdata, m = LIFT.Muffle(itemdata, floordata, cabindata)}})
end

function LIFT.Doors(itemdata, gatedata, opendata)
	LIFT.Play(itemdata, opendata and "lift_door_open" or "lift_door_close", 0.0, -itemdata.layout.hd + 0.05, gatedata.z, 1.2, 0.7, false)
end

function LIFT.Button(itemdata, namedata, landingdata)
	if landingdata ~= nil then
		LIFT.Play(itemdata, namedata, itemdata.layout.callX or 0.0, -itemdata.layout.hd, itemdata.gates[landingdata].z, 1.1, 0.7, false)
	else
		LIFT.Play(itemdata, namedata, (itemdata.layout.copX or 0.0) - (itemdata.layout.copW or 0.0) / 2.0, (itemdata.layout.cy0 or 0.0) + 0.05, itemdata.z, 1.3, 0.7, true)
	end
end

function LIFT.Hum(itemdata, speeddata)
	if not LIFT.sound.enabled then
		return
	end

	local nowdata = GetGameTimer()

	if speeddata > 0.0 and nowdata < (itemdata.humat or 0) then
		return
	end

	itemdata.humat = nowdata + 90

	local vdata, pdata, mdata = 0.0, 0.0, 0.0

	if speeddata > 0.0 then
		vdata, pdata = LIFT.Mix(LIFT.World(itemdata, 0.0, 0.0, itemdata.z + 1.3), 0.15 + 0.5 * speeddata)
		mdata = LIFT.Muffle(itemdata, itemdata.z, true)
	end

	if vdata < 0.01 and (itemdata.humv or 0.0) < 0.01 then
		return
	end

	itemdata.humv = vdata
	SendNUIMessage({message = "RTXLiftSound", loop = {id = tostring(itemdata.key) .. ":" .. tostring(itemdata.index), n = "lift_move", v = vdata, p = pdata, m = mdata, r = 0.97 + 0.06 * speeddata}})
end

function LIFT.Spawn(listdata, origindata, headingdata, keydata, basedata)
	local outdata = {}
	local angledata = math.rad(headingdata or 0.0)
	local cosdata, sindata = math.cos(angledata), math.sin(angledata)

	if basedata == nil or basedata == "" then
		return outdata
	end

	for indexdata, elevdata in ipairs(listdata or {}) do
		if type(elevdata) == "table" and type(elevdata.stops) == "table" and #elevdata.stops > 1 and type(elevdata.layout) == "table" and type(elevdata.inner) == "table" and IsModelInCdimage(GetHashKey(basedata .. "_e" .. indexdata .. "c")) then
			local itemdata = {
				data = elevdata, layout = elevdata.layout, index = indexdata, key = keydata, base = basedata, alive = true, busy = false, stop = 1, z = (elevdata.stops[1] or 0.0) + 0.0, caropen = 0.0,
				heading = ((headingdata or 0.0) + (elevdata.h or 0.0)) % 360.0,
				centre = vector3(origindata.x + elevdata.x * cosdata - elevdata.y * sindata, origindata.y + elevdata.x * sindata + elevdata.y * cosdata, origindata.z),
				gates = {}, entities = {}
			}
			local countdata = #elevdata.stops

			itemdata.cabin = LIFT.Object(itemdata, LIFT.Name(itemdata, "c"), 0.0, 0.0, itemdata.z, 0.0)
			itemdata.car = {}

			for leafindex = 1, 4 do
				itemdata.car[leafindex] = LIFT.Object(itemdata, LIFT.Name(itemdata, "k"), 0.0, 0.0, itemdata.z, 0.0)
			end

			for stopindex, zdata in ipairs(elevdata.stops) do
				local gatedata = {z = zdata + 0.0, open = 0.0, target = 0.0, closeat = 0}
				local variantdata = stopindex == 1 and "f0" or (stopindex == countdata and "f2" or "f1")

				gatedata.fixture = LIFT.Object(itemdata, LIFT.Name(itemdata, variantdata), 0.0, 0.0, gatedata.z, 0.0)
				gatedata.leaves = {}

				for leafindex = 1, 4 do
					gatedata.leaves[leafindex] = LIFT.Object(itemdata, LIFT.Name(itemdata, "d"), 0.0, 0.0, gatedata.z, 0.0)
				end
				itemdata.gates[stopindex] = gatedata
				LIFT.Gate(itemdata, gatedata)
			end

			LIFT.Digits(itemdata, 1)
			LIFT.Cop(itemdata, 1)
			LIFT.Cabin(itemdata)
			outdata[#outdata + 1] = itemdata
		end
	end

	return outdata
end

function LIFT.Clear(listdata)
	local peddata = PlayerPedId()

	for _, itemdata in ipairs(listdata or {}) do
		itemdata.alive = false

		if (itemdata.humv or 0.0) > 0.0 then
			itemdata.humv = 0.0
			SendNUIMessage({message = "RTXLiftSound", loop = {id = tostring(itemdata.key) .. ":" .. tostring(itemdata.index), v = 0.0}})
		end

		if itemdata.cabin ~= nil and DoesEntityExist(itemdata.cabin) and IsEntityAttachedToEntity(peddata, itemdata.cabin) then
			DetachEntity(peddata, true, false)
		end

		for indexdata = #itemdata.entities, 1, -1 do
			local entitydata = itemdata.entities[indexdata]

			if entitydata ~= nil and DoesEntityExist(entitydata) then
				SetEntityAsMissionEntity(entitydata, true, true)
				DeleteEntity(entitydata)
			end
		end

		itemdata.entities = {}
	end
end

function LIFT.Inside(itemdata, coordsdata)
	local lxdata, lydata, lzdata = LIFT.Local(itemdata, coordsdata)
	local innerdata = itemdata.data.inner
	local feetdata = lzdata - 1.0

	return lxdata >= innerdata[1] - 0.08 and lxdata <= innerdata[3] + 0.08 and lydata >= innerdata[2] - 0.12 and lydata <= innerdata[4] + 0.08 and feetdata > itemdata.z - 0.6 and feetdata < itemdata.z + 1.4
end

function LIFT.Landing(itemdata, coordsdata)
	local lxdata, lydata, lzdata = LIFT.Local(itemdata, coordsdata)
	local frontdata = -(itemdata.data.d or 1.9) / 2.0
	local halfdata = (itemdata.data.door or 0.8) / 2.0 + 0.8

	if math.abs(lxdata) > halfdata or lydata > frontdata + 0.05 or lydata < frontdata - 1.8 then
		return nil
	end

	for stopindex, zdata in ipairs(itemdata.data.stops) do
		if math.abs(lzdata - 1.0 - zdata) < 0.8 then
			return stopindex
		end
	end

	return nil
end

function LIFT.Nearest(itemdata)
	local bestdata, bestindex = nil, 1

	for stopindex, zdata in ipairs(itemdata.data.stops) do
		local distdata = math.abs(zdata - itemdata.z)

		if bestdata == nil or distdata < bestdata then
			bestdata, bestindex = distdata, stopindex
		end
	end

	return bestindex
end

function LIFT.WaitGate(itemdata, gatedata, targetdata)
	gatedata.target = targetdata

	local untildata = GetGameTimer() + 3500

	while itemdata.alive and math.abs(gatedata.open - targetdata) > 0.001 and GetGameTimer() < untildata do
		Wait(0)
	end
end

function LIFT.Go(itemdata, stopdata, carrydata, speeddata)
	if itemdata.busy or not itemdata.alive or itemdata.data.stops[stopdata] == nil then
		return false
	end

	itemdata.busy = true
	itemdata.going = stopdata

	if stopdata ~= itemdata.stop then
		LIFT.Lit(itemdata, stopdata)
	end

	CreateThread(function()
		local peddata = PlayerPedId()

		if stopdata ~= itemdata.stop then
			if itemdata.gates[itemdata.stop].open > 0.01 then
				LIFT.Doors(itemdata, itemdata.gates[itemdata.stop], false)
			end

			LIFT.WaitGate(itemdata, itemdata.gates[itemdata.stop], 0.0)
			Wait(250)
			LIFT.Play(itemdata, "lift_start", 0.0, 0.0, itemdata.z, 1.3, 0.9, true)
			Wait(150)
			itemdata.moving = true
			itemdata.pick = nil
			LIFT.Arrows(itemdata, stopdata > itemdata.stop and 1 or -1)

			local ridingdata = carrydata == true and itemdata.cabin ~= nil and DoesEntityExist(itemdata.cabin) and LIFT.Inside(itemdata, GetEntityCoords(peddata)) and not IsPedInAnyVehicle(peddata, false)

			if ridingdata then
				local lxdata, lydata, lzdata = LIFT.Local(itemdata, GetEntityCoords(peddata))

				NetworkAllowLocalEntityAttachment(peddata, true)
				AttachEntityToEntity(peddata, itemdata.cabin, 0, lxdata, lydata, lzdata - itemdata.z, 0.0, 0.0, (GetEntityHeading(peddata) - itemdata.heading) % 360.0, false, false, false, false, 2, true)
			end

			local fromdata = itemdata.z
			local todata = itemdata.data.stops[stopdata] + 0.0
			local timedata = math.max(1800.0, math.abs(todata - fromdata) / math.max(0.3, speeddata or 1.5) * 1000.0 + 600.0)
			local startdata = GetGameTimer()

			while itemdata.alive do
				local tdata = math.min(1.0, (GetGameTimer() - startdata) / timedata)

				itemdata.z = fromdata + (todata - fromdata) * (tdata * tdata * (3.0 - 2.0 * tdata))
				LIFT.Cabin(itemdata)

				local nearestdata = LIFT.Nearest(itemdata)

				if nearestdata ~= itemdata.passed then
					if itemdata.passed ~= nil and nearestdata ~= stopdata and LIFT.Inside(itemdata, GetEntityCoords(peddata)) then
						LIFT.Button(itemdata, "lift_pass", nil)
					end

					itemdata.passed = nearestdata
				end

				LIFT.Digits(itemdata, nearestdata)
				LIFT.Cop(itemdata, nearestdata)
				LIFT.Hum(itemdata, 4.0 * tdata * (1.0 - tdata))

				if tdata >= 1.0 then
					break
				end

				Wait(0)
			end

			itemdata.stop = stopdata
			itemdata.moving = false
			itemdata.passed = nil
			LIFT.Hum(itemdata, 0.0)
			LIFT.Play(itemdata, "lift_stop", 0.0, 0.0, itemdata.z, 1.3, 0.9, true)

			if ridingdata and itemdata.cabin ~= nil and DoesEntityExist(itemdata.cabin) and IsEntityAttachedToEntity(peddata, itemdata.cabin) then
				local coordsdata = GetEntityCoords(peddata)

				DetachEntity(peddata, true, false)
				SetEntityCoordsNoOffset(peddata, coordsdata.x, coordsdata.y, coordsdata.z + 0.03, false, false, false)
			end

			LIFT.Digits(itemdata, stopdata)
			LIFT.Cop(itemdata, stopdata)
			LIFT.Arrows(itemdata, nil)

			Wait(350)
			LIFT.Play(itemdata, "lift_ding", 0.0, -itemdata.layout.hd, itemdata.gates[stopdata].z, 2.4, 0.8, false)
			Wait(300)
		end

		LIFT.Lit(itemdata, nil)
		LIFT.Call(itemdata, stopdata, false)

		if itemdata.alive then
			if itemdata.gates[stopdata].open < 0.5 then
				LIFT.Doors(itemdata, itemdata.gates[stopdata], true)
			end

			LIFT.WaitGate(itemdata, itemdata.gates[stopdata], 1.0)
			itemdata.gates[stopdata].closeat = GetGameTimer() + 8000
		end

		itemdata.going = nil
		itemdata.busy = false
	end)

	return true
end

function LIFT.Help(textdata)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringPlayerName(textdata)
	EndTextCommandDisplayHelp(0, false, false, -1)
end

function LIFT.Tick(listdata, textsdata, updata, downdata, speeddata, senddata)
	local peddata = PlayerPedId()
	local coordsdata = GetEntityCoords(peddata)
	local nowdata = GetGameTimer()
	local framedata = GetFrameTime()
	local fastdata = false
	local prompteddata = false

	for _, itemdata in ipairs(listdata or {}) do
		if itemdata.alive then
			local flatdata = #(vector2(coordsdata.x, coordsdata.y) - vector2(itemdata.centre.x, itemdata.centre.y))

			local insidedata = LIFT.Inside(itemdata, coordsdata)
			local _, _, pedzdata = LIFT.Local(itemdata, coordsdata)

			for gateindex, gatedata in ipairs(itemdata.gates) do
				LIFT.Show(itemdata, gatedata, not insidedata and pedzdata - 1.0 > gatedata.z - 1.0 and pedzdata - 1.0 < gatedata.z + 2.6)

				if gatedata.target > 0.5 and gatedata.closeat > 0 and nowdata > gatedata.closeat and not itemdata.busy then
					if LIFT.Inside(itemdata, coordsdata) or LIFT.Landing(itemdata, coordsdata) ~= nil then
						gatedata.closeat = nowdata + 3000
					else
						gatedata.target = 0.0
						gatedata.closeat = 0
						LIFT.Doors(itemdata, gatedata, false)
					end
				end

				if math.abs(gatedata.open - gatedata.target) > 0.0005 then
					fastdata = true

					if gatedata.open < gatedata.target then
						gatedata.open = math.min(gatedata.target, gatedata.open + framedata * 1.1)
					else
						gatedata.open = math.max(gatedata.target, gatedata.open - framedata * 1.1)
					end

					LIFT.Gate(itemdata, gatedata)

					if gateindex == itemdata.stop and not itemdata.moving then
						itemdata.caropen = gatedata.open
						LIFT.Cabin(itemdata)
					end
				end
			end

			if itemdata.busy then
				fastdata = true
			end

			if flatdata < 22.0 then
				fastdata = true

				local lightdata = LIFT.World(itemdata, 0.0, (itemdata.layout.cy0 + itemdata.layout.cy1) / 2.0, itemdata.z + itemdata.layout.CH - 0.35)

				DrawLightWithRange(lightdata.x, lightdata.y, lightdata.z, 255, 243, 226, 2.6, 1.2)
			end

			if not itemdata.busy and itemdata.litstop ~= nil and not LIFT.Inside(itemdata, coordsdata) then
				LIFT.Lit(itemdata, nil)
				LIFT.Cop(itemdata, itemdata.stop)
				itemdata.pick = nil
			end

			if not prompteddata and flatdata < 4.0 and not IsPedInAnyVehicle(peddata, false) then
				local totaldata = #itemdata.data.stops

				if not itemdata.busy and LIFT.Inside(itemdata, coordsdata) then
					if itemdata.pick == nil or itemdata.pick < 1 or itemdata.pick > totaldata or itemdata.pickfor ~= itemdata.stop then
						itemdata.pick = itemdata.stop < totaldata and itemdata.stop + 1 or itemdata.stop - 1
						itemdata.pickfor = itemdata.stop
					end

					for _, controldata in ipairs({14, 15, 16, 17, 37, 172, 173, 174, 175, 241, 242, 261, 262}) do
						DisableControlAction(0, controldata, true)
					end

					LIFT.Help(textsdata.choose)
					LIFT.Lit(itemdata, itemdata.pick)
					LIFT.Cop(itemdata, itemdata.pick)
					prompteddata = true

					if IsDisabledControlJustPressed(0, 172) or IsDisabledControlJustPressed(0, 241) or IsDisabledControlJustPressed(0, 15) then
						if itemdata.pick < totaldata then
							itemdata.pick = itemdata.pick + 1
							LIFT.Button(itemdata, "lift_select", nil)
						end
					elseif IsDisabledControlJustPressed(0, 173) or IsDisabledControlJustPressed(0, 242) or IsDisabledControlJustPressed(0, 14) then
						if itemdata.pick > 1 then
							itemdata.pick = itemdata.pick - 1
							LIFT.Button(itemdata, "lift_select", nil)
						end
					elseif IsControlJustPressed(0, downdata) and itemdata.stop > 1 then
						itemdata.pick = itemdata.stop - 1
						LIFT.Button(itemdata, "lift_button", nil)
						if LIFT.Go(itemdata, itemdata.pick, true, speeddata) and senddata ~= nil then
							senddata(itemdata, itemdata.pick)
						end
					elseif IsControlJustPressed(0, updata) then
						local targetdata = itemdata.pick

						LIFT.Button(itemdata, "lift_button", nil)

						if targetdata == itemdata.stop then
							if itemdata.gates[targetdata].target < 0.5 then
								LIFT.Doors(itemdata, itemdata.gates[targetdata], true)
							end

							itemdata.gates[targetdata].target = 1.0
							itemdata.gates[targetdata].closeat = nowdata + 8000
						elseif LIFT.Go(itemdata, targetdata, true, speeddata) and senddata ~= nil then
							senddata(itemdata, targetdata)
						end
					end
				else
					local landingdata = LIFT.Landing(itemdata, coordsdata)

					if landingdata ~= nil then
						if itemdata.busy then
							LIFT.Help(textsdata.coming)
							prompteddata = true
						elseif itemdata.stop ~= landingdata or itemdata.gates[landingdata].target < 0.5 then
							LIFT.Help(textsdata.call)
							prompteddata = true

							if IsControlJustPressed(0, updata) then
								LIFT.Button(itemdata, "lift_button", landingdata)
								LIFT.Call(itemdata, landingdata, itemdata.stop ~= landingdata)

								if LIFT.Go(itemdata, landingdata, false, speeddata) and senddata ~= nil then
									senddata(itemdata, landingdata)
								end
							end
						end
					end
				end
			end
		end
	end

	return fastdata
end

LIFT.sound.enabled = Config.ElevatorSounds ~= false
LIFT.sound.volume = tonumber(Config.ElevatorVolume) or 0.8

local function LiftTextsRTX()
	local textsdata = Config.Texts or {}

	return {choose = textsdata.elevatorchoose or "~INPUT_CELLPHONE_UP~ ~INPUT_CELLPHONE_DOWN~ Choose a floor~n~~INPUT_CONTEXT~ Go", call = textsdata.elevatorcall or "~INPUT_CONTEXT~ Call the elevator", coming = textsdata.elevatorcoming or "The elevator is on its way"}
end

local function SendLiftRTX(itemdata, stopdata)
	if Config.SyncElevators ~= false then
		TriggerServerEvent(RESOURCE .. ":server:elevator", itemdata.key, itemdata.index, stopdata)
	end
end

local function SpawnFixturesRTX(instancedata)
	for indexdata, fixturedata in ipairs(instancedata.shell.fixtures or {}) do
		local hashdata = GetHashKey(fixturedata.model)

		if LoadModelRTX(hashdata) then
			local atdata = WorldRTX(instancedata, fixturedata.x, fixturedata.y, fixturedata.z)
			local entitydata = CreateObjectNoOffset(hashdata, atdata.x, atdata.y, atdata.z, false, false, false)

			SetEntityHeading(entitydata, (fixturedata.h + instancedata.heading) % 360.0)
			FreezeEntityPosition(entitydata, true)
			instancedata.doors["fx" .. indexdata] = {entity = entitydata, data = fixturedata, base = atdata, fixture = true}
			SetModelAsNoLongerNeeded(hashdata)
		end
	end
end

local function SpawnDoorsRTX(instancedata)
	SpawnFixturesRTX(instancedata)
	LIFT.Clear(instancedata.lifts)
	instancedata.lifts = LIFT.Spawn(instancedata.shell.elevators, instancedata.coords, instancedata.heading, instancedata.key, instancedata.shell.model)

	for indexdata, doordata in ipairs(instancedata.shell.doors or {}) do
		local hashdata = GetHashKey(doordata.model)

		if LoadModelRTX(hashdata) then
			local atdata = WorldRTX(instancedata, doordata.x, doordata.y, doordata.z)
			local headingdata = (doordata.h + instancedata.heading) % 360.0
			local entitydata = CreateObjectNoOffset(hashdata, atdata.x, atdata.y, atdata.z, false, doordata.garage ~= true, false)
			local itemdata = {entity = entitydata, data = doordata, base = atdata, heading = headingdata, open = false, lift = 0.0, locked = doordata.locked == true}

			if doordata.garage == true then
				SetEntityHeading(entitydata, headingdata)
				FreezeEntityPosition(entitydata, true)
				PlaceGarageRTX(itemdata)
			else
				SetEntityCoordsNoOffset(entitydata, atdata.x, atdata.y, atdata.z, false, false, false)
				SetEntityRotation(entitydata, 0.0, 0.0, headingdata, 2, true)
				FreezeEntityPosition(entitydata, true)

				local mindata, maxdata = GetModelDimensions(hashdata)

				itemdata.hinge = mindata.x
				itemdata.angle = 0.0
				itemdata.swing = 0.0
			end

			instancedata.doors[indexdata] = itemdata
			SetModelAsNoLongerNeeded(hashdata)
		else
			print("^3[" .. RESOURCE .. "] door model " .. tostring(doordata.model) .. " is missing, start rtx_shellcreator_assets^0")
		end
	end
end

local function SpawnPropsRTX(instancedata)
	for _, propdata in ipairs(instancedata.shell.props or {}) do
		local hashdata = GetHashKey(propdata.model)

		if LoadModelRTX(hashdata) then
			local atdata = WorldRTX(instancedata, propdata.p[1], propdata.p[2], propdata.p[3])
			local entitydata = CreateObjectNoOffset(hashdata, atdata.x, atdata.y, atdata.z, false, false, false)

			SetEntityRotation(entitydata, propdata.r[1] + 0.0, propdata.r[2] + 0.0, (propdata.r[3] + instancedata.heading) % 360.0, 2, false)
			FreezeEntityPosition(entitydata, true)
			instancedata.props[#instancedata.props + 1] = entitydata
			SetModelAsNoLongerNeeded(hashdata)
		end
	end
end

local function ClearDoorsRTX(instancedata)
	for _, itemdata in pairs(instancedata.doors) do
		if itemdata.hash ~= nil and IsDoorRegisteredWithSystem(itemdata.hash) then
			RemoveDoorFromSystem(itemdata.hash)
		end

		if DoesEntityExist(itemdata.entity) then
			DeleteEntity(itemdata.entity)
		end
	end

	instancedata.doors = {}
	LIFT.Clear(instancedata.lifts)
	instancedata.lifts = {}
end

local function ClearPropsRTX(instancedata)
	for _, entitydata in ipairs(instancedata.props) do
		if DoesEntityExist(entitydata) then
			DeleteEntity(entitydata)
		end
	end

	instancedata.props = {}
end

local function ClearRTX(instancedata)
	ClearDoorsRTX(instancedata)
	ClearPropsRTX(instancedata)
end

local function NewInstanceRTX(entitydata, coordsdata, headingdata, autodata, shelldata)
	NEXTID = NEXTID + 1

	local instancedata = {id = NEXTID, entity = entitydata, coords = coordsdata, heading = (headingdata or 0.0) + 0.0, key = KeyRTX(coordsdata), doors = {}, props = {}, lifts = {}, auto = autodata == true, shell = shelldata, model = shelldata.model}

	INSTANCES[NEXTID] = instancedata

	return instancedata
end

local function OptionsRTX(optionsdata)
	if type(optionsdata) == "number" then
		return {heading = optionsdata}
	end

	if type(optionsdata) == "vector3" or (type(optionsdata) == "table" and optionsdata.z ~= nil and optionsdata.heading == nil) then
		return {heading = optionsdata.z}
	end

	return optionsdata or {}
end

local function AttachRTX(targetdata, optionsdata, modeldata)
	local o = OptionsRTX(optionsdata)
	local entitydata, coordsdata, headingdata = nil, nil, (tonumber(o.heading) or 0.0) + 0.0
	local shelldata = ShellOfRTX(modeldata)

	if type(targetdata) == "number" and DoesEntityExist(targetdata) then
		shelldata = SHELLS[HASHES[GetEntityModel(targetdata)]] or shelldata
		entitydata = targetdata
		coordsdata = GetEntityCoords(targetdata)
		headingdata = o.heading ~= nil and headingdata or GetEntityHeading(targetdata)
	elseif targetdata ~= nil and targetdata.x ~= nil then
		coordsdata = vector3(targetdata.x + 0.0, targetdata.y + 0.0, targetdata.z + 0.0)
	else
		return nil
	end

	if shelldata == nil then
		return nil
	end

	local instancedata = nil

	for _, itemdata in pairs(INSTANCES) do
		if (entitydata ~= nil and itemdata.entity == entitydata) or (entitydata == nil and itemdata.entity == nil and #(itemdata.coords - coordsdata) < 0.05) then
			instancedata = itemdata
		end
	end

	local freshdata = instancedata == nil

	instancedata = instancedata or NewInstanceRTX(entitydata, coordsdata, headingdata, true, shelldata)

	if (o.doors == true or (freshdata and entitydata ~= nil and Config.AutoDoors)) and next(instancedata.doors) == nil then
		SpawnDoorsRTX(instancedata)
	end

	if o.props == true and #instancedata.props == 0 then
		SpawnPropsRTX(instancedata)
	end

	return instancedata.id
end

local function DetachRTX(iddata, doorsdata, propsdata)
	local instancedata = INSTANCES[iddata]

	if instancedata == nil then
		return false
	end

	if doorsdata then
		ClearDoorsRTX(instancedata)
	end

	if propsdata then
		ClearPropsRTX(instancedata)
	end

	if instancedata.auto and next(instancedata.doors) == nil and #instancedata.props == 0 then
		INSTANCES[iddata] = nil
	end

	return true
end

local function SpawnShellRTX(modeldata, coordsdata, optionsdata)
	local o = optionsdata or {}
	local headingdata = (tonumber(o.heading) or 0.0) + 0.0
	local shelldata = ShellOfRTX(modeldata)

	if shelldata == nil or coordsdata == nil then
		print("^1[" .. RESOURCE .. "] there is no shell called " .. tostring(modeldata or DEFAULT) .. " in this resource^0")
		return nil
	end

	local hashdata = GetHashKey(shelldata.model)

	coordsdata = vector3(coordsdata.x + 0.0, coordsdata.y + 0.0, coordsdata.z + 0.0)

	if not LoadModelRTX(hashdata) then
		print("^1[" .. RESOURCE .. "] the shell model " .. shelldata.model .. " could not be loaded^0")
		return nil
	end

	local entitydata = CreateObjectNoOffset(hashdata, coordsdata.x, coordsdata.y, coordsdata.z, o.networked == true, false, false)

	SetEntityHeading(entitydata, headingdata)
	FreezeEntityPosition(entitydata, true)
	SetModelAsNoLongerNeeded(hashdata)

	local instancedata = NewInstanceRTX(entitydata, coordsdata, headingdata, false, shelldata)

	if o.doors ~= false then
		SpawnDoorsRTX(instancedata)
	end

	if o.props ~= false then
		SpawnPropsRTX(instancedata)
	end

	return instancedata.id
end

local function DespawnShellRTX(iddata)
	local instancedata = INSTANCES[iddata]

	if instancedata == nil then
		return false
	end

	ClearRTX(instancedata)

	if not instancedata.auto and DoesEntityExist(instancedata.entity) then
		DeleteEntity(instancedata.entity)
	end

	INSTANCES[iddata] = nil

	return true
end

local function PointRTX(iddata, namedata, indexdata)
	local instancedata = INSTANCES[iddata]
	local pointdata = instancedata ~= nil and (instancedata.shell.points or {})[namedata or "exit"] or nil

	if instancedata == nil or pointdata == nil then
		return nil
	end

	if pointdata.p == nil then
		pointdata = pointdata[indexdata or 1]
	end

	if pointdata == nil or pointdata.p == nil then
		return nil
	end

	return WorldRTX(instancedata, pointdata.p[1], pointdata.p[2], pointdata.p[3]), ((pointdata.h or 0.0) + instancedata.heading) % 360.0
end

local function TeleportRTX(coordsdata, headingdata)
	local peddata = PlayerPedId()

	RequestCollisionAtCoord(coordsdata.x, coordsdata.y, coordsdata.z)
	FreezeEntityPosition(peddata, true)
	SetEntityCoords(peddata, coordsdata.x, coordsdata.y, coordsdata.z + 0.5, false, false, false, false)
	SetEntityHeading(peddata, (headingdata or 0.0) + 0.0)

	local untildata = GetGameTimer() + 5000

	while not HasCollisionLoadedAroundEntity(peddata) and GetGameTimer() < untildata do
		Wait(0)
	end

	FreezeEntityPosition(peddata, false)
end

local function EnterShellRTX(modeldata, coordsdata, optionsdata)
	if ShellOfRTX(modeldata) == nil or coordsdata == nil then
		return SpawnShellRTX(modeldata, coordsdata, optionsdata)
	end

	DoScreenFadeOut(400)

	while not IsScreenFadedOut() do
		Wait(0)
	end

	local iddata = SpawnShellRTX(modeldata, coordsdata, optionsdata)

	if iddata ~= nil then
		local atdata, headingdata = PointRTX(iddata, "exit")

		TeleportRTX(atdata or vector3(coordsdata.x, coordsdata.y, coordsdata.z + 1.0), headingdata)
	end

	DoScreenFadeIn(400)

	return iddata
end

local function LeaveShellRTX(iddata, coordsdata, headingdata)
	DoScreenFadeOut(400)

	while not IsScreenFadedOut() do
		Wait(0)
	end

	if coordsdata ~= nil then
		TeleportRTX(vector3(coordsdata.x + 0.0, coordsdata.y + 0.0, coordsdata.z + 0.0), headingdata)
	end

	DespawnShellRTX(iddata)
	DoScreenFadeIn(400)
end

local function InsideRTX()
	local coordsdata = GetEntityCoords(PlayerPedId())

	for iddata, instancedata in pairs(INSTANCES) do
		local boundsdata = instancedata.shell.bounds

		if boundsdata == nil then
			if #(coordsdata - instancedata.coords) < 30.0 then
				return iddata
			end
		else
			local angledata = -math.rad(instancedata.heading)
			local dx, dy = coordsdata.x - instancedata.coords.x, coordsdata.y - instancedata.coords.y
			local lx = dx * math.cos(angledata) - dy * math.sin(angledata)
			local ly = dx * math.sin(angledata) + dy * math.cos(angledata)
			local lz = coordsdata.z - instancedata.coords.z

			if lx >= boundsdata.min[1] and lx <= boundsdata.max[1] and ly >= boundsdata.min[2] and ly <= boundsdata.max[2] and lz >= boundsdata.min[3] - 1.0 and lz <= boundsdata.max[3] + 1.0 then
				return iddata
			end
		end
	end

	return false
end

local function SetDoorRTX(instancedata, indexdata, opendata)
	local itemdata = instancedata.doors[indexdata]

	if itemdata == nil or itemdata.locked then
		return
	end

	itemdata.open = opendata == true

	if itemdata.data.garage == true then
		itemdata.target = itemdata.open and (itemdata.data.height or 2.4) - 0.1 or 0.0
	elseif DoesEntityExist(itemdata.entity) then
		itemdata.swing = itemdata.open and 95.0 or 0.0
	end
end

local function PlaceSwingRTX(itemdata)
	local hrad = math.rad(itemdata.heading)
	local rightdata = vector3(math.cos(hrad), math.sin(hrad), 0.0)
	local hingepos = itemdata.base + rightdata * itemdata.hinge
	local arad = math.rad(itemdata.angle)
	local offx, offy = -rightdata.x * itemdata.hinge, -rightdata.y * itemdata.hinge

	SetEntityCoordsNoOffset(itemdata.entity, hingepos.x + offx * math.cos(arad) - offy * math.sin(arad), hingepos.y + offx * math.sin(arad) + offy * math.cos(arad), itemdata.base.z, false, false, false)
	SetEntityRotation(itemdata.entity, 0.0, 0.0, itemdata.heading + itemdata.angle, 2, true)
end

local function SwingRTX(itemdata, coordsdata, framedata)
	if itemdata.locked or itemdata.hinge == nil or not DoesEntityExist(itemdata.entity) then
		return false
	end

	local distancedata = #(coordsdata - (itemdata.base + vector3(0.0, 0.0, 1.0)))

	if distancedata < 1.5 and itemdata.swing == 0.0 then
		local hrad = math.rad(itemdata.heading)
		local sidedata = (coordsdata.x - itemdata.base.x) * -math.sin(hrad) + (coordsdata.y - itemdata.base.y) * math.cos(hrad)
		local signdata = itemdata.hinge < 0.0 and 1.0 or -1.0

		itemdata.swing = (sidedata > 0.0 and -95.0 or 95.0) * signdata
	elseif distancedata > 2.6 and itemdata.swing ~= 0.0 then
		itemdata.swing = 0.0
	end

	if math.abs(itemdata.angle - itemdata.swing) < 0.01 then
		return distancedata < 4.0
	end

	local stepdata = 320.0 * framedata

	if itemdata.angle < itemdata.swing then
		itemdata.angle = math.min(itemdata.swing, itemdata.angle + stepdata)
	else
		itemdata.angle = math.max(itemdata.swing, itemdata.angle - stepdata)
	end

	PlaceSwingRTX(itemdata)
	SetEntityCollision(itemdata.entity, math.abs(itemdata.angle) < 60.0, true)

	return true
end

local function DoorActionRTX(iddata, indexdata, opendata)
	local instancedata = INSTANCES[iddata]

	if instancedata == nil then
		return
	end

	SetDoorRTX(instancedata, indexdata, opendata)

	if Config.SyncDoors then
		TriggerServerEvent(RESOURCE .. ":server:door", instancedata.key, indexdata, opendata == true)
	end
end

RegisterNetEvent(RESOURCE .. ":client:elevator", function(keydata, indexdata, stopdata)
	for _, instancedata in pairs(INSTANCES) do
		if instancedata.key == keydata then
			for _, itemdata in ipairs(instancedata.lifts or {}) do
				if itemdata.index == indexdata then
					CreateThread(function()
						local untildata = GetGameTimer() + 15000

						while itemdata.alive and itemdata.busy and GetGameTimer() < untildata do
							Wait(100)
						end

						LIFT.Go(itemdata, stopdata, true, Config.ElevatorSpeed)
					end)
				end
			end
		end
	end
end)

CreateThread(function()
	while true do
		local sleepdata = 500

		for _, instancedata in pairs(INSTANCES) do
			if instancedata.lifts ~= nil and #instancedata.lifts > 0 and LIFT.Tick(instancedata.lifts, LiftTextsRTX(), Config.ElevatorUp or 38, Config.ElevatorDown or 47, Config.ElevatorSpeed or 1.5, SendLiftRTX) then
				sleepdata = 0
			end
		end

		Wait(sleepdata)
	end
end)

RegisterNetEvent(RESOURCE .. ":client:door", function(keydata, indexdata, opendata)
	for _, instancedata in pairs(INSTANCES) do
		if instancedata.key == keydata then
			SetDoorRTX(instancedata, indexdata, opendata)
		end
	end
end)

CreateThread(function()
	while true do
		local sleepdata = 700
		local coordsdata = GetEntityCoords(PlayerPedId())
		local bestdata, bestinstance, bestindex = nil, nil, nil

		for iddata, instancedata in pairs(INSTANCES) do
			for indexdata, itemdata in pairs(instancedata.doors) do
				if itemdata.target ~= nil and DoesEntityExist(itemdata.entity) then
					sleepdata = 0
					itemdata.lift = itemdata.lift + math.max(-0.035, math.min(0.035, itemdata.target - itemdata.lift))
					PlaceGarageRTX(itemdata)

					if math.abs(itemdata.target - itemdata.lift) < 0.001 then
						itemdata.target = nil
					end
				end

				if itemdata.data.garage ~= true and SwingRTX(itemdata, coordsdata, GetFrameTime()) then
					sleepdata = 0
				end

				local centredata = itemdata.base + vector3(0.0, 0.0, 1.0)
				local distancedata = #(coordsdata - centredata)

				if distancedata < 6.0 then
					sleepdata = math.min(sleepdata, 200)
				end

				if itemdata.data.garage == true and distancedata < Config.DoorDistance and (bestdata == nil or distancedata < bestdata) then
					bestdata, bestinstance, bestindex = distancedata, iddata, indexdata
				end
			end
		end

		if bestdata ~= nil then
			sleepdata = 0

			local itemdata = INSTANCES[bestinstance].doors[bestindex]
			local textdata = itemdata.open and Config.Texts.garageclose or Config.Texts.garageopen

			BeginTextCommandDisplayHelp("STRING")
			AddTextComponentSubstringPlayerName("~INPUT_CONTEXT~ " .. textdata)
			EndTextCommandDisplayHelp(0, false, false, -1)

			if IsControlJustPressed(0, Config.DoorKey) then
				DoorActionRTX(bestinstance, bestindex, not itemdata.open)
			end
		end

		Wait(sleepdata)
	end
end)

CreateThread(function()
	while true do
		for iddata, instancedata in pairs(INSTANCES) do
			if instancedata.auto and instancedata.entity ~= nil and not DoesEntityExist(instancedata.entity) then
				ClearRTX(instancedata)
				INSTANCES[iddata] = nil
			end
		end

		if Config.AutoDoors or Config.AutoProps then
			local coordsdata = GetEntityCoords(PlayerPedId())

			for hashdata, modeldata in pairs(HASHES) do
				local founddata = GetClosestObjectOfType(coordsdata.x, coordsdata.y, coordsdata.z, Config.AutoDistance + 0.0, hashdata, false, false, false)

				if founddata ~= 0 and DoesEntityExist(founddata) then
					local knowndata = false

					for _, instancedata in pairs(INSTANCES) do
						if instancedata.entity == founddata then
							knowndata = true
						end
					end

					if not knowndata then
						local instancedata = NewInstanceRTX(founddata, GetEntityCoords(founddata), GetEntityHeading(founddata), true, SHELLS[modeldata])

						if Config.AutoDoors then
							SpawnDoorsRTX(instancedata)
						end

						if Config.AutoProps then
							SpawnPropsRTX(instancedata)
						end
					end
				end
			end
		end

		Wait(1000)
	end
end)

local function TellToolkitRTX()
	for hashdata, modeldata in pairs(HASHES) do
		TriggerEvent("rtx_shellcreator:client:shellResource", RESOURCE, hashdata, modeldata)
	end
end

AddEventHandler("rtx_shellcreator:client:shellAsk", TellToolkitRTX)

CreateThread(TellToolkitRTX)

local function ModelArgsRTX(firstdata, seconddata, thirddata)
	if type(firstdata) == "string" then
		return firstdata, seconddata, thirddata
	end

	return nil, firstdata, seconddata
end

AddEventHandler("onResourceStop", function(namedata)
	if namedata ~= RESOURCE then
		return
	end

	for iddata, _ in pairs(INSTANCES) do
		DespawnShellRTX(iddata)
	end
end)

exports("SpawnShell", function(...) local modeldata, coordsdata, optionsdata = ModelArgsRTX(...) return SpawnShellRTX(modeldata, coordsdata, optionsdata) end)
exports("SpawnFurniture", function(...) local modeldata, targetdata, optionsdata = ModelArgsRTX(...) return AttachRTX(targetdata, {props = true, heading = OptionsRTX(optionsdata).heading}, modeldata) end)
exports("SpawnDoors", function(...) local modeldata, targetdata, optionsdata = ModelArgsRTX(...) return AttachRTX(targetdata, {doors = true, heading = OptionsRTX(optionsdata).heading}, modeldata) end)
exports("SpawnBuiltIn", function(...) local modeldata, targetdata, optionsdata = ModelArgsRTX(...) local o = OptionsRTX(optionsdata) return AttachRTX(targetdata, {doors = o.doors ~= false, props = o.props ~= false, heading = o.heading}, modeldata) end)
exports("DespawnFurniture", function(iddata) return DetachRTX(iddata, false, true) end)
exports("DespawnDoors", function(iddata) return DetachRTX(iddata, true, false) end)
exports("DespawnBuiltIn", function(iddata) return DetachRTX(iddata, true, true) end)
exports("DespawnShell", DespawnShellRTX)
exports("EnterShell", function(...) local modeldata, coordsdata, optionsdata = ModelArgsRTX(...) return EnterShellRTX(modeldata, coordsdata, optionsdata) end)
exports("LeaveShell", LeaveShellRTX)
exports("IsInsideShell", InsideRTX)
exports("GetShellData", function(modeldata) return ShellOfRTX(type(modeldata) == "string" and modeldata or nil) end)
exports("GetShells", function() local listdata = {} for modeldata, _ in pairs(SHELLS) do listdata[#listdata + 1] = modeldata end table.sort(listdata) return listdata end)
exports("GetShellModel", function(iddata) return INSTANCES[iddata] and INSTANCES[iddata].model or nil end)
exports("GetShellEntity", function(iddata) return INSTANCES[iddata] and INSTANCES[iddata].entity or nil end)
exports("GetPointCoords", PointRTX)
exports("GetShellProps", function(iddata) return INSTANCES[iddata] and INSTANCES[iddata].props or {} end)
exports("GetShellDoors", function(iddata)
	local listdata = {}

	for indexdata, itemdata in pairs(INSTANCES[iddata] and INSTANCES[iddata].doors or {}) do
		if not itemdata.fixture then
			listdata[#listdata + 1] = {index = indexdata, entity = itemdata.entity, open = itemdata.open, locked = itemdata.locked, garage = itemdata.data.garage == true}
		end
	end

	return listdata
end)
exports("SetDoorOpen", DoorActionRTX)
exports("SetDoorLocked", function(iddata, indexdata, lockeddata)
	local itemdata = INSTANCES[iddata] and INSTANCES[iddata].doors[indexdata] or nil

	if itemdata == nil then
		return false
	end

	if lockeddata and itemdata.open then
		SetDoorRTX(INSTANCES[iddata], indexdata, false)
	end

	itemdata.locked = lockeddata == true

	if itemdata.data.garage ~= true and DoesEntityExist(itemdata.entity) then
		if itemdata.locked then
			SetEntityRotation(itemdata.entity, 0.0, 0.0, itemdata.heading, 2, true)
		end

		FreezeEntityPosition(itemdata.entity, itemdata.locked)
	end

	return true
end)
