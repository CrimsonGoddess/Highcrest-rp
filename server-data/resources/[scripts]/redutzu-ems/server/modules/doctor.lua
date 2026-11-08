Statuses = {}
Duties = {}
Employees = {}

function GetStatus(source)
    if not Statuses[source] then
        Statuses[source] = "0"
    end
    return Statuses[source]
end

exports("GetDoctorStatus", function(source)
    return Statuses[source] or nil
end)

function SetStatus(source, status)
    Statuses[source] = tostring(status)
end

exports("SetDoctorStatus", function(source, status)
    local validStatuses = array.keys(Config.Statuses)
    if not table.includes(validStatuses, status) then
        error("Invalid status passed in SetDoctorStatus export")
        return
    end
    Statuses[source] = status
end)

function IsDuty(source)
    if not Duties[source] then
        if Config.Framework == "qb-core" or Config.Framework == "qbox" then
            local playerData = Framework.GetPlayerData(source)
            Duties[source] = playerData and playerData.PlayerData and playerData.PlayerData.job and playerData.PlayerData.job.onduty or false
        else
            Duties[source] = false
        end
    end
    return Duties[source]
end

exports("IsDuty", function(source)
    return Duties[source] or false
end)

function SetDuty(source, duty)
    if Config.Framework == "qb-core" or Config.Framework == "qbox" then
        local playerData = Framework.GetPlayerData(source)
        playerData.Functions.SetJobDuty(duty)
    end
    Duties[source] = duty
    TriggerClientEvent("redutzu-ems:client:setPlayerDuty", source, duty)
end

exports("SetDuty", SetDuty)

if Config.Framework == "qb-core" then
    RegisterNetEvent("QBCore:Server:OnJobUpdate", function(source, jobData)
        Duties[source] = jobData.onduty
        TriggerClientEvent("redutzu-ems:client:setPlayerDuty", source, jobData.onduty)
    end)
elseif Config.Framework == "qbox" then
    RegisterNetEvent("QBCore:Server:SetDuty", function(source, duty)
        Duties[source] = duty
        TriggerClientEvent("redutzu-ems:client:setPlayerDuty", source, duty)
    end)
end

if Config.Activity.Enabled then
    local activityData = {}
    
    local function clockOut(playerSource)
        playerSource = playerSource or source
        local data = activityData[playerSource]
        if not data then
            return
        end
        if data.amount > 0 then
            local identifier = Framework.GetPlayerIdentifier(playerSource)
            local hours = data.amount / 60
            MySQL.Sync.insert("INSERT INTO ems_activity (identifier, clockIn, amount) VALUES (:identifier, :clockIn, :amount)", {
                identifier = identifier,
                clockIn = data.clockIn,
                amount = hours
            })
            activityData[playerSource] = nil
        end
    end
    
    RegisterNetEvent("redutzu-ems:server:updatePlayerActivity", function()
        local source = source
        local data = activityData[source]
        if not data then
            local clockInTime = os.date("%c")
            activityData[source] = {
                clockIn = clockInTime,
                amount = Config.Activity.IncreaseInterval
            }
        else
            data.amount = data.amount + Config.Activity.IncreaseInterval
        end
        debugPrint(string.format("Activity time updated for source ^2%s^0. Current value: ^2%s^0 minutes", source, activityData[source].amount / 60))
    end)
    
    RegisterNetEvent("redutzu-ems:server:clockOut", function(source)
        clockOut(source)
    end)
    
    AddEventHandler("playerDropped", function()
        local source = source
        if IsDuty(source) then
            clockOut(source)
            debugPrint(string.format("[^2Leaving^0] Auto clock-out player with source ^2%s^0 because he was on-duty!", source))
        end
    end)
end

