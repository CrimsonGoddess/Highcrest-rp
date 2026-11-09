--[[
    Secret Sauce - Spray Rendering and Camera Computation
    This module handles the visual rendering of sprays using scaleforms
    and computes the proper rotation/position through camera manipulation.
]]

--[[
    Computes the final rotation and position for a spray through camera manipulation.
    Uses a temporary object and camera to calculate the optimal spray orientation.
    
    @param sprayLocation: vector3 - The desired location for the spray
    @param sprayRotation: vector3 - The normal vector of the surface
    @param sprayScale: number - The scale of the spray
    @return: computedPosition (vector3), computedRotation (vector3)
]]
function GetRotationThruCamera(sprayLocation, sprayRotation, sprayScale)
    -- Adjust the camera target point slightly above the spray location
    local cameraTargetOffset = sprayLocation - sprayRotation * 10
    local cameraPosition = sprayLocation
    
    -- Set up the camera
    SetCamCoord(rotCam, cameraPosition.x, cameraPosition.y, cameraPosition.z)
    PointCamAtCoord(rotCam, cameraTargetOffset.x, cameraTargetOffset.y, cameraTargetOffset.z)
    SetCamActive(rotCam, true)
    Citizen.Wait(0)
    
    -- Get the camera rotation
    local cameraRotation = GetCamRot(rotCam, 2)
    
    -- Deactivate the camera
    SetCamActive(rotCam, false)
    
    -- If using legacy rendering, return early with camera rotation
    if UseLegacyRendering then
        return sprayLocation, cameraRotation
    end
    
    -- For advanced rendering: Create a temporary object to calculate precise positioning
    -- Using prop_weed_02 as a placeholder object (hash: 974883178)
    local tempObject = CreateObject(974883178, sprayLocation.x, sprayLocation.y, sprayLocation.z, false, false, false)
    
    -- Position and rotate the object at the spray location
    SetEntityCoords(tempObject, sprayLocation.x, sprayLocation.y, sprayLocation.z, false, false, false, true)
    SetEntityRotation(tempObject, cameraRotation.x, cameraRotation.y, cameraRotation.z, 2, false)
    
    -- Get quaternion rotation and apply 180-degree rotation around X-axis
    local qx, qy, qz, qw = GetEntityQuaternion(tempObject)
    local objectQuaternion = quat(qw, qx, qy, qz)
    local rotationQuat = quat(180, vector3(1, 0, 0))
    local finalQuaternion = objectQuaternion * rotationQuat
    
    -- Apply the rotated quaternion
    SetEntityQuaternion(tempObject, finalQuaternion.x, finalQuaternion.y, finalQuaternion.z, finalQuaternion.w)
    
    -- Get the offset position (centering the spray)
    local offsetPosition = GetOffsetFromEntityInWorldCoords(tempObject, -sprayScale / 2, 0, -sprayScale / 2)
    local finalRotation = GetEntityRotation(tempObject)
    
    -- Clean up temporary object
    DeleteEntity(tempObject)
    
    return offsetPosition, finalRotation
end

