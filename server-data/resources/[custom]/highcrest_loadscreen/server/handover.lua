-- Gives the loading screen the player's name for its welcome message.
AddEventHandler('playerConnecting', function(name, _, deferrals)
    deferrals.handover({ playerName = name })
end)
