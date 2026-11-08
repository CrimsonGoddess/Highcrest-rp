RegisterNetEvent('highcrest_empire:client:notify', function(message)
    lib.notify({ title = 'Empire', description = message, position = 'top' })
end)