Framework.RegisterCallback("ChangeRank", function(source, callback, data)
    local playerIdentifier = Framework.GetPlayerIdentifier(source)
    local targetSource = Framework.GetSourceFromIdentifier(data.identifier)
    
    if data.identifier ~= playerIdentifier then
        if targetSource then
            local targetJob = Framework.GetPlayerJob(targetSource)
            Framework.SetPlayerJob(targetSource, targetJob.name, data.grade)
        end
        
        local jobs = Framework.GetJobs()
        local jobData = jobs[data.job]
        local newJob = {
            name = data.job,
            type = jobData.type,
            label = jobData.label,
            onduty = jobData.defaultDuty,
            isboss = jobData.grades[data.grade] and jobData.grades[data.grade].isboss or false,
            payment = jobData.grades[data.grade].payment,
            grade = {
                name = jobData.grades[data.grade].name,
                level = tonumber(data.grade)
            }
        }
        
        if not Config.UseExistentValues then
            MySQL.Sync.execute("UPDATE ems_citizens SET job = :job WHERE identifier = :identifier", {
                job = json.encode({
                    name = data.job,
                    label = newJob.label,
                    grade = newJob.grade.name
                }),
                identifier = data.identifier
            })
        else
            if Config.Framework == "qb-core" or Config.Framework == "qbox" then
                MySQL.Sync.execute("UPDATE players SET job = :job WHERE citizenid = :identifier", {
                    job = json.encode(newJob),
                    identifier = data.identifier
                })
            elseif Config.Framework == "esx" then
                MySQL.Sync.execute("UPDATE users SET job = :job, job_grade = :grade WHERE identifier = :identifier", {
                    job = data.job,
                    grade = data.grade,
                    identifier = data.identifier
                })
            end
        end
    end
    callback("ok")
end)

Framework.RegisterCallback("HireCitizen", function(source, callback, identifier)
    local targetSource = Framework.GetSourceFromIdentifier(identifier)
    local defaultJob = Framework.GetDefaultAmbulanceJob(targetSource)
    
    if targetSource then
        Framework.SetPlayerJob(targetSource, defaultJob.name, defaultJob.grade)
    else
        if not Config.UseExistentValues then
            local jobData = Framework.GetJobData(defaultJob.name)
            MySQL.Sync.execute("UPDATE ems_citizens SET job = :job WHERE identifier = :identifier", {
                job = json.encode({
                    name = defaultJob.name,
                    label = jobData.name,
                    grade = array.find(jobData.grades, function(g)
                        return g.level == defaultJob.grade
                    end) and array.find(jobData.grades, function(g)
                        return g.level == defaultJob.grade
                    end).name or nil
                }),
                identifier = identifier
            })
        else
            if Config.Framework == "qb-core" or Config.Framework == "qbox" then
                MySQL.Sync.execute("UPDATE players SET job = :job WHERE citizenid = :identifier", {
                    job = json.encode(defaultJob),
                    identifier = identifier
                })
            elseif Config.Framework == "esx" then
                MySQL.Sync.execute("UPDATE users SET job = :job, job_grade = :grade WHERE identifier = :identifier", {
                    job = defaultJob.name,
                    grade = defaultJob.grade,
                    identifier = identifier
                })
            end
        end
    end
    callback("ok")
end)

Framework.RegisterCallback("FireEmployee", function(source, callback, data)
    local playerIdentifier = Framework.GetPlayerIdentifier(source)
    local playerJob = Framework.GetPlayerJob(source)
    
    if not HasPermission(source, "administration.management.employee.fire") then
        debugPrint(string.format("Source ^2%s^0 tried to fire an employee without permissions", source))
        return
    end
    
    if data.identifier ~= playerIdentifier then
        if tonumber(data.grade) > tonumber(playerJob.grade) then
            callback(false)
            return
        end
        
        local targetSource = Framework.GetSourceFromIdentifier(data.identifier)
        local defaultJob = Framework.GetUnemployedJob(targetSource)
        
        if targetSource then
            Framework.SetPlayerJob(targetSource, defaultJob.name, defaultJob.grade)
        end
        
        if not Config.UseExistentValues then
            local jobData = Framework.GetJobData(defaultJob.name)
            MySQL.Sync.execute("UPDATE players SET job = :job WHERE identifier = :identifier", {
                job = json.encode({
                    label = jobData.name,
                    name = defaultJob.name,
                    grade = array.find(jobData.grades, function(g)
                        return g.level == defaultJob.grade
                    end) and array.find(jobData.grades, function(g)
                        return g.level == defaultJob.grade
                    end).name or nil
                }),
                identifier = data.identifier
            })
        else
            if Config.Framework == "qb-core" or Config.Framework == "qbox" then
                MySQL.Sync.execute("UPDATE players SET job = :job WHERE citizenid = :identifier", {
                    job = json.encode(defaultJob),
                    identifier = data.identifier
                })
            elseif Config.Framework == "esx" then
                MySQL.Sync.execute("UPDATE users SET job = :job, job_grade = :grade WHERE identifier = :identifier", {
                    job = defaultJob.name,
                    grade = defaultJob.grade,
                    identifier = data.identifier
                })
            end
        end
        return callback(true)
    else
        Framework.Notify(source, Locales.fire_self, "error")
        return
    end
end)

