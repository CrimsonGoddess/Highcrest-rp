Radar = {
    isActive = false,
    scaleformMovie = nil,
    scaleformTarget = nil,
    coords = nil,
    inZone = false,
    soundID = nil,

    Start = function(coords)
        if Radar.isActive then return end

        Radar.isActive = true
        Radar.coords = coords
        Minigame.RadarHandler()

        Radar.scaleformMovie = RequestScaleformMovie("digiscanner")
        while not HasScaleformMovieLoaded(Radar.scaleformMovie) do
            Citizen.Wait(1)
        end

        RegisterNamedRendertarget("digiscanner", false)

        if not IsNamedRendertargetRegistered("digiscanner") then
            RegisterNamedRendertarget("digiscanner", false)
        end

        LinkNamedRendertarget(GetWeapontypeModel("WEAPON_DIGISCANNER"))

        if IsNamedRendertargetRegistered("digiscanner") then
            Radar.scaleformTarget = GetNamedRendertargetRenderId("digiscanner")
        end

        Radar.soundID = GetSoundId()

        Citizen.CreateThread(function()
            local gameTimer = GetGameTimer()
            while Radar.isActive do
                local pPed = PlayerPedId()
                local _, currWeapon = GetCurrentPedWeapon(pPed, true)
                if currWeapon == GetHashKey("WEAPON_DIGISCANNER") then
                    BeginScaleformMovieMethod(Radar.scaleformMovie, "SET_COLOUR")
                    
                    local pCoords = GetEntityCoords(pPed)

                    local distance = #(pCoords - coords)
                    local calculatedDistance = (25 - distance) / 25

                    if calculatedDistance < 0.0 then calculatedDistance = 0.0 end

                    if calculatedDistance > 0.9 then
                        ScaleformMovieMethodAddParamInt(0)
                        ScaleformMovieMethodAddParamInt(255)
                        ScaleformMovieMethodAddParamInt(0)
                        ScaleformMovieMethodAddParamInt(0)
                        ScaleformMovieMethodAddParamInt(255)
                        ScaleformMovieMethodAddParamInt(0)
                        ScaleformMovieMethodAddParamInt(0)
                        ScaleformMovieMethodAddParamInt(0)
                        ScaleformMovieMethodAddParamInt(0)
                        EndScaleformMovieMethod()

                        Radar.inZone = true

                        if IsControlJustPressed(2, 38) then
                            local minigameResult = Minigame.Start()

                            if minigameResult then
                                --success
                                Jobs.HackedKeys()
                                break
                            end
                        end
                    else
                        Radar.inZone = false
                        if IsPedHeadingTowardsPosition(pPed, Radar.coords.x, Radar.coords.y, Radar.coords.z, 10.0) then
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(255)
                            ScaleformMovieMethodAddParamInt(179)
                            ScaleformMovieMethodAddParamInt(149)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                        else
                            ScaleformMovieMethodAddParamInt(255)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(255)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                            ScaleformMovieMethodAddParamInt(0)
                        end
                        EndScaleformMovieMethod()
                    end


                    BeginScaleformMovieMethod(Radar.scaleformMovie, "SET_DISTANCE")
                    ScaleformMovieMethodAddParamFloat(35 + 70 * calculatedDistance)
                    EndScaleformMovieMethod()
                    SetTextRenderId(Radar.scaleformTarget)
                    DrawScaleformMovie(Radar.scaleformMovie, 0.1, 0.24, 0.21, 0.51, 100, 100, 100, 255, 0)
                    
                    if GetGameTimer() - gameTimer > 2500 * (1 - calculatedDistance) then
                        PlaySoundFromCoord(Radar.soundID7, "IDLE_BEEP", pCoords.x, pCoords.y, pCoords.z, "EPSILONISM_04_SOUNDSET", false, 0, false)
                        gameTimer = GetGameTimer()
                    end
                else
                    Citizen.Wait(1000)
                end
                Citizen.Wait(1)
            end
            lib.TextUI.Stop()
        end)
    end,

    Stop = function()
        SetTextRenderId(Radar.scaleformTarget)
        DrawScaleformMovie(Radar.scaleformMovie, 0.1, 0.24, 0.21, 0.51, 100, 100, 100, 255, 0)
        Radar.isActive = false
        Radar.coords = nil
        Radar.inZone = false
        SetScaleformMovieAsNoLongerNeeded(Radar.scaleformMovie)
        ReleaseSoundId(Radar.soundID)
        lib.TextUI.Stop()
    end
}