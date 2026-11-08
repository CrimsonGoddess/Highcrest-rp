local HUD_COLOUR_FREEMODE = 116      -- pause menu header and accents
local HUD_COLOUR_FREEMODE_DARK = 123 -- darker version of the same accent
local MONEY_REFRESH_DELAY_MS = 300

ReplaceHudColourWithRgba(HUD_COLOUR_FREEMODE, 200, 16, 46, 255)
ReplaceHudColourWithRgba(HUD_COLOUR_FREEMODE_DARK, 92, 7, 20, 255)

local lastStats
local hiddenByApp = false

-- Other resources can hide the badge, such as the phone camera.
AddEventHandler('highcrest_ui:setHidden', function(hidden)
    hiddenByApp = hidden == true
end)

local function jobTitle(job)
    if not job or job.name == 'unemployed' then return nil end

    local title = job.label or job.name
    if job.grade and job.grade.name then
        title = ('%s - %s'):format(title, job.grade.name)
    end
    if job.onduty == false then
        title = ('%s (off duty)'):format(title)
    end
    return title
end

local function sendStats(playerData)
    if not playerData or not playerData.money then return end

    local stats = {
        id = GetPlayerServerId(PlayerId()),
        cash = playerData.money.cash or 0,
        bank = playerData.money.bank or 0,
        job = jobTitle(playerData.job),
    }

    -- Player data updates for many reasons, so only touch the UI when something shown changed.
    local encoded = json.encode(stats)
    if encoded == lastStats then return end
    lastStats = encoded

    SendNUIMessage({ stats = stats })
end

local function refreshStats()
    sendStats(exports.qbx_core:GetPlayerData())
end

RegisterNetEvent('QBCore:Player:SetPlayerData', sendStats)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', refreshStats)
RegisterNetEvent('QBCore:Client:OnJobUpdate', refreshStats)
RegisterNetEvent('QBCore:Client:SetDuty', refreshStats)
RegisterNetEvent('QBCore:Client:OnMoneyChange', function()
    SetTimeout(MONEY_REFRESH_DELAY_MS, refreshStats)
end)

-- Show the badge only while playing, not during character selection or in the pause menu.
CreateThread(function()
    local visible = false

    while true do
        Wait(200)
        local shouldShow = LocalPlayer.state.isLoggedIn == true and not IsPauseMenuActive() and not hiddenByApp

        if shouldShow ~= visible then
            visible = shouldShow
            if visible then
                lastStats = nil
                refreshStats()
            end
            SendNUIMessage({ iconVisible = visible })
        end
    end
end)

-- Community links. /discord and /store copy the link and show it in chat.
-- Leave a link empty until it exists; its command then says it's coming soon.
local LINKS = {
    discord = 'https://discord.gg/Se7Sx7nnkv',
    store = '',
}

local function shareLink(name, label)
    local url = LINKS[name]
    if not url or url == '' then
        lib.notify({ description = ('The %s is coming soon.'):format(label), type = 'inform' })
        return
    end
    lib.setClipboard(url)
    TriggerEvent('chat:addMessage', { args = { label, url } })
    lib.notify({ title = label, description = 'Link copied. Paste it into your browser.', type = 'success' })
end

RegisterCommand('discord', function() shareLink('discord', 'Highcrest Discord') end, false)
RegisterCommand('store', function() shareLink('store', 'Highcrest store') end, false)
TriggerEvent('chat:addSuggestion', '/discord', 'Get the Highcrest Discord link')
TriggerEvent('chat:addSuggestion', '/store', 'Get the Highcrest store link')