Framework.RegisterCallback("GetDoctorDuty", function(source, callback)
    callback(IsDuty(source))
end)

Framework.RegisterCallback("GetProfileInfo", function(source, callback)
    local firstName, lastName = Framework.GetCharacterName(source)
    local job = Framework.GetPlayerJob(source)
    
    local profile = {
        name = firstName .. " " .. lastName,
        job = job.label,
        rank = job.grade_label,
        duty = IsDuty(source),
        status = GetStatus(source)
    }
    callback(profile)
end)

Framework.RegisterCallback("UpdateProfileValue", function(source, callback, data)
    if data.type == "duty" then
        SetDuty(source, json.decode(data.value))
    elseif data.type == "status" then
        SetStatus(source, data.value)
    end
    callback("ok")
end)

function GetOnlineDoctors()
    local doctors = {}
    for i = 1, #Config.WhitelistedJobs do
        local jobPlayers = Framework.GetJobPlayers(Config.WhitelistedJobs[i])
        for _, player in ipairs(jobPlayers) do
            local source = player.source
            local firstName, lastName = Framework.GetCharacterName(source)
            local identifier = Framework.GetPlayerIdentifier(source)
            local job = Framework.GetPlayerJob(source)
            local ped = GetPlayerPed(source)
            local coords = GetEntityCoords(ped)
            
            doctors[#doctors + 1] = {
                image = "",
                name = firstName .. " " .. lastName,
                grade = job.grade,
                job = job.label,
                rank = job.grade_label,
                phoneNumber = Framework.GetPhoneNumberByIdentifier(identifier) or " ",
                identifier = identifier,
                duty = IsDuty(source),
                status = GetStatus(source),
                coords = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z
                }
            }
        end
    end
    return doctors
end

Framework.RegisterCallback("GetOnlineDoctors", function(source, callback)
    callback(GetOnlineDoctors())
end)

function Employees.single(identifier)
    local selection = nil
    
    if not Config.UseExistentValues then
        selection = [[
            CONCAT(ems_citizens.firstname, ' ', ems_citizens.lastname) AS name,
            JSON_VALUE(ems_citizens.job, '$.label') AS job,
            JSON_VALUE(ems_citizens.job, '$.name') AS jobName,
            JSON_VALUE(ems_citizens.job, '$.grade') AS grade_label,
            %s
        ]]
    else
        if Config.Framework == "qb-core" or Config.Framework == "qbox" then
            selection = [[
            CONCAT(JSON_VALUE(players.charinfo, '$.firstname'), ' ', JSON_VALUE(players.charinfo, '$.lastname')) AS name,
            JSON_VALUE(players.job, '$.label') AS job,
            JSON_VALUE(players.job, '$.name') AS jobName,
            JSON_VALUE(players.job, '$.grade.level') AS grade,
            JSON_VALUE(players.job, '$.grade.name') AS grade_label,
            %s
        ]]
        elseif Config.Framework == "esx" then
            selection = "CONCAT(users.firstname, ' ', users.lastname) AS name, users.job AS jobName, users.job_grade AS grade, %s"
        end
    end
    
    local activitySubquery = string.format([[
(
            SELECT
                CONCAT('[', GROUP_CONCAT(
                    JSON_OBJECT('hours', ems_activity.amount / 60, 'clockIn', ems_activity.clockIn, 'clockOut', ems_activity.clockOut)),
                ']')
            FROM
                ems_activity
            WHERE
                ems_activity.identifier = %s.%s
        ) AS activity
    ]], citizens.table, citizens.identifier)
    
    local query = string.format("SELECT %s FROM %s WHERE %s = ?", string.format(selection, activitySubquery), citizens.table, citizens.identifier)
    local result = MySQL.Sync.fetchSingle(query, {identifier})
    
    result.activity = json.decode(result.activity) or {}
    
    if Config.Framework == "esx" then
        local jobData = Framework.GetJobData(result.jobName)
        result.job = jobData.name
        local grade = array.find(jobData.grades, function(g)
            return g.level == result.grade
        end)
        if grade then
            result.grade_label = grade.name
        end
    else
        if not Config.UseExistentValues then
            local jobData = Framework.GetJobData(result.jobName)
            local grade = array.find(jobData.grades, function(g)
                return g.name == result.grade_label
            end)
            if grade then
                result.grade = grade.level
            end
        end
    end
    
    return result
