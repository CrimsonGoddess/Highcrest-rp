-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- The door lockpick's HUD and sounds, drawn and played on this resource's page
-- (ui/src/components/doorpick). Calls made every frame that change nothing
-- are not sent again.
local UI = {}
local sentHud, sentHudAt, loops = nil, 0, {}
local HUD_REFRESH = 1000

local function send(action, data) SendNUIMessage({ action = action, data = data }) end

function UI.hud(data)
    local encoded = json.encode(data)
    local now = GetGameTimer()
    if encoded == sentHud and now - sentHudAt < HUD_REFRESH then return end
    sentHud, sentHudAt = encoded, now
    send('doorpick:hud', data)
end

function UI.hide()
    if sentHud == nil then return end
    sentHud = nil
    send('doorpick:hud', false)
end

-- tone: 'default' | 'success' | 'error' | 'muted'
function UI.flash(text, tone, duration)
    send('doorpick:flash', { text = text, tone = tone or 'default', duration = duration or 1600 })
end

function UI.sound(name)
    send('doorpick:sound', { name = name, volume = Config.DoorPick.volume or 0.8 })
end

function UI.loop(id, name, params)
    local key = name .. json.encode(params or {})
    if loops[id] == key then return end
    loops[id] = key
    send('doorpick:loop', { id = id, name = name, params = params or {}, volume = Config.DoorPick.volume or 0.8 })
end

function UI.stopLoop(id)
    if not loops[id] then return end
    loops[id] = nil
    send('doorpick:loop', { id = id, stop = true })
end

DoorPickUI = UI
