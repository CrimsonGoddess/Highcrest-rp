Config = {}
local QBCore = exports['qb-core']:GetCoreObject()

Config.Cooldown = 120 --minutes (Highcrest: was 10)

Config.PoliceCount = 4 --number of police on duty to start (Highcrest: was 0)
Config.TrolleyWorth = 20000 -- Highcrest: value of the marked bills from each cash trolley (6 trolleys)

Config.C4Item = "thermite" --c4 Item

Config.ThermiteItem = "thermite" --thermite Item

Config.UseVaultDoor = true --if you want to use elevator and open the vault door

Config.PedModel = `a_m_m_genfat_01` --start ped model
Config.PedLoc = vector4(-748.83, 687.8, 143.75, 190.16) --ped location
Config.PedScenarioAnim = "WORLD_HUMAN_DRUG_DEALER" --Ped animation

Config['unionguards'] = {
    ['npcguards1'] = {
        { coords = vector3(-11.51, -694.63, 16.13), heading = 318.37, model = 'cs_casey'},
        { coords = vector3(5.83, -702.09, 16.13), heading = 61.91, model = 'cs_casey'},
        { coords = vector3(-4.07, -698.79, 16.13), heading = 334.91, model = 'cs_casey'},
        { coords = vector3(0.69, -706.51, 16.13), heading = 5.9, model = 'cs_casey'},
    },
}

Config.PedWeapon = `WEAPON_SMG`

-------------------------------dispatch--------------------------

AlertCops = function() --you can edit your dispatch code inside that function

    -- exports["ps-dispatch"]:CustomAlert({
    --     coords = GetEntityCoords(PlayerPedId()),
    --     message = "Union heist",
    --     dispatchCode = "10-90 Union",
    --     description = "Bang Bang",
    --     radius = 0,
    --     sprite = 64,
    --     color = 2,
    --     scale = 1.0,
    --     length = 3,
    -- })
    
end

ReceiveItems = function() --you can edit this function to give the item you want or money

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    Player.Functions.AddItem('markedbills', 1, false, { worth = Config.TrolleyWorth }) -- Highcrest: one bill carrying the value, like the other robberies
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")
    
end


----------------------------------Lang-----------------------------

Config.Lang = {
    --notifys
    ['robbed'] = 'Someone already rob this!',
    ['noitem'] = 'You are missing something!',
    ['nocops'] = 'No Cops!',
    ['cooldown'] = 'Cooldown!',
    ['willloc'] = 'You will recieve a location!',
    ['loc'] = 'You recieved a location!',

    --progress

    ['thermite'] = 'Using thermite...',
    ['c4'] = 'Using c4...',
    ['elev'] = 'Using elevator...',
    ['money'] = 'Robbing money...',

    --target
    ['rob'] = 'Rob Money',
    ['explode'] = 'Explode Door',
    ['usethermite'] = 'Apply Thermite',
    ['usec4'] = 'Apply C4',
    ['useelev'] = 'Use Lift',
    ['start'] = 'Start Heist',

    

}