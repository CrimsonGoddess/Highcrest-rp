-- Sign Studio: letter animations (night only, every change lasts 1 s or more, no strobe)
local POS = vector3(723.0936, 1193.0220, 336.9141)
local HEADING = 341.360
local PARTS = {
    { model = GetHashKey('vinewoodsign_a0'), anim = 'pulse', order = 0 },
    { model = GetHashKey('vinewoodsign_a1'), anim = 'pulse', order = 1 },
    { model = GetHashKey('vinewoodsign_a2'), anim = 'pulse', order = 2 },
    { model = GetHashKey('vinewoodsign_a3'), anim = 'pulse', order = 3 },
    { model = GetHashKey('vinewoodsign_a4'), anim = 'pulse', order = 4 },
    { model = GetHashKey('vinewoodsign_a5'), anim = 'pulse', order = 5 },
    { model = GetHashKey('vinewoodsign_a6'), anim = 'pulse', order = 6 },
    { model = GetHashKey('vinewoodsign_a7'), anim = 'pulse', order = 7 },
    { model = GetHashKey('vinewoodsign_a8'), anim = 'pulse', order = 8 }
}
local RANGE = 1200.0
local spawned = {}

local function night()
    local h = GetClockHours()
    return h >= 19 or h < 7
end

local function level(p, t)
    if p.anim == 'pulse' then return 0.55 + 0.45 * math.sin(t * math.pi)            -- 2 s period
    elseif p.anim == 'fade' then return 0.5 + 0.5 * math.sin(t * math.pi / 2)       -- 4 s period
    elseif p.anim == 'chase' then
        local n = #PARTS
        local step = math.floor(t) % (n + 1)                                        -- 1 s per letter, then all on
        if step == n then return 1.0 end
        return (p.order <= step) and 1.0 or 0.25
    elseif p.anim == 'flicker' then
        p.next = p.next or (t + 3 + math.random() * 5)
        if t > p.next then p.dip = t; p.next = t + 3 + math.random() * 5 end
        if p.dip and t - p.dip < 1.2 then return 0.45 + 0.55 * math.abs((t - p.dip) / 0.6 - 1.0) end
        return 1.0
    end
    return 1.0
end

CreateThread(function()
    while true do
        local near = #(GetEntityCoords(PlayerPedId()) - POS) < RANGE
        for i, p in ipairs(PARTS) do
            if near and not spawned[i] then
                RequestModel(p.model)
                local t = GetGameTimer() + 10000
                while not HasModelLoaded(p.model) and GetGameTimer() < t do Wait(50) end
                if HasModelLoaded(p.model) then
                    local o = CreateObjectNoOffset(p.model, POS.x, POS.y, POS.z, false, false, false)
                    SetEntityRotation(o, 0.0, 0.0, HEADING, 2, false)
                    FreezeEntityPosition(o, true)
                    SetEntityCollision(o, false, false)
                    SetModelAsNoLongerNeeded(p.model)
                    spawned[i] = o
                end
            elseif not near and spawned[i] then
                DeleteObject(spawned[i]); spawned[i] = nil
            end
        end
        if not near then Wait(2000) else
            local t = GetGameTimer() / 1000.0
            local nt = night()
            for i, p in ipairs(PARTS) do
                local o = spawned[i]
                if o then SetEntityAlpha(o, math.floor(255 * (nt and level(p, t) or 1.0)), false) end
            end
            Wait(50)
        end
    end
end)

AddEventHandler('onResourceStop', function(r)
    if r ~= GetCurrentResourceName() then return end
    for _, o in pairs(spawned) do DeleteObject(o) end
end)
