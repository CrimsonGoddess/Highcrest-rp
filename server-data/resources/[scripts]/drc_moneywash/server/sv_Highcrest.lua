-- Highcrest: money washing levels. Each player earns XP for every finished wash (counted into
-- clean cash): XP_PER_BATCH, plus XP_PER_THOUSAND for every $1,000 counted. Higher levels keep
-- more of the money. The table is created by highcrest_sql (009_moneywash_levels.sql).
local LEVELS = {
    { xp = 0, keep = 70 },
    { xp = 100, keep = 74 },
    { xp = 300, keep = 78 },
    { xp = 600, keep = 82 },
    { xp = 1000, keep = 85 },
}
local XP_PER_BATCH = 10
local XP_PER_THOUSAND = 1

local xpCache = {}

local function citizenIdOf(src)
    local player = exports.qbx_core:GetPlayer(src)
    return player and player.PlayerData.citizenid
end

local function xpOf(citizenid)
    if xpCache[citizenid] == nil then
        xpCache[citizenid] = tonumber(MySQL.scalar.await('SELECT xp FROM highcrest_wash_levels WHERE citizenid = ?', { citizenid })) or 0
    end
    return xpCache[citizenid]
end

local function levelFor(xp)
    local index = 1
    for i, level in ipairs(LEVELS) do
        if xp >= level.xp then index = i end
    end
    return index, LEVELS[index]
end

-- The % kept at each of the four wash stages, so the four together leave the level's total.
function HighcrestWashRate(src)
    local citizenid = citizenIdOf(src)
    local _, level = levelFor(citizenid and xpOf(citizenid) or 0)
    return ((level.keep / 100) ^ 0.25) * 100
end

function HighcrestAddWashXp(src, amount)
    local citizenid = citizenIdOf(src)
    if not citizenid then return end
    local gained = XP_PER_BATCH + math.floor((tonumber(amount) or 0) / 1000) * XP_PER_THOUSAND
    xpCache[citizenid] = xpOf(citizenid) + gained
    MySQL.update.await('INSERT INTO highcrest_wash_levels (citizenid, xp) VALUES (?, ?) ON DUPLICATE KEY UPDATE xp = xp + VALUES(xp)', {
        citizenid, gained,
    })
end

lib.callback.register('highcrest_moneywash:getLevel', function(source)
    local citizenid = citizenIdOf(source)
    if not citizenid then return end
    local xp = xpOf(citizenid)
    local index, level = levelFor(xp)
    local nextLevel = LEVELS[index + 1]
    return { level = index, keep = level.keep, xp = xp, nextXp = nextLevel and nextLevel.xp or nil }
end)
