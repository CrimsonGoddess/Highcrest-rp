---@alias SkillName "hacking" | "lockpicking" | "looting"

---@class Skill
---@field Level number The current level
---@field XP number The amount of XP
---@field LastChanged number The timestamp of when the latest change was done

---@alias PlayerSkills { [string]: Skill }

---@class Skills
---@field private data { [number]: PlayerSkills }

Skills = {
    data = {},

    ---Get the players skill data
    ---@param id number
    ---@param skill SkillName
    ---@return Skill
    Get = function(id, skill)
        if not Skills.data[id] then
            Skills.Load(id)
        end
        Skills.CheckLoseOverTime(id)
        if not skill then return Skills.data[id] end
        return Skills.data[id][skill]
    end,

    ---Loads the players skill data
    ---@param id number
    ---@return PlayerSkills
    Load = function(id)
        if not id then return nil end

        local identifier = Ply.GetIdentifier(id)
        if not identifier then return nil end

        local result = lib.Database.FetchSync('SELECT skills FROM `chopshop_players` WHERE identifier = ?', {identifier})
        result = result[1]

        local skills = {}
        if result then
            skills = json.decode(result.skills)
        end

        Skills.data[id] = {}
        for type, _ in pairs(Config.Skills) do
            if skills[type] then
                Skills.data[id][type] = skills[type]
            else 
                Skills.data[id][type] = {
                    XP = 0,
                    Level = 1,
                    LastChanged = os.time()
                }
            end
        end
    end,

    ---Saves players skill data
    ---@param id number
    Save = function(id)
        if not Skills.data[id] then return end
        return Ply.Save(id, nil, Skills.data[id])
    end,

    ---Saves and then clears skill data from memory
    ---@param id number
    Clear = function(id)
        Skills.Save(id)
        Skills.data[id] = nil
    end,

    ---Calculates the level for the given skill from the XP amount
    ---@param skill SkillName
    ---@param xp number
    ---@return number
    CalculateLevel = function(skill, xp)
        if not Config.Skills[skill] then return -1 end

        local level = 0

        for i = 1, #Config.Skills[skill].Levels do
            if Config.Skills[skill].Levels[i].minXP <= xp then
                level += 1
            end
        end

        return level
    end,

    ---Adds given amount of XP to the given skill
    ---@param id number
    ---@param skill SkillName
    ---@param xp number
    AddSkillXP = function(id, skill, xp)
        local skillData = Skills.Get(id, skill)
        skillData.XP += xp
        skillData.Level = Skills.CalculateLevel(skill, skillData.XP)
        skillData.LastChanged = os.time()
        Skills.Save(id)
    end,

    ---Removes given amount of XP from the given skill
    ---@param id number
    ---@param skill SkillName
    ---@param xp number
    RemoveSkillXP = function(id, skill, xp)
        local skillData = Skills.Get(id, skill)
        skillData.XP -= xp
        if skillData.XP < 0 then skillData.XP = 0 end
        skillData.Level = Skills.CalculateLevel(skill, skillData.XP)
        Skills.Save(id)
    end,

    
    ---Checks if any reputation should be taken away based on time passed since last interaction
    ---@param id number
    CheckLoseOverTime = function(id)
        local changed = false
        for k, v in pairs(Skills.data[id]) do
            if not Config.Skills[k].LoseOverTime then goto continue end

            if (os.time() - v.LastChanged) / 3600 > Config.Skills[k].LoseOverTime.minHours then
                local timeDiff = (os.time() - v.LastChanged) / 3600
                timeDiff -= Config.Skills[k].LoseOverTime.minHours
                if math.floor(timeDiff) > 0 then
                    v.XP -= math.floor(timeDiff) * Config.Skills[k].LoseOverTime.amount
                    if v.XP < 0 then v.XP = 0 end
                    v.Level = Skills.CalculateLevel(k, v.XP)
                    v.LastChanged = os.time()
                    changed = true
                end
            end

            ::continue::
        end
        
        if not changed then return end
        Skills.Save(id)
    end
}

return Skills