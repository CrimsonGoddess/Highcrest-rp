-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- A physical connection scene, intentionally separate from the alarm bypass.
-- The player holds the hacking device in both hands and drags its USB plug
-- into the panel's socket.
local P=AlarmPanels
local cfg=Config.Security.Alarm.Panel
local hold=cfg.Hold or {}
local view=cfg.Camera or {}
local scene
local function dot(a,b) return a.x*b.x+a.y*b.y+a.z*b.z end
local function length(v)return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z)end
local function cross(a,b)return vec3(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x)end
local function float(v,default)return (tonumber(v) or default)+0.0 end
local function holdVector(v,x,y,z)
    v=v or {}
    return float(v.x,x),float(v.y,y),float(v.z,z)
end

-- The device's screen: a flat rectangle at local z, measured from the mesh
-- (x left..right = DUI u 0..1, y top..bottom = DUI v 0..1).
local SCREEN={z=0.0317383,minX=-0.0297852,maxX=0.0297852,minY=0.0043945,maxY=0.0473633}
SCREEN.cy=(SCREEN.minY+SCREEN.maxY)*.5

local factoryLength=0
for i=2,#AlarmDeviceRig.cableRest do
    local a,b=AlarmDeviceRig.cableRest[i-1],AlarmDeviceRig.cableRest[i]
    factoryLength=factoryLength+math.sqrt((b.x-a.x)^2+(b.y-a.y)^2+(b.z-a.z)^2)
end

local function object(model,p)
    local hash=joaat(model)
    if not StreamModel(hash) then error('missing streamed model '..model) end
    local entity=CreateObjectNoOffset(hash,p.x,p.y,p.z,false,false,false);ReleaseStreamModel(hash)
    if entity==0 then error('could not create '..model) end
    SetEntityCollision(entity,false,false);FreezeEntityPosition(entity,true)
    return entity
end

-- Device in both hands, playing the hold animation.
local function holdDevice(ped,device)
    if hold.dict and hold.anim then
        lib.requestAnimDict(hold.dict)
        TaskPlayAnim(ped,hold.dict,hold.anim,4.0,4.0,-1,49,0,false,false,false)
    end
    FreezeEntityPosition(device,false)
    local ox,oy,oz=holdVector(hold.offset,-0.008,0.010,0.012)
    local rx,ry,rz=holdVector(hold.rotation,-253.5,-3.0,-8.0)
    AttachEntityToEntity(device,ped,GetPedBoneIndex(ped,hold.bone or 28422),ox,oy,oz,rx,ry,rz,true,true,false,true,1,true)
end

local function cleanup(s)
    if not s or s.cleaned then return end
    s.cleaned=true
    if s.focusCam then DestroyCam(s.focusCam,false) end
    if s.cam then
        SetCamUseShallowDofMode(s.cam,false)
        RenderScriptCams(false,true,350,true,true);DestroyCam(s.cam,false)
    end
    for _,entity in ipairs(s.links or {}) do if DoesEntityExist(entity) then DeleteEntity(entity) end end
    if s.device and DoesEntityExist(s.device) then DetachEntity(s.device,false,false) end
    for _,entity in ipairs({s.device or 0,s.connector or 0}) do if entity~=0 and DoesEntityExist(entity) then DeleteEntity(entity) end end
    P.unbindDeviceScreen()
    P.releaseScreen('device')
    if s.ped and DoesEntityExist(s.ped) then
        ClearPedTasks(s.ped)
        FreezeEntityPosition(s.ped,s.wasFrozen==true)
    end
    if hold.dict then RemoveAnimDict(hold.dict) end
    if s.locked then MinigameLockEnd(true) end
    lib.hideTextUI()
    P.busy,P.sceneKey=false,nil
    if scene==s then scene=nil end
end

-- Cable links follow the solved nodes. Each link's side axis is carried over
-- from the previous link (parallel transport), so a curled cable never flips
-- its links left and right from frame to frame.
local function placeCable(s,front)
    local right
    for i,entity in ipairs(s.links) do
        local a,b=ToVec3(s.cable.nodes[i]),ToVec3(s.cable.nodes[i+1])
        local delta=b-a;local distance=length(delta)
        if distance>.000001 then
            local forward=delta*(1/distance)
            if right then right=right-forward*dot(right,forward) end
            if not right or length(right)<.001 then
                right=cross(forward,front)
                if length(right)<.001 then right=cross(forward,vec3(0.0,0.0,1.0)) end
                if length(right)<.001 then right=vec3(1.0,0.0,0.0) end
            end
            right=right*(1/length(right))
            local up=cross(right,forward)
            local scaled=forward*(distance/AlarmDeviceRig.linkLength)
            SetEntityMatrix(entity,scaled.x,scaled.y,scaled.z,right.x,right.y,right.z,up.x,up.y,up.z,a.x,a.y,a.z)
        end
    end
