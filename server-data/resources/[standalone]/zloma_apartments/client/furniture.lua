-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Furniture: streaming for everyone, editor for admins (opened from the admin panel).
FurnitureEditor = { active = false }
local streamer
local draft = { anchor = { x = 0, y = 0, z = 0, heading = 0 }, props = {} }
local entities, selected, history, editingKey = {}, 0, {}, nil
local camera, cameraPos, cameraRot
local version = 0

local function copy(v) return json.decode(json.encode(v)) end
local function destroy(list) for _, e in pairs(list) do if DoesEntityExist(e) then DeleteEntity(e) end end end

local function spawn(prop, anchor, keep)
    local hash = joaat(prop.model)
    if not StreamModel(hash, keep) then return nil end
    local p = FurnitureTransform.world(anchor, prop.offset)
    local entity = CreateObjectNoOffset(hash, p.x, p.y, p.z, false, false, false)
    ReleaseStreamModel(hash)
    if entity == 0 then return nil end
    SetEntityRotation(entity, prop.rotation.x, prop.rotation.y, prop.rotation.z + anchor.heading, 2, true)
    FreezeEntityPosition(entity, true)
    return entity
end

-- Streaming -------------------------------------------------------------------
local function refreshStreams()
    streamer = streamer or PropStreamer.new()
    local list = {}
    for key, placement in pairs(ClientState.placements) do
        local set = ClientState.sets[placement.set]
        local def = Hotels.defs[placement.hotel]
        if set and def then
            local anchor, props = placement.anchor, set.props
            list['f:' .. key] = {
                hotel = placement.hotel, floor = math.floor(placement.room / 100),
                coords = vec3(anchor.x, anchor.y, anchor.z),
                distance = Config.Furniture.StreamDistance, vertical = Config.Furniture.VerticalStreamDistance,
                revision = json.encode({ placement, props }),
                eligible = function() return not (FurnitureEditor.active and editingKey == key) end,
                destroy = destroy,
                create = function(entitiesList, keep)
                    for i, prop in ipairs(props) do
                        if not keep() then return end
                        local entity = spawn(prop, anchor, keep)
                        if entity then
                            if not keep() then DeleteEntity(entity); return end
                            entitiesList[#entitiesList + 1] = entity
                        end
                        if i % Config.Furniture.SpawnBatchSize == 0 then Wait(0) end
                    end
                end,
            }
        end
    end
    streamer:replace(list)
end

OnHotelsChanged(refreshStreams)
AddEventHandler('zloma_apartments:client:furnitureLoaded', refreshStreams)
RegisterNetEvent('zloma_apartments:client:furniture', function(sets, placements)
    ClientState.sets, ClientState.placements = sets or {}, placements or {}
    refreshStreams()
    if FurnitureEditor.active then AdminMessage({ action = 'sets', sets = ClientState.sets, placements = ClientState.placements }) end
end)

-- Editor ----------------------------------------------------------------------
local function uiState()
    AdminMessage({ action = 'draft', draft = draft, selected = selected, editingKey = editingKey })
end

local function rebuild()
    version = version + 1
    local v = version
    destroy(entities); entities = {}
    for i, prop in ipairs(draft.props) do
        local entity = spawn(prop, draft.anchor)
        if not FurnitureEditor.active or v ~= version then
            if entity then DeleteEntity(entity) end
            return
        end
        entities[i] = entity
    end
end

local function applyAll()
    for i, prop in ipairs(draft.props) do
        local entity = entities[i]
        if entity and DoesEntityExist(entity) then
            local p = FurnitureTransform.world(draft.anchor, prop.offset)
            SetEntityCoordsNoOffset(entity, p.x, p.y, p.z, false, false, false)
            SetEntityRotation(entity, prop.rotation.x, prop.rotation.y, prop.rotation.z + draft.anchor.heading, 2, true)
        end
    end
end

local function pushUndo()
    history[#history + 1] = copy(draft)
    if #history > 40 then table.remove(history, 1) end
end

function FurnitureEditor.start()
    if FurnitureEditor.active then return end
    FurnitureEditor.active = true
    local p = GetEntityCoords(PlayerPedId())
    draft = { anchor = { x = p.x, y = p.y, z = p.z - 1.0, heading = 0.0 }, props = {} }
    history, selected, editingKey = {}, 0, nil
    FreezeEntityPosition(PlayerPedId(), true)
    cameraPos, cameraRot = GetGameplayCamCoord(), GetGameplayCamRot(2)
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(camera, cameraPos.x, cameraPos.y, cameraPos.z)
    SetCamRot(camera, cameraRot.x, 0.0, cameraRot.z, 2)
    SetCamFov(camera, 60.0)
    RenderScriptCams(true, false, 0, true, true)
    uiState()
end

function FurnitureEditor.stop()
    if not FurnitureEditor.active then return end
    version = version + 1
    FurnitureEditor.active = false
    destroy(entities); entities = {}
    if camera then RenderScriptCams(false, false, 0, true, true); DestroyCam(camera, false); camera = nil end
    FreezeEntityPosition(PlayerPedId(), false)
    editingKey = nil
    if streamer then streamer:refresh() end
end

local function cb(name, fn)
    RegisterNUICallback('fe_' .. name, function(data, respond)
        if not FurnitureEditor.active then respond({ success = false }); return end
        respond(fn(type(data) == 'table' and data or {}) or { success = true })
    end)
end

cb('select', function(data)
    selected = math.max(0, math.min(#draft.props, tonumber(data.index) or 0)); uiState()
end)

cb('add', function(data)
    if #draft.props >= Config.Furniture.MaxProps or type(data.model) ~= 'string' then return { success = false, error = _L('error_furniture_limit') } end
    local yaw = math.rad(cameraRot.z)
    local world = { x = cameraPos.x - math.sin(yaw) * 2, y = cameraPos.y + math.cos(yaw) * 2, z = draft.anchor.z }
    local prop = { model = data.model, label = data.label or data.model, offset = FurnitureTransform.localOffset(draft.anchor, world), rotation = { x = 0, y = 0, z = 0 } }
    local entity = spawn(prop, draft.anchor)
    if not entity then return { success = false, error = _L('error_model_missing') } end
    if not FurnitureEditor.active then DeleteEntity(entity); return { success = false } end
    pushUndo()
    draft.props[#draft.props + 1] = prop
    entities[#draft.props] = entity
    selected = #draft.props
    uiState()
end)

cb('delete', function()
    if draft.props[selected] then pushUndo(); table.remove(draft.props, selected); selected = 0; rebuild(); uiState() end
end)

cb('duplicate', function()
    if draft.props[selected] and #draft.props < Config.Furniture.MaxProps then
        pushUndo()
        local prop = copy(draft.props[selected])
        prop.offset.x = prop.offset.x + 0.3
        draft.props[#draft.props + 1] = prop
        selected = #draft.props
        entities[selected] = spawn(prop, draft.anchor)
        uiState()
    end
end)

cb('undo', function()
    if #history > 0 then draft = table.remove(history); selected = 0; rebuild(); uiState() end
end)

cb('ground', function()
    local entity = entities[selected]
    if entity then
        pushUndo()
        FreezeEntityPosition(entity, false); PlaceObjectOnGroundProperly(entity); FreezeEntityPosition(entity, true)
        local p = GetEntityCoords(entity)
        draft.props[selected].offset = FurnitureTransform.localOffset(draft.anchor, { x = p.x, y = p.y, z = p.z })
        uiState()
    end
end)

cb('transform', function(data)
    local target = selected == 0 and draft.anchor or (draft.props[selected] and draft.props[selected].offset)
    if not target then return end
    pushUndo()
    for _, k in ipairs({ 'x', 'y', 'z' }) do
        local v = tonumber(data[k]); if v and v == v and math.abs(v) < 20000 then target[k] = v end
    end
    if selected == 0 then
        draft.anchor.heading = tonumber(data.heading) or draft.anchor.heading
    else
        for _, k in ipairs({ 'x', 'y', 'z' }) do
            draft.props[selected].rotation[k] = tonumber(data['r' .. k]) or draft.props[selected].rotation[k]
        end
    end
    applyAll(); uiState()
end)

cb('beginDrag', function() pushUndo() end)
cb('endDrag', function() uiState() end)

cb('drag', function(data)
    if data.axis == 'rotation' then
        local angle = tonumber(data.angle) or 0
        if selected == 0 then draft.anchor.heading = (draft.anchor.heading + angle) % 360
        elseif draft.props[selected] then draft.props[selected].rotation.z = (draft.props[selected].rotation.z + angle) % 360 end
    elseif data.axis == 'x' or data.axis == 'y' or data.axis == 'z' then
        local axis = data.axis
        local center = selected == 0 and draft.anchor or (draft.props[selected] and FurnitureTransform.world(draft.anchor, draft.props[selected].offset))
        if center then
            local tip = { x = center.x, y = center.y, z = center.z }; tip[axis] = tip[axis] + 1
            local ok, x, y = GetScreenCoordFromWorldCoord(center.x, center.y, center.z)
            local ok2, ex, ey = GetScreenCoordFromWorldCoord(tip.x, tip.y, tip.z)
            local dx, dy = ex - x, ey - y
            local len = dx * dx + dy * dy
            if ok and ok2 and len > 0.000001 then
                local amount = math.max(-1, math.min(1, ((tonumber(data.dx) or 0) * dx + (tonumber(data.dy) or 0) * dy) / len))
                center[axis] = center[axis] + amount
                if selected == 0 then draft.anchor[axis] = center[axis]
                else draft.props[selected].offset = FurnitureTransform.localOffset(draft.anchor, center) end
            end
        end
    end
    applyAll()
end)

cb('camera', function(data)
    cameraRot = vec3(math.max(-85, math.min(85, cameraRot.x - (tonumber(data.dy) or 0) * 0.15)), 0.0, cameraRot.z - (tonumber(data.dx) or 0) * 0.15)
    local yaw = math.rad(cameraRot.z)
    local speed = data.fast and 0.25 or 0.07
    local f, r, u = tonumber(data.forward) or 0, tonumber(data.right) or 0, tonumber(data.up) or 0
    local position = cameraPos + vec3((-math.sin(yaw) * f + math.cos(yaw) * r) * speed, (math.cos(yaw) * f + math.sin(yaw) * r) * speed, u * speed)
    if #(position - GetEntityCoords(PlayerPedId())) <= Config.Furniture.CameraDistance then cameraPos = position end
    SetCamCoord(camera, cameraPos.x, cameraPos.y, cameraPos.z)
    SetCamRot(camera, cameraRot.x, 0.0, cameraRot.z, 2)
end)

cb('loadSet', function(data)
    local set = ClientState.sets[data.name]
    if not set then return { success = false, error = _L('error_invalid') } end
    pushUndo(); draft.props = copy(set.props); selected = 0; rebuild(); uiState()
end)

cb('loadPlacement', function(data)
    local key = tostring(data.hotel) .. ':' .. tostring(tonumber(data.room))
    local placement = ClientState.placements[key]
    if not placement or not ClientState.sets[placement.set] then return { success = false, error = _L('error_no_placement') } end
    pushUndo()
    editingKey = key
    draft = { anchor = copy(placement.anchor), props = copy(ClientState.sets[placement.set].props) }
    if streamer then streamer:refresh() end
    selected = 0; rebuild(); uiState()
    return { success = true, set = placement.set }
end)

-- Starts the draft at the room's door so the admin begins in the right place.
cb('anchorHere', function()
    local p = GetEntityCoords(PlayerPedId())
    pushUndo()
    draft.anchor = { x = p.x, y = p.y, z = p.z - 1.0, heading = GetEntityHeading(PlayerPedId()) }
    applyAll(); uiState()
end)

local function sameAsSet(name)
    local saved = ClientState.sets[name] and ClientState.sets[name].props
    if not saved or #saved ~= #draft.props then return false end
    for i, prop in ipairs(draft.props) do
        if prop.model ~= saved[i].model then return false end
        for _, k in ipairs({ 'x', 'y', 'z' }) do
            if math.abs(prop.offset[k] - saved[i].offset[k]) > 0.00001 or math.abs(prop.rotation[k] - saved[i].rotation[k]) > 0.00001 then return false end
        end
    end
    return true
end

cb('saveSet', function(data)
    local result = lib.callback.await('zloma_apartments:admin:saveSet', false, { name = data.name, props = draft.props })
    if result and result.success then ClientState.sets = result.sets end
    return result or { success = false }
end)

cb('savePlacement', function(data)
    if not sameAsSet(data.set) then return { success = false, error = _L('error_save_set_first') } end
    local result = lib.callback.await('zloma_apartments:admin:savePlacement', false, { hotel = data.hotel, room = data.room, set = data.set, anchor = draft.anchor })
    if result and result.success then
        editingKey = tostring(data.hotel) .. ':' .. tostring(tonumber(data.room))
        if streamer then streamer:refresh() end
    end
    return result or { success = false }
end)

for _, name in ipairs({ 'copyFloors', 'removePlacement', 'deleteSet' }) do
    cb(name, function(data) return lib.callback.await('zloma_apartments:admin:' .. name, false, data) or { success = false } end)
end

-- Gizmo screen positions for the NUI.
CreateThread(function()
    while true do
        if FurnitureEditor.active then
            DisablePlayerFiring(PlayerId(), true)
            local center = selected == 0 and draft.anchor or (draft.props[selected] and FurnitureTransform.world(draft.anchor, draft.props[selected].offset))
            if center then
                local ok, x, y = GetScreenCoordFromWorldCoord(center.x, center.y, center.z)
                local axes = {}
                for _, axis in ipairs({ 'x', 'y', 'z' }) do
                    local tip = { x = center.x, y = center.y, z = center.z }; tip[axis] = tip[axis] + 1
                    local visible, ex, ey = GetScreenCoordFromWorldCoord(tip.x, tip.y, tip.z)
                    axes[axis] = { x = ex, y = ey, visible = visible }
                end
                AdminMessage({ action = 'gizmo', visible = ok, center = { x = x, y = y }, axes = axes })
            end
            Wait(33)
        else
            Wait(400)
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    FurnitureEditor.stop()
    if streamer then streamer:stop() end
end)
