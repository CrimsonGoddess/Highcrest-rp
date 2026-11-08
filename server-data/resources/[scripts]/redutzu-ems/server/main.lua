function isDoctor(source)
    local job = Framework.GetPlayerJob(source)
    return table.includes(Config.WhitelistedJobs, job.name)
end

exports("isAllowed", isDoctor)

Framework.RegisterCallback("isAllowed", function(source, callback)
    local allowed = isDoctor(source)
    if not allowed then
        Framework.Notify(source, Locales.not_allowed, "error")
    else
        if Config.RequireDuty then
            if not IsDuty(source) then
                Framework.Notify(source, Locales.required_duty, "error")
                allowed = false
            end
        end
    end
    callback(allowed)
end)

exports("open", function(source)
    TriggerClientEvent("redutzu-ems:client:openEMS", source)
end)

function isJobWhitelisted(job)
    if type(job) == "string" then
        return table.includes(Config.WhitelistedJobs, job)
    elseif type(job) == "table" then
        for _, jobName in ipairs(job) do
            if table.includes(Config.WhitelistedJobs, jobName) then
                return true
            end
        end
        return false
    end
end

exports("isJobWhitelisted", isJobWhitelisted)

function GenerateRandomString(length)
    length = length or 5
    local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    math.randomseed(os.time())
    for i = 1, length do
        local randomIndex = math.random(1, #chars)
        result = result .. string.sub(chars, randomIndex, randomIndex)
    end
    return result
end

function GenerateUniqueId(tableName, columnName, generator)
    local isUnique = false
    local id = nil
    while not isUnique do
        id = generator()
        local query = string.format("SELECT COUNT(*) as count FROM %s WHERE %s = ?", tableName, columnName)
        local result = MySQL.Sync.fetchSingle(query, {id})
        if result and result.count == 0 then
            isUnique = true
        end
    end
    return id
end

function GenerateClause(data, exclude)
    exclude = exclude or {}
    local clause = ""
    for key, value in pairs(data) do
        if value ~= nil then
            if not table.includes(exclude, key) then
                clause = clause .. key .. " = :" .. key .. ", "
            end
        end
    end
    return string.sub(clause, 1, -3)
end

Framework.RegisterCallback("delete", function(source, callback, data)
    if data.type == "incident" then
        callback(incidents.delete(data.id))
    elseif data.type == "invoice" then
        callback(invoices.delete(data.id))
    elseif data.type == "code" then
        callback(codes.delete(data.id))
    elseif data.type == "announcement" then
        callback(announcements.delete(data.id))
    elseif data.type == "gallery" then
        callback(gallery.delete(data.id))
    end
    
    if Config.UseLogs then
        CreateLog("delete", data.type, data.id, source)
    end
end)

Framework.RegisterCallback("update", function(source, callback, data)
    if data.type == "incident" then
        callback(incidents.update(data.identifier, data.data))
    elseif data.type == "invoice" then
        callback(invoices.update(data.identifier, data.data))
    elseif data.type == "code" then
        callback(codes.update(data.identifier, data.data))
    elseif data.type == "citizen" then
        callback(citizens.update(data.identifier, data.data))
    elseif data.type == "announcement" then
        callback(announcements.update(data.identifier, data.data))
    end
    
    if Config.UseLogs then
        CreateLog("update", data.type, {
            data = data.data,
            identifier = data.identifier
        }, source)
    end
end)

Framework.RegisterCallback("create", function(source, callback, data)
    if data.type == "citizen" then
        callback(citizens.create(data.data, source))
    elseif data.type == "announcement" then
        callback(announcements.create(data.data, source))
    elseif data.type == "incident" then
        callback(incidents.create(data.data, source))
    elseif data.type == "invoice" then
        callback(invoices.create(data.data, source))
    elseif data.type == "code" then
        callback(codes.create(data.data, source))
    elseif data.type == "tag" then
        callback(tags.create(data.data, source))
    end
    
    if Config.UseLogs then
        CreateLog("create", data.type, data.data, source)
    end
end)

local function getAllPlayers()
    local players = GetPlayers()
    local result = {}
    for _, playerId in ipairs(players) do
        local id = tonumber(playerId)
        local identifier = Framework.GetPlayerIdentifier(id)
        result[#result + 1] = {
            name = GetPlayerName(id),
            identifier = identifier
        }
    end
    return result
end

local function generateFingerprint()
    return GenerateUniqueId("ems_citizens", "fingerprint", function()
        return GenerateRandomString(10)
    end)
end

local function getAllJobs()
    local jobs = Framework.GetJobs()
    local result = {}
    for jobName, jobData in pairs(jobs) do
        result[#result + 1] = {
            name = jobName,
            label = jobData.label
        }
    end
    return result
end

Framework.RegisterCallback("search", function(source, callback, data)
    if data.type == "identifiers" then
        callback(getAllPlayers())
    elseif data.type == "fingerprint" then
        callback(generateFingerprint())
    elseif data.type == "jobs" then
        callback(getAllJobs())
    elseif data.type == "bloodtypes" then
        callback(Framework.GetBloodTypes())
    elseif data.type == "incidents" then
        callback(incidents.search(data.query))
    elseif data.type == "incident" then
        callback(incidents.single(data.query))
    elseif data.type == "invoices" then
        callback(invoices.search(data.query))
    elseif data.type == "invoice" then
        callback(invoices.single(data.query))
    elseif data.type == "tags" then
        callback(tags.search(data.query, data.tagType))
    elseif data.type == "doctors" then
        callback(GetAllDoctors(data.query))
    elseif data.type == "citizens" then
        callback(citizens.search(data.query))
    elseif data.type == "citizen" then
        callback(citizens.single(data.query))
    elseif data.type == "codes" then
        callback(codes.search(data.query))
    elseif data.type == "code" then
        callback(codes.single(data.query))
    elseif data.type == "announcements" then
        callback(announcements.search(data.query))
    elseif data.type == "announcement" then
        callback(announcements.single(data.query))
    elseif data.type == "lastAnnouncement" then
        callback(announcements.last())
    elseif data.type == "job_ranks" then
        local jobData = Framework.GetJobData(data.query)
        local playerJob = Framework.GetPlayerJob(source)
        local playerGrade = playerJob and playerJob.grade or nil
        for i = 1, #jobData.grades do
            local grade = jobData.grades[i]
            grade.disabled = tonumber(grade.level) > tonumber(playerGrade)
        end
        callback(jobData.grades)
    elseif data.type == "recruits" then
        callback(SearchRecruits(data.query))
    elseif data.type == "employees" then
        callback(GetOnlineDoctors())
    elseif data.type == "employee" then
        callback(Employees.single(data.identifier))
    end
end)

Framework.RegisterCallback("GetSocietyFunds", function(source, callback)
    local promise = GetSocietyFunds(Config.Society)
    Citizen.Await(promise)
    promise:next(callback)
end)

Framework.RegisterCallback("GetUploadInfo", function(source, callback)
    local method = Upload.Methods[Upload.Method]
    callback(method)
end)