end

-- The plug points along the last cable link; seated, it points up into the socket.
local function placeConnector(s,plug,tip,front)
    tip=tip*(1/math.max(length(tip),.000001))
    local up=front-tip*dot(front,tip)
    if length(up)<.001 then up=cross(tip,vec3(1.0,0.0,0.0)) end
    up=up*(1/length(up))
    local right=cross(tip,up)
    SetEntityMatrix(s.connector,tip.x,tip.y,tip.z,right.x,right.y,right.z,up.x,up.y,up.z,plug.x,plug.y,plug.z)
end

local function cursorOn(point,pixels)
    local visible,x,y=World3dToScreen2d(point.x,point.y,point.z)
    if not visible then return false end
    local width,height=GetActiveScreenResolution()
    local dx=(GetDisabledControlNormal(0,239)-x)*width
    local dy=(GetDisabledControlNormal(0,240)-y)*height
    return dx*dx+dy*dy <= pixels*pixels
end

-- Where a world ray meets the device screen, as DUI coordinates 0..1 (may be
-- outside that range), or nil when it misses the screen plane.
local function screenHit(s,origin,dir)
    local o=P.offset(s.device,0,0,0)
    local ax,ay,az=P.offset(s.device,1,0,0)-o,P.offset(s.device,0,1,0)-o,P.offset(s.device,0,0,1)-o
    local rel=ToVec3(origin)-o
    local dz=dot(dir,az)
    if math.abs(dz)<.000001 then return nil end
    local t=(SCREEN.z-dot(rel,az))/dz
    if t<0 then return nil end
    local x,y=dot(rel,ax)+dot(dir,ax)*t,dot(rel,ay)+dot(dir,ay)*t
    return (x-SCREEN.minX)/(SCREEN.maxX-SCREEN.minX),1-(y-SCREEN.minY)/(SCREEN.maxY-SCREEN.minY)
end

local function deviceRest(s)
    local rest={}
    for i,p in ipairs(AlarmDeviceRig.cableRest) do rest[i]=P.offset(s.device,p.x,p.y,p.z) end
    return rest
end

local function waitFor(ms,s)
    local untilAt=GetGameTimer()+ms
    while GetGameTimer()<untilAt do
        if s.cleaned or IsEntityDead(s.ped) or IsDisabledControlJustPressed(0,200) then return false end
        Wait(0)
    end
    return true
end

