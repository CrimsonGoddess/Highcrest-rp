lib = exports.peuren_lib:Core()
lib.LoadLocales()

AddEventHandler('playerDropped', function()
    if not source then return end
    for k,_ in pairs(Config.Dealers) do 
        Jobs.Remove(source, k)
    end
end)