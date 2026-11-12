-- Highcrest /carry, client side. /carry next to someone asks them; /carry again or X puts them down.

local CARRIER_ANIM = { dict = 'missfinale_c2mcs_1', clip = 'fin_c2_mcs_1_camman', flag = 49 }
local CARRIED_ANIM = { dict = 'nm', clip = 'firemans_carry', flag = 33 }

local state = nil -- 'carrying' | 'carried'
local other = nil -- the other player's server id

local function playAnim(anim)
    lib.requestAnimDict(anim.dict)
    TaskPlayAnim(cache.ped, anim.dict, anim.clip, 8.0, -8.0, -1, anim.flag, 0, false, false, false)
end

local function finish()
    if state == 'carried' then
        DetachEntity(cache.ped, true, false)
        TriggerEvent('hospital:client:isEscorted', false)
    end
    if state then
        ClearPedTasks(cache.ped)
        if lib.isTextUIOpen() then lib.hideTextUI() end
    end
    state, other = nil, nil
end

RegisterCommand('carry', function()
    if state then
        TriggerServerEvent('highcrest_carry:server:stop')
        return
    end
    if cache.vehicle then
        return lib.notify({ description = 'Get out of the vehicle first.', type = 'error' })
    end
    local playerId = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.5, false)
    if not playerId then
        return lib.notify({ description = 'Nobody close enough to carry.', type = 'error' })
    end
    if IsPedInAnyVehicle(GetPlayerPed(playerId), false) then
        return lib.notify({ description = 'They are in a vehicle.', type = 'error' })
    end
    TriggerServerEvent('highcrest_carry:server:request', GetPlayerServerId(playerId))
end, false)

TriggerEvent('chat:addSuggestion', '/carry', 'Carry the closest player (they have to accept). Use again to put them down.')

RegisterNetEvent('highcrest_carry:client:ask', function(from)
    local name = GetPlayerName(GetPlayerFromServerId(from)) or 'Someone'
    local answer = lib.alertDialog({
        header = 'Carry request',
        content = ('%s wants to carry you.'):format(name),
        centered = true,
        cancel = true,
        labels = { confirm = 'Accept', cancel = 'Decline' },
    })
    TriggerServerEvent('highcrest_carry:server:answer', answer == 'confirm')
end)

RegisterNetEvent('highcrest_carry:client:carry', function(target)
    state, other = 'carrying', target
    playAnim(CARRIER_ANIM)
    lib.showTextUI('[X] Put down', { icon = 'hand' })

    CreateThread(function()
        while state == 'carrying' do
            local targetPed = GetPlayerPed(GetPlayerFromServerId(other))
            if not DoesEntityExist(targetPed) or IsPedInAnyVehicle(cache.ped, false) or IsPedRagdoll(cache.ped) then
                TriggerServerEvent('highcrest_carry:server:stop')
                break
            end
            if not IsEntityPlayingAnim(cache.ped, CARRIER_ANIM.dict, CARRIER_ANIM.clip, 3) then
                playAnim(CARRIER_ANIM)
            end
            DisableControlAction(0, 21, true)  -- sprint
            DisableControlAction(0, 22, true)  -- jump
            DisableControlAction(0, 23, true)  -- enter vehicle
            DisableControlAction(0, 24, true)  -- attack
            DisableControlAction(0, 25, true)  -- aim
            DisablePlayerFiring(cache.playerId, true)
            if IsControlJustReleased(0, 73) then -- X
                TriggerServerEvent('highcrest_carry:server:stop')
                break
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent('highcrest_carry:client:carried', function(carrier)
    state, other = 'carried', carrier
    TriggerEvent('hospital:client:isEscorted', true)
    local carrierPed = GetPlayerPed(GetPlayerFromServerId(carrier))
    AttachEntityToEntity(cache.ped, carrierPed, 0, 0.27, 0.15, 0.63, 0.5, 0.5, 180.0, false, false, false, false, 2, false)
    playAnim(CARRIED_ANIM)

    CreateThread(function()
        while state == 'carried' do
            if not DoesEntityExist(GetPlayerPed(GetPlayerFromServerId(other))) then
                TriggerServerEvent('highcrest_carry:server:stop')
                finish()
                break
            end
            if not IsEntityPlayingAnim(cache.ped, CARRIED_ANIM.dict, CARRIED_ANIM.clip, 3) then
                playAnim(CARRIED_ANIM)
            end
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisablePlayerFiring(cache.playerId, true)
            Wait(0)
        end
    end)
end)

RegisterNetEvent('highcrest_carry:client:stop', finish)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then finish() end
end)
