-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Building definitions shared by server and client.
-- A building has floors and a list of rooms measured on the first floor.
-- Upper floors reuse the first-floor X/Y and add floors.step to Z.
-- Room numbers are floor * 100 + index (101, 102 ... 2019).
Hotels = { defs = {} }

local function finite(value, limit)
    return type(value) == 'number' and value == value and math.abs(value) <= (limit or 1e6)
end

local function point(value, withHeading)
    if type(value) ~= 'table' then return nil end
    local x, y, z = tonumber(value.x), tonumber(value.y), tonumber(value.z)
    if not (finite(x, 20000) and finite(y, 20000) and finite(z, 5000)) then return nil end
    local result = { x = x + 0.0, y = y + 0.0, z = z + 0.0 }
    if withHeading then
        local w = tonumber(value.w or value.heading or 0)
        if not finite(w, 3600) then return nil end
        result.w = (w % 360) + 0.0
    end
    return result
end

local function int(value, min, max, fallback)
    value = tonumber(value)
    if value == nil then return fallback end
    if value ~= value or value % 1 ~= 0 or value < min or value > max then return nil end
    return value
end

local function text(value, max, fallback)
    if value == nil then return fallback end
    if type(value) ~= 'string' then return nil end
    value = value:gsub('^%s+', ''):gsub('%s+$', '')
    if #value == 0 then return fallback end
    if #value > max or value:find('[%c<>]') then return nil end
    return value
end

-- Image links are displayed by the NUI, never fetched by the server.
local function imageUrl(value)
    if value == nil then return '' end
    if type(value) ~= 'string' then return false end
    value = value:match('^%s*(.-)%s*$')
    if value == '' then return '' end
    local host = value:match('^https://([^/%?#]+)')
    if #value > 2048 or value:find('[%s%c<>]') or not host or not host:match('^[%w%.:%-]+$') then return false end
    return value
end

local function model(value)
    if value == nil or value == '' then return nil end
    if type(value) == 'number' and value % 1 == 0 and math.abs(value) <= 0xffffffff then return value end
    if type(value) == 'string' and #value <= 64 and value:match('^[%w_]+$') then return value end
    return false
end

-- Only plain floor tokens are allowed so string.format never sees user input.
local function iplPattern(value)
    if value == nil or value == '' then return nil end
    if type(value) ~= 'string' or #value > 96 then return false end
    local prefix, token, suffix = value:match('^([%w_]*)(%%0?2?d)([%w_]*)$')
    if not prefix or (token ~= '%d' and token ~= '%02d') then return false end
    return value
end

local function copy(value)
    if type(value) ~= 'table' then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end
Hotels.copy = copy

function Hotels.validId(id)
    return type(id) == 'string' and #id >= 2 and #id <= 32 and id:match('^[a-z0-9_]+$') ~= nil
end

