lib.Framework.RegisterCallback('peuren_chopshop:GetDealerCooldowns', function(source, cb)
    cb(Cooldown.data.dealers)
end)

lib.Framework.RegisterCallback('peuren_chopshop:GetPersonalCooldown', function(source, cb, dealer)
    local result = Cooldown.Get(source, 'personal', dealer)
    if not result then return cb(false) end
    cb(true)
end)