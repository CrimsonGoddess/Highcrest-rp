local isDetecting = false
local isCloseToItem = false
local isDigging = false
local isWaitingForShovel = false
local detectorProp = nil
local shovelProp = nil
local itemLocation = nil
local detectorProps = {}

for _, detector in pairs(Config.Detectors) do
    table.insert(detectorProps, detector.prop)
end

function IsInRestrictedArea(coords)
    for _, area in pairs(Config.Detecting.restricted_areas) do
        local distance = #(coords - area.coords)
        if distance < area.radius then
            return true
        end
    end
    return false
end

function IsInDesignatedArea(coords)
    for _, area in pairs(Config.Detecting.designated_areas.areas) do
        local distance = #(coords - area.coords)
        if distance < area.radius then
            return true
        end
    end
    return false
end

function CheckSoilType(coords)
    local offset = vec3(0.0, 2.0, -3.0)
    local endCoords = GetOffsetFromEntityInWorldCoords(cache.ped, offset.x, offset.y, offset.z)
    local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z, endCoords.x, endCoords.y, endCoords.z, 17, cache.ped, 7)
    local _, hit, _, _, _, materialHash, _ = GetShapeTestResultEx(rayHandle)
    if hit == 1 then
        if not Config.Detecting.soil_type[materialHash] then
            return false
        end
        return true
    end
    return false
end

function GetCurrentSoilType()
    local offset = vec3(0.0, 2.0, -3.0)
    local playerCoords = GetEntityCoords(cache.ped)
    local endCoords = GetOffsetFromEntityInWorldCoords(cache.ped, offset.x, offset.y, offset.z)
    local rayHandle = StartShapeTestRay(playerCoords.x, playerCoords.y, playerCoords.z, endCoords.x, endCoords.y, endCoords.z, 17, cache.ped, 7)
    local _, hit, _, _, _, materialHash, _ = GetShapeTestResultEx(rayHandle)
    if hit == 1 then
        if Config.Setup.debug then
            print("Currently detecting on soil type: " .. tostring(materialHash))
        end
        if not Config.Detecting.soil_type[materialHash] then
            return false
        end
        return true
    end
    return false
end

function FindItemLocation(radius)
    local playerCoords = GetEntityCoords(cache.ped)
    local attempts = 0
    while attempts < 25 do
        local randomDistance = math.random(1, radius)
        local randomAngle = math.random() * 2 * math.pi
        local x = randomDistance * math.cos(randomAngle)
        local y = randomDistance * math.sin(randomAngle)
        local testCoords = vec3(playerCoords.x + x, playerCoords.y + y, playerCoords.z)
        local validSoil = true
        if Config.Detecting.soil_check then
            validSoil = CheckSoilType(testCoords)
        end
        if validSoil then
            return testCoords
        end
        attempts = attempts + 1
    end
    return playerCoords
end

function StopDetecting()
    if DoesEntityExist(detectorProp) then
        DeleteEntity(detectorProp)
    end
    if detectorProp then
        detectorProp = nil
    end
    ClearPedTasks(cache.ped)
    RemoveAnimDict(Config.Animations.detecting.anim.dict)
    for _, prop in pairs(detectorProps) do
        SetModelAsNoLongerNeeded(prop)
    end
    isDetecting = false
    StoppedDetecting()
end

function SoundLoop()
    if not Config.Detecting.sound.enable then
        return
    end
    local audioConfig = Config.Detecting.sound.audio
    while true do
        if not isDetecting then
            break
        end
        Wait(0)
        local distance = 0
        if itemLocation then
            local playerCoords = GetEntityCoords(cache.ped)
            distance = #(playerCoords - itemLocation)
        end
        if searching then
            if itemLocation and distance <= 35 then
                if distance < 2.25 then
                    PlaySoundFrontend(-1, audioConfig.name, audioConfig.bank, true)
                    Wait(GetBeepTime(distance))
                end
            end
        elseif isCloseToItem then
            if distance < 2.25 then
                PlaySoundFrontend(-1, audioConfig.name, audioConfig.bank, true)
                Wait(GetBeepTime(distance))
            end
        else
            Wait(500)
        end
    end
end

function DisableControlsLoop()
    while true do
        if not isDetecting then
            break
        end
        Wait(0)
        for i = 1, #Config.Detecting.disable do
            DisableControlAction(0, Config.Detecting.disable[i], true)
        end
    end
end

function CheckDetectorItem(item)
    while true do
        if not isDetecting then
            break
        end
        Wait(500)
        local inVehicle = IsPedInAnyVehicle(cache.ped, true)
        local hasItem = HasItem(item, 1)
        if not hasItem or inVehicle then
            StopDetecting()
            break
        end
    end
end