local function run(s)
    local entry=P.entities[s.key]
    if not entry or not DoesEntityExist(entry.entity) then error('panel no longer streamed') end
    local panel=entry.entity;s.panel=panel
    s.ped=PlayerPedId();s.wasFrozen=IsEntityPositionFrozen(s.ped)
    if s.wasFrozen or IsPedInAnyVehicle(s.ped,false) or IsEntityDead(s.ped) then return false end
    local room=Hotels.room(ClientState.hotels[s.hotel],s.number)
    local anchor=P.offset(panel,0,0,0)
    local front=P.offset(panel,0,-1,0)-anchor
    local side=P.offset(panel,1,0,0)-anchor
    local up=P.offset(panel,0,0,1)-anchor
    local floorZ=room.floorZ or room.door.z
    local stand=P.offset(panel,0,-(cfg.ApproachDistance or .65),0)
    stand=vec3(stand.x,stand.y,floorZ+1.0)
    local heading=(GetEntityHeading(panel))%360
    MinigameLockBegin(true);s.locked=true
    TaskGoStraightToCoord(s.ped,stand.x,stand.y,stand.z,.8,6000,heading,.05)
    local deadline=GetGameTimer()+6500
    while #(GetEntityCoords(s.ped)-stand)>.28 do
        if GetGameTimer()>deadline or IsEntityDead(s.ped) or IsDisabledControlJustPressed(0,200) then return false end
        Wait(0)
    end
    ClearPedTasks(s.ped);SetEntityHeading(s.ped,heading)

    -- Take the device out, let the hold pose settle, then step so that the
    -- device's cable socket sits where Hold.socketTarget says.
    s.device=object(cfg.DeviceModel,GetEntityCoords(s.ped))
    holdDevice(s.ped,s.device)
    if not waitFor(450,s) then return false end
    local tx,ty,tz=holdVector(hold.socketTarget,-.03,.22,-.17)
    local root=ToVec3(deviceRest(s)[1])
    local wanted=anchor+side*tx+front*ty+up*tz
    local step=wanted-root;step=vec3(step.x,step.y,0.0)
    if length(step)>.5 then step=step*(.5/length(step)) end
    local at=GetEntityCoords(s.ped)+step
    SetEntityCoordsNoOffset(s.ped,at.x,at.y,at.z,false,false,false)
    FreezeEntityPosition(s.ped,true)
    if not waitFor(50,s) then return false end

    -- Shortened cable, but always long enough to reach the socket.
    local socket=P.offset(panel,.025,-.009,-.1285)
    local rest=deviceRest(s)
    -- The cable always has a little slack to the socket (8% more than the
    -- straight distance). It grows during the scene if the device moves away.
    local cableScale=tonumber(cfg.CableScale) or .7
    local function fitCable(points)
        local needed=#(ToVec3(points[1])-socket)*1.08/factoryLength
        if s.cable and needed<=s.cable.scale then return end
        local scale=math.max(cableScale,math.min(3.0,needed),s.cable and s.cable.scale or 0)
        if Config.Debug and needed>cableScale then
            print(('[zloma_apartments] alarm cable lengthened to %.2f so the plug reaches the panel (tune Hold.socketTarget)'):format(scale))
        end
        s.cable=AlarmCable.new(points,scale)
        s.cable.sag=front
    end
    fitCable(rest)
    local plug=ToVec3(AlarmCable.update(s.cable,nil,0,rest))
    s.connector=object(cfg.ConnectorModel,plug)
    s.links={}
    for i=1,#rest-1 do s.links[i]=object(AlarmDeviceRig.linkModel,rest[i]) end
    placeCable(s,front)

    local fov=float(view.fov,80.0)
    local minFov=math.min(fov,float(view.minFov,25.0))
    local head=GetPedBoneCoords(s.ped,31086,0.0,0.0,0.0) -- SKEL_Head
    local from,aim,cameraRotation,axes=AlarmPanel.headCamera(head,front*-1,anchor,GetEntityCoords(s.device),view)
    local look=view.look or {}
    local lookYaw,lookPitch,currentFov,wantedFov=0.0,0.0,fov,fov
    s.cam=CreateCam('DEFAULT_SCRIPTED_CAMERA',true);SetCamCoord(s.cam,from.x,from.y,from.z)
    SetCamRot(s.cam,cameraRotation.x,0,cameraRotation.z,2)
    SetCamFov(s.cam,fov);SetCamActive(s.cam,true)
    if view.dof ~= false then
        SetCamUseShallowDofMode(s.cam,true)
        SetCamNearDof(s.cam,math.max(.05,axes.distance-.2))
        SetCamFarDof(s.cam,axes.distance+.35)
        SetCamDofStrength(s.cam,1.0)
    end
    -- Do not interpolate from an old camera (which can still be at the world
    -- origin or below the MLO). Render the fully positioned camera directly.
    RenderScriptCams(true,false,0,true,true)
    if Config.Debug then
        print(('[zloma_apartments] alarm camera %s: panel %.3f %.3f %.3f; camera %.3f %.3f %.3f; aim %.3f %.3f %.3f'):format(
            s.key,anchor.x,anchor.y,anchor.z,from.x,from.y,from.z,aim.x,aim.y,aim.z))
    end
    local camFront=vec3(-axes.forward.x,-axes.forward.y,-axes.forward.z)
    local camRight=vec3(axes.right.x,axes.right.y,axes.right.z)
    local camUp=vec3(axes.up.x,axes.up.y,axes.up.z)
    -- The camera leans towards the mouse (twice as much fully zoomed in) and the
    -- wheel zooms. The cursor ray always uses the camera as it is this frame.
    local function moveCamera()
        local dt=math.min(GetFrameTime(),.05);local blend=1-math.exp(-7*dt)
        if IsDisabledControlJustPressed(0,241) then wantedFov=math.max(minFov,wantedFov-7) end -- wheel up: zoom in
        if IsDisabledControlJustPressed(0,242) then wantedFov=math.min(fov,wantedFov+7) end
        currentFov=currentFov+(wantedFov-currentFov)*blend
        local zoomed=fov>minFov and (fov-currentFov)/(fov-minFov) or 0
        local reach=1+zoomed -- twice as strong fully zoomed in
        local cx,cy=GetDisabledControlNormal(0,239),GetDisabledControlNormal(0,240)
        lookYaw=lookYaw+((.5-cx)*2*float(look.yaw,14.0)*reach-lookYaw)*blend
        lookPitch=lookPitch+((.5-cy)*2*float(look.pitch,12.0)*reach-lookPitch)*blend
        local pitch,yaw=cameraRotation.x+lookPitch,cameraRotation.z+lookYaw
        SetCamRot(s.cam,pitch,0.0,yaw,2);SetCamFov(s.cam,currentFov)
        local p,w=math.rad(pitch),math.rad(yaw)
        local forward=vec3(-math.sin(w)*math.cos(p),math.cos(w)*math.cos(p),math.sin(p))
        camFront=forward*-1
        camRight=vec3(math.cos(w),math.sin(w),0.0)
        camUp=cross(camRight,forward)
    end
    -- The plug is dragged on a plane parallel to the wall. On grab the plane is
    -- at the plug; while held it glides to just in front of the socket, so the
    -- plug reaches the panel even when the player stands further back.
    local socketDepth=dot(socket-anchor,front)+.012
    local planeDepth=dot(plug-anchor,front)
    local grabDepth,grabAt=planeDepth,0
    local grabOffset=vec3(0.0,0.0,0.0)
    local function pointerHit()
        local width,height=GetActiveScreenResolution()
        local x,y=GetDisabledControlNormal(0,239),GetDisabledControlNormal(0,240)
        local origin,direction=AlarmPanel.cursorPlaneRay(x,y,from,camFront,camRight,camUp,currentFov,width/height)
        return AlarmPanel.rayPlane(origin,direction,anchor+front*planeDepth,front)
    end
    local screen=P.screen('device')
    local screenData={state='connect',title=_L('alarm_connect_instruction'),sub=_L('alarm_connect_drag')}
    local function display(data) screenData=data;P.message(screen,data) end
    display(screenData)
    lib.showTextUI(_L('alarm_connect_controls'),{position='bottom-center'})
    local held,connected,progressAt,finishAt=false,false,nil,nil
    local target -- nil: the plug hangs from the device
    local deadline=GetGameTimer()+(cfg.SessionSeconds or 90)*1000;local resend=0
    -- phase: 'link' (drag the plug) > 'ready' (START HACK) > 'hack' > 'result'
    local phase,focusAt,resultAt,outcome='link',0,0,nil
    local hackCfg=s.kind=='safe' and Config.Security.Alarm.SafeHack or nil
    hackCfg=setmetatable(hackCfg or {},{__index=Config.Security.Alarm.Hack or {}})
    local focus=hackCfg.Camera or {}
    local focusFov=float(focus.fov,18.0)
    local focusDistance=(SCREEN.maxY-SCREEN.minY)*.5/(math.tan(math.rad(focusFov*.5))*math.max(.3,math.min(1,float(focus.fill,.82))))
    -- Cursor ray of the camera in use this frame.
    local function cursorRay()
        local width,height=GetActiveScreenResolution()
        local x,y=GetDisabledControlNormal(0,239),GetDisabledControlNormal(0,240)
        if phase=='hack' or phase=='result' then
            local o=P.offset(s.device,0,0,0)
            local ax,ay,az=P.offset(s.device,1,0,0)-o,P.offset(s.device,0,1,0)-o,P.offset(s.device,0,0,1)-o
            local origin=P.offset(s.device,0.0,SCREEN.cy,SCREEN.z+focusDistance)
            return AlarmPanel.cursorPlaneRay(x,y,origin,az,ax,ay,focusFov,width/height)
        end
        return AlarmPanel.cursorPlaneRay(x,y,from,camFront,camRight,camUp,currentFov,width/height)
    end
    -- Mouse on the device screen goes to its DUI as real mouse events.
    local mouseHeld=false
    -- The device screen's corners as the game draws them this frame. Mapping
    -- the cursor through them works for any camera and any player heading.
    local corners={{SCREEN.minX,SCREEN.maxY},{SCREEN.maxX,SCREEN.maxY},{SCREEN.maxX,SCREEN.minY},{SCREEN.minX,SCREEN.minY}}
    local function cursorUV()
        local quad={}
        for i,c in ipairs(corners) do
            local p=P.offset(s.device,c[1],c[2],SCREEN.z)
            local visible,x,y=GetScreenCoordFromWorldCoord(p.x,p.y,p.z)
            if not visible then quad=nil;break end
            quad[i]={x=x,y=y}
        end
        if quad then
            local u,v=AlarmPanel.quadUV(quad,GetDisabledControlNormal(0,239),GetDisabledControlNormal(0,240))
            if u then return u,v end
        end
        local origin,direction=cursorRay()
        return screenHit(s,origin,direction)
    end
    local function forwardMouse()
        local u,v=cursorUV()
        local inside=u and u>=0 and u<=1 and v>=0 and v<=1
        if u and (inside or mouseHeld) then
            SendDuiMouseMove(screen.dui,math.floor(math.max(0,math.min(1,u))*AlarmDeviceRig.screenWidth),math.floor(math.max(0,math.min(1,v))*AlarmDeviceRig.screenHeight))
        end
        if inside and IsDisabledControlJustPressed(0,24) then SendDuiMouseDown(screen.dui,'left');mouseHeld=true end
        if mouseHeld and IsDisabledControlJustReleased(0,24) then SendDuiMouseUp(screen.dui,'left');mouseHeld=false end
    end
    local function finishHack(result,fails)
        local res=lib.callback.await('zloma_apartments:alarmHackFinish',false,{token=s.token,result=result,fails=fails})
        s.finished=true
        outcome=res and res.result or 'fail'
        P.message(screen,{state='hack_result',result=outcome,dispatched=res and res.dispatched})
        phase,resultAt='result',GetGameTimer()+(outcome=='cancel' and 1200 or 2800)
        lib.hideTextUI()
    end
    s.events={}
    while not s.cleaned do
        if not DoesEntityExist(panel) or IsEntityDead(s.ped) or IsPedRagdoll(s.ped)
            or #(GetEntityCoords(s.ped)-anchor)>2.5 or GetGameTimer()>deadline then return false end
        local escape=IsDisabledControlJustPressed(0,200) or IsDisabledControlJustPressed(0,177)
        if phase=='hack' then
            if IsDisabledControlJustPressed(0,200) and s.hack.cancel then
                P.message(screen,{state='hack_abort'})
                finishHack('cancel',0)
            end
        elseif phase~='result' and escape then
            return false
        end
        SetMouseCursorActiveThisFrame();SetMouseCursorSprite(held and 4 or 1)
        if phase=='link' or phase=='ready' then moveCamera() end
        if phase=='ready' or (phase=='hack' and GetGameTimer()>focusAt) then forwardMouse() end
        -- What the device screen reported (NUI callback 'alarm_hack').
        local event=table.remove(s.events,1)
        if event and phase=='ready' and event.event=='start' then
            local started=lib.callback.await('zloma_apartments:alarmHackStart',false,{token=s.token})
            if not started or not started.success then
                ClientBridge.notify(started and started.error or _L('error_generic'),'error');return false
            end
            s.hackStarted=true;phase='hack'
            deadline=GetGameTimer()+1800*1000 -- the server enforces the real limit
            -- Lock the camera onto the device screen (no zoom, no mouse look).
            s.focusCam=CreateCam('DEFAULT_SCRIPTED_CAMERA',true)
            HardAttachCamToEntity(s.focusCam,s.device,-90.0,0.0,0.0,0.0,SCREEN.cy,SCREEN.z+focusDistance,true)
            SetCamFov(s.focusCam,focusFov);SetCamNearClip(s.focusCam,.01)
            SetCamActiveWithInterp(s.focusCam,s.cam,600,1,1)
            focusAt=GetGameTimer()+650
            P.message(screen,{state='hack',stages=s.hack.stages,strikes=s.hack.strikes})
            lib.showTextUI(_L(s.hack.cancel and 'alarm_hack_controls' or 'alarm_hack_controls_locked'),{position='bottom-center'})
        elseif event and phase=='hack' and event.event=='done' then
            finishHack(event.success==true and 'success' or 'fail',tonumber(event.fails) or 0)
        end
        if phase=='result' and GetGameTimer()>resultAt then return outcome=='success' end
        if view.dof ~= false then SetUseHiDof() end
        if hold.dict and not IsEntityPlayingAnim(s.ped,hold.dict,hold.anim,3) then
            TaskPlayAnim(s.ped,hold.dict,hold.anim,4.0,4.0,-1,49,0,false,false,false)
        end
        if not connected and phase=='link' then
            if IsDisabledControlJustPressed(0,24) and cursorOn(P.offset(s.connector,0.0,.018,0.0),38) then
                planeDepth=dot(plug-anchor,front)
                local hit=pointerHit()
                if hit then
                    held=true;grabDepth,grabAt=planeDepth,GetGameTimer()
                    grabOffset=plug-ToVec3(hit);grabOffset=grabOffset-front*dot(grabOffset,front)
                end
            end
            if held then
                local k=math.min(1,(GetGameTimer()-grabAt)/300)
                planeDepth=grabDepth+(socketDepth-grabDepth)*k
                local hit=pointerHit()
                if hit then
                    local v=ToVec3(hit)+grabOffset
                    local delta=v-anchor
                    local x=math.max(-.18,math.min(.18,dot(delta,side)))
                    local z=math.max(-.36,math.min(.12,dot(delta,up)))
                    local depth=planeDepth
                    target=anchor+side*x+up*z+front*depth
                end
                if IsDisabledControlJustReleased(0,24) then
                    held=false
                    local delta=plug-socket
                    local x,z=dot(delta,side),dot(delta,up)
                    if x*x+z*z<.035^2 or cursorOn(socket,28) then
                        connected=true;target=socket;progressAt=GetGameTimer()
                        PlaySoundFrontend(-1,'SELECT','HUD_FRONTEND_DEFAULT_SOUNDSET',true)
                        display({state='linking',title=_L('alarm_connect_linking'),progress=0,lines={_L('alarm_connect_probe')}})
                    end
                end
            end
            DrawMarker(28,socket.x,socket.y,socket.z,0,0,0,0,0,0,.012,.012,.012,80,220,200,190,false,false,2,false,nil,nil,false)
        end
        -- The device moves with the hold animation; the solver skips unchanged frames.
        local points=deviceRest(s)
        fitCable(points)
        plug=ToVec3(AlarmCable.update(s.cable,target,GetFrameTime(),points))
        if connected then plug=socket end
        local nodes=s.cable.nodes
        placeConnector(s,plug,connected and up or (ToVec3(nodes[#nodes])-ToVec3(nodes[#nodes-1])),front)
        placeCable(s,front)
        if connected and not finishAt then
            local fraction=math.min(1,(GetGameTimer()-progressAt)/(s.seconds*1000))
            if GetGameTimer()-resend>100 then
                display({state='linking',title=_L('alarm_connect_linking'),progress=fraction,lines={_L('alarm_connect_probe'),fraction>.35 and _L('alarm_connect_bus') or '',fraction>.7 and _L('alarm_connect_handshake') or ''}})
                resend=GetGameTimer()
            end
            if fraction>=1 then
                local result=lib.callback.await('zloma_apartments:alarmConnectFinish',false,{token=s.token,connected=true})
                if not result or not result.success or not result.connected or type(result.hack)~='table' then
                    s.finished=true
                    ClientBridge.notify(result and result.error or _L('error_generic'),'error');return false
                end
                s.hack=result.hack
                display({state='success',title=_L('alarm_connect_success'),sub=_L('alarm_connect_ready'),progress=1,start=true})
                finishAt=true;phase='ready'
                deadline=GetGameTimer()+110*1000
                lib.showTextUI(_L('alarm_hack_ready_controls'),{position='bottom-center'})
            end
        end
        -- Replay the link screens in case the browser started late; never during a hack.
        if (phase=='link' or phase=='ready') and GetGameTimer()-resend>750 then P.message(screen,screenData);resend=GetGameTimer() end
        DrawLightWithRange(from.x,from.y,from.z,235,242,255,1.2,1.0)
        P.drawDevice(s.device,screen)
        Wait(0)
    end
    return false
end
RegisterNUICallback('alarm_hack',function(data,cb)
    if scene and scene.events and type(data)=='table' then scene.events[#scene.events+1]=data end
    cb({})
end)

function StartAlarmConnection(hotel,number,kind)
    if P.busy or P.editing or (IsApartmentMinigameBusy and IsApartmentMinigameBusy()) then return end
    kind=kind=='safe' and 'safe' or 'door'
    P.busy=true;P.sceneKey=(kind=='safe' and 'safe:' or '')..hotel..':'..number
    local s={key=P.sceneKey,hotel=hotel,number=number,kind=kind};scene=s
    local ok,err=xpcall(function()
        local result=lib.callback.await('zloma_apartments:alarmConnectStart',false,{hotel_id=hotel,room_number=number,kind=kind})
        if not result or not result.success then ClientBridge.notify(result and result.error or _L('error_generic'),'error');return end
        s.token,s.seconds=result.token,result.seconds
        run(s)
    end,debug.traceback)
    cleanup(s)
    if s.token and not s.finished then
        pcall(lib.callback.await,'zloma_apartments:alarmConnectFinish',false,{token=s.token,connected=false})
    end
    if not ok then print('[zloma_apartments] alarm connection: '..err);ClientBridge.notify(_L('error_generic'),'error') end
end
AddEventHandler('onResourceStop',function(name) if name==GetCurrentResourceName() then cleanup(scene) end end)

-- Debug helper: hold the device and move it in the hand until it sits right.
-- W/S A/D Q/E move, hold SHIFT to rotate, CTRL for fine steps,
-- ENTER prints the Hold values for config.lua, BACKSPACE leaves.
if Config.Debug then
    RegisterCommand('apartment_alarm_hold',function()
        if P.busy or P.editing then return end
        P.busy=true
        local ped=PlayerPedId()
        local device
        local ok,err=pcall(function()
            device=object(cfg.DeviceModel,GetEntityCoords(ped))
            holdDevice(ped,device)
            local o={holdVector(hold.offset,-0.008,0.010,0.012)}
            local r={holdVector(hold.rotation,-253.5,-3.0,-8.0)}
            local bone=GetPedBoneIndex(ped,hold.bone or 28422)
            local function text()
                return ('Offset %.3f %.3f %.3f  \nRotation %.1f %.1f %.1f  \nW/S A/D Q/E move, SHIFT rotate, CTRL fine  \nENTER print, BACKSPACE close'):format(o[1],o[2],o[3],r[1],r[2],r[3])
            end
            lib.showTextUI(text(),{position='left-center'})
            while true do
                DisableAllControlActions(0);EnableControlAction(0,1,true);EnableControlAction(0,2,true);EnableControlAction(0,249,true)
                local fine=IsDisabledControlPressed(0,36)
                local rotate=IsDisabledControlPressed(0,21)
                local amount=rotate and (fine and .25 or 1.5) or (fine and .0005 or .003)
                local list=rotate and r or o
                local changed=false
                local keys={{32,2,1},{33,2,-1},{35,1,1},{34,1,-1},{38,3,1},{44,3,-1}}
                for _,k in ipairs(keys) do
                    if IsDisabledControlPressed(0,k[1]) then list[k[2]]=list[k[2]]+amount*k[3];changed=true end
                end
                if changed then
                    AttachEntityToEntity(device,ped,bone,o[1],o[2],o[3],r[1],r[2],r[3],true,true,false,true,1,true)
                    lib.showTextUI(text(),{position='left-center'})
                end
                local root=P.offset(device,AlarmDeviceRig.cableRest[1].x,AlarmDeviceRig.cableRest[1].y,AlarmDeviceRig.cableRest[1].z)
                DrawMarker(28,root.x,root.y,root.z,0,0,0,0,0,0,.006,.006,.006,80,220,200,220,false,false,2,false,nil,nil,false)
                if IsDisabledControlJustPressed(0,191) then
                    print(('offset = vec3(%.3f, %.3f, %.3f),\nrotation = vec3(%.1f, %.1f, %.1f),'):format(o[1],o[2],o[3],r[1],r[2],r[3]))
                    ClientBridge.notify('Hold values printed to F8','success')
                end
                if IsDisabledControlJustPressed(0,177) or IsEntityDead(ped) then break end
                Wait(0)
            end
        end)
        lib.hideTextUI()
        if device and DoesEntityExist(device) then DetachEntity(device,false,false);DeleteEntity(device) end
        ClearPedTasks(ped)
        P.busy=false
        if not ok then print('[zloma_apartments] alarm hold: '..tostring(err)) end
    end,false)
end
