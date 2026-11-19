-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Admin panel: building creator + furniture editor. Opened with Config.AdminCommand.
local open, capturing = false, false

function AdminMessage(message)
    SendNUIMessage({ action = 'admin', message = message })
end

local function show(focus)
    SetNuiFocus(focus, focus)
    AdminMessage({ action = focus and 'show' or 'hide' })
end

local function close()
    if not open then return end
    open = false
    if AlarmPanels and AlarmPanels.placement then AlarmPanels.placement.cancelled = true end
    FurnitureEditor.stop()
    SetNuiFocus(false, false)
    AdminMessage({ action = 'close' })
end

RegisterCommand(Config.AdminCommand, function()
    if open then close(); return end
    local data = lib.callback.await('zloma_apartments:admin:open', false)
    if not data or not data.success then
        ClientBridge.notify(data and data.error or _L('error_no_permission'), 'error')
        return
    end
    open = true
    SendNUIMessage({ action = 'admin', message = { action = 'open', data = data } })
    SetNuiFocus(true, true)
end, false)

local function groundZ()
    return GetEntityCoords(PlayerPedId()).z - 1.0
end

local function aimedObject(distance)
    local camPos, rot = GetGameplayCamCoord(), GetGameplayCamRot(2)
    local x, z = math.rad(rot.x), math.rad(rot.z)
    local dir = vec3(-math.sin(z) * math.abs(math.cos(x)), math.cos(z) * math.abs(math.cos(x)), math.sin(x))
    local target = camPos + dir * distance
    local handle = StartShapeTestLosProbe(camPos.x, camPos.y, camPos.z, target.x, target.y, target.z, 16, PlayerPedId(), 4)
    local status, hit, _, _, entity = GetShapeTestResult(handle)
    while status == 1 do Wait(0); status, hit, _, _, entity = GetShapeTestResult(handle) end
    if hit == 1 and entity ~= 0 and GetEntityType(entity) == 3 then return entity end
end

-- Each capture runs with the panel hidden and returns a table or nil.
local captures = {}

function captures.door()
    lib.showTextUI(_L('admin_capture_door'))
    local result, outlined
    while true do
        DisableControlAction(0, 24, true)
        local entity = aimedObject(6.0)
        if entity ~= outlined then
            if outlined and DoesEntityExist(outlined) then SetEntityDrawOutline(outlined, false) end
            outlined = entity
            if entity then SetEntityDrawOutline(entity, true); SetEntityDrawOutlineColor(80, 160, 255, 255) end
        end
        if IsControlJustPressed(0, 38) and entity then -- E
            local p = GetEntityCoords(entity)
            result = { door = { x = p.x, y = p.y, z = p.z }, model = GetEntityModel(entity), groundZ = groundZ() }
            break
        elseif IsControlJustPressed(0, 47) then -- G: no door object, use my position
            local p = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.6, 0.0)
            result = { door = { x = p.x, y = p.y, z = groundZ() }, groundZ = groundZ() }
            break
        elseif IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200) then -- Backspace / Esc
            break
        end
        Wait(0)
    end
    if outlined and DoesEntityExist(outlined) then SetEntityDrawOutline(outlined, false) end
    lib.hideTextUI()
    return result
end

function captures.safe()
    local model = joaat(Config.Safe.PropModel)
    if not StreamModel(model) then return nil end
    local ped = PlayerPedId()
    local ghost = CreateObject(model, 0.0, 0.0, 0.0, false, false, false)
    ReleaseStreamModel(model)
    SetEntityAlpha(ghost, 170, false)
    SetEntityCollision(ghost, false, false)
    FreezeEntityPosition(ghost, true)
    local turn, result = 180.0, nil
    lib.showTextUI(_L('admin_capture_safe'))
    while true do
        DisableControlAction(0, 14, true); DisableControlAction(0, 15, true)
        if IsDisabledControlPressed(0, 14) then turn = turn - 3.0 end
        if IsDisabledControlPressed(0, 15) then turn = turn + 3.0 end
        local p = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.9, 0.0)
        local z = groundZ()
        local heading = (GetEntityHeading(ped) + turn) % 360
        SetEntityCoordsNoOffset(ghost, p.x, p.y, z, false, false, false)
        SetEntityHeading(ghost, heading)
        if IsControlJustPressed(0, 38) then
            result = { x = p.x, y = p.y, z = z, w = heading }
            break
        elseif IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200) then
            break
        end
        Wait(0)
    end
    DeleteEntity(ghost)
    lib.hideTextUI()
    return result
end

local function stand(label)
    lib.showTextUI(label)
    local result
    while true do
        if IsControlJustPressed(0, 38) then
            local p = GetEntityCoords(PlayerPedId())
            result = { x = p.x, y = p.y, z = p.z - 1.0, w = GetEntityHeading(PlayerPedId()) }
            break
        elseif IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200) then
            break
        end
        Wait(0)
    end
    lib.hideTextUI()
    return result
end

function captures.panel(data)
    if type(data.definition) ~= 'table' or not tonumber(data.number) then return nil end
    return AlarmPanels.place(data.definition,tonumber(data.number))
end

function captures.panel_all(data)
    if type(data.definition) ~= 'table' or not tonumber(data.number) then return nil end
    local result, err = AlarmPanels.copyToRooms(data.definition, tonumber(data.number))
    if not result then ClientBridge.notify(_L(err or 'error_generic'), 'error') end
    return result
end

function captures.reception() return stand(_L('admin_capture_reception')) end
function captures.floor() return stand(_L('admin_capture_floor')) end

RegisterNUICallback('adm_capture', function(data, cb)
    cb({ success = true })
    local fn = captures[data and data.kind]
    if not open or capturing or not fn then return end
    capturing = true
    show(false)
    Wait(150)
    local ok, result = pcall(fn, data)
    capturing = false
    if not open then return end
    show(true)
    AdminMessage({ action = 'captured', kind = data.kind, data = ok and result or nil })
end)

RegisterNUICallback('adm_close', function(_, cb) cb({ success = true }); close() end)

RegisterNUICallback('adm_tab', function(data, cb)
    if data.tab == 'furniture' then FurnitureEditor.start() else FurnitureEditor.stop() end
    cb({ success = true })
end)

RegisterNUICallback('adm_position', function(_, cb)
    local p = GetEntityCoords(PlayerPedId())
    cb({ x = p.x, y = p.y, z = p.z - 1.0, w = GetEntityHeading(PlayerPedId()) })
end)

RegisterNUICallback('adm_goto', function(data, cb)
    local door = lib.callback.await('zloma_apartments:admin:roomCoords', false, data)
    if not door then cb({ success = false, error = _L('error_invalid') }); return end
    FurnitureEditor.stop()
    SetEntityCoords(PlayerPedId(), door.x, door.y, door.z, false, false, false, false)
    cb({ success = true })
end)

for _, name in ipairs({ 'saveHotel', 'deleteHotel', 'evictRoom' }) do
    RegisterNUICallback('adm_' .. name, function(data, cb)
        cb(lib.callback.await('zloma_apartments:admin:' .. name, false, data) or { success = false })
    end)
end

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() and open then SetNuiFocus(false, false); lib.hideTextUI() end
end)
