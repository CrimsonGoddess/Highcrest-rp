local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
end

-- ✅ ps-dispatch CustomAlert (custom message + routes to police + bcso)
local function doPoliceAlert(kind)
    if not Config.Police.enabled then return end
    if math.random(1, 100) > (Config.Police.alertChance or 0) then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local message, code, desc, sprite
    if kind == 'parking_meter' then
        message = 'Parking Meter Robbery'
        code    = '10-90'
        desc    = 'Parking Meter Robbery'
        sprite  = 431
    else
        message = 'Vending Machine Robbery'
        code    = '10-90'
        desc    = 'Vending Machine Robbery'
        sprite  = 52
    end

    -- Project Sloth docs: CustomAlert table supports coords/message/dispatchCode/description/recipientList/blipSprite/etc. :contentReference[oaicite:1]{index=1}
    exports["ps-dispatch"]:CustomAlert({
        coords = coords,
        message = message,
        dispatchCode = code,
        description = desc,
        radius = 0,
        sprite = sprite,
        color = 1,
        scale = 1.0,
        length = 3,
        recipientList = Config.Police.jobs
    })
end

local function maybeBreakItem(item, chance)
    if (chance or 0) <= 0 then return end
    if math.random(1, 100) <= chance then
        TriggerServerEvent('et_robs:server:breakItem', item)
        lib.notify({ type='error', description=('Your %s snapped.'):format(item) })
    end
end

local function parkingMeterAction(entity)
    if not entity or entity == 0 then return end

    local has = exports.ox_inventory:Search('count', Config.Items.Lockpick) > 0
    if not has then
        return lib.notify({ type='error', description='You need a lockpick.' })
    end

    local ped = PlayerPedId()

    local prog = lib.progressCircle({
        duration = Config.ParkingMeter.progressMs,
        position = 'bottom',
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        label = 'Picking the meter...',
    })

    if not prog then
        doPoliceAlert('parking_meter')
        return
    end

    loadAnim(Config.ParkingMeter.anim.dict)
    TaskPlayAnim(ped, Config.ParkingMeter.anim.dict, Config.ParkingMeter.anim.clip, 1.0, 1.0, -1, 1, 0, false, false, false)

    local ok = lib.skillCheck(Config.ParkingMeter.skillcheck, { 'w', 'a', 's', 'd' })

    ClearPedTasks(ped)

    doPoliceAlert('parking_meter')

    if not ok then
        maybeBreakItem(Config.Items.Lockpick, Config.BreakChance.LockpickFail)
        return lib.notify({ type='error', description='You messed it up.' })
    end

    local coords = GetEntityCoords(entity)
    TriggerServerEvent('et_robs:server:parkingMeterSuccess', coords)
    
end

local function vendingAction(entity)
    if not entity or entity == 0 then return end

    local has = exports.ox_inventory:Search('count', Config.Items.Crowbar) > 0
    if not has then
        return lib.notify({ type='error', description='You need a crowbar.' })
    end

    local ped = PlayerPedId()

    local prog = lib.progressCircle({
        duration = Config.Vending.progressMs,
        position = 'bottom',
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        label = 'Prying it open...',
    })

    if not prog then
        doPoliceAlert('vending')
        return
    end

    loadAnim(Config.Vending.anim.dict)
    TaskPlayAnim(ped, Config.Vending.anim.dict, Config.Vending.anim.clip, 1.0, 1.0, -1, 1, 0, false, false, false)

    local ok = lib.skillCheck(Config.Vending.skillcheck, { 'w', 'a', 's', 'd' })

    ClearPedTasks(ped)

    doPoliceAlert('vending')

    if not ok then
        maybeBreakItem(Config.Items.Crowbar, Config.BreakChance.CrowbarFail)
        return lib.notify({ type='error', description='Couldn’t get it open.' })
    end

    local coords = GetEntityCoords(entity)
    TriggerServerEvent('et_robs:server:vendingSuccess', { x = coords.x, y = coords.y, z = coords.z })
    
    
end

CreateThread(function()
    if not exports.ox_target then
        print('[et_robs] ox_target not found. Install/ensure it is started.')
        return
    end

    exports.ox_target:addModel(Config.Models.ParkingMeters, {
        {
            name = 'et_robs_parkingmeter',
            label = 'Rob Parking Meter',
            icon = 'fa-solid fa-screwdriver-wrench',
            distance = 1.5,
            onSelect = function(data)
                parkingMeterAction(data.entity)
            end
        }
    })

    exports.ox_target:addModel(Config.Models.VendingMachines, {
        {
            name = 'et_robs_vending',
            label = 'Rob Vending Machine',
            icon = 'fa-solid fa-crowbar',
            distance = 1.6,
            onSelect = function(data)
                vendingAction(data.entity)
            end
        }
    })
end)
