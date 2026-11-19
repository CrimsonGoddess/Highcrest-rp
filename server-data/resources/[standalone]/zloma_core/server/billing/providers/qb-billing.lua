ZlomaCore.RegisterServerBilling('qb-billing', {
    send = function(bill)
        TriggerEvent('qb-billing:server:sendBill', bill.target, bill.amount, bill.reason, GetPlayerName(bill.source))
        return true
    end,
})
