return {
    doctorCallCooldown = 1, -- Time in minutes for cooldown between doctors calls
    wipeInvOnRespawn = false, -- Highcrest: players keep their items when they respawn at the hospital
    depositSociety = function(society, amount)
        exports['Renewed-Banking']:addAccountMoney(society, amount)
    end
}