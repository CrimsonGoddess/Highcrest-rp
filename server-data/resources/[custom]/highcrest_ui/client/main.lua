local HUD_COLOUR_FREEMODE = 116      -- pause menu header and accents
local HUD_COLOUR_FREEMODE_DARK = 123 -- darker version of the same accent

ReplaceHudColourWithRgba(HUD_COLOUR_FREEMODE, 200, 16, 46, 255)
ReplaceHudColourWithRgba(HUD_COLOUR_FREEMODE_DARK, 92, 7, 20, 255)

-- Show the icon only while playing, not during character selection or in the pause menu.
CreateThread(function()
    local visible = false

    while true do
        Wait(500)
        local shouldShow = LocalPlayer.state.isLoggedIn == true and not IsPauseMenuActive()

        if shouldShow ~= visible then
            visible = shouldShow
            SendNUIMessage({ iconVisible = visible })
        end
    end
end)
