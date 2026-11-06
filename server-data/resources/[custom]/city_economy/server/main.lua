local banking = exports['Renewed-Banking']
local core = exports.qbx_core

-- Local event only (no RegisterNetEvent), so clients can't trigger it.
AddEventHandler('qbx_core:server:onPaycheck', function(playerId, payment)
    local tax = math.floor(payment * Config.taxRate)
    if tax <= 0 then return end

    local player = core:GetPlayer(playerId)
    if not player or Config.exemptJobs[player.PlayerData.job.name] then return end

    -- getAccountMoney returns false for an unknown account and 0 for an empty one.
    if banking:getAccountMoney(Config.treasuryAccount) == false then
        lib.print.error(('treasury account "%s" does not exist; no tax collected'):format(Config.treasuryAccount))
        return
    end

    if not core:RemoveMoney(playerId, 'bank', tax, 'income-tax') then return end

    banking:addAccountMoney(Config.treasuryAccount, tax)
    core:Notify(playerId, ('Income tax: $%d paid to the city'):format(tax), 'inform')
end)

lib.addCommand('treasury', {
    help = 'Show the city treasury balance',
    restricted = 'group.admin',
}, function(source)
    local balance = banking:getAccountMoney(Config.treasuryAccount)
    local message = balance == false
        and ('Treasury account "%s" does not exist'):format(Config.treasuryAccount)
        or ('City treasury: $%d'):format(balance)

    if source == 0 then
        print(message)
    else
        core:Notify(source, message, 'inform')
    end
end)
