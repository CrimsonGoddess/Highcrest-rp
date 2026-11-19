-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Rigid parts from the original skin groups. No per-frame work while idle.
SafeProps={entities={},states={}}
local S=SafeProps
local function offset(e,p)return GetOffsetFromEntityInWorldCoords(e,p.x+0.0,p.y+0.0,p.z+0.0)end
local function part(model,at,keep)
    local h=joaat(model)
    if not StreamModel(h,keep) then return nil end
    if keep and not keep() then ReleaseStreamModel(h);return nil end
    local e=CreateObjectNoOffset(h,at.x,at.y,at.z,false,false,false);ReleaseStreamModel(h)
    if e==0 then return nil end
    SetEntityCollision(e,false,false);FreezeEntityPosition(e,true);return e
end
function S.pose(s,angle,dial)
    if not DoesEntityExist(s.body) then return end
    s.angle,s.dialAngle=angle or s.angle or 0,dial or s.dialAngle or 0
    local h=SafeModel.hinge;local at=offset(s.body,h)
    SetEntityCoordsNoOffset(s.door,at.x,at.y,at.z,false,false,false)
    SetEntityHeading(s.door,GetEntityHeading(s.body)+s.angle)
    local d=SafeModel.dialPivot
    at=offset(s.door,{x=d.x-h.x,y=d.y-h.y,z=d.z-h.z})
    SetEntityCoordsNoOffset(s.dial,at.x,at.y,at.z,false,false,false)
    local x,y,z,w=GetEntityQuaternion(s.door);local a=math.rad(s.dialAngle)*.5;local sn,cs=math.sin(a),math.cos(a)
    SetEntityQuaternion(s.dial,x*cs-z*sn,y*cs+w*sn,z*cs+x*sn,w*cs-y*sn)
    if s.panel and DoesEntityExist(s.panel) then
        local p=SafeModel.panel;at=offset(s.door,{x=p.x-h.x,y=p.y-h.y,z=p.z-h.z})
        SetEntityCoordsNoOffset(s.panel,at.x,at.y,at.z,false,false,false)
        SetEntityHeading(s.panel,GetEntityHeading(s.door))
    end
end
function S.removePanel(s)
    if not s.panel then return end
    ClientBridge.removeEntity(s.panel,{'zloma_safe_alarm_'..s.key,'zloma_safe_alarm_'..s.key..'_arm'})
    if DoesEntityExist(s.panel) then DeleteEntity(s.panel) end
    if AlarmPanels then AlarmPanels.entities['safe:'..s.key]=nil end
    s.panel=nil
end
function S.destroy(key)
    local s=S.entities[key];if not s then return end
    S.entities[key]=nil;s.stopped=true;S.removePanel(s)
    for _,e in ipairs({s.door or 0,s.dial or 0})do if e~=0 and DoesEntityExist(e)then DeleteEntity(e)end end
end
function S.create(body,key,hotel,number,keep)
    if Config.Safe.PropModel~=SafeModel.body then return true end
    S.destroy(key)
    local s={body=body,key=key,hotel=hotel,number=number,angle=0,dialAngle=0};S.entities[key]=s
    s.door=part(SafeModel.door,GetEntityCoords(body),keep)
    if s.stopped then if s.door and DoesEntityExist(s.door)then DeleteEntity(s.door)end;return false end
    s.dial=part(SafeModel.dial,GetEntityCoords(body),keep)
    if s.stopped or (keep and not keep()) or not s.door or not s.dial then
        S.destroy(key)
        for _,e in ipairs({s.door or 0,s.dial or 0})do if e~=0 and DoesEntityExist(e)then DeleteEntity(e)end end
        return false
    end
    local cached=S.states[key]
    if cached then
        local data=cached.data
        s.breached=data.breached==true
        s.motion={from=data.from,target=data.target,duration=data.duration,started=cached.received-(data.elapsed or 0)}
        S.pose(s,SafeMotion.angle(s.motion,GetGameTimer()),0)
        -- Resume an in-flight motion on newly streamed props.
        S.states[key]=nil
        local copy={} for k,v in pairs(data)do copy[k]=v end
        copy.elapsed=(copy.elapsed or 0)+GetGameTimer()-cached.received
        S.apply(key,copy)
    else S.pose(s,0,0)end
    return true
