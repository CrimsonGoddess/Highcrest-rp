ZlomaCore.RegisterServerBilling('esx_billing', {
    send = function(bill)
        TriggerEvent('esx_billing:sendBill', bill.target, bill.society or 'mechanic', GetPlayerName(bill.source), bill.amount)
        return true
    end,
    getBills = function(source)
        local response, resolved = promise.new(), false
        TriggerEvent('esx_billing:getBills', source, function(result)
            if resolved then return end
            resolved = true
            response:resolve(type(result) == 'table' and result or {})
        end)
        SetTimeout(5000, function()
            if resolved then return end
            resolved = true
            response:resolve({})
        end)
        return Citizen.Await(response)
    end,
})
