function CreateVeh(model, ...)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local veh = CreateVehicle(model, ...)
    SetModelAsNoLongerNeeded(model)
    return veh
end

function CreateNPC(type, model, ...)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local npc = CreatePed(type, model, ...)
    SetModelAsNoLongerNeeded(model)
    return npc
end

function CreateProp(model, ...)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local prop = CreateObject(model, ...)
    SetModelAsNoLongerNeeded(model)
    return prop
end

function PlayAnim(ped, dict, ...)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(ped, dict, ...)
end

function PlayEffect(asset, effect, entity, offset, rotation, duration, callback)
    CreateThread(function()
        RequestNamedPtfxAsset(asset)
        while not HasNamedPtfxAssetLoaded(asset) do Wait(0) end
        UseParticleFxAssetNextCall(asset)
        Wait(10)
        local fx = StartParticleFxLoopedOnEntity(effect, entity, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, 1.0)
        SetParticleFxLoopedColour(fx, 0, 255/255, 0, 0)
        Wait(duration)
        StopParticleFxLooped(fx, false)
        if callback then callback() end
    end)
end

function CreateBlip(data)
    local x, y, z = table.unpack(data.Location)
    local radiusBlip = nil
    if data.Radius then
        radiusBlip = AddBlipForRadius(x, y, z, data.Radius.Size)
        SetBlipColour(radiusBlip, data.Radius.Color)
        SetBlipAlpha(radiusBlip, data.Radius.Opacity)
        SetBlipHighDetail(radiusBlip, true)
    end
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, data.ID)
    SetBlipDisplay(blip, data.Display)
    SetBlipScale(blip, data.Scale)
    SetBlipColour(blip, data.Color)
    if data.Rotation then
        SetBlipRotation(blip, math.ceil(data.Rotation))
    end
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.Label)
    EndTextCommandSetBlipName(blip)
    return blip, radiusBlip
end
