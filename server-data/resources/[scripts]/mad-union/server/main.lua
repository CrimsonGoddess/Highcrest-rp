
local QBCore = exports['qb-core']:GetCoreObject()


---------------------------------------------------------------------------
-- Highcrest: doors live in ox_doorlock (created here on start), and the door and payout
-- events only work during a heist, near the vault, a limited number of times.
---------------------------------------------------------------------------
local VAULT = vector3(2.69, -667.0, 16.13)
local HEIST_MINUTES = 60
local MAX_TROLLEYS = 6
HeistUntil = 0
local looted = {}

local UNION_DOORS = {
    ['union-1'] = { vec3(8.171528, -672.439270, 16.358606), 160.0, -1011692606 },
    ['union-2'] = { vec3(-3.584450, -668.164368, 16.358606), 340.0, -1011692606 },
    ['union-3'] = { vec3(4.351732, -682.933899, 16.358606), 160.0, -1011692606 },
    ['union-4'] = { vec3(-7.404243, -678.658997, 16.358606), 340.0, -1011692606 },
    ['union-10'] = { vec3(-0.977407, -671.113159, 16.358603), 250.0, -1011692606 },
    ['union-11'] = { vec3(4.278027, -673.023743, 16.358603), 250.0, -1011692606 },
    ['union-12'] = { vec3(2.266483, -678.550903, 16.358603), 250.0, -1011692606 },
    ['union-13'] = { vec3(-2.989136, -676.640259, 16.358603), 250.0, -1011692606 },
    ['union-14'] = { vec3(-1.656235, -662.132874, 16.358603), 340.0, -1011692606 },
    ['union-15'] = { vec3(10.572834, -666.583923, 16.358604), 160.0, -1011692606 },
    ['union-vault'] = { vec3(-1.727947, -686.541748, 16.689131), 160.0, -1932297301 },
}

local function heistActive() return os.time() < HeistUntil end

local function nearVault(src)
    return #(GetEntityCoords(GetPlayerPed(src)) - VAULT) < 60.0
end

local function doorId(name)
    local door = exports.ox_doorlock:getDoorFromName(name)
    return door and door.id
end

CreateThread(function()
    while GetResourceState('ox_doorlock') ~= 'started' do Wait(500) end
    Wait(2000)
    for name, d in pairs(UNION_DOORS) do
        local id = doorId(name)
        if not id then
            -- No groups or items: nobody can open these by hand, only the heist (and admins).
            exports.ox_doorlock:createDoor({
                name = name, coords = d[1], heading = d[2], model = d[3],
                state = 1, maxDistance = 2.0, hideUi = true,
            })
        else
            exports.ox_doorlock:setDoorState(id, 1)
        end
    end
end)

RegisterNetEvent('mad-union:server:door', function(name, locked)
    local src = source
    if not UNION_DOORS[name] then return end
    if not locked and not (heistActive() and nearVault(src)) then return end
    local id = doorId(name)
    if id then exports.ox_doorlock:setDoorState(id, locked and 1 or 0) end
end)

local function copsOnDuty()
    local cops = 0
    for _, id in ipairs(GetPlayers()) do
        local player = exports.qbx_core:GetPlayer(tonumber(id))
        local job = player and player.PlayerData.job
        if job and job.type == 'leo' and job.onduty then cops = cops + 1 end
    end
    return cops
end

RegisterServerEvent('mv-union:server:coolout', function()
    if Cooldown or copsOnDuty() < Config.PoliceCount then return end
    HeistUntil = os.time() + HEIST_MINUTES * 60
    looted = {}
    Cooldown = true
    local timer = Config.Cooldown * 60000
    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            Cooldown = false
            TriggerClientEvent("mv-union:client:clear", -1)
        end
    end
end)

QBCore.Functions.CreateCallback("mv-union:server:coolc",function(source, cb)
    if Cooldown then
        cb(true)
    else
        cb(false) 
    end
end)

QBCore.Functions.CreateCallback('union:server:getCops', function(source, cb)
	local cops = 0
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                cops = cops + 1
            end
        end
	end
	cb(copsOnDuty()) -- Highcrest: any on-duty law enforcement (job type leo)
end)


RegisterServerEvent('union:server:c4')
AddEventHandler('union:server:c4', function()
	TriggerClientEvent('c4:sync',-1)
end)

RegisterServerEvent("union:server:particleserver")
AddEventHandler("union:server:particleserver", function(particleCoords)
    TriggerClientEvent("union:client:ptfxparticle", -1, particleCoords)
end)

RegisterServerEvent("union:server:c4sync")
AddEventHandler("union:server:c4sync", function()
    TriggerClientEvent("union:client:c4sync", -1)
end)

RegisterServerEvent("union:server:c4syncCells")
AddEventHandler("union:server:c4syncCells", function(coords)
    TriggerClientEvent("union:client:c4syncCells", -1, coords)
end)

RegisterServerEvent("union:server:syncloot")
AddEventHandler("union:server:syncloot", function(index)
    TriggerClientEvent("union:client:syncloot", -1, index)
end)

RegisterServerEvent("union:server:removethermite")
AddEventHandler("union:server:removethermite", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    Player.Functions.RemoveItem(Config.ThermiteItem, 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ThermiteItem], "remove")
    
end)

RegisterServerEvent("union:server:removec4")
AddEventHandler("union:server:removec4", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    Player.Functions.RemoveItem(Config.C4Item, 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.C4Item], "remove")
    
end)

RegisterServerEvent("union:server:receive")
AddEventHandler("union:server:receive", function()
    -- Highcrest: only during a heist, at the vault, and once per trolley.
    local src = source
    if not heistActive() or not nearVault(src) then return end
    looted[src] = (looted[src] or 0) + 1
    if looted[src] > MAX_TROLLEYS then return end
    ReceiveItems()
end)