-- Returns a clean definition or nil plus an error key.
function Hotels.normalize(raw, defaults)
    defaults = defaults or Config.BuildingDefaults
    if type(raw) ~= 'table' then return nil, 'invalid' end
    if not Hotels.validId(raw.id) then return nil, 'invalid_id' end
    local def = { id = raw.id, preset = raw.preset == true }
    def.label = text(raw.label, 64, raw.id)
    if not def.label then return nil, 'invalid_label' end
    def.description = text(raw.description, 240, nil)
    if raw.description ~= nil and raw.description ~= '' and not def.description then return nil, 'invalid_label' end

    def.imageUrl = imageUrl(raw.imageUrl)
    if def.imageUrl == false then return nil, 'invalid_image' end

    def.reception = point(raw.reception, true)
    if not def.reception then return nil, 'missing_reception' end
    def.receptionModel = model(raw.receptionModel or defaults.receptionModel)
    if not def.receptionModel then return nil, 'invalid_model' end
    def.receptionScenario = text(raw.receptionScenario, 64, defaults.receptionScenario)

    local blip = type(raw.blip) == 'table' and raw.blip or {}
    def.blip = {
        sprite = int(blip.sprite, 0, 1000, defaults.blip.sprite),
        color = int(blip.color, 0, 100, defaults.blip.color),
        scale = tonumber(blip.scale) or defaults.blip.scale,
        hidden = blip.hidden == true,
    }
    if not def.blip.sprite or not def.blip.color or not finite(def.blip.scale, 5) then return nil, 'invalid_blip' end

    local floors = type(raw.floors) == 'table' and raw.floors or {}
    def.floors = { count = int(floors.count, 1, 99, 1), baseZ = tonumber(floors.baseZ), step = tonumber(floors.step) or 0.0 }
    if not def.floors.count then return nil, 'invalid_floors' end
    if not finite(def.floors.baseZ, 5000) then return nil, 'invalid_floors' end
    if not finite(def.floors.step, 50) or def.floors.step < 0 or (def.floors.count > 1 and def.floors.step < 1.0) then
        return nil, 'invalid_floor_step'
    end

    def.ipl = iplPattern(raw.ipl)
    if def.ipl == false then return nil, 'invalid_ipl' end
    def.doorModel = model(raw.doorModel)
    if def.doorModel == false then return nil, 'invalid_model' end

    if type(raw.rooms) ~= 'table' then return nil, 'no_rooms' end
    def.rooms = {}
    local seen = {}
    for _, room in pairs(raw.rooms) do
        if type(room) ~= 'table' then return nil, 'invalid_room' end
        local index = int(room.index, 1, 99)
        if not index or seen[index] then return nil, 'invalid_room' end
        local door = point(room.door, false)
        if not door then return nil, 'invalid_room' end
        local roomModel = model(room.model)
        if roomModel == false then return nil, 'invalid_model' end
        local safe = room.safe and point(room.safe, true)
        if room.safe and not safe then return nil, 'invalid_room' end
        local groundZ = room.groundZ and tonumber(room.groundZ) or nil
        if room.groundZ and not finite(groundZ, 5000) then return nil, 'invalid_room' end
        seen[index] = true
        local panel = room.alarmPanel and AlarmPanel.normalize(room.alarmPanel)
        if room.alarmPanel and not panel then return nil, 'invalid_room' end
        if panel and panel.position then
            local p = panel.position
            if (p.x-door.x)^2 + (p.y-door.y)^2 + (p.z-door.z)^2 > 16 then return nil, 'invalid_room' end
        end
        def.rooms[#def.rooms + 1] = { index = index, door = door, model = roomModel, safe = safe, groundZ = groundZ, alarmPanel = panel }
    end
    if #def.rooms == 0 then return nil, 'no_rooms' end
    table.sort(def.rooms, function(a, b) return a.index < b.index end)

    if raw.alarmPanels ~= nil and type(raw.alarmPanels) ~= 'table' then return nil, 'invalid_room' end
    def.alarmPanels = {}
    for key, rawPanel in pairs(raw.alarmPanels or {}) do
        local number = tonumber(key)
        local floor, index = Hotels.split(number)
        local panel = AlarmPanel.normalize(rawPanel)
        if not floor or floor < 1 or floor > def.floors.count or not seen[index] or not panel then return nil, 'invalid_room' end
        local base
        for _, b in ipairs(def.rooms) do if b.index == index then base = b end end
        if panel.position then
            local p, d = panel.position, base.door
            if (p.x-d.x)^2 + (p.y-d.y)^2 + (p.z-d.z-(floor-1)*def.floors.step)^2 > 16 then return nil, 'invalid_room' end
        end
        def.alarmPanels[tostring(number)] = panel
    end

    if raw.roomImages ~= nil and type(raw.roomImages) ~= 'table' then return nil, 'invalid_image' end
    def.roomImages = {}
    for key, value in pairs(raw.roomImages or {}) do
        local number = tonumber(key)
        local floor = number and math.floor(number / 100)
        if not number or number % 1 ~= 0 or floor < 1 or floor > def.floors.count
            or not seen[number % 100] then return nil, 'invalid_image' end
        local url = imageUrl(value)
        if url == false then return nil, 'invalid_image' end
        if url ~= '' then def.roomImages[tostring(number)] = url end
    end

    local pricing = type(raw.pricing) == 'table' and raw.pricing or {}
    local d = defaults.pricing
    def.pricing = {
        daily = int(pricing.daily, 0, 1e9, d.daily),
        contractDaily = int(pricing.contractDaily, 0, 1e9, d.contractDaily),
        contractMinDays = int(pricing.contractMinDays, 1, 365, d.contractMinDays),
        contractMaxDays = int(pricing.contractMaxDays, 1, 365, d.contractMaxDays),
        buy = int(pricing.buy, 0, 2e9, d.buy),
    }
    for _, v in pairs(def.pricing) do if not v then return nil, 'invalid_pricing' end end
    if def.pricing.contractMaxDays < def.pricing.contractMinDays then return nil, 'invalid_pricing' end
    local function flag(key) if raw[key] == nil then return defaults[key] ~= false end return raw[key] == true end
    def.enablePrepaid, def.enableContract, def.enableBuy = flag('enablePrepaid'), flag('enableContract'), flag('enableBuy')
    if not (def.enablePrepaid or def.enableContract or def.enableBuy) then return nil, 'invalid_pricing' end
    def.security = Security.normalizePrices(raw.security)
    if not def.security then return nil, 'invalid_pricing' end
    return def
end

function Hotels.roomNumber(floor, index) return floor * 100 + index end

function Hotels.split(number)
    number = tonumber(number)
    if not number or number % 1 ~= 0 then return nil end
    return math.floor(number / 100), number % 100
end

local function baseRoom(def, index)
    for _, room in ipairs(def.rooms) do if room.index == index then return room end end
end

-- Resolves one room on any floor. Returns nil for numbers the building lacks.
function Hotels.room(def, number)
    if not def then return nil end
    local floor, index = Hotels.split(number)
    if not floor or floor < 1 or floor > def.floors.count then return nil end
    local base = baseRoom(def, index)
    if not base then return nil end
    local offset = (floor - 1) * def.floors.step
    local floorZ = (base.groundZ or def.floors.baseZ) + offset
    local safe = base.safe and {
        x = base.safe.x, y = base.safe.y,
        z = base.safe.z + offset + (Config.Safe.HeightOffset or 0.0),
        w = (base.safe.w + (Config.Safe.HeadingOffset or 0.0)) % 360,
    }
    return {
        hotel = def.id, number = number, floor = floor, index = index,
        door = { x = base.door.x, y = base.door.y, z = base.door.z + offset },
        floorZ = floorZ,
        model = base.model or def.doorModel,
        safe = safe,
        ipl = Hotels.ipl(def, floor),
    }
end

function Hotels.image(def, number)
    if not Hotels.room(def, number) then return nil end
    local url = def.roomImages and def.roomImages[tostring(number)] or nil
    url = url or def.imageUrl
    return url ~= '' and url or nil
end

function Hotels.ipl(def, floor)
    return def.ipl and def.ipl:format(floor) or nil
end

function Hotels.each(def, callback)
    for floor = 1, def.floors.count do
        for _, base in ipairs(def.rooms) do
            local number = Hotels.roomNumber(floor, base.index)
            callback(number, floor, base.index)
        end
    end
end

function Hotels.count(def) return def.floors.count * #def.rooms end

-- Detects which floor of a building the player stands on.
function Hotels.floorAt(def, z)
    if def.ipl and IsIplActive then
        for floor = 1, def.floors.count do
            if IsIplActive(Hotels.ipl(def, floor)) then return floor end
        end
        return nil
    end
    if def.floors.count == 1 then return 1 end
    local floor = math.floor((z - def.floors.baseZ) / def.floors.step + 0.5) + 1
    if floor >= 1 and floor <= def.floors.count then return floor end
end

-- Data the UI needs; no coordinates.
function Hotels.public(def)
    return {
        id = def.id, label = def.label, description = def.description,
        floors = def.floors.count, roomsPerFloor = #def.rooms, imageUrl = def.imageUrl,
        pricing = def.pricing, enablePrepaid = def.enablePrepaid,
        enableContract = def.enableContract, enableBuy = def.enableBuy,
    }
end
