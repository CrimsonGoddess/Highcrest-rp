smokeActive = true

Config.useAlternativeSync = false
Config.syncSmoke = true
Config.syncQuality = 80
Config.syncToNearbyPlayersOnly = true
Config.syncRadius = 75.0

if Config.smokeDensity > 100 then
    Config.smokeDensity = 100
end

if Config.syncQuality > 100 then
    Config.syncQuality = 100
end

local vehicleWheelData = {}
local burnoutMultipliers = {}
local syncedVehicles = {}
local wheelDefaults = {}

local frontLeftWheel = {
    bone = "hub_lf",
    wheel = 0,
    minSync = 99,
    allowWheelSmoke = false,
    smokeDensity = 0
}

local frontRightWheel = {
    bone = "hub_rf",
    wheel = 1,
    minSync = 99,
    allowWheelSmoke = false,
    smokeDensity = 0
}

local rearRightWheel = {
    bone = "hub_rr",
    wheel = 2,
    minSync = 1,
    allowWheelSmoke = false,
    smokeDensity = 0
}

local rearLeftWheel = {
    bone = "hub_lr",
    wheel = 3,
    minSync = 1,
    allowWheelSmoke = false,
    smokeDensity = 0
}

wheelDefaults[1] = frontLeftWheel
wheelDefaults[2] = frontRightWheel
wheelDefaults[3] = rearRightWheel
wheelDefaults[4] = rearLeftWheel

Citizen.CreateThread(function()
    while true do
        for vehicle, wheels in pairs(vehicleWheelData) do
            for _, wheel in ipairs(wheels) do
                if not wheel.allowWheelSmoke then
                    wheel.allowWheelSmoke = true
                end
            end
        end

        Citizen.Wait(1200)
    end
end)

if not Config.useAlternativeSync then
    Citizen.CreateThread(function()
        while true do
            local activeVehicles = {}
            local players = GetActivePlayers()

            for i = 1, #players do
                local ped = GetPlayerPed(players[i])
                if IsPedInAnyVehicle(ped, false) then
                    local vehicle = GetVehiclePedIsIn(ped, false)

                    if not Contains(activeVehicles, vehicle) then
                        if Config.whitelist.useWhitelist then
                            if not IsWhitelisted(vehicle) then
                                goto continue
                            end
                        end

                        table.insert(activeVehicles, vehicle)
                    end
                end

                ::continue::
            end

            syncedVehicles = activeVehicles
            Citizen.Wait(3000)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        local waitTime = Config.smokeDensity * 2.5
        waitTime = 350 - waitTime

        if smokeActive then
            if Config.useAlternativeSync then
                waitTime = 3000
            end

            local playerPed = PlayerPedId()
            local playerVehicle = nil

            if IsPedInAnyVehicle(playerPed, false) then
                playerVehicle = GetVehiclePedIsIn(playerPed, false)

                if Config.whitelist.useWhitelist then
                    if not IsWhitelisted(playerVehicle) then
                        goto skipPlayerVehicle
                    end
                end

                CheckSmoke(playerVehicle)
            end

            ::skipPlayerVehicle::

            if not Config.useAlternativeSync then
                for i = 1, #syncedVehicles do
                    local vehicle = syncedVehicles[i]

                    if vehicle ~= playerVehicle then
                        if DoesEntityExist(vehicle) then
                            CheckSmoke(vehicle)
                        end
                    end
                end
            end
        else
            waitTime = 3000
        end

        Citizen.Wait(waitTime)
    end
end)

