camera = nil
local cameraProp = nil
local freecamEnabled = true
local currentFov = nil

local animationDict = Config.Camera.AnimationDict
local animation = Config.Camera.Animation
local propModel = Config.Camera.Prop
local minFov = Config.Camera.MinFov
local maxFov = Config.Camera.MaxFov
local fovSensitivity = Config.Camera.FovSenivity
local useEffect = Config.Camera.UseEffect

local function addScaleformParam(text)
    _ENV["ScaleformMovieMethodAddParamPlayerNameString"](text)
end

local function addScaleformText(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function createInstructionalButtons(scaleformName)
    local scaleform = RequestScaleformMovie(scaleformName)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    addScaleformParam(GetControlInstructionalButton(1, 191, true))
    addScaleformText("Take image")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    addScaleformParam(GetControlInstructionalButton(1, 96, true))
    addScaleformText("Zoom")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    addScaleformParam(GetControlInstructionalButton(1, 19, true))
    addScaleformText("Toggle freecam")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    addScaleformParam(GetControlInstructionalButton(1, 177, true))
    addScaleformText("Cancel")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(60)
    PopScaleformMovieFunctionVoid()
    
    return scaleform
end

local function setFullOpacity(visible)
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        action = "setFullOpacity",
        data = visible and 1 or 0
    })
end

local function takeScreenshot()
    local ped = PlayerPedId()
    local promise = promise.new()
    
    Framework.TriggerCallback("GetUploadInfo", function(uploadInfo)
        debugPrint("Retrieving upload information from server")
        exports["screenshot-basic"].requestScreenshotUpload(uploadInfo.link, uploadInfo.field, uploadInfo.options, function(response)
            local data = json.decode(response)
            local imageUrl = getValueAtPath(data, uploadInfo.path)
            FreezeEntityPosition(ped, false)
            promise:resolve(imageUrl)
        end)
    end)
    return promise
end

local function startCamera()
    local ped = PlayerPedId()
    BeginTextCommandBusyspinnerOn("STRING")
    AddTextComponentSubstringPlayerName("Loading camera..")
    EndTextCommandBusyspinnerOn(4)
    
    RequestDict(animationDict)
    if not DoesAnimDictExist(animationDict) then
        return
    end
    
    TaskPlayAnim(ped, animationDict, animation, 8.0, 8.0, -1, 50, 0, false, false, false)
    RequestProp(propModel)
    BusyspinnerOff()
    
    local boneIndex = GetPedBoneIndex(ped, 28422)
    local coords = GetEntityCoords(ped)
    local x, y, z = table.unpack(coords)
    
    cameraProp = CreateObject(propModel, x, y, z + 0.2, true, true, true)
    AttachEntityToEntity(cameraProp, ped, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
    
    camera = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
    AttachCamToEntity(camera, ped, 0.0, 0.7, 0.7, true)
    SetCamRot(camera, 0.0, 0.0, GetEntityHeading(ped))
    RenderScriptCams(true, false, 0, 1, 0)
    
    if useEffect then
        SetTimecycleModifier("phone_cam")
        SetTimecycleModifierStrength(1.0)
    end
end

local function stopCamera(keepFrozen)
    if not keepFrozen then
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, false)
        if IsEntityPlayingAnim(ped, Config.Camera.AnimationDict, Config.Camera.Animation, 3) then
            StopAnimTask(ped, Config.Camera.AnimationDict, Config.Camera.Animation, 1.0)
        end
    end
    
    SetModelAsNoLongerNeeded(propModel)
    DetachEntity(cameraProp, 0, 0)
    DeleteEntity(cameraProp)
    DetachCam(camera)
    RenderScriptCams(false, false, 0, 1, 0)
    camera = nil
    cameraProp = nil
    freecamEnabled = true
    
    if useEffect then
        SetTimecycleModifier("default")
        SetTimecycleModifierStrength(0.0)
    end
    
    if opened then
        setFullOpacity(true)
    end
end

local function handleCameraControls()
    currentFov = GetCamFov(camera)
    
    if IsControlJustPressed(0, 15) then
        if currentFov <= minFov then
            return
        end
        SetCamFov(camera, currentFov - fovSensitivity)
    end
    
    if IsControlJustPressed(0, 14) then
        if currentFov >= maxFov then
            return
        end
        SetCamFov(camera, currentFov + fovSensitivity)
    end
    
    if IsControlJustPressed(0, 19) then
        freecamEnabled = not freecamEnabled
    end
    
    if IsControlJustPressed(0, 194) then
        stopCamera()
    end
    
    if IsControlJustPressed(0, 176) then
        local ped = PlayerPedId()
        PlaySoundFrontend(1, "ON", "NOIR_FILTER_SOUNDS", true)
        FreezeEntityPosition(ped, true)
        local promise = takeScreenshot()
        Citizen.Await(promise)
        promise:next(function(imageUrl)
            debugPrint(string.format("Promise succesfully returned the image link: %s", imageUrl))
            SendNUIMessage({
                action = "setGalleryImage",
                data = imageUrl
            })
            stopCamera()
        end)
    end
end

local function handleFreecam()
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, not freecamEnabled)
    
    if freecamEnabled then
        local fovMultiplier = 51.5 * 0.5 - 3.0
        fovMultiplier = 0.010309278350515464 * fovMultiplier
        local mouseX = GetDisabledControlNormal(0, 220)
        local mouseY = GetDisabledControlNormal(0, 221)
        local camRot = GetCamRot(camera, 2)
        
        if mouseX ~= 0.0 or mouseY ~= 0.0 then
            local newZ = camRot.z + (mouseX * -1.0 * 8.0 * (fovMultiplier + 0.1))
            local newX = math.max(math.min(20.0, camRot.x + (mouseY * -1.0 * 8.0 * (fovMultiplier + 0.1))), -89.5)
            SetCamRot(camera, newX, 0.0, newZ, 2)
        end
    end
    
    SetEntityRotation(ped, 0, 0, new_z or GetEntityHeading(ped), 2, true)
end

CreateThread(function()
    local ped = PlayerPedId()
    while true do
        local waitTime = 2000
        if camera ~= nil then
            local scaleform = createInstructionalButtons("instructional_buttons")
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            
            if not IsEntityPlayingAnim(ped, animationDict, animation, 3) then
                TaskPlayAnim(ped, animationDict, animation, 1.0, -1, -1, 50, 0, 0, 0, 0)
            end
            
            handleFreecam()
            handleCameraControls()
            waitTime = 5
        end
        Wait(waitTime)
    end
end)

RegisterNuiCallback("ToggleCameraMode", function(data, callback)
    startCamera()
    setFullOpacity(false)
    callback("ok")
end)

AddEventHandler("gameEventTriggered", function(eventName, eventData)
    if eventName ~= "CEventNetworkEntityDamage" then
        return
    end
    
    local ped = PlayerPedId()
    local victim = eventData[1]
    local isDead = eventData[6]
    
    if isDead == 1 and victim == ped then
        stopCamera()
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    stopCamera(true)
end)
