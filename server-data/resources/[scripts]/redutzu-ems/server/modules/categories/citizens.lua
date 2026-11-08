citizens = {}
citizens.table = "ems_citizens"

if not Config.UseExistentValues then
    citizens.table = "ems_citizens"
    citizens.identifier = "identifier"
    citizens.name = "CONCAT(ems_citizens.firstname, ' ', ems_citizens.lastname)"
    citizens.job = "JSON_VALUE(ems_citizens.job, '$.name')"
else
    if Config.Framework == "qb-core" or Config.Framework == "qbox" then
        citizens.table = "players"
        citizens.identifier = "citizenid"
        citizens.name = "CONCAT(JSON_VALUE(players.charinfo, '$.firstname'), ' ', JSON_VALUE(players.charinfo, '$.lastname'))"
        citizens.job = "JSON_VALUE(players.job, '$.name')"
    elseif Config.Framework == "esx" then
        citizens.table = "users"
        citizens.identifier = "identifier"
        citizens.name = "CONCAT(users.firstname, ' ', users.lastname)"
        citizens.job = "users.job"
    end
end

function citizens.search(query)
    local selection = nil
    
    if not Config.UseExistentValues then
        selection = "ems_citizens.identifier, ems_citizens.firstname, ems_citizens.lastname, JSON_VALUE(ems_citizens.job, '$.label') AS job, JSON_VALUE(ems_citizens.job, '$.grade') AS job_grade"
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
    
    local results = MySQL.Sync.fetchAll(string.format("SELECT %s FROM %s WHERE %s LIKE :query LIMIT :limit", selection, citizens.table, citizens.name), {
        query = "%" .. query .. "%",
        limit = Config.Settings.MaximumResults
    })
    
    results = array.map(results, function(citizen)
        local phoneNumber = Framework.GetPhoneNumberByIdentifier(citizen.identifier)
        if not phoneNumber then
            phoneNumber = " "
        end
        citizen.phone_number = phoneNumber
        return citizen
    end)
    
    if Config.UseExistentValues and Config.Framework == "esx" then
        for i = 1, #results do
            local jobData = Framework.GetJobData(results[i].job)
            results[i].job = jobData.name
            local grade = array.find(jobData.grades, function(g)
                return g.level == results[i].job_grade
            end)
            if grade then
                results[i].job_grade = grade.name
            end
        end
    end
    
    return results
end

function citizens.single(identifier)
    if not identifier then
        print("^2No identifier passed in \"SearchCitizen\" export^0")
        return
    end
    
    local identifierColumn = nil
    local selection = nil
    
    if not Config.UseExistentValues then
        identifierColumn = "ems_citizens.identifier"
        selection = [[
            ems_citizens.identifier,
            ems_citizens.firstname,
            ems_citizens.lastname,
            ems_citizens.gender,
            ems_citizens.image,
            ems_citizens.notes,
            ems_citizens.bloodtype,
            ems_citizens.fingerprint,
            ems_citizens.birthdate,
            JSON_VALUE(ems_citizens.job, '$.label') AS job,
            JSON_VALUE(ems_citizens.job, '$.grade') AS job_grade,
        ]]
    else
        if Config.Framework == "qb-core" or Config.Framework == "qbox" then
            identifierColumn = "players.citizenid"
            selection = [[
            players.citizenid AS identifier,
            JSON_VALUE(players.charinfo, '$.firstname') AS firstname,
            JSON_VALUE(players.charinfo, '$.lastname') AS lastname,
            JSON_VALUE(players.charinfo, '$.phone') AS phone_number,
            JSON_VALUE(players.charinfo, '$.birthdate') AS birthdate,
            JSON_VALUE(players.job, '$.label') AS job,
            JSON_VALUE(players.job, '$.grade.name') AS job_grade,
            IF(JSON_VALUE(players.charinfo, '$.gender') = 0, 'm', 'f') AS gender,
            JSON_VALUE(players.metadata, '$.fingerprint') AS fingerprint,
            JSON_VALUE(players.metadata, '$.bloodtype') AS bloodtype,
            players.ems_notes AS notes,
            players.ems_image AS image,
        ]]
        elseif Config.Framework == "esx" then
            identifierColumn = "users.identifier"
            selection = [[
            users.identifier,
            users.firstname,
            users.lastname,
            users.sex AS gender,
            users.ems_image AS image,
            users.ems_notes AS notes,
            users.dateofbirth AS birthdate,
            users.job,
            users.job_grade,
        ]]
        end
    end
    
    selection = selection .. table.concat({
        string.format("(SELECT CONCAT('[', GROUP_CONCAT(JSON_OBJECT('id', ems_gallery.id, 'value', ems_gallery.value, 'description', ems_gallery.description)), ']') FROM ems_gallery WHERE %s = ems_gallery.identifier) AS images", identifierColumn),
        "(SELECT CONCAT('[', GROUP_CONCAT(JSON_OBJECT('id', ems_incidents.id, 'createdAt', ems_incidents.createdAt)), ']') FROM ems_incidents WHERE JSON_CONTAINS(ems_incidents.victims, JSON_QUOTE(" .. identifierColumn .. "))) AS incidents"
    }, ",\n")
    
    local result = MySQL.Sync.fetchSingle(string.format("SELECT %s FROM %s WHERE %s = ?", selection, citizens.table, identifierColumn), {identifier})
    
    if not result then
        print("^0No citizen found^0")
        return nil
    end
    
    result.insurance = GetHealthInsurance(identifier)
    result.phone_number = Framework.GetPhoneNumberByIdentifier(identifier)
    
    result.images = json.decode(result.images) or {}
    result.incidents = json.decode(result.incidents) or {}
    
    if Config.HiddenJobs == "all" or (Config.HiddenJobs[result.job]) then
        result.job = nil
        result.job_grade = nil
    end
    
    if Config.Framework == "esx" and Config.UseExistentValues then
        if result.job then
            local jobData = Framework.GetJobData(result.job)
            result.job = jobData.name
            local grade = array.find(jobData.grades, function(g)
                return g.level == result.job_grade
            end)
            if grade then
                result.job_grade = grade.name
            end
        end
    end
    
    return result
