lib = exports.peuren_lib:Core()
lib.LoadLocales()

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Orders.Load()        
    end
end)