function WaitForShovelInput()
    if isWaitingForShovel then
        return
    end
    isWaitingForShovel = true
    while true do
        if not isWaitingForShovel then
            break
        end
        Wait(0)
        if IsControlJustPressed(0, Config.Setup.control) then
            if Config.Shovel.required then
                if not HasItem(Config.Shovel.item, 1) then
                    ShowNotification(Strings.Notify.noShovel, "error")
                else
                    TriggerEvent("lation_detecting:UseShovel")
                    isWaitingForShovel = false
                end
            else
                TriggerEvent("lation_detecting:UseShovel")
                isWaitingForShovel = false
            end
        end
    end
end

function StartDetectingLoop(detectorData)
    local cooldown = detectorData.cooldown
    local radius = detectorData.radius
    local distance = nil
    local textUI = Strings.TextUI
    CreateThread(DisableControlsLoop)
    CreateThread(SoundLoop)
    CreateThread(function()
        CheckDetectorItem(detectorData.item)
    end)
    StartedDetecting()
    while true do
        if not isDetecting then
            break
        end
        Wait(1000)
        local playerCoords = GetEntityCoords(cache.ped)
        local inRestrictedArea = IsInRestrictedArea(playerCoords)
        local inDesignatedArea = true
        if Config.Detecting.designated_areas.enabled then
            inDesignatedArea = IsInDesignatedArea(playerCoords)
        end
        local validSoil = true
        if Config.Detecting.soil_check then
            validSoil = GetCurrentSoilType()
        end
        local isWalking = IsPedWalking(cache.ped)
        local isRunning = IsPedRunning(cache.ped)
        local isSprinting = IsPedSprinting(cache.ped)
        if itemLocation then
            local playerCoords = GetEntityCoords(cache.ped)
            distance = #(playerCoords - itemLocation)
        else
            distance = 0
        end
        if inRestrictedArea or not inDesignatedArea then
            StopDetecting()
            ShowNotification(Strings.Notify.cantDetect, "error")
            break
        end
        if validSoil then
            if Config.Detecting.running or (isWalking and not isRunning and not isSprinting) then
                if isWalking or isRunning or isSprinting then
                    cooldown = cooldown - 1000
                end
                if itemLocation then
                    searching = true
                    if radius >= distance then
                        ShowTextUI(textUI.distance.label .. tostring(math.floor(distance)), textUI.distance.icon)
                    end
                    if radius <= distance then
                        itemLocation = nil
                        cooldown = detectorData.cooldown
                        ShowNotification(Strings.Notify.lostItem, "error")
                    end
                    if distance < 2.25 then
                        isCloseToItem = true
                        if not isWaitingForShovel then
                            if not isDigging then
                                CreateThread(WaitForShovelInput)
                            end
                        end
                        ShowTextUI(textUI.dig.label, textUI.dig.icon)
                    else
                        if distance >= 2.25 then
                            isCloseToItem = false
                        end
                    end
                elseif isWalking or isRunning or isSprinting then
                    searching = true
                    ShowTextUI(textUI.searching.label, textUI.searching.icon)
                    if cooldown <= 0 then
                        itemLocation = FindItemLocation(radius)
                        cooldown = detectorData.cooldown
                        TriggerServerEvent("lation_detecting:ItemAssigned", detectorData.item)
                    end
                else
                    if isCloseToItem then
                        if not (distance < 2.25) then
                            searching = false
                            ShowTextUI(textUI.error.label, textUI.error.icon)
                        end
                    end
                end
            end
        else
            if isCloseToItem then
                if distance < 2.25 then
                    goto continue
                end
            end
            searching = false
            ShowTextUI(textUI.error.label, textUI.error.icon)
        end
        ::continue::
    end
    HideTextUI(textUI.error.label)
    HideTextUI(textUI.distance.label .. tostring(math.floor(distance)))
    HideTextUI(textUI.searching.label)
    HideTextUI(textUI.dig.label)
end

