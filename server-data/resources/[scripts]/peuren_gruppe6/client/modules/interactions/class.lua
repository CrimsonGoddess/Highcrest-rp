Interactions = {
    Data = {},
    
    Set = {       
        ['vehicle'] = function(id, netId, data)
            local bones = {}

            for _, bone in pairs(data.cargo.trunkBones) do
                bones[#bones + 1] = "door_"..bone
                bones[#bones + 1] = "seat_"..bone
            end

            lib.Target.AddBone(bones, {
                {
                    name = lib.Locale("interaction_take_bag"),
                    label = lib.Locale("interaction_take_bag"),
                    bones = bones,
                    icon = 'fas fa-hand-holding',
                    canInteract = function(entity)
                        local veh = NetworkGetEntityFromNetworkId(netId)
                        if veh ~= entity then return end
                        if not Cache.Get(id, 'caryying') then return true end
                        return not Cache.Get(id, 'caryying').state
                    end,
                    onSelect = function(entity)
                        Vehicle.TakeCargo(id, entity, data.cargo)
                    end
                },
                {
                    name = lib.Locale("interaction_place_bag"),
                    label = lib.Locale("interaction_place_bag"),
                    bones = bones,
                    icon = 'fas fa-truck-ramp-box',
                    canInteract = function(entity)
                        local veh = NetworkGetEntityFromNetworkId(netId)
                        if veh ~= entity then return end
                        if not Cache.Get(id, 'caryying') then return end
                        return Cache.Get(id, 'caryying').state
                    end,
                    onSelect = function(entity)
                        Vehicle.PlaceCargo(id, entity, data.cargo)
                    end
                }
            }, 1.2)
        end,

        ['pickup'] = function(id, netId, data)
            lib.Target.AddEntity(netId, {
                {
                    name = lib.Locale("interaction_take_money"),
                    icon = 'fas fa-handshake',
                    label = lib.Locale("interaction_take_money"),
                    canInteract = function()
                        if not Cache.Get(id, 'caryying') then return true end
                        return not Cache.Get(id, 'caryying').state
                    end,
                    onSelect = function()
                        if not Jobs.Data.args then return end

                        local result = Tasks.Get(Jobs.Data.args.groupId, 'pickup')
                        if not result then return end

                        local item = Config.Jobs[Jobs.Data.args.job].bag.item
                        Tasks.AddProgress(id, 'pickup', 1)

                        if not item then 
                            local ped = PlayerPedId()
                            local coords = GetEntityCoords(ped)
                            local heading = GetEntityHeading(ped)
                            local pos = vector4(coords.x, coords.y, coords.z - 180, heading)
                            local bag = Utils.SpawnBag(pos) 
                            Utils.PickUpObject(id, 'bag', bag)
                            return
                        end   

                        Utils.PickUpObject(id, 'bag')
                    end,
                }
            }, 2)        
        end,

        ['deliver'] = function(id, netId, data)
            lib.Target.AddEntity(netId, {
                {
                    name = lib.Locale("interaction_deliver_money"),
                    icon = 'fas fa-handshake',
                    label = lib.Locale("interaction_deliver_money"),
                    canInteract = function()
                        if not Cache.Get(id, 'caryying') then return true end
                        return Cache.Get(id, 'caryying').state
                    end,
                    onSelect = function(entity)      
                        Tasks.AddProgress(id, 'deliver', 1)
                        local cargo = Config.Jobs[Jobs.Data.args.job].bag
                        local ped = PlayerPedId()

                        Utils.LoadAnimDict("veh@common@motorbike@low@ps")
                        TaskPlayAnim(ped, "veh@common@motorbike@low@ps", "pickup", 2.0, 2.0, -1, 51, 0, false, false, false)
                        Wait(500)
                        ClearPedTasks(ped)

                        local item = Config.Jobs[Jobs.Data.args.job].bag.item
                        if item then 
                            Utils.RemoveBag(1)
                        else
                            local clohting = IsPedMale(ped) and cargo.clothing.male or cargo.clothing.female
                            SetPedComponentVariation(ped, clohting.id, 0, 0, 0)
                        end

                        Cache.Set(id, 'caryying', { state = false, type = nil, netId = nil })            
                    end,
                }
            }, 2)        
        end,

        ['trolley'] = function(id, netId, data)
            local trolley = NetworkGetEntityFromNetworkId(netId)

            lib.Target.AddEntity(netId, {
                {
                    name = lib.Locale("interaction_take_money"),
                    icon = 'fas fa-handshake',
                    label = lib.Locale("interaction_take_money"),
                    canInteract = function()
                        if not Cache.Get(id, 'caryying') then return end
                        return Cache.Get(id, 'caryying').state and not Entity(trolley).state.busy 
                    end,
                    onSelect = function(entity)
                        Entity(trolley).state.opened = true
                        Utils.TakeFromTrolley(entity)
                        Tasks.AddProgress(id, 'pickup', 1)
                        Entity(trolley).state.opened = false
                    end,
                }
            }, 2)        
        end,

        ['bag'] = function(id, netId, data)
            lib.Target.AddEntity(netId, {
                {
                    name = lib.Locale("interaction_pickup"),
                    label = lib.Locale("interaction_pickup"),
                    icon = 'fas fa-box',
                    onSelect = function(entity)
                        Utils.PickUpObject(id, 'bag', entity)
                    end
                }
            }, 2)           
        end,

        ['container'] = function(id, netId, data)
            local container = NetworkGetEntityFromNetworkId(netId)

            for _,door in pairs(data) do
                lib.Target.AddEntity(door , {
                    {
                        name = lib.Locale("interaction_open_container"),
                        label = lib.Locale("interaction_open_container"),
                        icon = 'fas fa-hand-holding',
                        canInteract = function()         
                            return not Entity(container).state.opened
                        end,
                        onSelect = function()
                            Entity(container).state.opened = true
                            Utils.ToggleContainerDoor(true, data.leftDoor, data.rightDoor)
                        end
                    },
                    {
                        name = lib.Locale("interaction_close_container"),
                        label = lib.Locale("interaction_close_container"),
                        icon = 'fas fa-truck-ramp-box',
                        canInteract = function()
                            return Entity(container).state.opened
                        end,
                        onSelect = function()
                            Entity(container).state.opened = false
                            Utils.ToggleContainerDoor(false, data.leftDoor, data.rightDoor)
                        end
                    }
                }, 2)  
            end                   
        end,
    },

    Remove = {
        ['pickup'] = function(id, netId, data)
            lib.Target.RemoveEntityZone(netId, lib.Locale("interaction_take_money"))
        end,

        ['trolley'] = function(id, netId, data)
            lib.Target.RemoveEntityZone(netId, lib.Locale("interaction_take_money"))
        end,

        ['container'] = function(id, netId, data)
            for _,door in pairs(data) do 
                lib.Target.RemoveEntityZone(door, {
                    lib.Locale("interaction_open_container"),
                    lib.Locale("interaction_close_container")
                })
            end
        end,
    },

    Register = function(id, type, netId, data)
        if not id or not type then return end
        TriggerServerEvent('peuren_gruppe6:server:CreateInteraction', id, type, netId, data)
    end,
    
    Delete = function(id, type, netId, data)
        if not id or not type then return end
        TriggerServerEvent('peuren_gruppe6:server:RemoveInteraction', id, type, netId, data)
    end
}