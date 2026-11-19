-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Fixed apartment furniture: admins build sets and place them in rooms.
-- Every client spawns the props locally, only near the player.
Furniture = { sets = {}, placements = {} }

local resource = GetCurrentResourceName()
local function readJson(path)
    local contents = LoadResourceFile(resource, path)
    if not contents then return nil end
    local ok, value = pcall(json.decode, contents)
    return ok and type(value) == 'table' and value or nil
end

local catalog = readJson('data/catalog.json') or {}
local allowed = {}
for _, group in ipairs(catalog) do
    for _, item in ipairs(group.items or {}) do allowed[item.model] = true end
end
Furniture.catalog = catalog

local function finite(v, limit) return type(v) == 'number' and v == v and math.abs(v) <= limit end
local function vector(v, limit) return type(v) == 'table' and finite(v.x, limit) and finite(v.y, limit) and finite(v.z, limit) end

function Furniture.validName(name)
    return type(name) == 'string' and #name > 0 and #name <= 64 and name:match('^[%w_ %-]+$') ~= nil
end

function Furniture.validProps(props)
    if type(props) ~= 'table' or #props == 0 or #props > Config.Furniture.MaxProps then return false end
    for _, prop in ipairs(props) do
        if type(prop) ~= 'table' or not allowed[prop.model] or not vector(prop.offset, Config.Furniture.MaxLocalOffset)
            or not vector(prop.rotation, 3600) then return false end
        if prop.label ~= nil and (type(prop.label) ~= 'string' or #prop.label > 96) then return false end
    end
    return true
end

local function cleanProps(props)
    local result = {}
    for i, p in ipairs(props) do
        result[i] = {
            model = p.model, label = p.label,
            offset = { x = p.offset.x, y = p.offset.y, z = p.offset.z },
            rotation = { x = p.rotation.x, y = p.rotation.y, z = p.rotation.z },
        }
    end
    return result
end

local function validAnchor(a)
    return vector(a, 20000) and finite(a.heading, 3600)
end

local function placementKey(hotel, room) return hotel .. ':' .. room end

function Furniture.publish(target)
    TriggerClientEvent('zloma_apartments:client:furniture', target or -1, Furniture.sets, Furniture.placements)
end

function Furniture.load()
    local sets, placements = {}, {}
    local setRows, placementRows = DB.loadFurniture()
    for _, row in ipairs(setRows) do
        local ok, props = pcall(json.decode, row.props)
        if ok and type(props) == 'table' then sets[row.name] = { props = props } end
    end
    for _, row in ipairs(placementRows) do
        local ok, anchor = pcall(json.decode, row.anchor)
        if ok and type(anchor) == 'table' then
            placements[placementKey(row.hotel_id, row.room_number)] = { hotel = row.hotel_id, room = tonumber(row.room_number), set = row.set_name, anchor = anchor }
        end
    end
    Furniture.sets, Furniture.placements = sets, placements
end

-- Installs the shipped WiWang furniture once. Deleting it later is respected.
function Furniture.seed()
    if Config.WiWang == false or DB.meta('furniture_seed_wiwang') then return 0 end
    local sets = readJson('data/wiwang_sets.json') or {}
    local placements = readJson('data/wiwang_placements.json') or {}
    local count = 0
    for name, set in pairs(sets) do
        if not Furniture.sets[name] and Furniture.validName(name) and Furniture.validProps(set.props) then
            DB.saveSet(name, json.encode(cleanProps(set.props)))
        end
    end
    local rows = {}
    for _, p in pairs(placements) do
        if not Furniture.placements[placementKey(p.hotel, p.room)] and validAnchor(p.anchor) then
            rows[#rows + 1] = { hotel = p.hotel, room = p.room, set = p.set, anchor = json.encode(p.anchor) }
        end
    end
    DB.savePlacements(rows)
    count = #rows
    DB.setMeta('furniture_seed_wiwang', tostring(os.time()))
    Furniture.load()
    return count
end

AdminMutation('saveSet', function(_, data)
    if not Furniture.validName(data.name) or not Furniture.validProps(data.props) then return Fail('error_furniture_invalid') end
    local props = cleanProps(data.props)
    DB.saveSet(data.name, json.encode(props))
    Furniture.sets[data.name] = { props = props }
    Furniture.publish()
    return { success = true, sets = Furniture.sets }
end)

AdminMutation('deleteSet', function(_, data)
    if not Furniture.sets[data.name] then return Fail('error_invalid') end
    for _, p in pairs(Furniture.placements) do
        if p.set == data.name then return Fail('error_set_in_use') end
    end
    DB.deleteSet(data.name)
    Furniture.sets[data.name] = nil
    Furniture.publish()
    return { success = true, sets = Furniture.sets }
end)

AdminMutation('savePlacement', function(_, data)
    local number = tonumber(data.room)
    if not State.room(data.hotel, number) or not Furniture.sets[data.set] or not validAnchor(data.anchor) then
        return Fail('error_furniture_invalid')
    end
    local anchor = { x = data.anchor.x, y = data.anchor.y, z = data.anchor.z, heading = data.anchor.heading % 360 }
    DB.savePlacements({ { hotel = data.hotel, room = number, set = data.set, anchor = json.encode(anchor) } })
    Furniture.placements[placementKey(data.hotel, number)] = { hotel = data.hotel, room = number, set = data.set, anchor = anchor }
    Furniture.publish()
    return { success = true }
end)

AdminMutation('removePlacement', function(_, data)
    local number = tonumber(data.room)
    local k = number and placementKey(data.hotel, number)
    if not k or not Furniture.placements[k] then return Fail('error_no_placement') end
    DB.deletePlacement(data.hotel, number)
    Furniture.placements[k] = nil
    Furniture.publish()
    return { success = true }
end)

-- Copies every placed room of one floor to a range of floors using the
-- building's floor height. Existing placements on target floors are replaced.
function Furniture.copyFloors(hotelId, from, to, last)
    local hotel = State.hotel(hotelId)
    from, to, last = tonumber(from), tonumber(to), tonumber(last)
    if not hotel or not from or not to or not last or from % 1 ~= 0 or to % 1 ~= 0 or last % 1 ~= 0
        or from < 1 or from > hotel.floors.count or to < 1 or last < to or last > hotel.floors.count then
        return nil, 'error_floor_range'
    end
    local rows, updates = {}, {}
    for _, base in ipairs(hotel.rooms) do
        local source = Furniture.placements[placementKey(hotelId, Hotels.roomNumber(from, base.index))]
        if source then
            for floor = to, last do
                if floor ~= from then
                    local number = Hotels.roomNumber(floor, base.index)
                    local anchor = { x = source.anchor.x, y = source.anchor.y, z = source.anchor.z + (floor - from) * hotel.floors.step, heading = source.anchor.heading }
                    rows[#rows + 1] = { hotel = hotelId, room = number, set = source.set, anchor = json.encode(anchor) }
                    updates[placementKey(hotelId, number)] = { hotel = hotelId, room = number, set = source.set, anchor = anchor }
                end
            end
        end
    end
    if #rows == 0 then return nil, 'error_no_placement' end
    DB.savePlacements(rows)
    for k, v in pairs(updates) do Furniture.placements[k] = v end
    Furniture.publish()
    return #rows
end

AdminMutation('copyFloors', function(_, data)
    local count, err = Furniture.copyFloors(data.hotel, data.from, data.to, data.last)
    if not count then return Fail(err) end
    return { success = true, count = count }
end)

lib.callback.register('zloma_apartments:getFurniture', function()
    return { sets = Furniture.sets, placements = Furniture.placements }
end)
