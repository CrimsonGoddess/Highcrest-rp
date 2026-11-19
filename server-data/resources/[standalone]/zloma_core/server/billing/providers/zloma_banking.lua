ZlomaCore.RegisterServerBilling('zloma_banking', {
    send = function(bill)
        return exports['zloma_banking']:CreateBill(
            bill.target, bill.amount, bill.reason, bill.reason, bill.source, 'zloma_core', bill.society
        ) == true
    end,
    getBills = function(source)
        local success, result = pcall(function() return exports['zloma_banking']:GetBills(source) end)
        return success and type(result) == 'table' and result or {}
    end,
})
