-- Highcrest emote menu (F4). Reads the emote lists from scully_emotemenu. While browsing, a copy of
-- the player's character stands next to the menu and acts out the highlighted emote, walk style or
-- expression; the real character only does it when the player presses Play (through scully's
-- exports, so props, scenarios and walk styles behave exactly like /e).

local SCULLY = 'scully_emotemenu'
local isOpen = false
local previewSpin = 0.0

-- Read one of scully's data files (they are plain `return { ... }` Lua tables).
local function loadData(path)
    local code = LoadResourceFile(SCULLY, path)
    if not code then return nil end
    local env = setmetatable({ locale = function(key) return key end }, { __index = _G })
    local chunk = load(code, ('@%s/%s'):format(SCULLY, path), 't', env)
    if not chunk then return nil end
    local ok, data = pcall(chunk)
    return ok and data or nil
end

local CATEGORIES = {
    { id = 'dance', label = 'Dances', file = 'shared/data/emotes/dance_emotes.lua', kind = 'emote' },
    { id = 'general', label = 'General', file = 'shared/data/emotes/general_emotes.lua', kind = 'emote' },
    { id = 'props', label = 'Props', file = 'shared/data/emotes/prop_emotes.lua', kind = 'emote' },
    { id = 'food', label = 'Food & drink', file = 'shared/data/emotes/consumable_emotes.lua', kind = 'emote' },
    { id = 'animals', label = 'Animals', file = 'shared/data/emotes/animal_emotes.lua', kind = 'emote' },
    { id = 'scenarios', label = 'Scenarios', file = 'shared/data/scenarios.lua', kind = 'emote' },
    -- Two-person emotes: playing one asks the nearest player to join (scully sends the request).
    { id = 'couples', label = 'Couples', file = 'shared/data/emotes/synchronized_emotes.lua', kind = 'emote', shared = true },
    -- scully builds its partner dances from the dance list ('s' + dance command); same here.
    { id = 'partnerdance', label = 'Partner dances', file = 'shared/data/emotes/dance_emotes.lua', kind = 'emote', shared = true, prefix = 's' },
    { id = 'walks', label = 'Walks', file = 'shared/data/walks.lua', kind = 'walk' },
    { id = 'expressions', label = 'Expressions', file = 'shared/data/expressions.lua', kind = 'expression' },
}

local catalogue      -- sent to the menu: { categories, emotes = { { i, c, l, k, x } } }
local fullData = {}  -- i -> scully's entry, used for the preview
local catLists = {}  -- category id -> scully's raw list (to find a shared emote's partner)

