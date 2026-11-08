local propObject = nil
local opened = false
local loaded = false

CreateThread(function()
    if Config.Keybind.Enabled then
        RegisterCommand("+keybind-ems", function()
            TriggerEvent("redutzu-ems:client:openEMS")
        end, false)
        
        RegisterKeyMapping("+keybind-ems", Config.Keybind.Description, "keyboard", Config.Keybind.Key)
    end
end)

exports("isOpened", function()
    return opened
end)

exports("open", function()
    TriggerEvent("redutzu-ems:client:openEMS")
end)

exports("close", function()
    TriggerEvent("redutzu-ems:client:closeEMS")
end)

function ToggleVisibility(visible)
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        action = "setVisibility",
        data = visible
    })
    
    if visible then
        SetNuiFocusKeepInput(visible)
        DisableControlActions()
        
        RequestDict(Config.AnimationDict)
        if not DoesAnimDictExist(Config.AnimationDict) then
            return
        end
        
        local ped = PlayerPedId()
        if not IsEntityPlayingAnim(ped, Config.AnimationDict, Config.Animation, 3) then
            TaskPlayAnim(ped, Config.AnimationDict, Config.Animation, 8.0, 8.0, -1, 50, 0, false, false, false)
        end
        
        opened = visible
        RequestProp(Config.Prop)
        local boneIndex = GetPedBoneIndex(ped, 28422)
        local coords = GetEntityCoords(ped)
        local x, y, z = table.unpack(coords)
        
        propObject = CreateObject(Config.Prop, x, y, z, true, true, true)
        AttachEntityToEntity(propObject, ped, boneIndex, 0.0, 0.0, -0.03, Config.PropRotation[1], Config.PropRotation[2], Config.PropRotation[3], true, true, false, true, 0, true)
    else
        Wait(250)
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        
        if propObject then
            if DoesEntityExist(propObject) then
                DetachEntity(propObject)
                DeleteEntity(propObject)
                DeleteObject(propObject)
                propObject = nil
            end
        end
        opened = visible
    end
end

RegisterNetEvent("redutzu-ems:client:openEMS", function()
    if not loaded then
        debugPrint("Wait for the tablet to load it's settings before opening it!")
        return
    end
    
    if not isOpenable() then
        Framework.Notify(Locales.not_openable, "error")
        return
    end
    
    Framework.TriggerCallback("isAllowed", function(allowed)
        if allowed then
            ToggleVisibility(true)
        end
    end)
end)

RegisterNetEvent("redutzu-ems:client:closeEMS", function()
    ToggleVisibility(false)
end)

RegisterNUICallback("hide", function(data, callback)
    ToggleVisibility(false)
    callback("ok")
end)

RegisterNuiCallback("GetPlayerPosition", function(data, callback)
    Framework.TriggerCallback("GetPlayerPosition", function(position)
        position.street = GetStreetNameFromCoords(position)
        callback(position)
    end)
end)

RegisterNuiCallback("SetWaypoint", function(data, callback)
    if data then
        SetNewWaypoint(data.x, data.y)
    end
    ToggleVisibility(false)
    callback("ok")
end)

RegisterNuiCallback("GetPermissions", function(data, callback)
    Framework.TriggerCallback("GetPermissions", callback)
end)

RegisterNuiCallback("GetProfileInfo", function(data, callback)
    Framework.TriggerCallback("GetProfileInfo", callback)
end)

RegisterNuiCallback("AddGalleryImage", function(data, callback)
    Framework.TriggerCallback("AddGalleryImage", callback, data)
end)

RegisterNuiCallback("UpdateProfileValue", function(data, callback)
    Framework.TriggerCallback("UpdateProfileValue", callback, data)
end)

RegisterNuiCallback("GenerateWeaponSerial", function(data, callback)
    Framework.TriggerCallback("GenerateWeaponSerial", callback, data)
end)

RegisterNuiCallback("GetSocietyFunds", function(data, callback)
    Framework.TriggerCallback("GetSocietyFunds", callback, data)
end)

RegisterNuiCallback("ChangeRank", function(data, callback)
    Framework.TriggerCallback("ChangeRank", callback, data)
end)

RegisterNuiCallback("HireCitizen", function(data, callback)
    Framework.TriggerCallback("HireCitizen", callback, data)
end)

RegisterNuiCallback("FireEmployee", function(data, callback)
    Framework.TriggerCallback("FireEmployee", callback, data)
end)

RegisterNuiCallback("UpdateGradePermissions", function(data, callback)
    Framework.TriggerCallback("UpdateGradePermissions", callback, data)
end)

RegisterNuiCallback("GetAllPermissions", function(data, callback)
    Framework.TriggerCallback("GetAllPermissions", callback, data)
end)

RegisterNuiCallback("search", function(data, callback)
    Framework.TriggerCallback("search", callback, data)
end)

RegisterNuiCallback("create", function(data, callback)
    Framework.TriggerCallback("create", callback, data)
end)

RegisterNuiCallback("update", function(data, callback)
    Framework.TriggerCallback("update", callback, data)
end)

RegisterNuiCallback("delete", function(data, callback)
    Framework.TriggerCallback("delete", callback, data)
end)

Framework.RegisterClientCallback("GetStreetName", function(source, coords, callback)
    local streetName = GetStreetNameFromCoords(coords)
    callback(streetName)
end)

RegisterNuiCallback("GetConfig", function(data, callback)
    local config = {
        debug = Config.Debug,
        jobs = Config.WhitelistedJobs,
        locale = Config.Locale,
        currency = Config.Currency,
        codes = {
            format = Config.Codes.Format,
            regex = Config.Codes.Regex
        },
        phone = {
            format = Config.PhoneNumberFormat
        },
        features = {
            alerts = {
                enabled = Config.Features.Alerts.Enabled,
                while_close = Config.Features.Alerts.WhileClosed
            },
            transparency = {
                enabled = Config.Features.Transparency.Enabled,
                control = Config.Features.Transparency.Control,
                strength = Config.Features.Transparency.Strength
            }
        },
        useExistentValues = Config.UseExistentValues,
        settings = Config.Settings,
        rankColors = Config.RankColors,
        statuses = Config.Statuses,
        templates = Config.Templates,
        permissions = permissions,
        locales = Config.Locales,
        colors = Config.Colors,
        pages = Config.Pages
    }
    callback(config)
    loaded = true
end)

RegisterNuiCallback("ToggleInputFocus", function(data, callback)
    SetNuiFocusKeepInput(not data)
    callback("ok")
end)

CreateThread(function()
    while true do
        if opened then
            if camera == nil then
                DisableControlActions()
                local ped = PlayerPedId()
                if not IsEntityPlayingAnim(ped, Config.AnimationDict, Config.Animation, 3) then
                    TaskPlayAnim(ped, Config.AnimationDict, Config.Animation, 8.0, 8.0, -1, 50, 0, false, false, false)
                end
            end
        end
        Wait(opened and 0 or 500)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    DeleteObject(propObject)
    ToggleVisibility(false)
    loaded = false
end)
