-- Flag to prevent multiple removal operations at once
local IsCurrentlyRemoving = false

--[[
    Event handler for removing the closest spray to the player.
    Finds the nearest spray within 3.0 units and starts the removal process.
]]
RegisterNetEvent('rcore_spray:removeClosestSpray')
AddEventHandler('rcore_spray:removeClosestSpray', function()
    if IsCurrentlyRemoving then 
        return 
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local closestSprayLoc = nil
    local closestSprayDist = nil

    -- Animation dictionary and name for the removal animation
    local animDict = 'timetable@maid@cleaning_window@idle_a'
    local animName = 'idle_a'

    for _, spray in pairs(SPRAYS) do
        local sprayPos = spray.location
        local dist = #(sprayPos - coords)

        if dist < 3.0 and (not closestSprayDist or closestSprayDist > dist) then
            closestSprayLoc = sprayPos
            closestSprayDist = dist
        end
    end

    if closestSprayLoc then
        local ragProp = CreateSprayRemoveProp(ped)

        TriggerServerEvent('rcore_spray:onSprayRemoveStarted', closestSprayLoc)
        TriggerEvent('rcore_spray:onSprayRemoveStarted', closestSprayLoc)

        IsCurrentlyRemoving = true
        CancellableProgress(
            Config.SPRAY_REMOVE_DURATION, 
            animDict, 
            animName, 
            1,
            function()
                IsCurrentlyRemoving = false
                RemoveSprayRemoveProp(ragProp)
                TriggerServerEvent('rcore_spray:remove', closestSprayLoc)
            end, 
            function()
                IsCurrentlyRemoving = false
                RemoveSprayRemoveProp(ragProp)
            end
        )
    else
        TriggerEvent('chat:addMessage', {
            template = '<div style="background: rgb(180, 136, 29); color: rgb(255, 255, 255); padding: 5px;">{0}</div>',
            args = {Config.Text.NO_SPRAY_NEARBY}
        })
    end
end)

--[[
    Creates and attaches a rag prop to the player's hand for the removal animation.
    
    @param ped: The player ped entity
    @return: The created prop entity
]]
function CreateSprayRemoveProp(ped)
    -- Create the rag prop object
    local ragProp = CreateObject(
        `p_loose_rag_01_s`,
        0.0, 0.0, 0.0,
        true, false, false
    )

    -- Attach to player's hand (bone index 28422 = SKEL_R_Hand)
    -- Position and rotation offsets (all zeros for default positioning)
    local attachX = 0.0
    local attachY = 0.0
    local attachZ = 0.0
    local attachRotX = 0.0
    local attachRotY = 0.0
    local attachRotZ = 0.0
    
    AttachEntityToEntity(
        ragProp, 
        ped, 
        GetPedBoneIndex(ped, 28422), 
        attachX, attachY, attachZ, 
        attachRotX, attachRotY, attachRotZ, 
        true, true, false, true, 1, true
    )

    return ragProp
end

--[[
    Safely removes the rag prop entity after the removal animation.
    Ensures proper network control before deletion.
    
    @param ent: The entity to remove
]]
function RemoveSprayRemoveProp(ent)
    -- Request network control if we don't own the entity
    if NetworkGetEntityOwner(ent) ~= PlayerId() then
        NetworkRequestControlOfEntity(ent)
        Wait(500)
    end

    DeleteEntity(ent)
end