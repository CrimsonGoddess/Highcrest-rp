-- Taxi and 911. Requests live in memory, so they clear when the server restarts.
local TAXI_JOB = 'taxi'
local REQUEST_COOLDOWN_MS = 30000
local MAX_NOTE_LENGTH = 200
local EMERGENCY_KEEP_SECONDS = 1800
local EMERGENCY_TYPES = { police = 'leo', ems = 'ems' }
local EMERGENCY_LABELS = { police = 'Police', ems = 'EMS' }

local taxiRequests = {}
local nextTaxiId = 0
local emergencies = {}
local nextEmergencyId = 0

local function onDutyPlayers(matches)
    local found = {}
    for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
        local job = player.PlayerData.job
        if job and job.onduty and matches(job) then found[#found + 1] = player end
    end
    return found
end

local function isTaxiDriver(player)
    local job = player.PlayerData.job
    return job and job.name == TAXI_JOB and job.onduty
end

local function charName(player)
    local info = player.PlayerData.charinfo
    return ('%s %s'):format(info.firstname, info.lastname)
end

local function requestFor(src)
    for _, request in pairs(taxiRequests) do
        if request.passenger == src then return request end
    end
end

local function jobFor(src)
    for _, request in pairs(taxiRequests) do
        if request.driver == src then return request end
    end
end

local function notifyDrivers(event, payload)
    for _, driver in ipairs(onDutyPlayers(function(job) return job.name == TAXI_JOB end)) do
        TriggerClientEvent(event, driver.PlayerData.source, payload)
    end
end

-- Only what each side needs: drivers see a pickup, and a passenger sees their driver once accepted.
local function loadTaxi(player, src)
    local request = requestFor(src)
    local status = { isDriver = isTaxiDriver(player) and true or false }

    if request then
        status.request = {
            state = request.state,
            driverName = request.driverName,
            driverNumber = request.driverNumber,
        }
    end

    if status.isDriver then
        status.open = {}
        for _, item in pairs(taxiRequests) do
            if item.state == 'waiting' then
                status.open[#status.open + 1] = { id = item.id, name = item.name, note = item.note, x = item.x, y = item.y }
            end
        end
        local job = jobFor(src)
        if job then
            status.job = { id = job.id, name = job.name, number = job.number, note = job.note, x = job.x, y = job.y }
        end
    end

    return status
end

lib.callback.register('highcrest_phone:server:taxiGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end
    return loadTaxi(player, source)
end)

lib.callback.register('highcrest_phone:server:taxiRequest', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end
    if requestFor(source) then return { error = 'You already have a taxi on the way.' } end

    local note = TrimText(data.note)
    if #note > MAX_NOTE_LENGTH then return { error = 'Notes can be up to 200 characters.' } end

    local drivers = onDutyPlayers(function(job) return job.name == TAXI_JOB end)
    if #drivers == 0 then return { error = 'No taxi drivers are on duty right now.' } end

    if IsRateLimited(source, 'taxiRequest', REQUEST_COOLDOWN_MS) then return { error = 'Wait a moment before calling again.' } end

    local coords = GetPlayerCoords(source)
    if not coords then return { error = 'Your location could not be found.' } end

    nextTaxiId += 1
    taxiRequests[nextTaxiId] = {
        id = nextTaxiId,
        passenger = source,
        name = charName(player),
        number = player.PlayerData.charinfo.phone,
        note = note,
        x = coords.x,
        y = coords.y,
        state = 'waiting',
    }

    notifyDrivers('highcrest_phone:client:taxiAlert', { name = charName(player), note = note })
    return loadTaxi(player, source)
end)

lib.callback.register('highcrest_phone:server:taxiAccept', function(source, value)
    local player = GetPhoneOwner(source)
    local request = taxiRequests[tonumber(value)]
    if not player then return end
    if not isTaxiDriver(player) then return { error = 'You need to be an on-duty taxi driver.' } end
    if jobFor(source) then return { error = 'Finish your current fare first.' } end
    if not request or request.state ~= 'waiting' then return { error = 'Another driver took that fare.' } end

    request.state = 'accepted'
    request.driver = source
    request.driverName = charName(player)
    request.driverNumber = player.PlayerData.charinfo.phone

    TriggerClientEvent('highcrest_phone:client:taxiAccepted', request.passenger, {
        name = request.driverName,
        number = request.driverNumber,
    })
    local status = loadTaxi(player, source)
    status.waypoint = { x = request.x, y = request.y }
    return status
end)

-- Either side can end a request, and the other side is told.
lib.callback.register('highcrest_phone:server:taxiEnd', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end

    local request = requestFor(source) or jobFor(source)
    if request then
        local isPassenger = request.passenger == source
        local other = isPassenger and request.driver or request.passenger
        taxiRequests[request.id] = nil
        if other then
            TriggerClientEvent('highcrest_phone:client:taxiEnded', other, isPassenger and 'The passenger cancelled the fare.' or 'Your taxi fare has ended.')
        end
    end
    return loadTaxi(player, source)
end)

local function trimEmergencies()
    local cutoff = os.time() - EMERGENCY_KEEP_SECONDS
    for id, call in pairs(emergencies) do
        if call.time < cutoff then emergencies[id] = nil end
    end
end

lib.callback.register('highcrest_phone:server:emergencyCall', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end

    local service = data.service
    local jobType = EMERGENCY_TYPES[service]
    if not jobType then return { error = 'Choose police or EMS.' } end

    local message = TrimText(data.message)
    if #message < 1 or #message > MAX_NOTE_LENGTH then return { error = 'Describe your emergency in up to 200 characters.' } end
    if IsRateLimited(source, 'emergencyCall', REQUEST_COOLDOWN_MS) then return { error = 'Wait a moment before calling again.' } end

    local coords = GetPlayerCoords(source)
    if not coords then return { error = 'Your location could not be found.' } end

    trimEmergencies()
    nextEmergencyId += 1
    local call = {
        id = nextEmergencyId,
        service = service,
        label = EMERGENCY_LABELS[service],
        message = message,
        name = charName(player),
        number = player.PlayerData.charinfo.phone,
        x = coords.x,
        y = coords.y,
        time = os.time(),
    }
    emergencies[call.id] = call

    local units = onDutyPlayers(function(job) return job.type == jobType end)
    for _, unit in ipairs(units) do
        TriggerClientEvent('highcrest_phone:client:emergency', unit.PlayerData.source, call)
    end
    return { units = #units }
end)

-- Responders see recent calls for their own service only.
lib.callback.register('highcrest_phone:server:emergencyGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end
    trimEmergencies()

    local job = player.PlayerData.job
    local service
    if job and job.onduty then
        for name, jobType in pairs(EMERGENCY_TYPES) do
            if job.type == jobType then service = name end
        end
    end

    local calls = {}
    if service then
        for _, call in pairs(emergencies) do
            if call.service == service then calls[#calls + 1] = call end
        end
        table.sort(calls, function(a, b) return a.id > b.id end)
    end
    return { isResponder = service ~= nil, calls = calls }
end)

AddEventHandler('playerDropped', function()
    local src = source
    local request = requestFor(src) or jobFor(src)
    if not request then return end

    local isPassenger = request.passenger == src
    if isPassenger or request.state == 'waiting' then
        if request.driver then
            TriggerClientEvent('highcrest_phone:client:taxiEnded', request.driver, 'The passenger left the city.')
        end
        taxiRequests[request.id] = nil
    else
        -- The driver left, so the fare goes back to other drivers.
        request.state = 'waiting'
        request.driver = nil
        request.driverName = nil
        request.driverNumber = nil
        TriggerClientEvent('highcrest_phone:client:taxiEnded', request.passenger, 'Your driver left. Looking for another.')
    end
end)
