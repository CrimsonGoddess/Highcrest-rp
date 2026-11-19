local function sendOkokBill(bill)
    TriggerEvent('okokBilling:CreateInvoice', bill.source, bill.target, bill.amount, bill.reason, bill.society or 'unknown')
    return true
end
ZlomaCore.RegisterServerBilling('okokBilling', { send = sendOkokBill })
ZlomaCore.RegisterServerBilling('okok_billing', { send = sendOkokBill })
