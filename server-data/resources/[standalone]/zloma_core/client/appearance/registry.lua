ZlomaCore.AppearanceHelpers = ZlomaCore.AppearanceHelpers or {}

function ZlomaCore.RegisterClientAppearance(provider, adapter)
    ZlomaCore.RegisterAdapter('client', 'Appearance', provider, adapter)
end

function ZlomaCore.AppearanceHelpers.decode(data)
    if type(data) ~= 'string' then return data end
    local success, decoded = pcall(json.decode, data)
    return success and decoded or data
end

function ZlomaCore.AppearanceHelpers.getSkinchangerSkin(timeoutMs)
    local skin, startedAt = nil, GetGameTimer()
    TriggerEvent('skinchanger:getSkin', function(data) skin = data end)
    while skin == nil and GetGameTimer() - startedAt < (timeoutMs or 2000) do Wait(1) end
    return skin
end

function ZlomaCore.AppearanceHelpers.try(actions)
    for _, action in ipairs(actions) do
        local success, result = pcall(action)
        if success and result ~= false then return true end
    end
    return false
end
