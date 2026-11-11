-- Highcrest mechanic: the customer's design bay (live preview on their own car) and the
-- mechanic's tablet (quote, fit the parts, get paid).

local design      -- active design session
local tabletOpen = false
local working = false

local function trimPlate(plate)
    return plate and plate:gsub('^%s+', ''):gsub('%s+$', ''):upper() or ''
end

local function modLabel(vehicle, slot, index, fallback)
    local text = GetModTextLabel(vehicle, slot, index)
    local label = text and GetLabelText(text) or nil
    if not label or label == 'NULL' or label == '' then return ('%s %d'):format(fallback, index + 1) end
    return label
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
    if item.kind == 'color' then return prices.color end
    return prices.cosmetic
end

local NEON_PRESETS = {
    { { false, false, false, false }, 'Off' },
    { { true, true, true, true }, 'All sides' },
    { { true, true, false, false }, 'Sides only' },
    { { false, false, true, true }, 'Front & back' },
}

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
        options = { { value = false, label = 'None' }, { value = true, label = 'Fitted' } }
    elseif item.kind == 'color' then
        for _, c in ipairs(Config.colors) do options[#options + 1] = { value = c[1], label = c[2] } end
    elseif item.kind == 'list' then
        for _, c in ipairs(Config.lists[item.list]) do options[#options + 1] = { value = c[1], label = c[2] } end
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
                items[#items + 1] = { key = item.key, label = item.label, kind = item.kind, options = options, current = props[item.key] }
            end
        end
        if #items > 0 then tabs[#tabs + 1] = { id = tab.id, label = tab.label, items = items } end
    end
    return tabs
end

-- Orbit camera around the car in the design bay.
local function updateCamera()
    if not design then return end
    local pos = GetEntityCoords(design.vehicle)
    local rad = math.rad(design.camAngle)
    local x = pos.x + math.cos(rad) * design.camDist
    local y = pos.y + math.sin(rad) * design.camDist
    SetCamCoord(design.cam, x, y, pos.z + design.camHeight)
    PointCamAtCoord(design.cam, pos.x, pos.y, pos.z + 0.3)
end

local function endDesign()
    if not design then return end
    local d = design
    design = nil
    if DoesEntityExist(d.vehicle) then
        lib.setVehicleProperties(d.vehicle, d.original)
        FreezeEntityPosition(d.vehicle, false)
    end
    RenderScriptCams(false, true, 500, true, false)
    DestroyCam(d.cam, false)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeDesign' })
end

local function startDesign(shopId)
    local vehicle = cache.vehicle
    if not vehicle or GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then return end
    local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
    local ok, reason, prices = lib.callback.await('highcrest_mechanic:canDesign', false, shopId, plate)
    if not ok then return lib.notify({ title = 'Mechanic', description = reason, type = 'error' }) end

    local props = lib.getVehicleProperties(vehicle)
    SetVehicleModKit(vehicle, 0)
    FreezeEntityPosition(vehicle, true)
    SetVehicleEngineOn(vehicle, false, true, true)

    design = {
        shop = shopId, vehicle = vehicle, plate = plate, original = props, draft = {}, prices = prices,
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true), camAngle = GetEntityHeading(vehicle) + 135.0,
        camDist = 6.0, camHeight = 1.4,
    }
    updateCamera()
    SetCamActive(design.cam, true)
    RenderScriptCams(true, true, 600, true, false)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openDesign',
        shop = Config.shops[shopId].label,
        vehicle = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))),
        plate = plate,
        tabs = buildCatalogue(vehicle, props),
    })
end

RegisterNUICallback('preview', function(data, cb)
    cb(1)
    if not design or type(data) ~= 'table' or not data.key then return end
    local change = { [data.key] = data.value }
    if data.key == 'wheels' then
        -- A new wheel type has its own rim list.
        change.modFrontWheels = -1
        design.draft.modFrontWheels = nil
    end
    lib.setVehicleProperties(design.vehicle, change)
    design.draft[data.key] = data.value

    if data.key == 'wheels' then
        local item = { key = 'modFrontWheels', label = 'Rims', kind = 'mod' }
        SendNUIMessage({ action = 'updateItem', item = { key = item.key, label = item.label, kind = item.kind, options = itemOptions(design.vehicle, item) or {}, current = -1 } })
    end
end)

RegisterNUICallback('reset', function(data, cb)
    cb(1)
    if not design or type(data) ~= 'table' or not data.key then return end
    design.draft[data.key] = nil
    lib.setVehicleProperties(design.vehicle, { [data.key] = design.original[data.key] })
end)

