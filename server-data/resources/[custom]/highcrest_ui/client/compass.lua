-- Highcrest compass bar: heading, the street and area you're on, and markers for the waypoint
-- and important blips. Players change it, and the minimap, in the /hud menu.
local UPDATE_MS = 50
local STREET_UPDATE_MS = 500
local FIELD_OF_VIEW = 180        -- Degrees of the compass shown across the bar.
local MARKER_RANGE = 3000.0      -- Blips further than this (metres) are left off the bar.
local KVP_KEY = 'highcrest_hud_settings'

-- Blips shown on the bar, by sprite. The waypoint is always included.
local MARKER_BLIPS = {
    { sprite = 280, colour = '#4aa3ff', label = 'Friend' },      -- Phone: shared live location
    { sprite = 161, colour = '#ff3b4e', label = '911 call' },    -- Phone: emergency calls
    { sprite = 225, colour = '#3fd17a', label = 'Vehicle' },     -- Phone: valet
    { sprite = 198, colour = '#f5c542', label = 'Taxi' },        -- Taxi pickups
}

local settings = { compass = true, street = true, markers = true }
do
    local saved = GetResourceKvpString(KVP_KEY)
    local ok, decoded = pcall(json.decode, saved or '')
    if ok and type(decoded) == 'table' then
        for key in pairs(settings) do
            if type(decoded[key]) == 'boolean' then settings[key] = decoded[key] end
        end
    end
end

local function saveSettings()
    SetResourceKvp(KVP_KEY, json.encode(settings))
end

local function bearingTo(from, to)
    local degrees = math.deg(math.atan(to.x - from.x, to.y - from.y))
    return (degrees + 360.0) % 360.0
end

local function collectMarkers(origin, heading)
    local markers = {}
    local function add(coords, colour, label)
        local distance = #(vec2(coords.x, coords.y) - vec2(origin.x, origin.y))
        if distance > MARKER_RANGE or distance < 5.0 then return end
        local relative = ((bearingTo(origin, coords) - heading + 540.0) % 360.0) - 180.0
        if math.abs(relative) > FIELD_OF_VIEW / 2 then return end
        markers[#markers + 1] = {
            offset = relative / FIELD_OF_VIEW,  -- -0.5 (left edge) to 0.5 (right edge)
            colour = colour,
            label = label,
            distance = math.floor(distance + 0.5),
        }
    end

    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then add(GetBlipInfoIdCoord(waypoint), '#d4af37', 'Waypoint') end

    for _, kind in ipairs(MARKER_BLIPS) do
        local blip = GetFirstBlipInfoId(kind.sprite)
        local guard = 0
        while DoesBlipExist(blip) and guard < 20 do
            add(GetBlipInfoIdCoord(blip), kind.colour, kind.label)
            blip = GetNextBlipInfoId(kind.sprite)
            guard += 1
        end
    end
    return markers
end

local hiddenByApp = false
AddEventHandler('highcrest_ui:setHidden', function(hidden) hiddenByApp = hidden == true end)

CreateThread(function()
    local lastStreetAt = 0
    local street = {}
    local wasVisible = false

    while true do
        Wait(UPDATE_MS)
        local visible = LocalPlayer.state.isLoggedIn == true and not IsPauseMenuActive() and not hiddenByApp
            and (settings.compass or settings.street)

        if not visible then
            if wasVisible then SendNUIMessage({ compass = { visible = false } }) end
            wasVisible = false
        else
            wasVisible = true
            local coords = GetEntityCoords(cache.ped)
            local heading = (360.0 - ((GetGameplayCamRot(2).z + 360.0) % 360.0)) % 360.0

            local now = GetGameTimer()
            if settings.street and now - lastStreetAt > STREET_UPDATE_MS then
                lastStreetAt = now
                local mainHash, crossHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                local zoneLabel = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
                street = {
                    main = GetStreetNameFromHashKey(mainHash),
                    cross = crossHash ~= 0 and GetStreetNameFromHashKey(crossHash) or nil,
                    area = zoneLabel ~= 'NULL' and zoneLabel or nil,
                }
            end

            SendNUIMessage({
                compass = {
                    visible = true,
                    showBar = settings.compass,
                    showStreet = settings.street,
                    heading = heading,
                    fieldOfView = FIELD_OF_VIEW,
                    markers = (settings.compass and settings.markers) and collectMarkers(coords, heading) or {},
                    street = settings.street and street or nil,
                },
            })
        end
    end
end)

-- /hud: one place for players to switch the minimap and compass on or off.
local function openHudMenu()
    local minimapOn = GetResourceState('qbx_hud') == 'started' and exports.qbx_hud:IsOutMapEnabled()
    local function toggle(key)
        settings[key] = not settings[key]
        saveSettings()
    end
    local function state(on) return on and 'On' or 'Off' end

    lib.registerContext({
        id = 'highcrest_hud_menu',
        title = 'HUD settings',
        options = {
            {
                title = ('Minimap on foot: %s'):format(state(minimapOn)),
                description = 'The minimap always shows in vehicles.',
                icon = 'map',
                onSelect = function()
                    TriggerEvent('qbx_hud:client:setOutMap', not minimapOn)
                    SetTimeout(100, openHudMenu)
                end,
            },
            { title = ('Compass bar: %s'):format(state(settings.compass)), icon = 'compass', onSelect = function() toggle('compass') openHudMenu() end },
            { title = ('Markers on compass: %s'):format(state(settings.markers)), description = 'Waypoint, friends, 911 calls and more.', icon = 'location-dot', disabled = not settings.compass, onSelect = function() toggle('markers') openHudMenu() end },
            { title = ('Street and area: %s'):format(state(settings.street)), icon = 'road', onSelect = function() toggle('street') openHudMenu() end },
            { title = 'Move HUD items', description = 'Drag food, water, armor and the rest anywhere.', icon = 'up-down-left-right', onSelect = function() exports[GetCurrentResourceName()]:EditHud() end },
            { title = 'Line up the map border', description = 'Arrow keys to move, Shift + arrows to resize.', icon = 'border-all', onSelect = function() CreateThread(function() exports[GetCurrentResourceName()]:AdjustMapBorder() end) end },
        },
    })
    lib.showContext('highcrest_hud_menu')
end

RegisterCommand('hud', openHudMenu, false)
TriggerEvent('chat:addSuggestion', '/hud', 'HUD settings: minimap, compass, street name, layout')
TriggerEvent('chat:addSuggestion', '/hudedit', 'Drag your HUD icons where you want them')
TriggerEvent('chat:addSuggestion', '/hudborder', 'Line the map border up with the minimap')
