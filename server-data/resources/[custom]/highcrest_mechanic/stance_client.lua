-- Stance, client side: applies wheel poke, camber and ride height to cars near you that have a
-- stance (state bag hcStance, set by stance_server.lua), plus the live preview in the design bay.
-- GTA resets these wheel values on its own, so they're re-applied every frame while close.

local preview = {}   -- vehicle -> stance shown in the design bay (overrides the saved one)
local base = {}      -- vehicle -> { [wheel] = stock x offset }, recorded before we change anything
local nearby = {}    -- vehicles in range that need applying

local function stanceFrom(t)
    if not t then return nil end
    local s, any = {}, false
    for key in pairs(Config.stance.keys) do
        s[key] = tonumber(t[key]) or 0
        if s[key] ~= 0 then any = true end
    end
    return any and s or nil
end

-- props = the design preview's properties (stance keys included), or nil to go back to the saved stance.
function StancePreview(vehicle, props)
    if props == nil then preview[vehicle] = nil return end
    preview[vehicle] = stanceFrom(props) or false -- false = "stock while previewing"
end

local function desired(vehicle)
    local p = preview[vehicle]
    if p ~= nil then return p or nil end
    local s = Entity(vehicle).state.hcStance
    return s and stanceFrom(s) or nil
end

local function apply(vehicle, s)
    local cfg = Config.stance
    local wheels = GetVehicleNumberOfWheels(vehicle)
    if not base[vehicle] then
        base[vehicle] = {}
        for i = 0, wheels - 1 do base[vehicle][i] = GetVehicleWheelXOffset(vehicle, i) end
    end
    local b = base[vehicle]
    for i = 0, wheels - 1 do
        local front = i < 2
        local left = (b[i] or 0) < 0
        local track = (front and s.stanceTrackF or s.stanceTrackR) * cfg.trackStep
        local camber = math.rad((front and s.stanceCamberF or s.stanceCamberR) * cfg.camberStep) * cfg.camberSign
        SetVehicleWheelXOffset(vehicle, i, (b[i] or 0) + (left and -track or track))
        SetVehicleWheelYRotation(vehicle, i, left and -camber or camber)
    end
    SetVehicleSuspensionHeight(vehicle, s.stanceHeight * cfg.heightStep * cfg.heightSign)
end

-- Put a car back to stock (stance removed, preview cancelled).
local function reset(vehicle)
    local b = base[vehicle]
    base[vehicle] = nil
    if not b or not DoesEntityExist(vehicle) then return end
    for i, x in pairs(b) do
        SetVehicleWheelXOffset(vehicle, i, x)
        SetVehicleWheelYRotation(vehicle, i, 0.0)
    end
    SetVehicleSuspensionHeight(vehicle, 0.0)
end

-- Find stanced cars near you once a second.
CreateThread(function()
    while true do
        local me = GetEntityCoords(cache.ped)
        local range = Config.stance.drawDistance
        local list = {}
        for _, vehicle in ipairs(GetGamePool('CVehicle')) do
            if (preview[vehicle] ~= nil or Entity(vehicle).state.hcStance) and #(GetEntityCoords(vehicle) - me) <= range then
                list[#list + 1] = vehicle
            end
        end
        -- Cars that lost their stance (or the preview ended) go back to stock.
        for vehicle in pairs(base) do
            if not DoesEntityExist(vehicle) then base[vehicle] = nil
            elseif not desired(vehicle) then reset(vehicle) end
        end
        for vehicle in pairs(preview) do
            if not DoesEntityExist(vehicle) then preview[vehicle] = nil end
        end
        nearby = list
        Wait(1000)
    end
end)

-- Apply every frame while any are close.
CreateThread(function()
    while true do
        if #nearby == 0 then
            Wait(500)
        else
            for _, vehicle in ipairs(nearby) do
                if DoesEntityExist(vehicle) then
                    local s = desired(vehicle)
                    if s then apply(vehicle, s) end
                end
            end
            Wait(0)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for vehicle in pairs(base) do reset(vehicle) end
end)
