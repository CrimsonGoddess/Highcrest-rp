local TSE = TriggerServerEvent

if Config.WarehouseShop.enabled then

RegisterNetEvent("drc_moneywash:WarehouseMenu", function()
    PlayPedAmbientSpeechNative(WarehouseSellerNPC, 'Generic_Hows_It_Going', 'Speech_Params_Force')
    options = {}
    lib.callback('drc_moneywash:checkhouses', false, function(value)
        if value then
            if Config.Context == "ox_lib" then
                for k, v in pairs(Config.Warehouses) do
                    
                    for g, b in pairs(value) do
                        if b == k then
                            options[v.label] = {}
                            options[v.label].arrow = false
                            options[v.label].description = v.description .. "    \n" .. locale("Price") .. v.price
                            options[v.label].event = 'drc_moneywash:WarehouseSubMenu'
                            options[v.label].image = v.image
                            options[v.label].icon = "warehouse"
                            options[v.label].args = { house = k }
                        end
                    end
                end
                lib.registerContext({
                    id = 'WarehouseSeller',
                    title = locale("warehouseshop"),
                    options = options
                })
                lib.showContext('WarehouseSeller')
            elseif Config.Context == "qbcore" then
                options[#options + 1] = {
                    isMenuHeader = true,
                    header = locale("warehouseshop")
                }

                for k, v in pairs(Config.Warehouses) do
                    options[#options + 1] = {
                        header = v.label,
                        arrow = false,
                        txt = v.description .. "    \n" .. locale("Price") .. v.price,
                        params = {
                            event = 'drc_moneywash:WarehouseSubMenu',
                            args = { house = k }
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

RegisterNetEvent("drc_moneywash:WarehouseSubMenu", function(data)
    if Config.Context == "ox_lib" then
        lib.registerContext({
            id = 'ConfirmMenu',
            title = locale("ConfirmPurchase"),
            options = {
                {
                    title = locale("ConfirmYes"),
                    icon = 'check',
                    event = 'drc_moneywash:WarehouseSeller:buy',
                    args = {
                        house = data.house
                    }
                },
                {
                    title = locale("ConfirmNo"),
                    icon = 'circle-xmark',
                    onSelect = function()
                        
                    end,
                },
                {
                    title = locale("ConfirmMap"),
                    icon = 'map',
                    event = 'drc_moneywash:WarehouseSeller:map',
                    args = {
                        house = data.house
                    }
                },
            },
        })
        lib.showContext('ConfirmMenu')
    elseif Config.Context == "qbcore" then
        exports['qb-menu']:openMenu({
            {
                header = locale("ConfirmPurchase"),
                icon = 'fas fa-warehouse',
                isMenuHeader = true,
            },
            {
                header = locale("ConfirmYes"),
                txt = '',
                icon = 'fas fa-check',
                params = {
                    event = 'drc_moneywash:WarehouseSeller:buy',
                    args = {
                        house = data.house
                    }
                }
            }, 
            {
                header = locale("ConfirmNo"),
                txt = '',
                icon = 'fas fa-circle-xmark',
                params = {
                    event = '',
                }
            },  
            {
                header = locale("ConfirmMap"),
                txt = '',
                icon = 'fas fa-map',
                params = {
                    event = 'drc_moneywash:WarehouseSeller:map',
                    args = {
                        house = data.house
                    }
                }
            },  
        })
    end
end)

RegisterNetEvent('drc_moneywash:WarehouseSeller:map', function(data)
    for k, v in pairs(Config.Warehouses) do
        if k == data.house then
            Notify("info", locale("info"), locale("WaypointMap"))
            SetNewWaypoint(v.Coords.x, v.Coords.y)
        end
    end
end)

RegisterNetEvent("drc_moneywash:WarehouseSellMenu", function()
    PlayPedAmbientSpeechNative(WarehouseSellerNPC, 'Generic_Hows_It_Going', 'Speech_Params_Force')
    options = {}
    lib.callback('drc_moneywash:checkownedhouses', false, function(value)
        if value then
            if Config.Context == "ox_lib" then
                for k, v in pairs(Config.Warehouses) do
                    
                    for g, b in pairs(value) do
                        if b == k then
                            options[v.label] = {}
                            options[v.label].arrow = false
                            options[v.label].description = locale("sellprice") .."" .. math.floor(v.price * Config.ResellValue / 100)
                            options[v.label].image = v.image
                            options[v.label].icon = "warehouse"
                            options[v.label].event = 'drc_moneywash:WarehouseSeller:sell'
                            options[v.label].args = { house = k }
                        end
                    end
                end
                lib.registerContext({
                    id = 'WarehouseSeller',
                    title = locale("warehousessell"),
                    options = options
                })
                lib.showContext('WarehouseSeller')
            elseif Config.Context == "qbcore" then
                options[#options + 1] = {
                    isMenuHeader = true,
                    header = locale("warehousessell")
                }

                for k, v in pairs(Config.Warehouses) do
                    options[#options + 1] = {
                        header = v.label,
                        arrow = false,
                        txt = locale("sellprice") .."" .. math.floor(v.price * Config.ResellValue / 100),
                        params = {
                            event = 'drc_moneywash:WarehouseSeller:sell',
                            args = { house = k }
                        }
                    }
                end
                exports['qb-menu']:openMenu(options)
            end
        else
            Notify("error", locale("error"), locale("nowarehousestosell"))
        end
    end)
end)

RegisterNetEvent("drc_moneywash:WarehouseSeller:sell")
AddEventHandler("drc_moneywash:WarehouseSeller:sell", function(data)
    lib.callback('drc_moneywash:sellwarehouse', false, function(value)
        if value then
            dict = "misscarsteal4@actor"
            clip = "actor_berating_loop"
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2000, locale("selling"))
            ClearPedTasks(cache.ped)
            PlayPedAmbientSpeechNative(WarehouseSellerNPC, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
            Notify("success", locale("success"), locale("warehousesold"))
        else
            Notify("error", locale("error"), locale("nomoney"))
        end
    end, data.house)
end)


RegisterNetEvent("drc_moneywash:WarehouseSeller:buy")
AddEventHandler("drc_moneywash:WarehouseSeller:buy", function(data)
    lib.callback('drc_moneywash:purchasewarehouse', false, function(value)
        if value then
            if value == "alreadyown" then
                Notify("error", locale("error"), locale("onlyone"))
            else
                dict = "misscarsteal4@actor"
                clip = "actor_berating_loop"
                RequestAnimDict(dict)
                while (not HasAnimDictLoaded(dict)) do Wait(0) end
                TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                ProgressBar(2000, locale("buying"))
                ClearPedTasks(cache.ped)
                PlayPedAmbientSpeechNative(WarehouseSellerNPC, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
                Notify("success", locale("success"), locale("warehousebought"))
            end
        else
            Notify("error", locale("error"), locale("nomoney"))
        end
    end, data.house)
end)

local WarehouseSellerPed = nil
local Spawned = false
CreateThread(function()
    while true do
        Wait(2000)
        local Coords = GetEntityCoords(PlayerPedId())
        local distance = #(Coords - vec3(Config.WarehouseShop.Ped.coords.xyz))
        if distance < Config.WarehouseShop.Ped.renderdistance and not Spawned then
            Spawned = true
            RequestModel(Config.WarehouseShop.Ped.model)

            while not HasModelLoaded(Config.WarehouseShop.Ped.model) do
                Wait(100)
            end

            WarehouseSellerNPC = CreatePed(4, Config.WarehouseShop.Ped.model, Config.WarehouseShop.Ped.coords.x, Config.WarehouseShop.Ped.coords.y, Config.WarehouseShop.Ped.coords.z, Config.WarehouseShop.Ped.coords.w, false, true)
            WarehouseSellerPed = WarehouseSellerNPC
                if Config.InteractionType == 'textui' or Config.InteractionType == "3dtext" then
                    npctxtui = lib.zones.sphere({
                        coords = GetEntityCoords(WarehouseSellerNPC),
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('drc_moneywash:WarehouseMenu')
                            end
                            if IsControlJustReleased(0, 74) then
                                TriggerEvent('drc_moneywash:WarehouseSellMenu')
                            end

                            if Config.InteractionType == "3dtext" then
                                Draw3DText(self.coords, string.format("[~g~E~w~] - %s  \n [~g~H~w~] - %s", locale('warehouses'), locale('sell')))
                            end
                        end,
                        onEnter = function()
                            if Config.InteractionType == "textui" then
                                TextUIShow('[E] - ' .. locale('warehouses') .. '  \n [H] - '.. locale('sell'))
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
                    target:AddTargetEntity(WarehouseSellerNPC, {
                        options = {
                            {
                                type = "client",
                                event = "drc_moneywash:WarehouseMenu",
                                icon = "fas fa-warehouse",
                                label = locale("warehouses")
                            },
                            {
                                type = "client",
                                event = "drc_moneywash:WarehouseSellMenu",
                                icon = "fas fa-money-bill",
                                label = locale("sell")
                            },
                        },
                        distance = 2
                    })
                end)
            end
            for i = 0, 255, 51 do
                Wait(50)
                SetEntityAlpha(WarehouseSellerNPC, i, false)
            end
            FreezeEntityPosition(WarehouseSellerNPC, true)
            SetEntityInvincible(WarehouseSellerNPC, true)
            SetBlockingOfNonTemporaryEvents(WarehouseSellerNPC, true)
            TaskStartScenarioInPlace(WarehouseSellerNPC, Config.WarehouseShop.Ped.scenario, 0, true)
        elseif distance >= Config.WarehouseShop.Ped.renderdistance and Spawned then
            for i = 255, 0, -51 do
                Wait(50)
                SetEntityAlpha(WarehouseSellerPed, i, false)
            end
            DeletePed(WarehouseSellerPed)
            Spawned = false
        end
    end
end)

end