end

exports("SearchCitizen", citizens.single)

function citizens.create(data, source)
    if not data.identifier then
        print("[citizens.create] Please provide an identifier")
        return
    end
    
    local success = pcall(function()
        MySQL.Sync.insert([[
            INSERT INTO ems_citizens
                (identifier, firstname, lastname, gender, birthdate, job, bloodtype, fingerprint, notes, image) 
            VALUES 
                (:identifier, :firstname, :lastname, :gender, :birthdate, :job, :bloodtype, :fingerprint, :notes, :image)
        ]], {
            identifier = data.identifier,
            firstname = data.firstname,
            lastname = data.lastname,
            gender = data.gender,
            birthdate = data.birthdate,
            fingerprint = data.fingerprint,
            bloodtype = data.bloodtype,
            notes = data.notes,
            image = data.image,
            job = json.encode(data.job)
        })
    end)
    return success
end

exports("CreateCitizen", citizens.create)

function citizens.update(identifier, data, source)
    if not identifier then
        print("No identifier")
        return
    end
    
    if table.isEmpty(data) then
        return true
    end
    
    if data.incidents then
        MySQL.Sync.execute([[
            UPDATE 
                ems_incidents
            SET 
                victims = CASE
                    WHEN NOT JSON_CONTAINS(:incidents, ems_incidents.id) AND JSON_SEARCH(ems_incidents.victims, 'one', :identifier) IS NOT NULL THEN JSON_REMOVE(ems_incidents.victims, JSON_UNQUOTE(JSON_SEARCH(ems_incidents.victims, 'one', :identifier)))
                    WHEN JSON_CONTAINS(:incidents, ems_incidents.id) AND JSON_SEARCH(ems_incidents.victims, 'one', :identifier) IS NULL THEN JSON_ARRAY_APPEND(ems_incidents.victims, '$', :identifier)            
                    ELSE ems_incidents.victims
                END
        ]], {
            incidents = json.encode(data.incidents),
            identifier = identifier
        })
        return true
    end
    
    if Config.UseExistentValues then
        data.ems_notes = data.notes
        data.ems_image = data.image
        data.notes = nil
        data.image = nil
    else
        if data.job then
            if type(data.job) == "table" then
                local sourcePlayer = Framework.GetSourceFromIdentifier(identifier)
                if sourcePlayer then
                    local jobData = Framework.GetJobData(data.job.name)
                    local gradeLevel = array.find(jobData.grades, function(g)
                        return g.name == data.job.grade
                    end)
                    if gradeLevel then
                        Framework.SetPlayerJob(sourcePlayer, data.job.name, gradeLevel.level)
                    end
                end
                data.job = json.encode(data.job)
            end
        else
            data.job = nil
        end
    end
    
    local clause = GenerateClause(data)
    data.id = identifier
    
    return MySQL.Sync.execute("UPDATE " .. citizens.table .. " SET " .. clause .. " WHERE " .. citizens.identifier .. " = :id", replaceFalseWithNil(data)) > 0
end

exports("UpdateCitizen", citizens.update)
