local onDuty = false

RegisterNetEvent("redutzu-ems:client:setPlayerDuty", function(duty)
    if Config.Activity.Enabled and not duty then
        TriggerServerEvent("redutzu-ems:server:clockOut")
    end
    onDuty = duty
end)

RegisterNetEvent("redutzu-ems:client:onPlayerLoaded", function()
    Framework.TriggerCallback("GetDoctorDuty", function(duty)
        onDuty = duty
    end)
end)

CreateThread(function()
    Framework.TriggerCallback("GetDoctorDuty", function(duty)
        onDuty = duty
    end)
end)

function isDoctor()
    local job = Framework.GetPlayerJob()
    return table.includes(Config.WhitelistedJobs, job.name)
end

if Config.Activity.Enabled then
    CreateThread(function()
        while true do
            if onDuty and isDoctor() then
                TriggerServerEvent("redutzu-ems:server:updatePlayerActivity")
            end
            Wait(Config.Activity.IncreaseInterval * 1000)
        end
    end)
end

RegisterNuiCallback("GetOnlineDoctors", function(data, callback)
    Framework.TriggerCallback("GetOnlineDoctors", callback)
end)
