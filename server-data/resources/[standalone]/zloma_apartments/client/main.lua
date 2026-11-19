-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Reception peds, blips and the player UI.
local peds, blips = {}, {}
local uiOpen = false

local function clearReception()
    for id, ped in pairs(peds) do
        if DoesEntityExist(ped) then
            ClientBridge.removeEntity(ped, { 'zloma_apt_browse_' .. id })
            DeleteEntity(ped)
        end
    end
    for _, blip in pairs(blips) do RemoveBlip(blip) end
    peds, blips = {}, {}
end

local function spawnPed(def)
    local model = type(def.receptionModel) == 'string' and joaat(def.receptionModel) or def.receptionModel
    if not IsModelInCdimage(model) then
        print(('^1[zloma_apartments]^0 Reception model for %s does not exist'):format(def.id))
        return
    end
    lib.requestModel(model, 10000)
    local r = def.reception
    local ped = CreatePed(0, model, r.x, r.y, r.z, r.w, false, true)
    SetModelAsNoLongerNeeded(model)
    if ped == 0 then return end
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    if def.receptionScenario then TaskStartScenarioInPlace(ped, def.receptionScenario, 0, true) end
    ClientBridge.addEntity(ped, { {
        name = 'zloma_apt_browse_' .. def.id, icon = 'fas fa-building', label = _L('target_browse'), distance = 2.5,
        onSelect = function() OpenApartmentUI(def.id) end,
    } })
    peds[def.id] = ped
end

local function createBlip(def)
    if def.blip.hidden then return end
    local r = def.reception
    local blip = AddBlipForCoord(r.x, r.y, r.z)
    SetBlipSprite(blip, def.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, def.blip.scale + 0.0)
    SetBlipColour(blip, def.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(def.label)
    EndTextCommandSetBlipName(blip)
    blips[def.id] = blip
end

OnHotelsChanged(function(hotels)
    clearReception()
    for _, def in pairs(hotels) do
        createBlip(def)
        spawnPed(def)
    end
end)

function OpenApartmentUI(hotelId)
    if uiOpen then return end
    local data = lib.callback.await('zloma_apartments:getRooms', false, hotelId)
    if not data then return end
    uiOpen = true
    SendNUIMessage({ action = 'openMainUI', data = data })
    SetNuiFocus(true, true)
end

function CloseApartmentUI()
    if CloseSafePinUI then CloseSafePinUI() end
    if not uiOpen then return end
    uiOpen = false
    SendNUIMessage({ action = 'closeUI' })
    SetNuiFocus(false, false)
    RefreshDoorAccess()
end

RegisterNUICallback('closeUI', function(_, cb) CloseApartmentUI(); cb('ok') end)
RegisterNetEvent('zloma_apartments:client:closeUI', CloseApartmentUI)

local function forward(name, serverName)
    RegisterNUICallback(name, function(data, cb)
        cb(lib.callback.await('zloma_apartments:' .. (serverName or name), false, data) or {})
    end)
end
forward('getRooms')
forward('getNearbyPlayers')
forward('getSettings')
forward('saveSettings')
forward('rentOrBuy')
forward('cancelRent')
forward('leaveApartment')
forward('upgradeSafe')
forward('upgradeSecurity')
forward('addRoommate')
forward('removeRoommate')
forward('setSafePin')

RegisterNetEvent('zloma_apartments:client:evicted', function(data)
    CloseApartmentUI()
    RefreshDoorAccess()
    -- Only someone standing in the released room is moved out.
    if data and IsInsideRoom(data.hotel_id, data.room_number) then
        local def = ClientState.hotels[data.hotel_id]
        local r = def.reception
        DoScreenFadeOut(300)
        Wait(350)
        SetEntityCoords(PlayerPedId(), r.x, r.y, r.z, false, false, false, false)
        DoScreenFadeIn(300)
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    clearReception()
    if uiOpen then SetNuiFocus(false, false) end
end)