end

function SearchRecruits(query)
    local selection = nil
    
    if not Config.UseExistentValues then
        selection = [[
            ems_citizens.identifier,
            ems_citizens.firstname,
            ems_citizens.lastname,
            JSON_VALUE(ems_citizens.job, '$.label') AS job,
            JSON_VALUE(ems_citizens.job, '$.grade') AS job_grade
        ]]
    else
        if Config.Framework == "qb-core" or Config.Framework == "qbox" then
            selection = [[
            players.citizenid AS identifier,
            JSON_VALUE(players.charinfo, '$.firstname') AS firstname,
            JSON_VALUE(players.charinfo, '$.lastname') AS lastname,
            JSON_VALUE(players.job, '$.label') AS job,
            JSON_VALUE(players.job, '$.grade.name') AS job_grade
        ]]
        elseif Config.Framework == "esx" then
            selection = "users.identifier, users.firstname, users.lastname, users.job, users.job_grade"
        end
    end
    
    if Config.Phone == "default" then
        if Config.UseExistentValues then
            if Config.Framework == "qb-core" or Config.Framework == "qbox" then
                selection = selection .. ", JSON_VALUE(players.charinfo, '$.phone') AS phone_number"
            elseif Config.Framework == "esx" then
                selection = selection .. ", phone_number"
            end
        end
    end
    
    local results = MySQL.Sync.fetchAll(string.format("SELECT %s FROM %s WHERE %s LIKE :query AND %s NOT IN (:jobs)", selection, citizens.table, citizens.name, citizens.job), {
        jobs = Config.WhitelistedJobs,
        query = "%" .. query .. "%"
    })
    
    for i = 1, #results do
        if Config.Framework == "esx" then
            local jobData = Framework.GetJobData(results[i].job)
            results[i].job = jobData.name
            local grade = array.find(jobData.grades, function(g)
                return g.level == results[i].job_grade
            end)
            if grade then
                results[i].job_grade = grade.name
            end
        end
        results[i].phone_number = Framework.GetPhoneNumberByIdentifier(results[i].identifier)
    end
    
    return results
end

function GetAllDoctors(query)
    local selection = nil
    
    if not Config.UseExistentValues then
        selection = "ems_citizens.identifier, ems_citizens.firstname, ems_citizens.lastname"
    else
        if Config.Framework == "qb-core" or Config.Framework == "qbox" then
            selection = [[
            players.citizenid AS identifier,
            JSON_VALUE(players.charinfo, '$.firstname') AS firstname,
            JSON_VALUE(players.charinfo, '$.lastname') AS lastname
        ]]
        elseif Config.Framework == "esx" then
            selection = "users.identifier, users.firstname, users.lastname"
        end
    end
    
    local results = MySQL.Sync.fetchAll(string.format("SELECT %s FROM %s WHERE %s LIKE :query AND %s IN (:jobs) LIMIT :limit", selection, citizens.table, citizens.name, citizens.job), {
        query = "%" .. query .. "%",
        jobs = Config.WhitelistedJobs,
        limit = Config.Settings.MaximumResults
    })
    
    return results
end
