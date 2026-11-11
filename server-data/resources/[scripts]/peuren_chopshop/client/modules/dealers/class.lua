Dealers = {
    Data = {},

    ---Load dealers for client
    LoadDealers = function()
        local result = lib.Framework.Callbacks.Trigger('peuren_chopshop:GetDealerCooldowns')

        for k, _ in pairs(Config.Dealers) do
            if not result[k] then 
                Dealers.SpawnDealer(k)
            end
        end
    end,

    ---Spawn dealer
    ---@param dealer string
    SpawnDealer = function(dealer)
        local options = Config.Dealers[dealer].Dealer
        local ped = nil

        Utils.LoadModel(options.model)        
        ped = CreatePed(4, options.model, options.pos.x, options.pos.y, options.pos.z, options.heading, false, true)

        Dealers.Data[dealer] = ped

        lib.Target.AddEntity(ped, {
            {
                name = lib.Locale('dealer_interaction'),
                icon = 'fas fa-user-secret',
                label = lib.Locale('dealer_interaction'),
                onSelect = function()
                    DealerMenu(dealer)
                end,
            }
        }, 2)

        if options.animation then
            if options.animation.dict then
                Utils.LoadAnimDict(options.animation.dict)
                TaskPlayAnim(ped, options.animation.dict, options.animation.clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                RemoveAnimDict(options.animation.dict)
            elseif options.animation.scenario then
                TaskStartScenarioInPlace(ped, options.animation.scenario, 0, true)
            end
        end

        SetEntityAsMissionEntity(ped, true, false)
        FreezeEntityPosition(ped, true)
        SetPedCanRagdoll(ped, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 17, true)
        SetEntityInvincible(ped, true)
        SetPedSeeingRange(ped, 0)
    end,

    ---Deletes all created dealer peds
    ClearAllDealers = function()
        for k,v in pairs(Dealers.Data) do 
            lib.Target.RemoveEntityZone(v, lib.Locale('dealer_interaction'))
            DeletePed(v)
            Dealers.Data[k] = nil
        end
    end,

    ---Enable cooldown for a dealer
    ---@param dealer string
    CoolDownDealer = function(dealer)
        ClearPedTasks(Dealers.Data[dealer])
        FreezeEntityPosition(Dealers.Data[dealer], false)
        TaskWanderStandard(Dealers.Data[dealer], 10.0, 10)
        lib.Target.RemoveEntityZone(Dealers.Data[dealer], lib.Locale('dealer_interaction'))
        Dealers.Data[dealer] = nil
    end
}