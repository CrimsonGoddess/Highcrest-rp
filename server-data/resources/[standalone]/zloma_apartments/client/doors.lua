-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Native door locks, 3D prompt and keybinds for every loaded building.
-- A door is bound only to an existing object of the right model at the
-- floor's height, so a reused entity handle never links room 101 to 201.
local doors, byKey = {}, {}
local locked, occupied = {}, {}
local access = {}
local current, busy = nil, false

function CanAccessApartmentSafe(key) return occupied[key] == true end
local function doorKey(hotel, number) return ('%s:%d'):format(hotel, number) end

local function floorLoaded(door) return not door.ipl or IsIplActive(door.ipl) end

local function matches(door, entity)
    if not door.model or not entity or entity == 0 or not DoesEntityExist(entity) or not floorLoaded(door) then return false end
    if (GetEntityModel(entity) & 0xffffffff) ~= (door.model & 0xffffffff) then return false end
    local c = GetEntityCoords(entity)
    local dx, dy = c.x - door.coords.x, c.y - door.coords.y
    return dx * dx + dy * dy <= Config.Doors.SearchRadius ^ 2 and c.z >= door.floorZ - 0.25 and c.z < door.floorZ + 2.75
end

local function release(door)
    if door.entity then RemoveDoorInteract(door.entity) end
    if door.frozen and matches(door, door.entity) then FreezeEntityPosition(door.entity, false) end
    if door.registered then RemoveDoorFromSystem(door.id) end
    door.entity, door.registered, door.frozen, door.applied, door.physics = nil, false, false, nil, false
end

local function shouldLock(door) return not occupied[door.key] or locked[door.key] ~= false end

local function apply(door, force)
    if not door.registered or not matches(door, door.entity) then return end
    local isLocked = shouldLock(door)
    local state = isLocked and 1 or 0
    if not DoorSystemGetIsPhysicsLoaded(door.id) then
        -- Lock states apply only once door physics loads; hold it shut meanwhile.
        if isLocked ~= door.frozen then FreezeEntityPosition(door.entity, isLocked); door.frozen = isLocked end
        door.applied, door.physics = nil, false
        return
    end
    if force or not door.physics or door.applied ~= state or DoorSystemGetDoorState(door.id) ~= state then
        DoorSystemSetDoorState(door.id, 4, false, true)
        if isLocked then DoorSystemSetOpenRatio(door.id, 0.0, false, true) end
        DoorSystemSetDoorState(door.id, state, false, true)
        door.applied = state
    end
    door.physics = true
    if door.frozen then FreezeEntityPosition(door.entity, false); door.frozen = false end
end

local function bind(door)
    if door.registered and matches(door, door.entity) then return true end
    if door.registered or door.entity then release(door) end
    if not door.model or not floorLoaded(door) or not IsModelValid(door.model) then return false end
    local c = door.coords
    local entity = GetClosestObjectOfType(c.x, c.y, c.z, Config.Doors.SearchRadius, door.model, false, false, false)
    if not matches(door, entity) then return false end
    local p = GetEntityCoords(entity)
    RemoveDoorFromSystem(door.id)
    AddDoorToSystem(door.id, door.model, p.x, p.y, p.z, false, false, false)
    door.entity, door.registered = entity, true
    DoorSystemSetAutomaticRate(door.id, 10.0, false, false)
    AddDoorInteract(door, entity)
    apply(door, true)
    return true
end

local function modelHash(value)
    if type(value) == 'string' then return joaat(value) end
    return value
end

