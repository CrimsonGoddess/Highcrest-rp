-- Highcrest mechanic: the design bay. Customers design a build on their own car (live preview);
-- on-duty mechanics drive an ordered car into the same bay, press E and fit each part from the
-- same menu. The tablet (further down) is for quotes, orders, prices and clocking in.

local design      -- active bay session (mode = 'design' or 'work')
local tabletOpen = false

local function trimPlate(plate)
    return plate and plate:gsub('^%s+', ''):gsub('%s+$', ''):upper() or ''
end

local function modLabel(vehicle, slot, index, fallback)
    local text = GetModTextLabel(vehicle, slot, index)
    local label = text and GetLabelText(text) or nil
    if not label or label == 'NULL' or label == '' then return ('%s %d'):format(fallback, index + 1) end
    return label
end

local illegal = {}
for name, list in pairs(Config.lists) do
    illegal[name] = {}
    for _, entry in ipairs(list) do if entry[3] then illegal[name][entry[1]] = true end end
end

-- Prices come from the shop's price list (set by its boss), falling back to the config.
local function priceFor(item, value)
    local prices = design and design.prices or Config.prices
    if item.kind == 'level' then
        local levels = prices.levels and prices.levels[item.key] or Config.prices.levels[item.key]
        return levels[value + 2] or levels[#levels]
    end
    if item.key == 'modTurbo' then return value and prices.turbo or 0 end
    if item.kind == 'toggle' and value == false then return 0 end
    if item.kind == 'paint' then return type(value) == 'table' and (prices.customPaint or Config.prices.customPaint) or prices.color end
    if item.kind == 'color' then return prices.color end
    if item.kind == 'list' and illegal[item.list][value] then return prices.illegalTint or Config.prices.illegalTint end
    return prices.cosmetic
end

local NEON_PRESETS = {
    { { false, false, false, false }, 'Off' },
    { { true, true, true, true }, 'All sides' },
    { { true, true, false, false }, 'Sides only' },
    { { false, false, true, true }, 'Front & back' },
}

local function hexToRgb(hex)
    return { tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16) }
end

