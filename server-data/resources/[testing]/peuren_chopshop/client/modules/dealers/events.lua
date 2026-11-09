---Event that listens when a cooldown is set for a dealer
RegisterNetEvent('peuren_chopshop:SetCooldown', function(dealer)
    Dealers.CoolDownDealer(dealer)
end)

---Event that listens when a cooldown is removed from a dealer
RegisterNetEvent('peuren_chopshop:RemoveCooldown', function(dealer)
    Dealers.SpawnDealer(dealer)
end)