end
-- The panel and the safe body expose the same physical hacking action.
function S.canHack(key)
    local s=S.entities[key];local p=AlarmPanels
    local active=p and p.active['safe:'..key]
    return s and s.panel and DoesEntityExist(s.panel) and s.angle<1 and not s.breached
        and active and not active.disabled and not p.busy and not p.editing
        and (Config.Debug or LockpickOptions('safe',s.hotel,s.number).panelHack==true) or false
end
function S.apply(key,data)
    local cached=S.states[key]
    if cached and data.revision<cached.data.revision then return end
    if cached and data.revision==cached.data.revision then return end
    local received=GetGameTimer();S.states[key]={data=data,received=received}
    local s=S.entities[key];if not s then return end
    s.breached=data.breached==true
    if s.animating and s.motion and s.motion.target~=data.target then
        -- Reverse from the last rendered angle, even when network jitter makes
        -- the server's sampled angle slightly different. Keep the same deadline.
        s.motion={from=s.angle,target=data.target,duration=math.max(0,data.duration-(data.elapsed or 0)),started=received}
    else
        s.motion={from=data.from,target=data.target,duration=data.duration,started=received-(data.elapsed or 0)}
    end
    if s.animating then return end
    s.animating=true
    CreateThread(function()
        while not s.stopped and s.motion do
            local motion=s.motion;local now=GetGameTimer()
            S.pose(s,SafeMotion.angle(motion,now))
            if now-motion.started>=motion.duration then
                if s.motion==motion then s.animating=false;return end
            end
            Wait(0)
        end
        s.animating=false
    end)
end
RegisterNetEvent('zloma_apartments:safeState',function(hotel,number,data)S.apply(hotel..':'..number,data)end)
RegisterNetEvent('zloma_apartments:closeSafeInventory',function()
    if GetResourceState('ox_inventory')=='started'then exports.ox_inventory:closeInventory()end
end)
CreateThread(function()
    while true do
        if next(S.entities)then
            local ok,states=pcall(lib.callback.await,'zloma_apartments:safeStates',false)
            if ok and type(states)=='table'then
                for key,data in pairs(states)do S.apply(key,data)end
                for key,s in pairs(S.entities)do
                    if not states[key] and S.states[key]then
                        S.states[key]=nil;s.motion={from=s.angle,target=0,duration=0,started=GetGameTimer()};s.breached=false;S.pose(s,0)
                    end
                end
            end
        end
        Wait(2000)
    end
end)
CreateThread(function()
    while true do
        if AlarmPanels then
            for key,s in pairs(S.entities)do
                local state=AlarmPanels.active['safe:'..key]
                if not state or not DoesEntityExist(s.body) then S.removePanel(s)
                elseif not s.panel or not DoesEntityExist(s.panel) or s.disabled~=state.disabled then
                    if not (AlarmPanels.busy and AlarmPanels.sceneKey=='safe:'..key) then
                        S.removePanel(s)
                        local p=offset(s.body,SafeModel.panel)
                        s.panel=AlarmPanels.create({position=p,rotation={x=0,y=0,z=GetEntityHeading(s.body)}},nil,state.disabled)
                        s.disabled=state.disabled
                        if s.panel then
                            AlarmPanels.entities['safe:'..key]={entity=s.panel,hotel=s.hotel,number=s.number,kind='safe',disabled=state.disabled,targetName='zloma_safe_alarm_'..key}
                            ClientBridge.addEntity(s.panel,{{name='zloma_safe_alarm_'..key,label=_L('alarm_panel_hack'),icon='fas fa-microchip',distance=Config.Safe.TargetDistance,
                                canInteract=function()
                                    return S.canHack(key)
                                end,
                                onSelect=function()StartAlarmConnection(s.hotel,s.number,'safe')end},AlarmPanels.armOption('safe',s.hotel,s.number,'safe:'..key,'zloma_safe_alarm_'..key..'_arm')})
                            S.pose(s)
                        end
                    end
                end
            end
        end
        Wait(500)
    end
end)
AddEventHandler('onResourceStop',function(name)
    if name==GetCurrentResourceName()then for key in pairs(S.entities)do S.destroy(key)end end
end)