--[[
    Draws a spray on the screen using scaleform rendering.
    Handles both text and image sprays with proper formatting and positioning.
    
    @param scaleformHandle: The scaleform handle to use for rendering
    @param sprayData: Table containing spray information
        - location: vector3 - Position where spray should appear
        - realLocation: vector3 - Computed final position (optional, uses currentComputedLocation if not provided)
        - rotation: vector3 - Surface normal vector
        - realRotation: vector3 - Computed final rotation (optional, uses currentComputedRotation if not provided)
        - scale: number - Scale of the spray
        - text: string - Text content (for text sprays)
        - font: string - Font name (for text sprays)
        - color: string - Hex color code (for text sprays)
        - imageDict: string - Texture dictionary (for image sprays)
        - image: string - Texture name (for image sprays)
]]
function DrawSpray(scaleformHandle, sprayData)
    -- Validate scaleform handle
    if not scaleformHandle then
        return
    end
    
    if not HasScaleformMovieLoaded(scaleformHandle) then
        return
    end
    
    -- Don't render if pause menu is active
    if IsPauseMenuActive() then
        return
    end
    
    local sprayColor = sprayData.color
    
    -- Push scaleform function to set player name (used for spray text/image)
    PushScaleformMovieFunction(scaleformHandle, "SET_PLAYER_NAME")
    
    -- Handle image sprays
    if sprayData.imageDict then
        -- Load texture dictionary if not already loaded
        if not HasStreamedTextureDictLoaded(sprayData.imageDict) then
            RequestStreamedTextureDict(sprayData.imageDict, true)
        end
        
        -- Get image dimensions from config
        local imageConfig = FastImageMap[sprayData.imageDict .. sprayData.image]
        local imageWidth = 256
        local imageHeight = 256
        
        if imageConfig then
            imageWidth = imageConfig.width
            imageHeight = imageConfig.height
        end
        
        -- Calculate scaled width (maintain aspect ratio)
        local scaledWidth = tonumber(math.floor(imageWidth * 1.775))
        
        -- Create HTML image tag for scaleform
        local imageTag = string.format(
            "<img src='img://%s/%s' height='%d' width='%d'/>",
            sprayData.imageDict,
            sprayData.image,
            imageHeight,
            scaledWidth
        )
        
        PushScaleformMovieFunctionParameterString(imageTag)
    else
        -- Handle text sprays
        -- Create HTML font tag for scaleform
        local textTag = string.format(
            "<FONT color='#%s' FACE='%s'>%s</FONT>",
            sprayColor,
            sprayData.font,
            sprayData.text
        )
        
        PushScaleformMovieFunctionParameterString(textTag)
    end
    
    PopScaleformMovieFunctionVoid()
    
    -- Set up computed position/rotation for rendering
    if not sprayData.realRotation then
        wantedSprayLocation = sprayData.location
        wantedSprayRotation = sprayData.rotation
        wantedSprayScale = sprayData.scale
    end
    
    -- Render the scaleform
    local finalPosition = sprayData.realLocation or currentComputedLocation
    local finalRotation = sprayData.realRotation or currentComputedRotation
    local uniformScale = 1.0
    
    if UseLegacyRendering then
        -- Legacy non-additive rendering (sprays look more "out of place")
        DrawScaleformMovie_3dNonAdditive(
            scaleformHandle,
            finalPosition.x, finalPosition.y, finalPosition.z,
            finalRotation.x, finalRotation.y, finalRotation.z,
            uniformScale, uniformScale, uniformScale,
            sprayData.scale, sprayData.scale, uniformScale,
            2
        )
    else
        -- Modern additive rendering (sprays blend better into walls)
        DrawScaleformMovie_3d(
            scaleformHandle,
            finalPosition.x, finalPosition.y, finalPosition.z,
            finalRotation.x, finalRotation.y, finalRotation.z,
            uniformScale, uniformScale, uniformScale,
            sprayData.scale, sprayData.scale, uniformScale,
            2
        )
  end
end

--[[
    Initializes the NUI (HTML/JS interface) with configuration data.
    Sends font, image, color, and translation data to the UI.
    
    @return: The configuration data table that was sent
]]
function InitializeNui()
    local configData = {
        fonts = FONTS,
        images = IMAGES,
        resourceName = GetCurrentResourceName(),
        wordBlacklist = Config.Blacklist,
        sprayCharLimit = Config.SPRAY_CHAR_LIMIT,
        translation = Config.Text.NUI_TEXT,
        disableText = Config.DisableText
    }
    
    SendNUIMessage({
        type = "setData",
        data = configData
    })
    
    return configData
end

-- Initialize NUI after collision loading
Citizen.CreateThread(function()
    -- Wait for collision to load around player
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        Citizen.Wait(500)
    end
    
    -- Initialize NUI after a short delay
    Citizen.SetTimeout(500, function()
        InitializeNui()
    end)
    
    -- Initialize again after a longer delay (fallback)
    Citizen.SetTimeout(2000, function()
        InitializeNui()
    end)
end)

-- NUI callback: Initialize request
RegisterNUICallback('initialize', function(data, cb)
    Wait(500)
    local configData = InitializeNui()
    cb(configData)
end)

-- Network event: Remove spray at specified position
RegisterNetEvent('rcore_spray:removeSpray')
AddEventHandler('rcore_spray:removeSpray', function(position)
    -- Find and remove spray from local SPRAYS table
    for idx, spray in pairs(SPRAYS) do
        if spray.location.x == position.x and 
           spray.location.y == position.y and 
           spray.location.z == position.z then
            table.remove(SPRAYS, idx)
          break
      end
    end
end)

