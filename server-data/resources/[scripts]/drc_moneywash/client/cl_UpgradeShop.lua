local TSE = TriggerServerEvent

if Config.UpgradeShop.enabled then

RegisterNetEvent("drc_moneywash:upgradesmainmenu", function()
    PlayPedAmbientSpeechNative(houserobberyNPC, 'Generic_Hows_It_Going', 'Speech_Params_Force')
    options = {}
    if Config.Context == "ox_lib" then
        for k, v in pairs(Config.UpgradeShop.Items) do
            if v.enabled then
                options[v.label] = {}
                options[v.label].arrow = false
                options[v.label].description = v.description .. v.price
                options[v.label].image = v.image
                options[v.label].icon = v.icon
                options[v.label].event = 'drc_moneywash:upgrades:houses'
                options[v.label].args = { type = k, price = v.price }
            end
        end
        lib.registerContext({
            id = 'Shop',
            title = locale("upgradeshop"),
            options = options
        })
        lib.showContext('Shop')
    elseif Config.Context == "qbcore" then
        options[#options + 1] = {
            isMenuHeader = true,
            header = locale("upgradeshop")
        }

        for _, v in pairs(Config.UpgradeShop.Items) do
            options[#options + 1] = {
                header = v.label,
                arrow = false,
                txt = v.description .. v.price,
                params = {
                    event = 'drc_moneywash:Shop:progress',
                    args = { item = v.item, price = v.price, min = v.MinAmount, 
                        max = v.MaxAmount }
                }
            }
        end
        exports['qb-menu']:openMenu(options)
    end
end)

RegisterNetEvent("drc_moneywash:upgrades:houses")
AddEventHandler("drc_moneywash:upgrades:houses", function(data)
    options = {}
    lib.callback('drc_moneywash:checkownedhouses', false, function(value)
        if value then
            if Config.Context == "ox_lib" then
                for k, v in pairs(Config.Warehouses) do
                    for g, b in pairs(value) do
                        if b == k then
                            options[v.label] = {}
                            options[v.label].arrow = false
                            options[v.label].description = locale("upgradethis")
                            options[v.label].event = 'drc_moneywash:upgrades:buy'
                            options[v.label].image = v.image
                            options[v.label].args = { house = k, type = data.type, }
                        end
                    end
                end
                lib.registerContext({
                    id = 'upgradehouses',
                    title = locale("selectwarehouse"),
                    options = options
                })
                lib.showContext('upgradehouses')
            elseif Config.Context == "qbcore" then
                options[#options + 1] = {
                    isMenuHeader = true,
                    header = locale("selectwarehouse")
                }

                for _, v in pairs(Config.Warehouses) do
                    options[#options + 1] = {
                        header = v.label,
                        arrow = false,
                        txt = locale("upgradethis"),
                        params = {
                            event = 'drc_moneywash:upgrades:buy',
                            args = { house = k, type = data.type, }
                        }
                    }
                end
                exports['qb-menu']:openMenu(options)
            end
        else
            Notify("error", locale("error"), locale("nowarehouses"))
        end
    end)
end)

RegisterNetEvent("drc_moneywash:upgrades:buy")
AddEventHandler("drc_moneywash:upgrades:buy", function(data)
    lib.callback('drc_moneywash:upgrade', false, function(value)
        if value then
            if value == "needlaundry" then
                Notify("error", locale("error"), locale("needlaundry"))
            elseif value == "alreadybought" then
                Notify("error", locale("error"), locale("alreadybought"))
            elseif value == "nomoney" then
                Notify("error", locale("error"), locale("nomoney"))
            else
            dict = "misscarsteal4@actor"
            clip = "actor_berating_loop"
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("buying"))
            ClearPedTasks(cache.ped)
            PlayPedAmbientSpeechNative(houserobberyNPC, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
            end
        else
            Notify("error", locale("error"), locale("RequiredItems"))
        end
    end, data.house, data.type, "buy")
end)

local ShopPed = nil
local Spawned = false
CreateThread(function()
    while true do
        Wait(2000)
        local Coords = GetEntityCoords(PlayerPedId())
        local distance = #(Coords - vec3(Config.UpgradeShop.Ped.coords.xyz))
        if distance < Config.UpgradeShop.Ped.renderdistance and not Spawned then
            Spawned = true
            RequestModel(Config.UpgradeShop.Ped.model)

            while not HasModelLoaded(Config.UpgradeShop.Ped.model) do
                Wait(100)
            end

            houserobberyNPC = CreatePed(4, Config.UpgradeShop.Ped.model, Config.UpgradeShop.Ped.coords.x, Config.UpgradeShop.Ped.coords.y, Config.UpgradeShop.Ped.coords.z, Config.UpgradeShop.Ped.coords.w, false, true)
            ShopPed = houserobberyNPC
                if Config.InteractionType == 'textui' or Config.InteractionType == "3dtext" then
                    npctxtui = lib.zones.sphere({
                        coords = GetEntityCoords(houserobberyNPC),
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('drc_moneywash:upgradesmainmenu')
                            end

                            if Config.InteractionType == "3dtext" then
                                Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('buy')))
                            end
                        end,
                        onEnter = function()
                            if Config.InteractionType == "textui" then
                                TextUIShow('[E] - ' .. locale('buy'))
                            end
                        end,
                        onExit = function()
                            if Config.InteractionType == "textui" then
                                TextUIHide()
                            end
                        end
                    })
                elseif Config.InteractionType == 'target' then
                    SetTimeout(1000, function()
                    target = Target()
                    target:AddTargetEntity(houserobberyNPC, {
                        options = {
                            {
                                type = "client",
                                event = "drc_moneywash:upgradesmainmenu",
                                icon = "fas fa-laptop",
                                label = locale("shop")
                            },
                        },
                        distance = 2
                    })
                end)
            end
            for i = 0, 255, 51 do
                Wait(50)
                SetEntityAlpha(houserobberyNPC, i, false)
            end
            FreezeEntityPosition(houserobberyNPC, true)
            SetEntityInvincible(houserobberyNPC, true)
            SetBlockingOfNonTemporaryEvents(houserobberyNPC, true)
            TaskStartScenarioInPlace(houserobberyNPC, Config.UpgradeShop.Ped.scenario, 0, true)
        elseif distance >= Config.UpgradeShop.Ped.renderdistance and Spawned then
            for i = 255, 0, -51 do
                Wait(50)
                SetEntityAlpha(ShopPed, i, false)
            end
            DeletePed(ShopPed)
            Spawned = false
        end
    end
end)

end
