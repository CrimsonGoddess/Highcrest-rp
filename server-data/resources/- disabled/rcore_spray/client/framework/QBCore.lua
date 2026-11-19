if Framework == nil or Framework == 0 then
    if GetResourceState('qb-core') == 'starting' or GetResourceState('qb-core') == 'started' then
        Framework = FW_QBCORE
    end
end

if Framework == FW_QBCORE then
    if FrameworkTriggers['notify'] == '' or string.strtrim(string.lower(FrameworkTriggers['notify'])) == 'qbcore' then
        FrameworkTriggers['notify'] = 'QBCore:Notify'
    end

    if FrameworkTriggers['object'] == '' or string.strtrim(string.lower(FrameworkTriggers['object'])) == 'qbcore' then
        FrameworkTriggers['object'] = 'QBCore:GetObject'
    end

    if FrameworkTriggers['resourceName'] == '' or string.strtrim(string.lower(FrameworkTriggers['resourceName'])) == 'qbcore' then
        FrameworkTriggers['resourceName'] = 'qb-core'
    end
end

if Framework == FW_QBCORE then
    QBCore = Citizen.Await(GetSharedObjectSafe())
end