RegisterNUICallback('camera', function(data, cb)
    cb(1)
    if not design or type(data) ~= 'table' then return end
    design.camAngle = design.camAngle + (tonumber(data.dx) or 0) * 0.35
    design.camHeight = math.max(0.2, math.min(3.5, design.camHeight + (tonumber(data.dy) or 0) * 0.01))
    design.camDist = math.max(3.0, math.min(10.0, design.camDist + (tonumber(data.zoom) or 0) * 0.004))
    updateCamera()
end)

RegisterNUICallback('submitDesign', function(_, cb)
    if not design then return cb({ ok = false }) end
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
    endDesign()
end)

-- Design bay zones, with a shop blip and a ground marker so customers can find the bay.
for shopId, shop in pairs(Config.shops) do
    local blip = AddBlipForCoord(shop.bay.x, shop.bay.y, shop.bay.z)
    SetBlipSprite(blip, 446)
    SetBlipColour(blip, 47)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(shop.label)
    EndTextCommandSetBlipName(blip)

    lib.points.new({
        coords = shop.bay.xyz,
        distance = 40.0,
        nearby = function()
            if design then return end
            DrawMarker(1, shop.bay.x, shop.bay.y, shop.bay.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                shop.bayRadius * 1.6, shop.bayRadius * 1.6, 0.6, 225, 60, 60, 90, false, false, 2, false, nil, nil, false)
        end,
    })

    lib.zones.sphere({
        coords = shop.bay.xyz,
        radius = shop.bayRadius,
        inside = function()
            if design or not cache.vehicle or GetPedInVehicleSeat(cache.vehicle, -1) ~= cache.ped then
                if lib.isTextUIOpen() then lib.hideTextUI() end
                return
            end
            if not lib.isTextUIOpen() then lib.showTextUI(('[E] Design your build · %s'):format(shop.label), { icon = 'wrench' }) end
            if IsControlJustReleased(0, 38) then
                lib.hideTextUI()
                startDesign(shopId)
            end
        end,
        onExit = function() lib.hideTextUI() end,
    })
end

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
    if tabletOpen or working then return end
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

local function findVehicleByPlate(plate, range)
    local pos = GetEntityCoords(cache.ped)
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if trimPlate(GetVehicleNumberPlateText(vehicle)) == plate and #(pos - GetEntityCoords(vehicle)) <= range then
            return vehicle
        end
    end
end

local function takeControl(entity)
    local timeout = GetGameTimer() + 2000
    NetworkRequestControlOfEntity(entity)
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
        Wait(50)
        NetworkRequestControlOfEntity(entity)
    end
    return NetworkHasControlOfEntity(entity)
end

local function doWork(order)
    local vehicle = findVehicleByPlate(order.plate, 8.0)
    if not vehicle then return lib.notify({ title = 'Mechanic', description = ('Stand next to the car (%s).'):format(order.plate), type = 'error' }) end

    local ok, lines = lib.callback.await('highcrest_mechanic:startWork', false, order.id, NetworkGetNetworkIdFromEntity(vehicle))
    if not ok then return lib.notify({ title = 'Mechanic', description = lines, type = 'error' }) end

    working = true
    local performance = { modEngine = true, modBrakes = true, modTransmission = true, modSuspension = true, modArmor = true, modTurbo = true }
    for i, line in ipairs(lines) do
        local seconds = performance[line.key] and Config.installSeconds.performance or Config.installSeconds.default
        local done = lib.progressCircle({
            duration = seconds * 1000,
            label = ('Fitting %s (%d/%d)'):format(line.label, i, #lines),
            position = 'bottom',
            canCancel = true,
            disable = { move = true, car = true, combat = true },
            anim = { dict = 'mini@repair', clip = 'fixing_a_player' },
        })
        if not done then
            working = false
            return lib.notify({ title = 'Mechanic', description = 'Work paused. Start again from the tablet.', type = 'inform' })
        end
    end

    local finished, values, earned = lib.callback.await('highcrest_mechanic:complete', false, order.id, NetworkGetNetworkIdFromEntity(vehicle))
    working = false
    if not finished then return lib.notify({ title = 'Mechanic', description = values, type = 'error' }) end

    if takeControl(vehicle) then lib.setVehicleProperties(vehicle, values) end
    lib.notify({ title = 'Mechanic', description = ('Order #%d done. You earned $%d.'):format(order.id, earned), type = 'success', duration = 8000 })
end

RegisterNUICallback('startWork', function(data, cb)
    cb(1)
    closeTablet()
    if type(data) == 'table' and data.order then doWork(data.order) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if design then endDesign() end
    if tabletOpen then SetNuiFocus(false, false) end
end)
