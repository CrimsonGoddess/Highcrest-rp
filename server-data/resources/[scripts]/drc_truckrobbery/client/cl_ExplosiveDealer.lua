local TSE = TriggerServerEvent

if Config.Shop.enabled then

RegisterNetEvent("drc_truckrobbery:Shop:menus", function()
    PlayPedAmbientSpeechNative(truckrobberyNPC, 'Generic_Hows_It_Going', 'Speech_Params_Force')
    options = {}
    if Config.Context == "ox_lib" then
        for _, v in pairs(Config.Shop.Items) do
            options[v.label] = {}
            options[v.label].arrow = false
            options[v.label].description = v.description .. v.price
            options[v.label].event = 'drc_truckrobbery:Shop:progress'
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
                    event = 'drc_truckrobbery:Shop:progress',
                    args = { item = v.item, price = v.price, min = v.MinAmount, 
                        max = v.MaxAmount }
                }
            }
        end
        exports['qb-menu']:openMenu(options)
    end
end)

RegisterNetEvent("drc_truckrobbery:Shop:progress")
AddEventHandler("drc_truckrobbery:Shop:progress", function(data)
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
            amount = tonumber(dialog["amount"])
        end
    elseif Config.Input == "ox_lib" then
        amount = lib.inputDialog(locale("Pricefor") .. data.price,
            { locale("Amount") .. locale("Range") .. data.min .. ' - ' .. data.max })
        amount = tonumber(amount[1])
    end

    if amount then
        if tonumber(amount) >= data.min and tonumber(amount) <= data.max then
            lib.callback('drc_truckrobbery:Shop:getitem', false, function(value)
                if value then
                    dict = "misscarsteal4@actor"
                    clip = "actor_berating_loop"
                    RequestAnimDict(dict)
                    while (not HasAnimDictLoaded(dict)) do Wait(0) end
                    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                    ProgressBar(2500, locale("buying"))
                    ClearPedTasks(cache.ped)
                    PlayPedAmbientSpeechNative(truckrobberyNPC, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
                    TSE("drc_truckrobbery:Shop:giveitems", data.item, data.price, amount)
                else    
                    showNotification(locale("RequiredItems"), 'error')
                end
            end, data.price, amount)
        else
            showNotification(locale("IvalidAmount"), 'error')
        end
    else
        showNotification(locale("IvalidAmount"), 'error')
    end
end)

local ShopPed = nil
local Spawned = false
CreateThread(function()
    while true do
        Wait(1000)

        if Config.Shop.Time.enabled then
            local hour = GetClockHours()
            local isTimeInRange = (hour >= Config.Shop.Time.time.from or hour < Config.Shop.Time.time.to)

            if not isTimeInRange then
                if Spawned then
                    for i = 255, 0, -51 do
                        Wait(50)
                        SetEntityAlpha(ShopPed, i, false)
                    end
                    DeletePed(ShopPed)
                    Spawned = false
                end
                goto continue
            end
        end
        
        local Coords = GetEntityCoords(PlayerPedId())
        local distance = #(Coords - vec3(Config.Shop.Ped.coords.xyz))
        
        if distance < 20 and not Spawned then
            Spawned = true
            RequestModel(Config.Shop.Ped.model)

            while not HasModelLoaded(Config.Shop.Ped.model) do
                Wait(100)
            end

            truckrobberyNPC = CreatePed(4, Config.Shop.Ped.model, Config.Shop.Ped.coords.x, Config.Shop.Ped.coords.y, Config.Shop.Ped.coords.z, Config.Shop.Ped.coords.w, false, true)
            ShopPed = truckrobberyNPC
                if Config.InteractionType == 'textui' or Config.InteractionType == "3dtext" then
                    npctxtui = lib.zones.sphere({
                        coords = GetEntityCoords(truckrobberyNPC),
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('drc_truckrobbery:Shop:menus')
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
                        AddTargetEntity(truckrobberyNPC, {
                        options = {
                            {
                                type = "client",
                                event = "drc_truckrobbery:Shop:menus",
                                icon = "fas fa-bomb",
                                label = locale("shop")
                            },
                        },
                        distance = 2
                    })
                end)
            end
            for i = 0, 255, 51 do
                Wait(50)
                SetEntityAlpha(truckrobberyNPC, i, false)
            end
            FreezeEntityPosition(truckrobberyNPC, true)
            SetEntityInvincible(truckrobberyNPC, true)
            SetBlockingOfNonTemporaryEvents(truckrobberyNPC, true)
            TaskStartScenarioInPlace(truckrobberyNPC, Config.Shop.Ped.scenario, 0, true)
        elseif distance >= 20 and Spawned then
            for i = 255, 0, -51 do
                Wait(50)
                SetEntityAlpha(ShopPed, i, false)
            end
            DeletePed(ShopPed)
            Spawned = false
        end
        ::continue::
    end
end)

end