-- Build the option list for one catalogue item on this car (nil if the car can't take it).
local function itemOptions(vehicle, item)
    local options = {}
    local slot = Config.modSlots[item.key]
    if item.kind == 'mod' then
        local count = GetNumVehicleMods(vehicle, slot)
        if count <= 0 then return nil end
        options[1] = { value = -1, label = 'Stock' }
        for i = 0, count - 1 do options[#options + 1] = { value = i, label = modLabel(vehicle, slot, i, item.label) } end
    elseif item.kind == 'level' then
        local count = math.min(#Config.prices.levels[item.key] - 1, GetNumVehicleMods(vehicle, slot))
        if count <= 0 then return nil end
        options[1] = { value = -1, label = 'Stock' }
        for i = 0, count - 1 do options[#options + 1] = { value = i, label = ('Level %d'):format(i + 1) } end
    elseif item.kind == 'toggle' then
        if item.key == 'repair' then
            -- Only offered when the car is actually damaged.
            if GetVehicleEngineHealth(vehicle) >= 990.0 and GetVehicleBodyHealth(vehicle) >= 990.0 then return nil end
            options = { { value = false, label = 'Not needed' }, { value = true, label = 'Repair it' } }
        else
            options = { { value = false, label = 'None' }, { value = true, label = 'Fitted' } }
        end
    elseif item.kind == 'paint' then
        for _, group in ipairs(Config.paintGroups) do
            for _, c in ipairs(group.colors) do
                options[#options + 1] = { value = c[1], label = c[2], group = group.label, swatch = hexToRgb(c[3]) }
            end
        end
        for _, w in ipairs(Config.wildPaints) do
            options[#options + 1] = { value = w[1], label = w[2], group = 'Wild', swatch = { w[1][1], w[1][2], w[1][3] }, finish = w[1][4] }
        end
    elseif item.kind == 'color' then
        for _, c in ipairs(Config.colors) do options[#options + 1] = { value = c[1], label = c[2], swatch = c[3] and hexToRgb(c[3]) } end
    elseif item.kind == 'list' then
        for _, c in ipairs(Config.lists[item.list]) do
            options[#options + 1] = { value = c[1], label = c[2], illegal = c[3] == true or nil,
                swatch = item.list == 'smokeColors' and Config.smokeRgb[c[1]] or nil }
        end
    elseif item.kind == 'neon' then
        for _, n in ipairs(NEON_PRESETS) do options[#options + 1] = { value = n[1], label = n[2] } end
    elseif item.kind == 'neoncolor' then
        for _, n in ipairs(Config.neonColors) do options[#options + 1] = { value = n[1], label = n[2], swatch = n[1] } end
    end
    for _, option in ipairs(options) do option.price = priceFor(item, option.value) end
    return options
end

local function buildCatalogue(vehicle, props)
    local tabs = {}
    for _, tab in ipairs(Config.catalogue) do
        local items = {}
        for _, item in ipairs(tab.items) do
            local options = itemOptions(vehicle, item)
            if options then
                items[#items + 1] = {
                    key = item.key, label = item.label, kind = item.kind, options = options,
                    current = Config.fromProps(item.key, props),
                    customPrice = item.kind == 'paint' and priceFor(item, { 0, 0, 0, 0 }) or nil,
                }
            end
        end
        if #items > 0 then tabs[#tabs + 1] = { id = tab.id, label = tab.label, items = items } end
    end
    return tabs
end

---------------------------------------------------------------------------
-- Camera: orbit the car; glides between views in work mode.
---------------------------------------------------------------------------

local function camPosition()
    local pos = GetEntityCoords(design.vehicle)
    local rad = math.rad(design.camAngle)
    return vec3(pos.x + math.cos(rad) * design.camDist, pos.y + math.sin(rad) * design.camDist, pos.z + design.camHeight), pos
end

local function updateCamera()
    if not design then return end
    local camPos, pos = camPosition()
    SetCamCoord(design.cam, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(design.cam, pos.x, pos.y, pos.z + 0.3)
end

-- Glide to a new view with a second camera, then swap.
local function glideCamera(angle, dist, height, ms)
    if not design then return end
    design.camAngle, design.camDist, design.camHeight = GetEntityHeading(design.vehicle) + angle, dist, height
    local camPos, pos = camPosition()
    local nextCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(nextCam, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(nextCam, pos.x, pos.y, pos.z + 0.3)
    SetCamActiveWithInterp(nextCam, design.cam, ms or 900, 1, 1)
    local old = design.cam
    design.cam = nextCam
    SetTimeout((ms or 900) + 50, function() DestroyCam(old, false) end)
end

---------------------------------------------------------------------------
-- Preview: the car shows the original plus every change picked so far.
---------------------------------------------------------------------------

local function previewProps(d)
    local props = {}
    for k, v in pairs(d.original) do props[k] = v end
    if d.draft.wheels ~= nil and d.draft.modFrontWheels == nil then props.modFrontWheels = -1 end
    for key, value in pairs(d.draft) do
        -- The design preview never repairs the car (that would be a free fix); only fitting it does.
        if key == 'repair' and d.mode ~= 'work' then goto continue end
        for prop, v in pairs(Config.toProps(key, value)) do props[prop] = v end
        ::continue::
    end
    return props
end

local function applyPreview()
    if not design or not DoesEntityExist(design.vehicle) then return end
    local props = previewProps(design)
    -- A custom colour going back to a numbered one needs the custom colour cleared first.
    if type(props.color1) == 'number' then ClearVehicleCustomPrimaryColour(design.vehicle) end
    if type(props.color2) == 'number' then ClearVehicleCustomSecondaryColour(design.vehicle) end
    if design.mode == 'work' and design.draft.repair then
        SetVehicleFixed(design.vehicle)
        SetVehicleDeformationFixed(design.vehicle)
    end
    lib.setVehicleProperties(design.vehicle, props)
end

local workProp

local function stopWorking()
    ClearPedTasks(cache.ped)
    if workProp and DoesEntityExist(workProp) then DeleteEntity(workProp) end
    workProp = nil
end


local function endDesign()
    if not design then return end
    local d = design
    design = nil
    if DoesEntityExist(d.vehicle) then
        -- Work that wasn't finished (and paid) comes off again.
        lib.setVehicleProperties(d.vehicle, d.finalProps or d.original)
        SetVehicleDoorShut(d.vehicle, 4, false)
        FreezeEntityPosition(d.vehicle, false)
    end
    stopWorking()
    RenderScriptCams(false, true, 700, true, false)
    DestroyCam(d.cam, false)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeDesign' })
end

-- Open the bay for a car: from the driver's seat (E), or on foot by targeting the car.
local function startBay(shopId, target)
    if design then return end
    local vehicle = target or cache.vehicle
    if not vehicle or not DoesEntityExist(vehicle) then return end
    if not target and GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then return end
    local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
    if target and not NetworkHasControlOfEntity(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local timeout = GetGameTimer() + 1500
        while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do Wait(50) end
    end
    local ok, reason, prices, order = lib.callback.await('highcrest_mechanic:canDesign', false, shopId, plate, NetworkGetNetworkIdFromEntity(vehicle))
    if not ok then return lib.notify({ title = 'Mechanic', description = reason, type = 'error', duration = 8000 }) end

    local props = lib.getVehicleProperties(vehicle)
    SetVehicleModKit(vehicle, 0)
    FreezeEntityPosition(vehicle, true)
    SetVehicleEngineOn(vehicle, false, true, true)

    design = {
        mode = order and 'work' or 'design', shop = shopId, vehicle = vehicle, plate = plate,
        original = props, draft = {}, prices = prices, order = order,
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true), camAngle = GetEntityHeading(vehicle) + 135.0,
        camDist = 6.0, camHeight = 1.4,
    }
    updateCamera()
    SetCamActive(design.cam, true)
    RenderScriptCams(true, true, 800, true, false)
    SetNuiFocus(true, true)

    local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
    if order then
        -- Parts already fitted earlier (and not undone) go back on.
        for _, line in ipairs(order.lines) do
            if line.fitted and line.raw ~= nil then design.draft[line.key] = line.raw end
        end
        applyPreview()
        order.damaged = GetVehicleEngineHealth(vehicle) < 990.0 or GetVehicleBodyHealth(vehicle) < 990.0
        SendNUIMessage({ action = 'openWork', shop = Config.shops[shopId].label, vehicle = vehicleName, plate = plate, order = order })
    else
        SendNUIMessage({
            action = 'openDesign', shop = Config.shops[shopId].label, vehicle = vehicleName, plate = plate,
            tabs = buildCatalogue(vehicle, props), finishes = Config.finishes,
        })
    end
end

RegisterNUICallback('preview', function(data, cb)
    cb(1)
    if not design or design.mode ~= 'design' or type(data) ~= 'table' or not data.key then return end
    design.draft[data.key] = data.value
    if data.key == 'wheels' then
        -- A new rim category has its own rim list.
        design.draft.modFrontWheels = nil
        applyPreview()
        local item = { key = 'modFrontWheels', label = 'Rims', kind = 'mod' }
        SendNUIMessage({ action = 'updateItem', item = { key = item.key, label = item.label, kind = item.kind, options = itemOptions(design.vehicle, item) or {}, current = -1 } })
        return
    end
    applyPreview()
end)

RegisterNUICallback('reset', function(data, cb)
    cb(1)
    if not design or design.mode ~= 'design' or type(data) ~= 'table' or not data.key then return end
    design.draft[data.key] = nil
    applyPreview()
end)

RegisterNUICallback('camera', function(data, cb)
    cb(1)
    if not design or design.busy or type(data) ~= 'table' then return end
    design.camAngle = design.camAngle + (tonumber(data.dx) or 0) * 0.35
    design.camHeight = math.max(0.2, math.min(3.5, design.camHeight + (tonumber(data.dy) or 0) * 0.01))
    design.camDist = math.max(3.0, math.min(10.0, design.camDist + (tonumber(data.zoom) or 0) * 0.004))
    updateCamera()
end)

RegisterNUICallback('submitDesign', function(_, cb)
    if not design or design.mode ~= 'design' then return cb({ ok = false }) end
    local d = design
    local ok, idOrReason, parts = lib.callback.await('highcrest_mechanic:submit', false, d.shop, d.plate,
        GetDisplayNameFromVehicleModel(GetEntityModel(d.vehicle)), d.draft)
    cb({ ok = ok, message = ok and ('Order #%d sent. Parts: $%d. A mechanic will quote the labour.'):format(idOrReason, parts) or idOrReason })
    if ok then
        endDesign()
        lib.notify({ title = 'Mechanic', description = ('Order #%d sent. Leave your car at the shop; you will get a quote to approve.'):format(idOrReason), type = 'success', duration = 9000 })
    end
end)

RegisterNUICallback('cancelDesign', function(_, cb)
    cb(1)
    if design and design.busy then return end
    endDesign()
end)

---------------------------------------------------------------------------
-- Work mode: the mechanic clicks a part, the camera glides to it, it's fitted.
---------------------------------------------------------------------------

local tabOf = {}
for _, tab in ipairs(Config.catalogue) do
    for _, item in ipairs(tab.items) do tabOf[item.key] = tab.id end
end

-- Where the mechanic stands and what they do for each kind of part.
local WORK_ANIMS = {
    performance = { spot = 'front', dict = 'mini@repair', clip = 'fixing_a_player' },
    lights = { spot = 'front', dict = 'mini@repair', clip = 'fixing_a_ped' },
    wheels = { spot = 'wheel', dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' },
    body = { spot = 'side', scenario = 'WORLD_HUMAN_WELDING' },
    paint = { spot = 'side', dict = 'switch@franklin@lamar_tagging_wall', clip = 'lamar_tagging_wall_loop_lamar', prop = 'prop_cs_spray_can' },
    extras = { spot = 'rear', dict = 'mini@repair', clip = 'fixing_a_ped' },
    repair = { spot = 'front', dict = 'mini@repair', clip = 'fixing_a_player' },
}

-- Get out, walk to the part and start working on it.
local function goToWork(vehicle, tab)
    local anim = WORK_ANIMS[tab] or WORK_ANIMS.body
    local ped = cache.ped
    if IsPedInVehicle(ped, vehicle, false) then
        TaskLeaveVehicle(ped, vehicle, 0)
        local timeout = GetGameTimer() + 3500
        while IsPedInVehicle(ped, vehicle, false) and GetGameTimer() < timeout do Wait(100) end
        Wait(400)
    end

    local min, max = GetModelDimensions(GetEntityModel(vehicle))
    local stand, look
    if anim.spot == 'front' then
        stand, look = vec3(0.0, max.y + 0.55, 0.0), vec3(0.0, max.y - 0.4, 0.0)
    elseif anim.spot == 'rear' then
        stand, look = vec3(0.0, min.y - 0.55, 0.0), vec3(0.0, min.y + 0.4, 0.0)
    elseif anim.spot == 'wheel' then
        stand, look = vec3(min.x - 0.45, max.y * 0.62, 0.0), vec3(min.x + 0.2, max.y * 0.62, 0.0)
    else
        stand, look = vec3(min.x - 0.75, 0.0, 0.0), vec3(0.0, 0.0, 0.0)
    end
    local standAt = GetOffsetFromEntityInWorldCoords(vehicle, stand.x, stand.y, stand.z)
    local lookAt = GetOffsetFromEntityInWorldCoords(vehicle, look.x, look.y, look.z)
    local heading = GetHeadingFromVector_2d(lookAt.x - standAt.x, lookAt.y - standAt.y)

    TaskGoStraightToCoord(ped, standAt.x, standAt.y, standAt.z, 1.0, 6000, heading, 0.2)
    local timeout = GetGameTimer() + 6000
    while #(GetEntityCoords(ped).xy - standAt.xy) > 0.45 and GetGameTimer() < timeout do Wait(100) end
    SetEntityHeading(ped, heading)

    if anim.scenario then
        TaskStartScenarioInPlace(ped, anim.scenario, 0, true)
    else
        lib.requestAnimDict(anim.dict)
        TaskPlayAnim(ped, anim.dict, anim.clip, 3.0, 3.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(anim.dict)
        if anim.prop then
            lib.requestModel(anim.prop)
            local pos = GetEntityCoords(ped)
            workProp = CreateObject(joaat(anim.prop), pos.x, pos.y, pos.z, true, true, false)
            AttachEntityToEntity(workProp, ped, GetPedBoneIndex(ped, 57005), 0.11, 0.05, -0.06, 28.0, 30.0, 0.0, true, true, false, true, 1, true)
            SetModelAsNoLongerNeeded(joaat(anim.prop))
        end
    end
end

RegisterNUICallback('fitPart', function(data, cb)
    if not design or design.mode ~= 'work' or design.busy or type(data) ~= 'table' then return cb({ ok = false }) end
    local d = design
    local netId = NetworkGetNetworkIdFromEntity(d.vehicle)
    local ok, seconds = lib.callback.await('highcrest_mechanic:fitPart', false, d.order.id, data.key, netId, 'start')
    if not ok then return cb({ ok = false, message = seconds }) end

    d.busy = true
    cb({ ok = true })
    local tab = tabOf[data.key] or 'body'
    local view = Config.workViews[tab] or Config.workViews.body
    glideCamera(view.angle, view.dist, view.height, 1000)
    if view.hood then SetVehicleDoorOpen(d.vehicle, 4, false, false) end

    CreateThread(function()
        goToWork(d.vehicle, tab)
        if design ~= d then return stopWorking() end
        SendNUIMessage({ action = 'partStarted', key = data.key, seconds = seconds })
        Wait(seconds * 1000)
        stopWorking()
        if design ~= d then return end
        local done, props, stock = lib.callback.await('highcrest_mechanic:fitPart', false, d.order.id, data.key, netId, 'finish')
        if view.hood then SetVehicleDoorShut(d.vehicle, 4, false) end
        d.busy = false
        if done then
            local raw
            for _, line in ipairs(d.order.lines) do if line.key == data.key then raw = line.raw end end
            d.draft[data.key] = raw
            applyPreview()
            PlaySoundFrontend(-1, 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
        end
        SendNUIMessage({ action = 'partDone', key = data.key, ok = done == true, message = not done and props or nil, stock = done and stock or nil })
    end)
end)

-- Mechanic: add a full repair to the order (the car came in damaged).
RegisterNUICallback('addRepair', function(_, cb)
    if not design or design.mode ~= 'work' or design.busy then return cb({ ok = false }) end
    local d = design
    local ok, line, parts = lib.callback.await('highcrest_mechanic:addRepair', false, d.order.id, NetworkGetNetworkIdFromEntity(d.vehicle))
    if not ok then return cb({ ok = false, message = line }) end
    d.order.lines[#d.order.lines + 1] = line
    d.order.parts = parts
    d.order.hasRepair = true
    cb({ ok = true, line = line, parts = parts })
end)

RegisterNUICallback('finishWork', function(_, cb)
    if not design or design.mode ~= 'work' or design.busy then return cb({ ok = false }) end
    local d = design
    local ok, applied, earned, total = lib.callback.await('highcrest_mechanic:complete', false, d.order.id, NetworkGetNetworkIdFromEntity(d.vehicle))
    if not ok then return cb({ ok = false, message = applied }) end
    local final = {}
    for k, v in pairs(d.original) do final[k] = v end
    for k, v in pairs(applied) do final[k] = v end
    d.finalProps = final
    cb({ ok = true })
    glideCamera(160.0, 7.0, 1.6, 1400)
    lib.notify({ title = 'Mechanic', description = ('Order #%d done. The customer paid $%d and you earned $%d.'):format(d.order.id, total or 0, earned or 0), type = 'success', duration = 9000 })
    SetTimeout(1800, function() if design == d then endDesign() end end)
end)

-- Personal lockers (registered per player on the server, mechanic job only).
for shopId, shop in pairs(Config.shops) do
    if shop.locker then
        exports.ox_target:addSphereZone({
            coords = shop.locker.xyz,
            radius = 1.0,
            options = {{
                name = 'mechlocker_' .. shopId,
                label = 'Open my locker',
                icon = 'fa-solid fa-lock',
                distance = 2.0,
                groups = { [Config.job] = 0 },
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', 'mechlocker_' .. shopId)
                end,
            }},
        })
    end
end

-- Stalls: a shop blip, [E] from the driver's seat (no ground markers; the RFC interior
-- shows the stalls), and "Open in the bay" when targeting a car parked in a stall.
local function stallAt(coords)
    for shopId, shop in pairs(Config.shops) do
        for _, bay in ipairs(shop.bays or { shop.bay }) do
            if #(coords - bay.xyz) <= shop.bayRadius then return shopId end
        end
    end
end

for shopId, shop in pairs(Config.shops) do
    local blip = AddBlipForCoord(shop.bay.x, shop.bay.y, shop.bay.z)
    SetBlipSprite(blip, 446)
    SetBlipColour(blip, 47)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(shop.label)
    EndTextCommandSetBlipName(blip)

    for _, bay in ipairs(shop.bays or { shop.bay }) do

        lib.zones.sphere({
            coords = bay.xyz,
            radius = shop.bayRadius,
            inside = function()
                if design or not cache.vehicle or GetPedInVehicleSeat(cache.vehicle, -1) ~= cache.ped then
                    if lib.isTextUIOpen() then lib.hideTextUI() end
                    return
                end
                if not lib.isTextUIOpen() then lib.showTextUI(('[E] Open the bay · %s'):format(shop.label), { icon = 'wrench' }) end
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    startBay(shopId)
                end
            end,
            onExit = function() lib.hideTextUI() end,
        })
    end
end

exports.ox_target:addGlobalVehicle({
    {
        name = 'highcrest_mechanic_bay',
        icon = 'fa-solid fa-screwdriver-wrench',
        label = 'Open in the bay',
        distance = 3.0,
        canInteract = function(entity)
            return not design and not cache.vehicle and stallAt(GetEntityCoords(entity)) ~= nil
        end,
        onSelect = function(data)
            local shopId = stallAt(GetEntityCoords(data.entity))
            if shopId then startBay(shopId, data.entity) end
        end,
    },
})

-- Customer: a mechanic sent a quote.
RegisterNetEvent('highcrest_mechanic:client:quote', function(quote)
    local lines = {}
    for _, line in ipairs(quote.lines or {}) do
        lines[#lines + 1] = ('- %s: %s ($%d)'):format(line.label, line.value or '', line.price or 0)
    end
    local answer = lib.alertDialog({
        header = ('Quote for order #%d (%s)'):format(quote.id, quote.plate),
        content = ('%s\n\n**Parts:** $%d  \n**Labour (%s):** $%d  \n**Total:** $%d\n\nYou pay when the work is finished.'):format(
            table.concat(lines, '\n'), quote.parts, quote.mechanic, quote.labour, quote.parts + quote.labour),
        centered = true,
        cancel = true,
        labels = { confirm = 'Approve', cancel = 'Decline' },
    })
    TriggerServerEvent('highcrest_mechanic:server:respond', quote.id, answer == 'confirm')
end)

-- Mechanic tablet.
local function openTablet()
    if tabletOpen or design then return end
    local data = lib.callback.await('highcrest_mechanic:orders', false)
    if not data then return lib.notify({ title = 'Mechanic', description = 'Only mechanics can use this tablet.', type = 'error' }) end
    tabletOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openTablet', data = data })
end
exports('openTablet', openTablet)
RegisterCommand('mechtablet', openTablet, false)

local function closeTablet()
    tabletOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeTablet' })
end

RegisterNUICallback('closeTablet', function(_, cb) cb(1) closeTablet() end)

RegisterNUICallback('refresh', function(_, cb)
    cb(lib.callback.await('highcrest_mechanic:orders', false) or false)
end)

RegisterNUICallback('quote', function(data, cb)
    local ok, message = lib.callback.await('highcrest_mechanic:quote', false, data.id, data.labour)
    cb({ ok = ok, message = message, data = ok and lib.callback.await('highcrest_mechanic:orders', false) or nil })
end)

RegisterNUICallback('setDuty', function(data, cb)
    lib.callback.await('highcrest_mechanic:setDuty', false, data and data.onDuty == true)
    Wait(250) -- let the job update reach the server's player data
    cb(lib.callback.await('highcrest_mechanic:orders', false) or false)
end)

RegisterNUICallback('getPrices', function(data, cb)
    cb(lib.callback.await('highcrest_mechanic:prices', false, data and data.shop) or false)
end)

RegisterNUICallback('savePrices', function(data, cb)
    local ok, message, sheet = lib.callback.await('highcrest_mechanic:setPrices', false, data.shop, data.prices)
    cb({ ok = ok, message = message, sheet = sheet })
end)

RegisterNUICallback('cancelOrder', function(data, cb)
    local ok = lib.callback.await('highcrest_mechanic:cancel', false, data.id)
    cb({ ok = ok, data = lib.callback.await('highcrest_mechanic:orders', false) })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if design then endDesign() end
    if tabletOpen then SetNuiFocus(false, false) end
end)
