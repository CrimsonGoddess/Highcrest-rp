-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Volatile, booking-bound breach and hinge state. A server/resource restart resets it.
SafeLifecycle={}
local L=SafeLifecycle
local states,viewers,pending,queries={},{},{},{}
local revision=0
local function key(b)return b.hotel..':'..b.room end
local function resident(b,id)return id and (b.owner==id or b.roommate==id)end
local function nextRevision()revision=revision+1;return revision end
local function state(b)
    local k=key(b);local s=states[k]
    if not s or s.booking~=b then
        s={booking=b,from=0,target=0,started=GetGameTimer(),duration=0,revision=nextRevision(),breached=false,recovery=0}
        states[k]=s
    end
    return s
end
local function wire(s)
    return {from=s.from,target=s.target,duration=s.duration,elapsed=math.max(0,GetGameTimer()-s.started),revision=s.revision,breached=s.breached}
end
local function publish(s)
    TriggerClientEvent('zloma_apartments:safeState',-1,s.booking.hotel,s.booking.room,wire(s))
end
local function move(s,target)
    local now=GetGameTimer();local angle=SafeMotion.angle(s,now)
    if s.target~=target then
        local seconds=target==0 and (Config.Safe.CloseSeconds or .4) or (Config.Safe.DoorSeconds or 1.2)
        s.from,s.target,s.started=angle,target,now
        s.duration=math.max(0,math.floor(seconds*1000*math.abs(target-angle)/SafeModel.openAngle))
        if Config.Safe.PropModel~=SafeModel.body then s.duration=0 end
        s.revision=nextRevision();publish(s)
    end
    return math.max(0,s.duration-(now-s.started))
end
local function valid(v)
    return states[key(v.booking)]==v.state and v.state.recovery==v.recovery
        and State.booking(v.booking.hotel,v.booking.room)==v.booking and Bridge.identifier(v.src)==v.identifier
        and GetPlayerRoutingBucket(v.src)==v.bucket and NearSafe(v.src,v.booking)
        and SafePinVersion(v.recordKey)==v.pinVersion
end
local function viewing(s)
    for _,v in pairs(viewers)do if v.state==s then return true end end
    for _,v in pairs(pending)do if v.state==s then return true end end
    return false
end
local function idle(s)
    if not s.breached and not viewing(s)then move(s,0)end
end
local function closeClient(v)
    -- Let ox close its own server inventory and fire the normal close event.
    local closed=false
    if GetResourceState('ox_inventory')=='started' then
        pcall(function()
            local inv=exports.ox_inventory:GetInventory(v.src)
            if inv and tostring(inv.open)==v.id and inv.closeInventory then inv:closeInventory();closed=true end
        end)
    end
    if not closed then TriggerClientEvent('zloma_apartments:closeSafeInventory',v.src)end
end
function L.generation(b)return state(b).recovery end
function L.isBreached(b)
    local s=b and states[key(b)]
    return s~=nil and s.booking==b and s.breached==true
end
function L.current(src,v)return v~=nil and viewers[src]==v and valid(v)end
function L.inventoryAllowed(src,id)
    local v=viewers[src]
    return v and v.id==tostring(id) and valid(v) or false
