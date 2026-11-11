Minigame = {
    ActivePromise = nil,

    Start = function()
        if Minigame.ActivePromise then return end
        local skill = lib.Framework.Callbacks.Trigger('peuren_chopshop:GetPlayerSkill', 'hacking')
        if not skill then return end
        local numbers = Config.Skills['hacking'].Levels[skill.Level].numbers
        local count = math.random(numbers.min, numbers.max)
        local completeTime = Config.Skills['hacking'].Levels[skill.Level].completeTime 

        ToggleNuiFrame(true)
        SendUIMessage("openPage", {
            page = "hacking",
            options = {
                count = count,
                completeTime = completeTime
            }
        })
        Minigame.ActivePromise = promise:new()
        return Citizen.Await(Minigame.ActivePromise)
    end,

    RadarHandler = function()
        Citizen.CreateThread(function()
            local isDrawn = false
            while Radar.isActive do
                if Radar.inZone and not isDrawn then
                    lib.TextUI.Draw(lib.Locale('radar_start'))
                    isDrawn = true
                elseif not Radar.inZone and isDrawn then
                    lib.TextUI.Stop()
                    isDrawn = false
                end
                Citizen.Wait(1000)
            end
            lib.TextUI.Stop()
        end)
    end
}

RegisterNuiCallback("failedHacking", function(data, cb)
    lib.TextUI.Stop()
    Minigame.ActivePromise:resolve(false)
    Minigame.ActivePromise = nil
    lib.Framework.Callbacks.Trigger('peuren_chopshop:SetPlayerSkill', 'hacking', false)
    ToggleNuiFrame(false)
    cb(true)
end)

RegisterNuiCallback("successHacking", function(data, cb)
    lib.TextUI.Stop()
    cb(true)
    Minigame.ActivePromise:resolve(true)
    Minigame.ActivePromise = nil
    lib.Framework.Callbacks.Trigger('peuren_chopshop:SetPlayerSkill', 'hacking', true)

    if Jobs.Data.dealer then 
        lib.Framework.Callbacks.Trigger('peuren_chopshop:AddTaskProgress', Jobs.Data.dealer, 'hacking', 1)
    end

    ToggleNuiFrame(false)
end)

function ToggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendUIMessage('setVisible', shouldShow)
    if not shouldShow then
        TriggerScreenblurFadeOut(500)
        SendUIMessage('openPage', false)
        if (Minigame.ActivePromise) then
            Minigame.ActivePromise:resolve(false)
            Minigame.ActivePromise = nil
        end
    else
        TriggerScreenblurFadeIn(500)
        SendUIMessage("setSettings", {
            locale = {
                time_left = lib.Locale("ui_time_left")
            }
        })
    end
end

function SendUIMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

RegisterNUICallback('hide', function(_, cb)
    ToggleNuiFrame(false)
    cb(true)
end)