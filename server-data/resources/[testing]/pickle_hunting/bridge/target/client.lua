local Targets = {}

function GetModels()
    local models = {}
    for k,v in pairs(Config.Animals) do 
        table.insert(models, k)
    end
    return models
end

Targets.OX = function()
    local models = GetModels()
    local optionsNames = { 'pickle_hunting:skinAnimal', 'pickle_hunting:carryAnimal', 'pickle_hunting:trunkAnimal' }
    local options = {
        {
            name = 'pickle_hunting:skinAnimal',
            event = 'pickle_hunting:skinAnimal',
            label = 'Skin Animal',
        },
        {
            name = 'pickle_hunting:carryAnimal',
            event = 'pickle_hunting:carryAnimal',
            label = 'Carry Animal',
        },
        {
            name = 'pickle_hunting:trunkAnimal',
            event = 'pickle_hunting:trunkAnimal',
            label = 'Place Animal on Trunk',
        },
    }

    exports.ox_target:removeModel(models, optionsNames)
    exports.ox_target:addModel(models, options)

    RegisterNetEvent("pickle_hunting:skinAnimal", function(data)
        SkinAnimal(data.entity)
    end)

    RegisterNetEvent("pickle_hunting:carryAnimal", function(data)
        CarryAnimal(data.entity)
    end)

    RegisterNetEvent("pickle_hunting:trunkAnimal", function(data)
        TrunkAnimal(data.entity)
    end)
end

Targets.QB = function()
    local models = GetModels()
    local optionsNames = { 'Skin Animal', 'Carry Animal', 'Place Animal on Trunk' }
    local options = {
        {
            type = "client",
            name = 'pickle_hunting:skinAnimal',
            event = 'pickle_hunting:skinAnimal',
            label = 'Skin Animal',
        },
        {
            type = "client",
            name = 'pickle_hunting:carryAnimal',
            event = 'pickle_hunting:carryAnimal',
            label = 'Carry Animal',
        },
        {
            type = "client",
            name = 'pickle_hunting:trunkAnimal',
            event = 'pickle_hunting:trunkAnimal',
            label = 'Place Animal on Trunk',
        },
    }

    exports['qb-target']:RemoveTargetModel(models, optionsNames)
    exports['qb-target']:AddTargetModel(models, {options = options, distance = 2.5})

    RegisterNetEvent("pickle_hunting:skinAnimal", function(data)
        SkinAnimal(data.entity)
    end)

    RegisterNetEvent("pickle_hunting:carryAnimal", function(data)
        CarryAnimal(data.entity)
    end)

    RegisterNetEvent("pickle_hunting:trunkAnimal", function(data)
        TrunkAnimal(data.entity)
    end)
end

Targets.Q = function()
    local models = GetModels()
    local optionsNames = { 'Skin Animal', 'Carry Animal', 'Place Animal on Trunk' }
    local options = {
        {
            type = "client",
            name = 'pickle_hunting:skinAnimal',
            event = 'pickle_hunting:skinAnimal',
            label = 'Skin Animal',
        },
        {
            type = "client",
            name = 'pickle_hunting:carryAnimal',
            event = 'pickle_hunting:carryAnimal',
            label = 'Carry Animal',
        },
        {
            type = "client",
            name = 'pickle_hunting:trunkAnimal',
            event = 'pickle_hunting:trunkAnimal',
            label = 'Place Animal on Trunk',
        },
    }

    exports['qtarget']:RemoveTargetModel(models, optionsNames)
    exports['qtarget']:AddTargetModel(models, {options = options, distance = 2.5})

    RegisterNetEvent("pickle_hunting:skinAnimal", function(data)
        SkinAnimal(data.entity)
    end)

    RegisterNetEvent("pickle_hunting:carryAnimal", function(data)
        CarryAnimal(data.entity)
    end)

    RegisterNetEvent("pickle_hunting:trunkAnimal", function(data)
        TrunkAnimal(data.entity)
    end)
end

if Config.Target then
    if not Targets[Config.Target] then 
        print("You do not have a valid target set in \"Config.Target\".")
        local options = ""
        local f = true
        for k,v in pairs(Targets) do 
            if f then
                f = false 
                options = k
            else 
                options = options .. ", " .. k
            end
        end
        print("Valid Target Options: " .. options .. ".")
        return
    end
    Targets[Config.Target]()
end