end
function L.closed(src,id)
    src=tonumber(src);local v=viewers[src]
    if not v or tostring(id)~=v.id then return end
    viewers[src]=nil;RevokeSafeGrant(src)
    local s=v.state
    if State.booking(v.booking.hotel,v.booking.room)~=v.booking then idle(s);return end
    -- Closing the inventory opened by a crack never recovers the safe, even
    -- when Debug allowed its owner/roommate to act as the robber. Only a
    -- subsequent normal resident open/close is a recovery operation.
    if v.opened and not v.breachAttempt and valid(v) and resident(v.booking,Bridge.identifier(src)) then
        s.breached=false;s.recovery=s.recovery+1;s.revision=nextRevision()
        if SetApartmentAlarmDisabled then SetApartmentAlarmDisabled(v.booking,'safe',false)end
        -- Recovery revokes other open/pending robber sessions too.
        for player,other in pairs(pending)do
            if other.state==s then pending[player]=nil;RevokeSafeGrant(player)end
        end
        local others={}
        for player,other in pairs(viewers)do
            if other.state==s then viewers[player]=nil;RevokeSafeGrant(player);others[#others+1]=other end
        end
        for _,other in ipairs(others)do closeClient(other)end
        publish(s)
    end
    idle(s)
end
function L.opened(src,id)
    local v=viewers[tonumber(src)]
    if v and v.id==tostring(id)then v.opened=true end
end
AddEventHandler('ox_inventory:openedInventory',L.opened)
AddEventHandler('ox_inventory:closedInventory',function(src,id)L.closed(src,id)end)
function L.open(src,b,mode,expected)
    if not b or not NearSafe(src,b)then return Fail('error_safe_too_far')end
    local old=viewers[src]
    if old and old.opened then return old.booking==b and {success=true,already_open=true} or Fail('error_busy')end
    if old then viewers[src]=nil;RevokeSafeGrant(src);idle(old.state)end
    local record=SafeRecord(b);if not record then return Fail('error_generic')end
    local s=state(b)
    if s.recovery~=expected or (mode=='breached' and not s.breached)then return Fail('error_invalid')end
    if mode==true then s.breached=true;s.revision=nextRevision();publish(s)end
    local previous=pending[src]
    pending[src]=nil
    if previous and previous.state~=s then idle(previous.state)end
    local v={src=src,booking=b,state=s,breachAttempt=mode==true,recovery=expected,id=record.stash,recordKey=record.key,pinVersion=SafePinVersion(record.key),
        identifier=Bridge.identifier(src),bucket=GetPlayerRoutingBucket(src)}
    pending[src]=v
    TriggerClientEvent('zloma_apartments:client:closeUI',src)
    local delay=move(s,SafeModel.openAngle)
    local function ready()
        if pending[src]~=v then return end
        pending[src]=nil
        if not valid(v)then RevokeSafeGrant(src);idle(s);return end
        viewers[src]=v
        local ok,result=pcall(OpenSafeInventoryNow,src,b,v)
        if viewers[src]~=v then return end
        if not ok or not result or not result.success then
            if viewers[src]==v then viewers[src]=nil end
            RevokeSafeGrant(src,v);idle(s);Bridge.notify(src,_L('error_generic'),'error');return
        end
        -- A failed client open must not leave a normal safe open indefinitely.
        SetTimeout(12000,function()
            if viewers[src]==v and not v.opened then viewers[src]=nil;RevokeSafeGrant(src);idle(s)end
        end)
    end
    if delay<=0 then ready()else SetTimeout(math.ceil(delay),ready)end
    return {success=true,opening=true}
end
function L.release(b)
    if not b then return end
    local s=states[key(b)];if not s or s.booking~=b then return end
    for player,v in pairs(pending)do if v.state==s then pending[player]=nil;RevokeSafeGrant(player)end end
    local close={}
    for player,v in pairs(viewers)do if v.state==s then viewers[player]=nil;RevokeSafeGrant(player);close[#close+1]=v end end
    s.breached=false;move(s,0);publish(s);states[key(b)]=nil
    for _,v in ipairs(close)do closeClient(v)end
end
lib.callback.register('zloma_apartments:safeStates',function(src)
    if not Config.Safe.Enabled then return {}end
    local now=os.time();if queries[src]==now then return nil end;queries[src]=now
    local out={}
    for _,rooms in pairs(State.bookings)do for _,b in pairs(rooms)do
        local room=State.room(b.hotel,b.room)
        if room and room.safe and NearPoint(src,room.safe,(Config.Safe.StreamDistance or 18)+5)then out[key(b)]=wire(state(b))end
    end end
    return out
end)
CreateThread(function()
    if GetResourceState('ox_inventory')~='started'then return end
    exports.ox_inventory:registerHook('swapItems',function(payload)
        for _,id in ipairs({payload.fromInventory,payload.toInventory})do
            id=tostring(id)
            if (id:find('^apt_personal_') or id:find('^apt_room_')) and not L.inventoryAllowed(payload.source,id)then return false end
        end
    end,{inventoryFilter={'^apt_personal_','^apt_room_'}})
end)
AddEventHandler('playerDropped',function()
    local src=source;queries[src]=nil
    local p=pending[src];pending[src]=nil
    local v=viewers[src];viewers[src]=nil
    if p then idle(p.state)end
    if v then idle(v.state)end
end)
AddEventHandler('onResourceStop',function(name)
    if name~=GetCurrentResourceName()then return end
    local closing={}
    for src,v in pairs(viewers)do closing[#closing+1]=v;RevokeSafeGrant(src)end
    viewers={};pending={}
    for _,v in ipairs(closing)do closeClient(v)end
end)
