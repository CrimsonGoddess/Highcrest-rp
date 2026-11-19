-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Custom keypad LCD materials. Private armed/off model variants keep each
-- apartment's status independent without replacing any stock GTA textures.
AlarmPanels = { entities = {}, active = {}, editing = false }
local P = AlarmPanels
local cfg = Config.Security.Alarm.Panel
local screens, stopped = {}, false
local panelBindings = {}
local txds, generation = {}, 0

function P.offset(entity, x, y, z)
    -- These native parameters are floats. In particular integer -1 can arrive
    -- as an invalid float in the native invoker and poison every derived axis.
    return GetOffsetFromEntityInWorldCoords(entity, x+0.0, y+0.0, z+0.0)
end
function P.screen(kind)
    if screens[kind] then return screens[kind] end
    local width, height = kind == 'device' and AlarmDeviceRig.screenWidth or 512, kind == 'device' and AlarmDeviceRig.screenHeight or 224
    local dui = CreateDui(('https://cfx-nui-%s/ui/dist/alarm/screen.html?kind=%s&lang=%s'):format(GetCurrentResourceName(), kind, Config.Locale), width, height)
    local deadline = GetGameTimer() + 5000
    while not IsDuiAvailable(dui) and GetGameTimer() < deadline and not stopped do Wait(0) end
    if stopped or not IsDuiAvailable(dui) then DestroyDui(dui); error('alarm DUI unavailable') end
    -- One runtime dictionary per kind; a fresh texture name each time the DUI
    -- is recreated, so a new browser never reuses a texture of a destroyed one.
    local dict = 'zloma_alarm_' .. kind
    txds[dict] = txds[dict] or CreateRuntimeTxd(dict)
    generation = generation + 1
    local texture = 'screen' .. generation
    CreateRuntimeTextureFromDuiHandle(txds[dict], texture, GetDuiHandle(dui))
    local s = { dui = dui, dict = dict, texture = texture, kind = kind }
    screens[kind] = s
    return s
end
-- Shut a screen's browser down. The material falls back to the model's own texture.
function P.releaseScreen(kind)
    local s = screens[kind]
    if not s then return end
    screens[kind] = nil
    if kind == 'device' then P.unbindDeviceScreen() else P.unbindPanelScreens() end
    DestroyDui(s.dui)
end
function P.message(screen, data)
    -- Screen sends a ready acknowledgement; messages are also replayed until it
    -- arrives, so a slow CEF startup cannot leave the instruction blank.
    screen.last = data
    SendDuiMessage(screen.dui, json.encode(data))
end
RegisterNUICallback('alarm_screen_ready', function(data, cb)
    local s = screens[data and data.kind]
    if s and s.last then SendDuiMessage(s.dui, json.encode(s.last)) end
    cb({ success = true })
end)
function P.drawPanel(entity, screen)
    local texture = screen.kind == 'disabled' and AlarmPanelModel.disabledTexture or AlarmPanelModel.armedTexture
    if panelBindings[texture] then return end
    -- The real recessed LCD mesh owns its own emissive material and 0..1 UVs.
    AddReplaceTexture(AlarmPanelModel.textureDictionary,texture,screen.dict,screen.texture)
    panelBindings[texture]=true
end
function P.unbindPanelScreens()
    for texture in pairs(panelBindings) do
        RemoveReplaceTexture(AlarmPanelModel.textureDictionary,texture)
        panelBindings[texture]=nil
    end
end
function P.drawDevice(entity, screen)
    -- Replace the custom model's namespaced render-target material, using the
    -- factory screen UVs and rounded corners. No floating device-screen quad.
    if not P.deviceScreenBound then
        AddReplaceTexture(cfg.DeviceModel,AlarmDeviceRig.screenTexture,screen.dict,screen.texture)
        P.deviceScreenBound=true
    end
end
function P.unbindDeviceScreen()
    if not P.deviceScreenBound then return end
    RemoveReplaceTexture(cfg.DeviceModel,AlarmDeviceRig.screenTexture)
    P.deviceScreenBound=false
end

-- The door entity of an apartment and its closed heading (nil when not streamed).
local function doorEntity(def, number)
    local room = Hotels.room(def, number)
    if not room then return nil end
    local model = room.model and (type(room.model) == 'string' and joaat(room.model) or room.model)
    if not model then return nil end
    local d = room.door
    local entity = GetClosestObjectOfType(d.x,d.y,d.z,1.6,model,false,false,false)
    if entity == 0 or not DoesEntityExist(entity) then return nil end
    P.closed = P.closed or {}
    local heading = P.closed[def.id .. ':' .. number] or GetEntityHeading(entity)
    return entity, heading, room
end

