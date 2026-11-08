local TSE = TriggerServerEvent

if Config.Shop.enabled then

RegisterNetEvent("drc_moneywash:Shop:menus", function()
    PlayPedAmbientSpeechNative(MoneyWashNPC, 'Generic_Hows_It_Going', 'Speech_Params_Force')
    options = {}
    if Config.Context == "ox_lib" then
        for _, v in pairs(Config.Shop.Items) do
            options[v.label] = {}
            options[v.label].arrow = false
            options[v.label].description = v.description .. v.price
            options[v.label].event = 'drc_moneywash:Shop:progress'
            options[v.label].image = v.image
            options[v.label].args = { item = v.item, price = v.price, min = v.MinAmount, 
                max = v.MaxAmount }
        end
        lib.registerContext({
            id = 'Shop',
            title = Config.Shop.Header,
            options = options
        })
        lib.showContext('Shop')
    elseif Config.Context == "qbcore" then
        options[#options + 1] = {
            isMenuHeader = true,
            header = Config.Shop.Header
        }

        for _, v in pairs(Config.Shop.Items) do
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

RegisterNetEvent("drc_moneywash:Shop:progress")
AddEventHandler("drc_moneywash:Shop:progress", function(data)
    if Config.Input == "qb-input" then
        local dialog = exports['qb-input']:ShowInput({
            header = locale("Pricefor") .. data.price,
            submitText = "Submit",
            inputs = {
                {
                    text = locale("Amount") .. locale("Range") .. data.min .. ' - ' .. data.max,
                    name = "amount",
                    type = "number",
                    isRequired = true,
                }
            }
        })
        if dialog then
            input = tonumber(dialog["amount"])
        else
            Notify('error', locale('error'), locale('InvalidAmount'))
            return -- Return if dialog is nil
        end
    elseif Config.Input == "ox_lib" then
        local inputDialog = lib.inputDialog(locale("Pricefor") .. data.price,
            { locale("Amount") .. locale("Range") .. data.min .. ' - ' .. data.max })
        if not inputDialog or not inputDialog[1] then
            Notify('error', locale('error'), locale('InvalidAmount'))
            return
        end
        input = tonumber(inputDialog[1])
    end

    if not input then
        Notify('error', locale('error'), locale('InvalidAmount'))
        return 
    end
    amount = input
    if tonumber(amount) >= data.min and tonumber(amount) <= data.max then
        lib.callback('drc_moneywash:Shop:getitem', false, function(value)
            if value then
                dict = "misscarsteal4@actor"
                clip = "actor_berating_loop"
                RequestAnimDict(dict)
                while (not HasAnimDictLoaded(dict)) do Wait(0) end
                TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                ProgressBar(2500, locale("buying"))
                ClearPedTasks(cache.ped)
                PlayPedAmbientSpeechNative(MoneyWashNPC, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
                TSE("drc_moneywash:Shop:giveitems", data.item, data.price, amount)
            else
                Notify("error", locale("error"), locale("RequiredItems"))
            end
        end, data.price, amount)
    else
        Notify("error", locale("error"), locale("IvalidAmount"))
    end
end)

local ShopPed = nil
local Spawned = false
CreateThread(function()
    while true do
        Wait(1000)
        local Coords = GetEntityCoords(PlayerPedId())
        local distance = #(Coords - vec3(Config.Shop.Ped.coords.xyz))
        if distance < Config.Shop.Ped.renderdistance and not Spawned then
            Spawned = true
            RequestModel(Config.Shop.Ped.model)

            while not HasModelLoaded(Config.Shop.Ped.model) do
                Wait(100)
            end

            MoneyWashNPC = CreatePed(4, Config.Shop.Ped.model, Config.Shop.Ped.coords.x, Config.Shop.Ped.coords.y, Config.Shop.Ped.coords.z, Config.Shop.Ped.coords.w, false, true)
            ShopPed = MoneyWashNPC
                if Config.InteractionType == 'textui' or Config.InteractionType == "3dtext" then
                    npctxtui = lib.zones.sphere({
                        coords = GetEntityCoords(MoneyWashNPC),
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('drc_moneywash:Shop:menus')
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
                    target:AddTargetEntity(MoneyWashNPC, {
                        options = {
                            {
                                type = "client",
                                event = "drc_moneywash:Shop:menus",
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
                SetEntityAlpha(MoneyWashNPC, i, false)
            end
            FreezeEntityPosition(MoneyWashNPC, true)
            SetEntityInvincible(MoneyWashNPC, true)
            SetBlockingOfNonTemporaryEvents(MoneyWashNPC, true)
            TaskStartScenarioInPlace(MoneyWashNPC, Config.Shop.Ped.scenario, 0, true)
        elseif distance >= Config.Shop.Ped.renderdistance and Spawned then
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