function CheckSmoke(vehicle)
    Citizen.CreateThread(function()
        if Config.onlyWithDriftTires then
            if not Entity(vehicle).state.hasDriftTires then
                return
            end
        end

        local wheels = vehicleWheelData[vehicle]

        if wheels == nil then
            vehicleWheelData[vehicle] = json.decode(json.encode(wheelDefaults))
            burnoutMultipliers[vehicle] = 0
        end

        local playerPed = PlayerPedId()
        local useColoredSmoke = true
        local r, g, b = GetVehicleTyreSmokeColor(vehicle)
        local isInBurnout = IsVehicleInBurnout(vehicle)

        if isInBurnout then
            local currentMultiplier = burnoutMultipliers[vehicle]
            local maxMultiplier = Config.maxBurnoutSmokeMultiplier * 20

            if currentMultiplier < maxMultiplier then
                burnoutMultipliers[vehicle] = burnoutMultipliers[vehicle] + 1
            end
        else
            if burnoutMultipliers[vehicle] > 0 then
                burnoutMultipliers[vehicle] = burnoutMultipliers[vehicle] - 3
            end
        end

        if r ~= 255 or g ~= 255 or b ~= 255 then
            if Config.allowColoredSmoke then
                goto allowSmoke
            end
        end

        if isInBurnout then
            if Config.bigBurnoutSmoke then
                goto allowSmoke
            end
        end

        useColoredSmoke = false

        ::allowSmoke::
        
        local shouldCreateSmoke = false

        for _, wheel in ipairs(vehicleWheelData[vehicle]) do
            local boneIndex = GetEntityBoneIndexByName(vehicle, wheel.bone)
            local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)

            if bonePos.x ~= 0.0 and bonePos.y ~= 0.0 and bonePos.z ~= 0.0 then
                if vehicleWheelData[vehicle].smokeDensity == nil then
                    vehicleWheelData[vehicle].smokeDensity = 0
                end

                local surfaceMaterial = GetVehicleWheelSurfaceMaterial(vehicle, wheel.wheel)

                if not Contains(Config.roadSurfaces, surfaceMaterial) then
                    break
                end

                local isDrifting = false
                local tractionLength = math.abs(GetVehicleWheelTractionVectorLength(vehicle, wheel.wheel))
                local threshold = Config.driftThreshold + 0.0

                if tractionLength > threshold then
                    isDrifting = true

                    if wheel.smokeDensity < 4 then
                        wheel.smokeDensity = wheel.smokeDensity + 2
                    end
                else
                    if wheel.smokeDensity > 0 then
                        wheel.smokeDensity = wheel.smokeDensity - 1
                    end
                end

                if not isDrifting then
                    if not (wheel.smokeDensity > 0) then
                        goto skipWheel
                    end
                end
                
                shouldCreateSmoke = true

                local netId = NetworkGetNetworkIdFromEntity(vehicle)
                local wheelSpeed = GetVehicleWheelSpeed(vehicle, wheel.wheel)

                if wheelSpeed > 50 then
                    wheelSpeed = 50
                end

                local burnoutMultiplier = 1

                if isInBurnout then
                    burnoutMultiplier = GetBurnoutMultiplier(vehicle)
                    useColoredSmoke = true
                end

                local scale = 1.0

                if not isInBurnout then
                    local tractionBasedScale = GetVehicleWheelTractionVectorLength(vehicle, wheel.wheel) / 40
                    scale = 0.25 + tractionBasedScale
                    local speedBasedScale = wheelSpeed / 70
                    scale = scale + speedBasedScale
                    scale = scale * burnoutMultiplier
                    scale = scale * Config.scaleMultiplier
                else
                    local tractionBasedScale = GetVehicleWheelTractionVectorLength(vehicle, wheel.wheel) / 45
                    scale = 0.5 + tractionBasedScale
                    local speedBasedScale = wheelSpeed / 80
                    scale = scale + speedBasedScale
                    scale = scale * burnoutMultiplier
                    scale = scale * Config.scaleMultiplier
                end

                local densityMultiplier = wheel.smokeDensity
                densityMultiplier = 5 - densityMultiplier
                densityMultiplier = densityMultiplier / 5
                densityMultiplier = 1 - densityMultiplier
                scale = scale * densityMultiplier

                if scale > 0.4 then
                    if not useColoredSmoke then
                        scale = scale * 0.8
                    end

                    RunSmoke(vehicle, wheel.bone, scale * 0.75, true)

                    if wheel.allowWheelSmoke and not useColoredSmoke then
                        wheel.allowWheelSmoke = false
                        RunSmoke(vehicle, wheel.bone, scale * 1.1, false)

                        if Config.useAlternativeSync then
                            if Config.syncSmoke then
                                if wheel.minSync < Config.syncQuality then
                                    local randomValue = math.random(0, 99)

                                    if Config.syncQuality > randomValue then
                                        TriggerServerEvent("kq_driftsmoke:smoke", netId, wheel.bone, scale, false)
                                    end
                                end
                            end
                        end
                    end

                    if Config.useAlternativeSync then
                        if Config.syncSmoke then
                            local randomValue = math.random(0, 99)

                            if Config.syncQuality > randomValue then
                                if wheel.minSync < Config.syncQuality then
                                    TriggerServerEvent("kq_driftsmoke:smoke", netId, wheel.bone, scale, true)
                                end
                            end
                        end
                    end
                end
            end

            ::skipWheel::
        end
    end)
