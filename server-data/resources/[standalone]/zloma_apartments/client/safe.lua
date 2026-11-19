-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Safe props with a target to open the personal safe with a PIN.
local streamer
local opening = false

local function notifyError(result)
    ClientBridge.notify(result and result.error or _L('error_generic'), 'error')
end

local session, submitting, serial = nil, false, 0

function CloseSafePinUI()
    if not session then return end
    session = nil
    SendNUIMessage({ action = 'closeSafePin' })
    SetNuiFocus(false, false)
end

local function openSafe(hotel, number)
    if opening or session or submitting then return end
    opening = true
    local result = lib.callback.await('zloma_apartments:openSafe', false, { hotel_id = hotel, room_number = number })
    opening = false
    if result and (result.needs_pin_setup or result.needs_pin) then
        CloseApartmentUI()
        serial = serial + 1
        session = { requestId = serial, hotel = hotel, number = number, setup = result.needs_pin_setup == true }
        SendNUIMessage({ action = 'openSafePin', requestId = serial, setup = session.setup,
            pinLength = Config.Safe.PinLength, locale = UiLocale(), lang = Config.Locale })
        SetNuiFocus(true, true)
    elseif not result or not result.success then notifyError(result) end
end

RegisterNUICallback('cancelSafePin', function(data, cb)
    if session and data.requestId == session.requestId and not submitting then CloseSafePinUI() end
    cb({ success = true })
end)

RegisterNUICallback('submitSafePin', function(data, cb)
    local current = session
    if not current or data.requestId ~= current.requestId or submitting then cb({ success = false }); return end
    local pin = data.pin
    if type(pin) ~= 'string' or not pin:match('^%d+$') or #pin ~= Config.Safe.PinLength
        or (current.setup and pin ~= data.confirmPin) then
        cb({ success = false, error = _L('error_pin_mismatch', Config.Safe.PinLength) }); return
    end
    submitting = true
    local result
    if current.setup then
        result = lib.callback.await('zloma_apartments:setSafePin', false, { pin = pin })
        if result and result.success then current.setup = false end
    end
    if not current.setup then
        result = lib.callback.await('zloma_apartments:openSafe', false, { hotel_id = current.hotel, room_number = current.number, pin = pin })
    end
    submitting = false
    if result and result.success then CloseSafePinUI() end
    cb(result or { success = false, error = _L('error_generic') })
end)

local function entries(hotels)
    local list = {}
    local model = joaat(Config.Safe.PropModel)
    for id, def in pairs(hotels) do
        Hotels.each(def, function(number, floor)
            local room = Hotels.room(def, number)
            if room.safe then
                local key = ('%s:%d'):format(id, number)
                local coords = vec3(room.safe.x, room.safe.y, room.safe.z)
                local targetName = 'zloma_apt_safe_' .. key
                list[key] = {
                    hotel = id, floor = floor, coords = coords, revision = json.encode(room.safe),
                    distance = Config.Safe.StreamDistance, vertical = 2.5,
                    destroy = function(entities)
                        local entity = entities[1]
                        if SafeProps then SafeProps.destroy(key) end
                        if entity and DoesEntityExist(entity) then
                            ClientBridge.removeEntity(entity, { targetName, targetName .. '_pick', targetName .. '_hack' })
                            DeleteEntity(entity)
                        end
                    end,
                    create = function(entities, keep)
                        if not StreamModel(model, keep) then return end
                        local entity
                        if SafeModel and Config.Safe.PropModel==SafeModel.body then
                            entity=CreateObjectNoOffset(model,coords.x,coords.y,coords.z+.73779297,false,false,false)
                        else entity=CreateObject(model,coords.x,coords.y,coords.z,false,false,false) end
                        ReleaseStreamModel(model)
                        if entity == 0 then return end
                        if not keep() then DeleteEntity(entity); return end
                        SetEntityHeading(entity, room.safe.w)
                        FreezeEntityPosition(entity, true)
                        entities[1] = entity
                        if SafeProps and not SafeProps.create(entity,key,id,number,keep) then DeleteEntity(entity);entities[1]=nil;return end
                        ClientBridge.addEntity(entity, { {
                            name = targetName, label = _L('target_safe'), icon = 'fas fa-vault',
                            distance = Config.Safe.TargetDistance,
                            canInteract = function() return CanAccessApartmentSafe(key) end,
                            onSelect = function() openSafe(id, number) end,
                        }, {
                            name = targetName .. '_pick', label = _L('target_safe_lockpick'), icon = 'fas fa-user-secret',
                            distance = Config.Safe.TargetDistance,
                            canInteract = function()
                                return CanAccessApartmentSafe(key) and ClientState.lockpick and ClientState.lockpick.safe == true
                                    and LockpickOptions('safe', id, number).lockpick == true
                            end,
                            onSelect = function() LockpickApartmentSafe(id, number) end,
                        }, {
                            name = targetName .. '_hack', label = _L('target_safe_hack'), icon = 'fas fa-microchip',
                            distance = Config.Safe.TargetDistance,
                            canInteract = function()
                                if not CanAccessApartmentSafe(key) then return false end
                                local panel=Config.Security and Config.Security.Alarm and Config.Security.Alarm.Panel
                                if panel and panel.Enabled and panel.SafeEnabled~=false then
                                    return SafeProps and SafeProps.canHack(key) or false
                                end
                                return LockpickOptions('safe', id, number).hack == true
                            end,
                            onSelect = function() HackApartmentSafe(id, number) end,
                        } })
                    end,
                }
            end
        end)
    end
    return list
end

OnHotelsChanged(function(hotels)
    if not Config.Safe.Enabled then return end
    streamer = streamer or PropStreamer.new()
    streamer:replace(entries(hotels))
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        CloseSafePinUI()
        if streamer then streamer:stop() end
    end
end)