-- Network event: Add spray to local table
RegisterNetEvent('rcore_spray:addSpray')
AddEventHandler('rcore_spray:addSpray', function(sprayData)
    -- Find first available index and add spray
    local idx = 1
  while true do
        if not SPRAYS[idx] then
            SPRAYS[idx] = sprayData
      break
    else
            idx = idx + 1
        end
    end
end)

--[[
    Converts a heading angle (in degrees) to direction vectors for frustum bounds.
    Creates left and right prongs of the camera frustum.
    
    @param position: vector3 - Base position
    @param heading: number - Camera heading in degrees
    @return: finalCamPos (vector3), leftProng (vector3), rightProng (vector3)
]]
function RotationToDirectionVector(position, heading)
    -- Calculate forward direction vector (3 units, offset by 90 degrees)
    heading = heading + 90
    local forwardVector = vector3(
        math.cos(math.rad(heading)),
        math.sin(math.rad(heading)),
        0.0
    ) * 3
    
    -- Calculate left prong (45 degrees to the left, 200 units long)
    local leftHeading = heading - 45
    local leftProng = vector3(
        math.cos(math.rad(leftHeading)),
        math.sin(math.rad(leftHeading)),
        0.0
    ) * 200
    
    -- Calculate right prong (45 degrees to the right, 200 units long)
    local rightHeading = heading + 45
    local rightProng = vector3(
        math.cos(math.rad(rightHeading)),
        math.sin(math.rad(rightHeading)),
        0.0
    ) * 200
    
    -- Return adjusted camera position (moved back by forward vector) and prongs
    return position - forwardVector, leftProng, rightProng
end

--[[
    Checks if a point is within the camera's frustum (viewing area).
    Used for frustum culling optimization - only render sprays that are visible.
    
    @param cameraPosition: vector3 - Camera position
    @param leftBound: vector3 - Left bound of frustum
    @param rightBound: vector3 - Right bound of frustum
    @param testPoint: vector3 - Point to test
    @return: boolean - true if point is in frustum
]]
function IsInFrustrum(cameraPosition, leftBound, rightBound, testPoint)
    return PointInTriangle(testPoint, cameraPosition, cameraPosition + leftBound, cameraPosition + rightBound)
end

--[[
    Calculates the sign of a point relative to a line segment.
    Used for point-in-triangle tests.
    
    @param point: vector3 - Point to test
    @param lineStart: vector3 - Start of line
    @param lineEnd: vector3 - End of line
    @return: number - Sign value (positive/negative)
]]
function sign(point, lineStart, lineEnd)
    return (point.x - lineEnd.x) * (lineStart.y - lineEnd.y) - (lineStart.x - lineEnd.x) * (point.y - lineEnd.y)
end

--[[
    Tests if a point is inside a triangle using the barycentric coordinate method.
    
    @param testPoint: vector3 - Point to test
    @param v1, v2, v3: vector3 - Triangle vertices
    @return: boolean - true if point is inside triangle
]]
function PointInTriangle(testPoint, v1, v2, v3)
    local sign1 = sign(testPoint, v1, v2)
    local sign2 = sign(testPoint, v2, v3)
    local sign3 = sign(testPoint, v3, v1)
    
    -- Point is inside if all signs are the same (all positive or all negative)
    local hasNegative = (sign1 < 0) or (sign2 < 0) or (sign3 < 0)
    local hasPositive = (sign1 > 0) or (sign2 > 0) or (sign3 > 0)
    
    return not (hasNegative and hasPositive)
end

--[[
    Computes frustum parameters from gameplay camera.
    Returns camera position and left/right bounds for frustum culling.
    
    @return: cameraPosition (vector3), leftBound (vector3), rightBound (vector3)
]]
function ComputeGameplayFrustrumParams()
    -- If frustum culling is disabled, return nil values
    if not FrustumCullSprays then
        return nil, nil, nil
    end
    
    -- Get camera rotation and position
    local cameraRotation = GetGameplayCamRot(2)
    local cameraPosition = GetGameplayCamCoord()
    local playerPosition = GetEntityCoords(PlayerPedId())
    
    -- Adjust camera position to player's Z level
    cameraPosition = vector3(cameraPosition.x, cameraPosition.y, playerPosition.z)
    
    -- Calculate frustum bounds based on camera heading
    return RotationToDirectionVector(cameraPosition, cameraRotation.z)
end
