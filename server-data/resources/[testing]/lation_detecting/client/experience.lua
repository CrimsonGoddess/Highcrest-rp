function FormatNumber(num)
    local prefix, number, suffix = string.match(tostring(num), "^([^%d]*%d)(%d*)(.-)$")
    local reversed = number:reverse()
    local formatted = reversed:gsub("(%d%d%d)", "%1,")
    formatted = formatted:reverse()
    return prefix .. formatted .. suffix
end

function GetPlayerData(field)
    return lib.callback.await("lation_detecting:GetPlayerData", false, field)
end

function GetProgressPercent(experience, level)
    local maxLevel = #Config.Detecting.levels
    if level >= maxLevel then
        return 100
    end
    local currentLevelXP = Config.Detecting.levels[level] or 0
    local nextLevelXP = Config.Detecting.levels[level + 1] or experience
    if currentLevelXP >= nextLevelXP then
        return 100
    end
    local progress = (experience - currentLevelXP) / (nextLevelXP - currentLevelXP)
    progress = progress * 100
    return math.max(0, progress)
end

function GetXPToNextLevel(level, experience)
    if level < #Config.Detecting.levels then
        local nextLevelXP = Config.Detecting.levels[level + 1]
        local remaining = nextLevelXP - experience
        return math.floor(remaining)
    end
    return 0
end

function OpenMenu()
    local playerData = GetPlayerData()
    if not playerData then
        EventLog("[experience.lua]: OpenMenu: unable to retrieve player data")
        return
    end
    local menuStrings = Strings.ContextMenu.stats_menu
    local progressPercent = GetProgressPercent(playerData.experience, playerData.level)
    local progressColor = menuStrings.colors.green
    if progressPercent < 30 then
        progressColor = menuStrings.colors.red
    elseif progressPercent > 30 and progressPercent < 80 then
        progressColor = menuStrings.colors.yellow
    end
    local xpToNext = GetXPToNextLevel(playerData.level, playerData.experience)
    RegisterMenu({
        id = "md_menu",
        title = menuStrings.title,
        options = {
            {
                title = menuStrings.level.title,
                description = string.format(menuStrings.level.description, tostring(playerData.level)),
                progress = playerData.level * 20,
                colorScheme = playerData.level <= 2 and menuStrings.colors.red or (playerData.level >= 3 and playerData.level <= 4 and menuStrings.colors.yellow or menuStrings.colors.green),
                icon = menuStrings.level.icon
            },
            {
                title = menuStrings.progress.title,
                description = menuStrings.progress.description .. tostring(math.floor(progressPercent)) .. menuStrings.progress.description2,
                progress = tonumber(progressPercent),
                colorScheme = progressColor,
                icon = menuStrings.progress.icon,
                metadata = {
                    {
                        label = menuStrings.progress.metadata.currentXP.one,
                        value = FormatNumber(playerData.experience) .. menuStrings.progress.metadata.currentXP.two
                    },
                    {
                        label = menuStrings.progress.metadata.nextLevel.one,
                        value = FormatNumber(xpToNext) .. menuStrings.progress.metadata.nextLevel.two
                    }
                }
            },
            {
                title = menuStrings.itemsFound.title,
                description = string.format(menuStrings.itemsFound.description, tostring(FormatNumber(playerData.items_found))),
                icon = menuStrings.itemsFound.icon
            },
            {
                title = menuStrings.moneyEarned.title,
                description = menuStrings.moneyEarned.description .. tostring(FormatNumber(playerData.money_earned)),
                icon = menuStrings.moneyEarned.icon
            }
        }
    })
    ShowMenu("md_menu")
end

function GetLevelData()
    return Config.Detecting.levels
end

RegisterCommand(Config.Setup.command, function()
    OpenMenu()
end, false)

exports("OpenMenu", OpenMenu)
exports("GetPlayerData", GetPlayerData)
exports("GetLevelData", GetLevelData)