-- Only list emotes this game can actually play: every animation dictionary must exist
-- (some use animations from newer GTA updates or files that aren't loaded on this build).
local function animsExist(e)
    local dicts = type(e.Dictionary) == 'table' and e.Dictionary or { e.Dictionary }
    for _, dict in ipairs(dicts) do
        if type(dict) ~= 'string' or not DoesAnimDictExist(dict) then return false end
    end
    local secondary = e.Options and e.Options.SecondaryEmote
    if secondary and not DoesAnimDictExist(secondary.Dictionary or '') then return false end
    return true
end

-- Explicit two-person emotes stay out of this menu (still in /e; meant for a separate F5 menu).
local function explicit(e)
    local label = e.Label:lower()
    return label:find('blowjob', 1, true) or label:find('sex', 1, true)
end

local function playable(e, cat)
    if cat.shared then
        if explicit(e) then return false end
    elseif e.Options and e.Options.Shared then
        return false
    end
    if e.PedTypes then return not IsPedHuman(cache.ped) end  -- animal emotes need an animal ped
    if e.Dictionary then return animsExist(e) end
    return true
end

local builtForHuman
local function buildCatalogue()
    -- Rebuilt if the player switches between a human and an animal ped.
    if catalogue and builtForHuman == IsPedHuman(cache.ped) then return catalogue end
    builtForHuman = IsPedHuman(cache.ped)
    fullData = {}
    local emotes, cats = {}, {}
    for _, cat in ipairs(CATEGORIES) do
        local data = loadData(cat.file)
        local list = data and (data.options or data) or {}
        catLists[cat.id] = list
        local count = 0
        for _, e in ipairs(list) do
            if type(e) == 'table' and e.Command and e.Label and playable(e, cat) then
                local index = #emotes + 1
                emotes[index] = { i = index, c = (cat.prefix or '') .. e.Command, l = e.Label, k = cat.kind, x = cat.id }
                fullData[index] = e
                count = count + 1
            end
        end
        if count > 0 then cats[#cats + 1] = { id = cat.id, label = cat.label, count = count } end
    end
    catalogue = { categories = cats, emotes = emotes }
    return catalogue
end

---------------------------------------------------------------------------
-- The preview character: a copy of the player, standing to the right of the menu
---------------------------------------------------------------------------

local preview = { ped = nil, props = {}, id = 0, walking = false }

local function clearPreview()
    for _, prop in ipairs(preview.props) do
        if DoesEntityExist(prop) then DeleteEntity(prop) end
    end
    preview.props = {}
    if preview.ped and DoesEntityExist(preview.ped) then DeleteEntity(preview.ped) end
    preview.ped = nil
    preview.walking = false
end

local function makePreviewPed()
    clearPreview()
    local ped = ClonePed(cache.ped, false, false, true)
    SetEntityCollision(ped, false, false)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, false)
    SetEntityAlpha(ped, 254, false)
    preview.ped = ped
    return ped
end

-- Keep the copy standing on screen (right of the menu), facing the camera, every frame.
CreateThread(function()
    while true do
        if isOpen and preview.ped and DoesEntityExist(preview.ped) then
            local world, normal = GetWorldCoordFromScreenCoord(0.6, 0.62)
            local pos = world + normal * 3.4
            local camRot = GetGameplayCamRot(2)
            SetEntityCoordsNoOffset(preview.ped, pos.x, pos.y, pos.z, false, false, false)
            SetEntityRotation(preview.ped, 0.0, 0.0, camRot.z + 180.0 + previewSpin, 2, false)
            Wait(0)
        else
            Wait(150)
        end
    end
end)

local function attachProps(ped, options)
    for _, prop in ipairs(options and options.Props or {}) do
        local hash = joaat(prop.Name)
        if IsModelValid(hash) and lib.requestModel(hash, 2000) then
            local pos = GetEntityCoords(ped)
            local object = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false)
            local place = prop.Placement or {}
            local offset, rot = place[1] or vec3(0, 0, 0), place[2] or vec3(0, 0, 0)
            SetEntityCollision(object, false, false)
            AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, prop.Bone or 0), offset.x, offset.y, offset.z,
                rot.x, rot.y, rot.z, true, true, false, true, 1, true)
            SetModelAsNoLongerNeeded(hash)
            preview.props[#preview.props + 1] = object
        end
    end
end

local function showPreview(index)
    local data = fullData[index]
    if not data then return end
    preview.id = preview.id + 1
    local id = preview.id
    local ped = makePreviewPed()

    if data.Walk then
        if lib.requestAnimSet(data.Walk, 2000) then
            SetPedMovementClipset(ped, data.Walk, 0.2)
            -- Walk "towards" a far point; the copy is put back in place every frame, so it walks on the spot.
            local fwd = GetEntityCoords(ped) + GetEntityForwardVector(ped) * 50.0
            TaskGoStraightToCoord(ped, fwd.x, fwd.y, fwd.z, 1.0, -1, 0.0, 0.0)
            preview.walking = true
        end
    elseif data.Expression then
        SetFacialIdleAnimOverride(ped, data.Expression, 0)
    elseif data.Scenario then
        TaskStartScenarioInPlace(ped, data.Scenario, 0, true)
    elseif data.Dictionary and data.Animation then
        local dict, anim = data.Dictionary, data.Animation
        if type(dict) == 'table' and type(anim) == 'table' then
            local pick = math.random(1, #anim)
            dict, anim = dict[pick], anim[pick]
        end
        if not lib.requestAnimDict(dict, 2000) or id ~= preview.id then return end
        attachProps(ped, data.Options)
        -- Always loop in the preview so the player can see it properly.
        TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(dict)
        local secondary = data.Options and data.Options.SecondaryEmote
        if secondary and lib.requestAnimDict(secondary.Dictionary, 1000) then
            TaskPlayAnim(ped, secondary.Dictionary, secondary.Animation, 2.0, 2.0, -1, 51, 0, false, false, false)
        end
    end
end

---------------------------------------------------------------------------
-- Menu
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Two-person emotes: we ask the other player ourselves (clear prompt, 15 s, feedback for the
-- sender), then the server starts scully's synchronized emote for both.
---------------------------------------------------------------------------

local SHARED = { couples = true, partnerdance = true }
local ASK_SECONDS = 15

local function copy(t) return lib.table.deepclone(t) end

-- scully's data for both sides: mine and the partner's.
local function sharedPair(entry)
    local e = fullData[entry.i]
    if not e then return nil end
    if entry.x == 'partnerdance' then
        -- Same as scully's partner dances: 's' + dance command, both people do the same dance.
        local d = copy(e)
        d.Command = 's' .. e.Command
        d.Options = d.Options or {}
        d.Options.Shared = { OtherEmote = d.Command }
        d.Synchronized = true
        return d, copy(d)
    end
    local otherCommand = e.Options and e.Options.Shared and e.Options.Shared.OtherEmote
    for _, o in ipairs(catLists.couples or {}) do
        if o.Command == otherCommand then
            local mine, theirs = copy(e), copy(o)
            mine.Synchronized, theirs.Synchronized = true, true
            return mine, theirs
        end
    end
end

local function askShared(entry)
    local mine, theirs = sharedPair(entry)
    if not mine then
        return lib.notify({ description = 'That emote is missing its partner animation.', type = 'error' })
    end
    local playerId = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
    if not playerId then
        return lib.notify({ description = 'Stand next to someone first (within 3 m).', type = 'error' })
    end
    TriggerServerEvent('highcrest_emotes:server:ask', GetPlayerServerId(playerId), mine, theirs)
end

-- Someone asked us.
local asking = false
RegisterNetEvent('highcrest_emotes:client:asked', function(name, label)
    if asking then return end
    asking = true
    PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
    local deadline = GetGameTimer() + ASK_SECONDS * 1000
    local answer, shown
    while GetGameTimer() < deadline and answer == nil do
        local left = math.ceil((deadline - GetGameTimer()) / 1000)
        if left ~= shown then
            shown = left
            lib.showTextUI(('%s wants to do **%s** with you  \n[Y] Accept · [N] Decline (%d)'):format(name, label, left), { icon = 'people-arrows' })
        end
        if IsControlJustPressed(0, 246) then answer = true end      -- Y
        if IsControlJustPressed(0, 306) then answer = false end     -- N
        Wait(0)
    end
    lib.hideTextUI()
    asking = false
    TriggerServerEvent('highcrest_emotes:server:answer', answer == true)
end)

local function play(entry)
    if type(entry) ~= 'table' or type(entry.c) ~= 'string' then return end
    if entry.k == 'emote' and SHARED[entry.x] then return askShared(entry) end
    if entry.k == 'walk' then
        exports[SCULLY]:setWalkByCommand(entry.c)
    elseif entry.k == 'expression' then
        exports[SCULLY]:setExpressionByCommand(entry.c)
    else
        exports[SCULLY]:playEmoteByCommand(entry.c)
    end
end

local function close()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    clearPreview()
end

local function favourites()
    local raw = GetResourceKvpString('favourites')
    return raw and json.decode(raw) or {}
end

local function open()
    if isOpen then return close() end
    if IsPauseMenuActive() or IsNuiFocused() then return end
    if GetResourceState(SCULLY) ~= 'started' then return end
    isOpen, previewSpin = true, 0.0
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = buildCatalogue(), favourites = favourites() })
end