end

function GetBurnoutMultiplier(vehicle)
    local multiplier = 1

    if Config.growBurnoutSmoke then
        if burnoutMultipliers[vehicle] > 0 then
            multiplier = burnoutMultipliers[vehicle] / 20

            if multiplier > Config.maxBurnoutSmokeMultiplier then
                multiplier = Config.maxBurnoutSmokeMultiplier
            end
        end
    end

    return multiplier * 0.7
end

function SmokeWhite(vehicle, bone, scale)
    Citizen.CreateThread(function()
        local assetName = "core_snow"

        if not HasNamedPtfxAssetLoaded(assetName) then
            RequestNamedPtfxAsset(assetName)

            while not HasNamedPtfxAssetLoaded(assetName) do
                Citizen.Wait(1)
            end
        end

        local boneIndex = GetEntityBoneIndexByName(vehicle, bone)
        SetPtfxAssetNextCall(assetName)

        local particleFx = StartParticleFxLoopedOnEntityBone(
            "wheel_fric_snow",
            vehicle,
            0.0, 0.0, -0.12,
            0.0, 0.0, 0.0,
            boneIndex,
            scale,
            1, 1, 1
        )

        SetParticleFxLoopedFarClipDist(particleFx, 300.0)
        Citizen.Wait(1600)
        StopParticleFxLooped(particleFx, 0)
        RemoveParticleFx(particleFx, true)
    end)
end

function SmokeColor(vehicle, bone, scale)
    Citizen.CreateThread(function()
        local assetName = "scr_carsteal4"

        if not HasNamedPtfxAssetLoaded(assetName) then
            RequestNamedPtfxAsset(assetName)

            while not HasNamedPtfxAssetLoaded(assetName) do
                Citizen.Wait(1)
            end
        end

        local boneIndex = GetEntityBoneIndexByName(vehicle, bone)
        local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)

        SetPtfxAssetNextCall(assetName)

        local zOffset = scale * 0.4
        zOffset = 1.0 + zOffset
        local finalZ = bonePos.z - zOffset

        local particleFx = StartParticleFxLoopedAtCoord(
            "scr_carsteal4_wheel_burnout",
            bonePos.x, bonePos.y, finalZ,
            0.0, 0.0, GetEntityHeading(vehicle),
            scale * 1.6,
            1, 1, 1,
            false
        )

        SetParticleFxLoopedAlpha(particleFx, Config.smokeOpacity)
        SetParticleFxLoopedFarClipDist(particleFx, 300.0)

        if Config.allowColoredSmoke then
            local r, g, b = GetVehicleTyreSmokeColor(vehicle)
            SetParticleFxLoopedColour(particleFx, r / 255, g / 255, b / 255, 0)
        end

        Citizen.Wait(1500)
        StopParticleFxLooped(particleFx, 0)
        RemoveParticleFx(particleFx, true)
    end)
end

RegisterNetEvent("kq_driftsmoke:smoke")
AddEventHandler("kq_driftsmoke:smoke", function(netId, bone, scale, isColored)
    if not NetworkDoesNetworkIdExist(netId) then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    RunSmoke(vehicle, bone, scale, isColored)
end)

function RunSmoke(vehicle, bone, scale, isColored)
    if DoesEntityExist(vehicle) then
        if isColored then
            SmokeColor(vehicle, bone, scale)
        else
            SmokeWhite(vehicle, bone, scale)
        end
    end
end

if Config.debug then
    RegisterCommand('surface', function(source, args)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
            local surface = GetVehicleWheelSurfaceMaterial(vehicle, 0)

            TriggerEvent("chat:addMessage", {
                color = { 255, 0, 0 },
                multiline = true,
                args = { "KuzQuality", string.format("Surface: %s\n", surface) }
            })
        else
            TriggerEvent("chat:addMessage", {
                color = { 255, 0, 0 },
                multiline = true,
                args = { "KuzQuality", "You need to be in a vehicle to check the surface!" }
            })
        end
    end)
end

function Contains(table, value)
    for _, item in ipairs(table) do
        if item == value then
            return true
        end
    end

    return false
end
