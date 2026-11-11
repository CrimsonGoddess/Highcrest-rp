
while GetCurrentResourceName() ~= "bp_handlingeditor" do
    Wait(2000)
    print("Make sure the resource name is bp_handlingeditor, it will break the resource if you rename it.")
end

RegisterCommand('handlingeditor', function(source, args, rawCommand)
    -- Add your permission system here.

    if Config.isAllowed(source) then
        TriggerClientEvent('bp_handlingeditor:openHandlingEditor', source)
    else
        print('No permission')
    end
end, false)
