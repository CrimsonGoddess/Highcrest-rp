lib.Framework.RegisterCallback('peuren_chopshop:GetPlayerSkill', function(source, cb, skill)
    local result = Skills.Get(source, skill)
    cb(result)
end)

lib.Framework.RegisterCallback('peuren_chopshop:SetPlayerSkill', function(source, cb, type, success)
    if not type then return cb(false) end

    if success then 
        local gain = Config.Skills[type].GainPerAction
        Skills.AddSkillXP(source, type, math.random(gain.min, gain.max))
    else
        local decrease = Config.Skills[type].DecreaseOnFail
        Skills.RemoveSkillXP(source, type, math.random(decrease.min, decrease.max))

        if type == 'disassemble' then 
            if math.random(1, 100) <= Config.Disassemble.chance then 
                if not Config.Disassemble.requiredItem then return end
                lib.Inventory.RemoveItem(source, Config.Disassemble.requiredItem, 1)
            end
        elseif type == 'hacking' then 
            if math.random(1, 100) <= Config.Hacking.chance then 
                lib.Inventory.RemoveItem(source, Config.Hacking.requiredItem, 1)
            end
        end
    end

    cb(true)
end)