function StartDetectingAnimation(detectorData)
    local playerCoords = GetEntityCoords(cache.ped)
    local animConfig = Config.Animations.detecting.anim
    local propConfig = Config.Animations.detecting.prop
    lib.requestModel(detectorData.prop)
    lib.requestAnimDict(animConfig.dict)
    while true do
        if HasModelLoaded(detectorData.prop) then
            if HasAnimDictLoaded(animConfig.dict) then
                break
            end
        end
        Wait(0)
    end
    ClearPedTasks(cache.ped)
    if detectorProp then
        detectorProp = nil
    end
    detectorProp = CreateObject(detectorData.prop, playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
    AttachEntityToEntity(detectorProp, cache.ped, GetPedBoneIndex(cache.ped, 60309), propConfig.pos.x, propConfig.pos.y, propConfig.pos.z, propConfig.rot.x, propConfig.rot.y, propConfig.rot.z, true, false, false, true, 1, true)
    TaskPlayAnim(cache.ped, animConfig.dict, animConfig.clip, 8.0, 8.0, -1, 49, 0.0, false, false, false)
end

function PlayShovelAnimation()
    local playerCoords = GetEntityCoords(cache.ped)
    local animConfig = Config.Animations.shovel.anim
    local propConfig = Config.Animations.shovel.prop
    lib.requestModel(propConfig.model)
    lib.requestAnimDict(animConfig.dict)
    while true do
        if HasModelLoaded(propConfig.model) then
            if HasAnimDictLoaded(animConfig.dict) then
                break
            end
        end
        Wait(0)
    end
    if shovelProp then
        shovelProp = nil
    end
    shovelProp = CreateObject(propConfig.model, playerCoords.x, playerCoords.y, playerCoords.z - 2.0, true, true, false)
    AttachEntityToEntity(shovelProp, cache.ped, GetPedBoneIndex(cache.ped, 28422), propConfig.pos.x, propConfig.pos.y, propConfig.pos.z, propConfig.rot.x, propConfig.rot.y, propConfig.rot.z, true, false, false, true, 1, true)
    TaskPlayAnim(cache.ped, animConfig.dict, animConfig.clip, 8.0, 8.0, -1, 1, 0.0, false, false, false)
    Wait(Config.Animations.shovel.duration)
    ClearPedTasks(cache.ped)
    DeleteEntity(shovelProp)
    SetModelAsNoLongerNeeded(propConfig.model)
    RemoveAnimDict(animConfig.dict)
end

RegisterNetEvent("lation_detecting:UseDetector", function(level)
    if isDetecting then
        StopDetecting()
        ShowNotification(Strings.Notify.stopped, "info")
        return
    end
    if not level or type(level) ~= "number" then
        EventLog("[detecting.lua]: lation_detecting:UseDetector: invalid missing or invalid param type")
        return
    end
    local detectorData = Config.Detectors[level]
    if not detectorData then
        EventLog("[detecting.lua]: lation_detecting:UseDetector: unable to retrieve detector data from config")
        return
    end
    if IsPedInAnyVehicle(cache.ped, true) then
        ShowNotification(Strings.Notify.inVehicle, "error")
        return
    end
    StartDetectingAnimation(detectorData)
    isDetecting = true
    CreateThread(function()
        StartDetectingLoop(detectorData)
    end)
end)

RegisterNetEvent("lation_detecting:UseShovel")
AddEventHandler("lation_detecting:UseShovel", function()
    if isDigging then
        ShowNotification(Strings.Notify.alreadyDigging, "error")
        return
    end
    if itemLocation == nil then
        ShowNotification(Strings.Notify.nothingToDig, "error")
        return
    end
    local playerCoords = GetEntityCoords(cache.ped)
    local distance = #(playerCoords - itemLocation)
    if isCloseToItem then
        if distance > 2.25 then
            ShowNotification(Strings.Notify.nothingToDig, "error")
            return
        end
    end
    if not isDetecting then
        EventLog("[detecting.lua]: lation_detecting:UseShovel: player wasnt identified as using a detector")
        return
    end
    StopDetecting()
    isDigging = true
    StartedDigging()
    PlayShovelAnimation()
    HideTextUI(Strings.TextUI.dig.label)
    isDigging = false
    StoppedDigging()
    TriggerServerEvent("lation_detecting:ItemFound")
    itemLocation = nil
    isCloseToItem = false
end)

if Config.Setup.debug then
    function SortTableByValue(tbl)
        local sorted = {}
        for key, value in pairs(tbl) do
            table.insert(sorted, {key = key, value = value})
        end
        table.sort(sorted, function(a, b)
            return a.value > b.value
        end)
        return sorted
    end

    function SimulateLoot(level)
        local loot = Config.Detectors[level].loot
        if not loot then
            return nil
        end
        local totalChance = 0
        for _, itemData in pairs(loot) do
            if itemData.chance and type(itemData.chance) == "number" then
                totalChance = totalChance + itemData.chance
            end
        end
        local random = math.random() * totalChance
        local currentChance = 0
        for itemName, itemData in pairs(loot) do
            if itemData.chance and type(itemData.chance) == "number" then
                currentChance = currentChance + itemData.chance
                if random <= currentChance then
                    return itemName
                end
            end
        end
        return nil
    end

    RegisterCommand("simulate", function(source, args)
        local level = tonumber(args[1])
        local iterations = tonumber(args[2])
        local detectorData = Config.Detectors[level]
        if not detectorData then
            return
        end
        local results = {}
        for i = 1, iterations do
            local item = SimulateLoot(level)
            if item then
                if not results[item] then
                    results[item] = 0
                end
                results[item] = results[item] + 1
            end
        end
        local sorted = SortTableByValue(results)
        for _, entry in ipairs(sorted) do
            print(string.format("Item: %s, Quantity: %d", entry.key, entry.value))
        end
    end, false)
end
