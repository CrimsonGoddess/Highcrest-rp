Dumpsters = {}

if Config.DumpsterDiving.Enable then
    debugPrint("^5Debug^7: ^2Loading^7: '^6Dumpster Diving^7'")
    local Searching = false -- No touch

    -- Dumpster Third Eye
    onPlayerLoaded(function()
        createModelTarget(Config.DumpsterDiving.models, {
            {
                action = function(data)
                    Dumpsters.StartSearch(type(data) == "table" and data.entity or data)
                end,
                icon = "fas fa-dumpster",
                label = locale("target", "search_trash"),
            }
        }, 1.5)
    end, true)

    Dumpsters.StartSearch = function(entity)
        local Ped = PlayerPedId()
        if Searching then return end
        Searching = true

        local searched = false
        debugPrint("^5Debug^7: ^2Starting Search of entity^7: '^6" .. entity .. "^7'")

        if Config.DumpsterDiving.searched[entity] then
            triggerNotify(nil, locale("error", "searched"), "error")
            Searching = false
            lockInv(false)
            return
        end

        if not searched then
            lookEnt(entity)
            playAnim("anim@amb@machinery@speed_drill@", "look_around_left_02_amy_skater_01", 35000, 1, Ped)

            -- NO SKILLCHECK / MINIGAME
            triggerNotify(nil, locale("success", "get_trash"), "success")
            Dumpsters.searchAnim(GetEntityCoords(entity))

            Config.DumpsterDiving.searched[entity] = true
            Wait(1000)
            stopAnim("anim@amb@machinery@speed_drill@", "look_around_left_02_amy_skater_01", Ped)
        end
    end

    -- Search animations
    Dumpsters.searchAnim = function(coords)
        local Ped = PlayerPedId()

        if #(coords - GetEntityCoords(Ped)) > 1.5 then
            TaskGoStraightToCoord(Ped, coords, 0.4, 200, 0.0, 0)
            Wait(300)
        end

        lookEnt(coords)
        playAnim("amb@prop_human_bum_bin@base", "base", Config.DumpsterDiving.searchTime, 1, Ped)
        lockInv(true)

        if progressBar({
            label = locale("progressbar", "search"),
            time = Config.DumpsterDiving.searchTime,
            cancel = true,
        }) then
            TriggerServerEvent("jim-recycle:server:getDumpsterReward")
        end

        stopAnim("amb@prop_human_bum_bin@base", "base", Ped)
        lockInv(false)
        Searching = false
    end
end