-- Copy apartment `number`'s manual panel to every room of the building,
-- relative to each room's own door (hinge side, outside face, heading). Rooms
-- are measured on the source floor, whose doors must be streamed (stand on it).
-- Returns { specs = { [roomIndex] = floor-one placement }, missing = { numbers } }.
function P.copyToRooms(def, number)
    local source = AlarmPanel.forRoom(def, number)
    if source.mode ~= 'manual' then return nil, 'alarm_panel_copy_need_manual' end
    local entity, heading, room = doorEntity(def, number)
    if not entity then return nil, 'alarm_panel_door_missing' end
    local rel = AlarmPanel.relativeTo(AlarmPanel.doorFrame(GetEntityCoords(entity), heading, room.safe), source)
    local floor = math.floor(number / 100)
    local lift = (floor - 1) * def.floors.step
    local out = { specs = {}, missing = {} }
    for _, base in ipairs(def.rooms) do
        local target = floor * 100 + base.index
        local e, h, r = doorEntity(def, target)
        if e then
            local spec = AlarmPanel.fromRelative(AlarmPanel.doorFrame(GetEntityCoords(e), h, r.safe), rel)
            spec.position.z = spec.position.z - lift
            out.specs[tostring(base.index)] = spec
        else
            out.missing[#out.missing + 1] = target
        end
    end
    return out
end

function P.resolve(def, number)
    local spec = AlarmPanel.forRoom(def, number)
    if spec.mode == 'manual' then return spec end
    local room = Hotels.room(def, number)
    if not room then return nil end
    local model = room.model and (type(room.model) == 'string' and joaat(room.model) or room.model)
    if not model then return nil end
    local d = room.door
    local entity = GetClosestObjectOfType(d.x,d.y,d.z,1.6,model,false,false,false)
    if entity == 0 or not DoesEntityExist(entity) then return nil end
    -- Store the closed orientation once. The door manager keeps occupied locked
    -- doors shut; never derive a new pose while a door is open or swinging.
    P.closed = P.closed or {}
    local key = def.id .. ':' .. number
    local heading = P.closed[key]
    if not heading then
        if ClientState.doors[key] == false then return nil end
        heading = GetEntityHeading(entity); P.closed[key] = heading
    end
    local lo, hi = GetModelDimensions(model)
    local x, z = (lo.x+hi.x)*.5, (lo.z+hi.z)*.5 + (cfg.AutoHeight or .18)
    -- The safe is inside the room: choose the opposite face. For a building
    -- without safes, the approaching player's side is the corridor fallback.
    local angle = math.rad(heading)
    local origin = GetEntityCoords(entity)
    local center = vec3(origin.x+x*math.cos(angle),origin.y+x*math.sin(angle),origin.z+z)
    local reference = room.safe and ToVec3(room.safe) or GetEntityCoords(PlayerPedId())
    local side = (reference.x-center.x)*-math.sin(angle)+(reference.y-center.y)*math.cos(angle)
    local positive = room.safe and side < 0 or (not room.safe and side > 0)
    local y = positive and hi.y+.025 or lo.y-.025
    return { mode = 'manual', position = { x=origin.x+x*math.cos(angle)-y*math.sin(angle), y=origin.y+x*math.sin(angle)+y*math.cos(angle), z=origin.z+z }, rotation={x=0,y=0,z=(heading+(positive and 180 or 0))%360} }
end
function P.armOption(kind,hotel,number,key,name)
    return {name=name,label=_L('alarm_activate'),icon='fas fa-shield-halved',distance=2.0,
        canInteract=function()
            local state=P.active[key]
            return not P.busy and not P.editing and state and state.disabled and state.canArm==true
        end,
        onSelect=function()
            local result=lib.callback.await('zloma_apartments:activateAlarm',false,{kind=kind,hotel_id=hotel,room_number=number})
            if not result or not result.success then ClientBridge.notify(result and result.error or _L('error_generic'),'error')end
        end}
end
RegisterNetEvent('zloma_apartments:alarmStateChanged',function(hotel,number,kind,disabled)
    local key=(kind=='safe' and 'safe:' or '')..hotel..':'..number
    if P.active[key]then P.active[key].disabled=disabled==true end
end)
local function remove(key)
    local entry = P.entities[key]
    if not entry then return end
    ClientBridge.removeEntity(entry.entity, { entry.targetName or ('zloma_alarm_' .. key), (entry.targetName or ('zloma_alarm_' .. key))..'_arm' })
    if DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
    P.entities[key] = nil
end
function P.create(spec, alpha, disabled)
    local model = joaat(disabled and (cfg.DisabledModel or AlarmPanelModel.disabledModel) or cfg.Model)
    if not StreamModel(model) then return nil end
    local p,r = spec.position,spec.rotation
    local entity=CreateObjectNoOffset(model,p.x,p.y,p.z,false,false,false)
    ReleaseStreamModel(model)
    if entity == 0 then return nil end
    SetEntityRotation(entity,r.x+0.0,r.y+0.0,r.z+0.0,2,true)
    FreezeEntityPosition(entity,true)
    -- Entity targets require the camera raycast to hit the panel. Only editor
    -- ghosts are non-colliding; disabling collision on live panels hides targets.
    SetEntityCollision(entity,alpha == nil,true)
    if alpha then SetEntityAlpha(entity,alpha,false) end
    return entity
end
OnHotelsChanged(function()
    for key in pairs(P.entities) do remove(key) end
    P.closed = {}
end)
-- Ask the server which doors have an armed alarm only while standing on an
-- apartment floor near the doors (P.near, set by the streaming thread).
CreateThread(function()
    while not stopped do
        if ClientState.ready and cfg.Enabled and P.near then
            local ok, data = pcall(lib.callback.await,'zloma_apartments:alarmPanels',false)
            if ok and type(data)=='table' then P.active=data end
            local waited = 0
            while waited < 3000 and P.near and not stopped do Wait(250); waited = waited + 250 end
        else
            if not P.near then P.active={} end
            Wait(500)
        end
    end
end)
CreateThread(function()
    while not stopped do
        local pos=GetEntityCoords(PlayerPedId());local wanted={};local near=false
        if cfg.Enabled and not P.editing then
            for id,def in pairs(ClientState.hotels) do
                local floor=Hotels.floorAt(def,pos.z)
                if floor then
                    for _,base in ipairs(def.rooms) do
                        local number=floor*100+base.index;local key=id..':'..number
                        local room=Hotels.room(def,number)
                        local distance=#(pos-ToVec3(room.door))
                        if distance < (cfg.StreamDistance or 18)+10 or (room.safe and #(pos-ToVec3(room.safe)) < Config.Safe.StreamDistance+5) then near=true end
                        if P.active[key] and (not room.ipl or IsIplActive(room.ipl)) and distance < (cfg.StreamDistance or 18) then
                            wanted[key]=true
                            local disabled=P.active[key].disabled == true
                            if P.entities[key] and P.entities[key].disabled ~= disabled then remove(key) end
                            if not P.entities[key] then
                                local spec=P.resolve(def,number)
                                local entity=spec and P.create(spec,nil,disabled)
                                if entity then
                                    P.entities[key]={entity=entity,hotel=id,number=number,disabled=disabled}
                                    local hotelId,roomNumber,panelKey=id,number,key
                                    ClientBridge.addEntity(entity,{{name='zloma_alarm_'..key,label=_L('alarm_panel_hack'),icon='fas fa-microchip',distance=2.0,
                                        canInteract=function()
                                            if P.busy or P.editing or not P.active[panelKey] or P.active[panelKey].disabled then return false end
                                            if Config.Debug then return true end -- server revalidates the start
                                            return LockpickOptions('door',hotelId,roomNumber).panelHack == true
                                        end,
                                        onSelect=function() StartAlarmConnection(hotelId,roomNumber) end},P.armOption('door',hotelId,roomNumber,key,'zloma_alarm_'..key..'_arm')})
                                end
                            end
                        end
                    end
                end
            end
        end
        for key in pairs(P.entities) do if key:sub(1,5)~='safe:' and not wanted[key] and not (P.busy and P.sceneKey==key) then remove(key) end end
        P.near=near or P.busy
        Wait(650)
    end
end)
-- Live panel screens only within ScreenDistance of a panel (a little more to
-- switch off, so standing on the edge does not flicker). The material bind is
-- permanent until released, so nothing has to run every frame.
CreateThread(function()
    local on=false
    while not stopped do
        local reach=cfg.ScreenDistance or 3.5
        local closest=math.huge
        local pos=GetEntityCoords(PlayerPedId())
        for _,entry in pairs(P.entities) do
            if DoesEntityExist(entry.entity) then
                local d=#(pos-GetEntityCoords(entry.entity))
                if d<closest then closest=d end
            end
        end
        if not on and closest<=reach then
            local ok=pcall(function()
                local armed=P.screen('armed');local disabled=P.screen('disabled')
                P.message(armed,{state='armed',title=_L('alarm_panel_armed')})
                P.message(disabled,{state='disabled',title=_L('alarm_panel_disabled')})
                P.drawPanel(nil,armed);P.drawPanel(nil,disabled)
            end)
            on=ok
        elseif on and closest>reach+1.0 then
            P.releaseScreen('armed');P.releaseScreen('disabled')
            on=false
        end
        Wait(on and 400 or 750)
    end
end)
AddEventHandler('onResourceStop',function(name)
    if name~=GetCurrentResourceName() then return end
    stopped=true
    P.unbindPanelScreens()
    P.unbindDeviceScreen()
    if P.stopPlacement then P.stopPlacement() end
    for key in pairs(P.entities) do remove(key) end
    for _,s in pairs(screens) do DestroyDui(s.dui) end
end)
-- Used by the admin capture flow, so save/cancel participates in the existing
-- building draft. An abandoned preview never writes a database row.
function AlarmPanels.place(def, number)
    local P=AlarmPanels
    if P.editing or P.busy then return nil end
    local spec=P.resolve(def,number)
    if not spec then ClientBridge.notify(_L('alarm_panel_door_missing'),'error'); return nil end
    local ghost,cam,ped,frozen
    local placement = { cancelled = false }
    P.placement = placement
    P.stopPlacement = function()
        if placement.cleaned then return end
        placement.cleaned = true
        placement.cancelled = true
        if cam then RenderScriptCams(false,true,300,true,true);DestroyCam(cam,false) end
        if ghost and DoesEntityExist(ghost) then DeleteEntity(ghost) end
        if ped then FreezeEntityPosition(ped,frozen==true) end
        lib.hideTextUI();P.editing=false;P.placement=nil
    end
    P.editing=true
    local result
    local ok,err=xpcall(function()
        ghost=P.create(spec,150)
        if not ghost then error('panel model unavailable') end
        ped=PlayerPedId(); frozen=IsEntityPositionFrozen(ped); FreezeEntityPosition(ped,true)
        local center=ToVec3(spec.position);local from=P.offset(ghost,0,-.85,0)
        local cameraFov=75.0
        cam=CreateCam('DEFAULT_SCRIPTED_CAMERA',true)
        SetCamCoord(cam,from.x,from.y,from.z);PointCamAtCoord(cam,center.x,center.y,center.z);SetCamFov(cam,cameraFov)
        RenderScriptCams(true,true,400,true,true)
        lib.showTextUI(_L('alarm_panel_place_help'),{position='bottom-center'})
        local r=spec.rotation;local angle=math.rad(r.z)
        local right=vec3(math.cos(angle),math.sin(angle),0);local forward=vec3(-math.sin(angle),math.cos(angle),0)
        while not placement.cancelled do
            DisableAllControlActions(0);EnableControlAction(0,249,true)
            local dt=math.min(GetFrameTime(),.05);local fine=IsDisabledControlPressed(0,36)
            -- Optical zoom keeps the camera out of the opposite corridor wall.
            -- Z/X are separate from the wheel, which adjusts panel depth.
            local zoomSpeed=(fine and 12.0 or 60.0)*dt
            if IsDisabledControlPressed(0,20) then cameraFov=math.min(120.0,cameraFov+zoomSpeed) end -- Z: out
            if IsDisabledControlPressed(0,73) then cameraFov=math.max(10.0,cameraFov-zoomSpeed) end -- X: in
            SetCamFov(cam,cameraFov)
            SetEntityLocallyInvisible(ped)
            local step=(fine and .025 or .15)*dt;local turn=(fine and 8 or 40)*dt
            if IsDisabledControlPressed(0,32) then center=center+vec3(0,0,step) end
            if IsDisabledControlPressed(0,33) then center=center-vec3(0,0,step) end
            if IsDisabledControlPressed(0,34) then center=center-right*step end
            if IsDisabledControlPressed(0,35) then center=center+right*step end
            if IsDisabledControlJustPressed(0,15) then center=center+forward*(fine and .001 or .01) end
            if IsDisabledControlJustPressed(0,14) then center=center-forward*(fine and .001 or .01) end
            local axis=IsDisabledControlPressed(0,21) and 'x' or (IsDisabledControlPressed(0,19) and 'y' or 'z')
            if IsDisabledControlPressed(0,44) then r[axis]=(r[axis]-turn)%360 end
            if IsDisabledControlPressed(0,38) then r[axis]=(r[axis]+turn)%360 end
            SetEntityCoordsNoOffset(ghost,center.x,center.y,center.z,false,false,false);SetEntityRotation(ghost,r.x,r.y,r.z,2,true)
            PointCamAtCoord(cam,center.x,center.y,center.z)
            DrawLine(center.x,center.y,center.z,center.x,center.y,center.z+.12,80,220,255,190)
            if IsDisabledControlJustPressed(0,191) then
                result={number=number,spec={mode='manual',position={x=center.x,y=center.y,z=center.z},rotation={x=r.x,y=r.y,z=r.z}}};break
            end
            if IsDisabledControlJustPressed(0,177) or IsDisabledControlJustPressed(0,200) or IsEntityDead(ped) then break end
            Wait(0)
        end
    end,debug.traceback)
    P.stopPlacement()
    if not ok then print('[zloma_apartments] panel placement: '..err);ClientBridge.notify(_L('error_generic'),'error') end
    return result
end
