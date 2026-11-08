local resourceName = GetCurrentResourceName()
local permissionsData = json.decode(LoadResourceFile(resourceName, "./config/permissions.json"))

Framework.RegisterCallback("GetAllPermissions", function(source, callback)
    callback(permissionsData)
end)

Framework.RegisterCallback("GetPermissions", function(source, callback)
    local job = Framework.GetPlayerJob(source)
    local permissions = {}
    
    for grade = job.grade, 0, -1 do
        local jobRanks = permissionsData.ranks[job.name]
        if not jobRanks then
            jobRanks = {}
        end
        
        local gradePermissions = jobRanks[tostring(grade)]
        if not gradePermissions then
            gradePermissions = {}
        end
        
        for i = 1, #gradePermissions do
            permissions[#permissions + 1] = gradePermissions[i]
        end
    end
    
    callback(permissions)
end)

Framework.RegisterCallback("UpdateGradePermissions", function(source, callback, data)
    local gradeStr = tostring(data.grade)
    local jobRanks = permissionsData.ranks[data.job]
    
    if jobRanks then
        local gradePermissions = jobRanks[gradeStr]
        if gradePermissions then
            permissionsData.ranks[data.job][gradeStr] = data.permissions
            SaveResourceFile(resourceName, "./config/permissions.json", json.encode(permissionsData), -1)
            callback(true)
        end
    end
    callback(false)
end)

function HasPermission(source, permission)
    local job = Framework.GetPlayerJob(source)
    local hasPermission = false
    
    local jobRanks = permissionsData.ranks[job.name]
    if not jobRanks then
        jobRanks = {}
    end
    
    local gradePermissions = jobRanks[tostring(job.grade)]
    if not gradePermissions then
        gradePermissions = {}
    end
    
    for i = 1, #gradePermissions do
        if gradePermissions[i] == permission then
            hasPermission = true
        end
    end
    
    return hasPermission
end

exports("hasPermission", HasPermission)