RegisterCommand('emotes', open, false)
RegisterKeyMapping('emotes', 'Emote menu', 'keyboard', 'F4')

RegisterNUICallback('preview', function(entry, cb)
    cb(1)
    if isOpen and type(entry) == 'table' then showPreview(tonumber(entry.i)) end
end)

RegisterNUICallback('choose', function(entry, cb)
    cb(1)
    if not isOpen then return end
    if cache.vehicle and entry.k == 'emote' then
        lib.notify({ description = 'Get out of the vehicle for that.', type = 'error' })
        return
    end
    close()
    play(entry)
end)

RegisterNUICallback('stop', function(_, cb)
    cb(1)
    exports[SCULLY]:cancelEmote()
end)

RegisterNUICallback('close', function(_, cb)
    cb(1)
    close()
end)

RegisterNUICallback('favourites', function(list, cb)
    cb(1)
    if type(list) == 'table' then SetResourceKvp('favourites', json.encode(list)) end
end)

RegisterNUICallback('rotate', function(data, cb)
    cb(1)
    previewSpin = previewSpin + (tonumber(data and data.dx) or 0) * 0.6
end)

CreateThread(function()
    while true do
        if isOpen and IsPedDeadOrDying(cache.ped, true) then close() end
        Wait(500)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if isOpen then SetNuiFocus(false, false) end
    clearPreview()
end)