local function rebuild(hotels)
    for _, door in ipairs(doors) do release(door) end
    doors, byKey, current = {}, {}, nil
    for id, def in pairs(hotels) do
        Hotels.each(def, function(number)
            local room = Hotels.room(def, number)
            local key = doorKey(id, number)
            local door = {
                key = key, hotel = id, number = number, id = joaat('zloma_apt_' .. key),
                model = modelHash(room.model), coords = ToVec3(room.door), floorZ = room.floorZ, ipl = room.ipl,
            }
            doors[#doors + 1] = door
            byKey[key] = door
        end)
    end
end
OnHotelsChanged(rebuild)

local function setDoor(key, isLocked, isOccupied)
    locked[key] = isLocked
    occupied[key] = isOccupied
    local door = byKey[key]
    if door and bind(door) then apply(door, true) end
end

RegisterNetEvent('zloma_apartments:client:door', function(key, isLocked, isOccupied)
    setDoor(key, isLocked == true, isOccupied == true)
end)

RegisterNetEvent('zloma_apartments:client:doors', function(states)
    locked, occupied = {}, {}
    for key, value in pairs(states or {}) do locked[key] = value; occupied[key] = true end
    for _, door in ipairs(doors) do if door.registered then apply(door, true) end end
end)

function RefreshDoorAccess()
    local ok, data = pcall(lib.callback.await, 'zloma_apartments:getAccess', false)
    if not ok or not data then return end
    access = data.control or {}
    locked, occupied = {}, {}
    for key, value in pairs(data.doors or {}) do locked[key] = value; occupied[key] = true end
end
RegisterNetEvent('zloma_apartments:client:refreshAccess', RefreshDoorAccess)

CreateThread(function()
    while not ClientState.ready do Wait(500) end
    for key, value in pairs(ClientState.doors) do locked[key] = value; occupied[key] = true end
    while true do
        RefreshDoorAccess()
        Wait(30000)
    end
end)

-- The patched WiWang map announces floor swaps; without the patch the loops below catch up within 100 ms.
AddEventHandler('wiwang_hotel:floorUnloading', function()
    current = nil
    for _, door in ipairs(doors) do release(door) end
end)

-- The door the player stands at, for lockpicking: door, hasAccess, isLocked.
function CurrentApartmentDoor()
    if not current then return nil end
    return current, access[current.key] == true, shouldLock(current)
end

-- Keeps nearby doors in their server state.
CreateThread(function()
    while true do
        local ped = GetEntityCoords(PlayerPedId())
        local nearby = false
        for i = 1, #doors do
            local door = doors[i]
            if #(ped - door.coords) <= Config.Doors.EnforceRadius then
                nearby = true
                if bind(door) then apply(door) end
            elseif door.registered then
                release(door)
            end
        end
        Wait(nearby and Config.Doors.EnforceInterval or 1000)
    end
end)

local function toggleDoor(door)
    if not door or not access[door.key] or busy then return end
    busy = true
    local result = lib.callback.await('zloma_apartments:useDoor', false, { hotel_id = door.hotel, room_number = door.number, action = 'toggle' })
    if result and result.success then
        locked[door.key] = result.locked == true
        apply(door, true)
        lib.requestAnimDict('anim@heists@keycard@')
        TaskPlayAnim(PlayerPedId(), 'anim@heists@keycard@', 'exit', 8.0, 1.0, -1, 16, 0, false, false, false)
        Wait(800)
        ClearPedTasks(PlayerPedId())
        RemoveAnimDict('anim@heists@keycard@')
    elseif result and result.error then
        ClientBridge.notify(result.error, 'error')
    end
    busy = false
end

local function knock(door)
    if not door then return end
    local result = lib.callback.await('zloma_apartments:ringDoorbell', false, { hotel_id = door.hotel, room_number = door.number })
    if not result or not result.success then return end
    lib.requestAnimDict('timetable@jimmy@doorknock@')
    TaskPlayAnim(PlayerPedId(), 'timetable@jimmy@doorknock@', 'knockdoor_idle', 8.0, 1.0, -1, 16, 0, false, false, false)
    Wait(1500)
    ClearPedTasks(PlayerPedId())
    RemoveAnimDict('timetable@jimmy@doorknock@')
end

-- sleepless_interact options on the door handle (replaces the old 3D text + keybinds).
local function breakIn(door, kind)
    return occupied[door.key] and shouldLock(door) and (not access[door.key] or Config.Debug)
        and LockpickOptions('door', door.hotel, door.number)[kind] == true
end

local function pick(door, fn)
    return function()
        current = door -- lockpick.lua reads the door through CurrentApartmentDoor()
        CreateThread(function() fn(door) end)
    end
end

local function handleOffset(model)
    local min, max = GetModelDimensions(model)
    -- Hinge sits at the origin; the handle is on the far edge, ~1 m up.
    local x = math.abs(max.x) >= math.abs(min.x) and max.x - 0.12 or min.x + 0.12
    local size = max - min
    -- sleepless_interact offsets are fractions of the model box (0..1), not metres.
    return vec3((x - min.x) / size.x, 0.5, math.min(1.0 / size.z, 1.0))
end

function AddDoorInteract(door, entity)
    if GetResourceState('sleepless_interact') ~= 'started' then return end
    local offset, distance = handleOffset(door.model), Config.Doors.InteractDistance
    exports.sleepless_interact:addLocalEntity(entity, {
        { name = 'zloma_apt_unlock', label = _L('interact_unlock'), icon = 'fas fa-lock-open', offset = offset, distance = distance,
            canInteract = function() return occupied[door.key] and access[door.key] and shouldLock(door) end,
            onSelect = pick(door, toggleDoor) },
        { name = 'zloma_apt_lock', label = _L('interact_lock'), icon = 'fas fa-lock', offset = offset, distance = distance,
            canInteract = function() return occupied[door.key] and access[door.key] and not shouldLock(door) end,
            onSelect = pick(door, toggleDoor) },
        { name = 'zloma_apt_knock', label = _L('interact_knock'), icon = 'fas fa-hand-fist', offset = offset, distance = distance,
            canInteract = function() return occupied[door.key] end,
            onSelect = pick(door, knock) },
        { name = 'zloma_apt_lockpick', label = _L('interact_lockpick'), icon = 'fas fa-user-secret', offset = offset, distance = distance,
            canInteract = function() return breakIn(door, 'lockpick') end,
            onSelect = pick(door, function() LockpickApartmentDoor() end) },
        { name = 'zloma_apt_hack', label = _L('interact_hack'), icon = 'fas fa-microchip', offset = offset, distance = distance,
            canInteract = function() return breakIn(door, 'hack') end,
            onSelect = pick(door, function() HackApartmentDoor() end) },
    })
end

-- sleepless_interact forgets every option when it restarts; re-add for bound doors.
AddEventHandler('onClientResourceStart', function(name)
    if name ~= 'sleepless_interact' then return end
    for _, door in ipairs(doors) do
        if door.registered and matches(door, door.entity) then AddDoorInteract(door, door.entity) end
    end
end)

function RemoveDoorInteract(entity)
    if GetResourceState('sleepless_interact') ~= 'started' then return end
    exports.sleepless_interact:removeLocalEntity(entity)
end

RegisterNetEvent('zloma_apartments:client:doorbell', function()
    PlaySoundFrontend(-1, Config.Doorbell.Sound, Config.Doorbell.SoundSet, true)
end)

-- Used by the evicted handler: is the player standing inside this room?
function IsInsideRoom(hotelId, number)
    local def = ClientState.hotels[hotelId]
    local room = def and Hotels.room(def, number)
    if not room then return false end
    local p = GetEntityCoords(PlayerPedId())
    return #(p - ToVec3(room.door)) < 8.0 and math.abs(p.z - room.floorZ) < 2.5
end

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    for _, door in ipairs(doors) do release(door) end
end)
