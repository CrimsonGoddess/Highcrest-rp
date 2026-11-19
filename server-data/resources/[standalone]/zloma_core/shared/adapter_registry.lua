-- Internal adapter registry. Providers register capabilities; facades own the
-- public exports and never expose this table to dependent resources.
ZlomaCore.Adapters = ZlomaCore.Adapters or { client = {}, server = {} }

function ZlomaCore.RegisterAdapter(side, feature, provider, adapter)
    if (side ~= 'client' and side ~= 'server') or type(feature) ~= 'string'
        or type(provider) ~= 'string' or type(adapter) ~= 'table' then
        error('Invalid ZlomaCore adapter registration')
    end
    ZlomaCore.Adapters[side][feature] = ZlomaCore.Adapters[side][feature] or {}
    ZlomaCore.Adapters[side][feature][provider] = adapter
end

function ZlomaCore.GetAdapter(side, feature, provider)
    local features = ZlomaCore.Adapters[side]
    return features and features[feature] and features[feature][provider] or nil
end
