local Config = {
    MaxOnFootSpeed = 9.0,   -- m/s; above this on foot (no vehicle/parachute/ragdoll) gets clamped
    Debug = false,
}

-- Controls that trigger a combat roll: Jump (22) and Cover (44)
local ROLL_CONTROLS = { 22, 44 }

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local sleep = 500

        if IsPedArmed(ped, 6) or IsPlayerFreeAiming(PlayerId()) then
            sleep = 0
            for _, control in ipairs(ROLL_CONTROLS) do
                DisableControlAction(0, control, true)
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local sleep = 200

        if not IsPedInAnyVehicle(ped, false)
            and not IsPedRagdoll(ped)
            and not IsPedFalling(ped)
            and not IsPedInParachuteFreeFall(ped) then

            local speed = GetEntitySpeed(ped)
            if speed > Config.MaxOnFootSpeed then
                -- Clamp velocity to the cap, keeping direction
                local vel = GetEntityVelocity(ped)
                local scale = Config.MaxOnFootSpeed / speed
                SetEntityVelocity(ped, vel.x * scale, vel.y * scale, vel.z)
                if Config.Debug then print(("anti-roll-speed: clamped %.2f m/s"):format(speed)) end
            end
        end

        Wait(sleep)
    end
end)

-- shortcut: client-side only, a modified client can skip this; add server-side position/speed checks to enforce it, and upgrade when cheating matters
