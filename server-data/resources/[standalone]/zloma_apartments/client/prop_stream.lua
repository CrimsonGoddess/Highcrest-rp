-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Streams props (furniture, safes) for the floor the player is on.
-- ox_lib points exist only for the active floor of each building. Creators run
-- in their own thread and must check keep() after every wait.
PropStreamer = {}

function PropStreamer.new()
    local self = { entries = {}, byFloor = {}, points = {}, stopped = false }

    local function eligible(point)
        local entry = point.entry
        local p = GetEntityCoords(PlayerPedId())
        return not self.stopped and self.points[point.key] == point
            and #(p - entry.coords) <= entry.distance
            and math.abs(p.z - entry.coords.z) <= entry.vertical
            and (not entry.eligible or entry.eligible())
            and (not point.ipl or IsIplActive(point.ipl))
    end

    local function unload(point)
        local list = point.entities
        point.entities = nil -- also cancels a creator still waiting for a model
        if list then
            point.entry.destroy(list)
            for i in pairs(list) do list[i] = nil end
        end
    end

    local function reconcile(point)
        if not eligible(point) then unload(point); return end
        if point.entities then return end
        local list = {}
        point.entities = list
        CreateThread(function()
            local function keep() return point.entities == list and eligible(point) end
            if keep() then point.entry.create(list, keep) end
            if not keep() then point.entry.destroy(list) end
        end)
    end

    local function remove(key)
        local point = self.points[key]
        if not point then return end
        self.points[key] = nil
        unload(point)
        point:remove()
    end

    function self:clear() for key in pairs(self.points) do remove(key) end end

    function self:refresh()
        if self.stopped then return end
        local p = GetEntityCoords(PlayerPedId())
        local floors = {}
        for id, def in pairs(Hotels.defs) do
            local r = def.rooms[1]
            -- Skip buildings far away horizontally before any per-floor work.
            if r and #(vec2(p.x, p.y) - vec2(r.door.x, r.door.y)) < 150.0 then
                floors[id] = Hotels.floorAt(def, p.z)
            end
        end
        for key, point in pairs(self.points) do
            local entry = self.entries[key]
            if not entry or floors[entry.hotel] ~= entry.floor or entry.revision ~= point.entry.revision then remove(key) end
        end
        for hotelId, floor in pairs(floors) do
            local list = self.byFloor[hotelId] and self.byFloor[hotelId][floor] or {}
            for key, entry in pairs(list) do
                if not self.points[key] then
                    local def = Hotels.defs[hotelId]
                    self.points[key] = lib.points.new({
                        coords = entry.coords, distance = entry.distance, key = key, entry = entry,
                        ipl = def and Hotels.ipl(def, entry.floor), onEnter = reconcile, onExit = unload,
                    })
                end
            end
        end
        for _, point in pairs(self.points) do reconcile(point) end
    end

    function self:replace(entries)
        self.entries, self.byFloor = entries, {}
        for key, entry in pairs(entries) do
            local hotel = self.byFloor[entry.hotel] or {}
            self.byFloor[entry.hotel] = hotel
            hotel[entry.floor] = hotel[entry.floor] or {}
            hotel[entry.floor][key] = entry
        end
        self:refresh()
    end

    function self:stop() self.stopped = true; self:clear() end

    AddEventHandler('wiwang_hotel:floorUnloading', function() self:clear() end)
    AddEventHandler('wiwang_hotel:floorRequested', function() self:refresh() end)
    CreateThread(function()
        while not self.stopped do
            self:refresh()
            Wait(next(self.points) and 500 or 1500)
        end
    end)
    return self
end

-- Loads a model for a creator that may be cancelled.
local requests = {}
function StreamModel(hash, keep)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then return false end
    requests[hash] = (requests[hash] or 0) + 1
    RequestModel(hash)
    local deadline = GetGameTimer() + 3000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline and (not keep or keep()) do Wait(0) end
    local loaded = HasModelLoaded(hash) and (not keep or keep())
    if not loaded then ReleaseStreamModel(hash) end
    return loaded
end

function ReleaseStreamModel(hash)
    requests[hash] = (requests[hash] or 1) - 1
    if requests[hash] <= 0 then requests[hash] = nil; SetModelAsNoLongerNeeded(hash) end
end
