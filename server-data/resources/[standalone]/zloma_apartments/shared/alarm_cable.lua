-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Attached USB cable. The device end is always pinned, the plug end follows the
-- target. The shape is solved from scratch every call (no state carried between
-- frames), so the same device pose and target always give the same cable: a
-- tightly bent cable can no longer feed back into itself and shake. A scale
-- below 1 shortens the cable around the device socket, keeping its shape.
AlarmCable = {}
local ITERATIONS = 36 -- rounding + length passes
local SETTLE = 30     -- length passes only, so the cable never looks stretched
local function point(p) return {x=p.x,y=p.y,z=p.z} end
local function distance(a,b) return math.sqrt((b.x-a.x)^2+(b.y-a.y)^2+(b.z-a.z)^2) end

local function setRest(cable, rest)
    local root = rest[1]
    for i, p in ipairs(rest) do
        local r = cable.rest[i] or {}
        r.x = root.x + (p.x - root.x) * cable.scale
        r.y = root.y + (p.y - root.y) * cable.scale
        r.z = root.z + (p.z - root.z) * cable.scale
        cable.rest[i] = r
    end
end

function AlarmCable.new(rest, scale)
    local cable = { rest = {}, nodes = {}, lengths = {}, length = 0, scale = scale or 1 }
    setRest(cable, rest)
    for i, p in ipairs(cable.rest) do
        cable.nodes[i] = point(p)
        if i > 1 then
            local length = distance(cable.rest[i-1], p)
            cable.lengths[i-1] = length; cable.length = cable.length + length
        end
    end
    return cable
end

-- target: where the plug goes; nil = hanging at rest from the device.
-- rest (optional): the factory curve again in world space, when the device moved.
function AlarmCable.update(cable, target, _, rest)
    if rest then setRest(cable, rest) end
    local nodes, rest = cable.nodes, cable.rest
    local root = rest[1]; local last = rest[#rest]
    target = point(target or last)
    local reach = distance(root, target)
    if reach > cable.length * .985 then
        local scale = cable.length * .985 / reach
        target = { x = root.x + (target.x - root.x) * scale, y = root.y + (target.y - root.y) * scale, z = root.z + (target.z - root.z) * scale }
    end
    -- Nothing changed since the last solve: keep the cable exactly where it is.
    local key = cable.solved
    if key and key[1] == root.x and key[2] == root.y and key[3] == root.z
        and key[4] == target.x and key[5] == target.y and key[6] == target.z then
        return target
    end
    cable.solved = { root.x, root.y, root.z, target.x, target.y, target.z }

    -- Start shape. Near the device the cable keeps its factory coil; once the
    -- plug is pulled away it starts as a smooth hanging arc whose length
    -- already matches the cable, so a slack cable bows in one clean curve
    -- instead of buckling into a zigzag.
    local n = #nodes
    local fraction = cable.fraction
    if not fraction then
        fraction = { 0 }
        for i = 2, n do fraction[i] = fraction[i-1] + cable.lengths[i-1] / cable.length end
        cable.fraction = fraction
    end
    local chord = { x = target.x - root.x, y = target.y - root.y, z = target.z - root.z }
    local c = math.sqrt(chord.x^2 + chord.y^2 + chord.z^2)
    -- Bow direction: down and away from the wall (cable.sag), square to the chord.
    local sag = cable.sag or { x = 0, y = 0, z = 0 }
    local dir = { x = sag.x * .6, y = sag.y * .6, z = sag.z * .6 - 1 }
    if c > .000001 then
        local along = (dir.x * chord.x + dir.y * chord.y + dir.z * chord.z) / (c * c)
        dir.x, dir.y, dir.z = dir.x - chord.x * along, dir.y - chord.y * along, dir.z - chord.z * along
    end
    local dl = math.sqrt(dir.x^2 + dir.y^2 + dir.z^2)
    if dl < .0001 then dir, dl = { x = sag.x, y = sag.y, z = sag.z }, math.sqrt(sag.x^2 + sag.y^2 + sag.z^2) end
    if dl < .0001 then dir, dl = { x = 1, y = 0, z = 0 }, 1 end
    dir.x, dir.y, dir.z = dir.x / dl, dir.y / dl, dir.z / dl
    -- Sample the arc finely, then place the nodes at their own distance along
    -- it, so every link already has its length and nothing has to buckle.
    local SAMPLES = 48
    local function arc(h, out)
        local total, px, py, pz = 0, root.x, root.y, root.z
        if out then out[0] = { 0, px, py, pz } end
        for k = 1, SAMPLES do
            local t = k / SAMPLES; local bow = 4 * t * (1 - t) * h
            local x, y, z = root.x + chord.x * t + dir.x * bow, root.y + chord.y * t + dir.y * bow, root.z + chord.z * t + dir.z * bow
            total = total + math.sqrt((x - px)^2 + (y - py)^2 + (z - pz)^2); px, py, pz = x, y, z
            if out then out[k] = { total, x, y, z } end
        end
        return total
    end
    local lo, hi = 0, cable.length
    for _ = 1, 18 do
        local mid = (lo + hi) * .5
        if arc(mid) < cable.length then lo = mid else hi = mid end
    end
    local samples = {}
    local total = arc((lo + hi) * .5, samples)
    local shape, k = {}, 1
    for i = 1, n do
        local want = fraction[i] * total
        while k < SAMPLES and samples[k][1] < want do k = k + 1 end
        local a, b = samples[k - 1], samples[k]
        local f = b[1] > a[1] and (want - a[1]) / (b[1] - a[1]) or 0
        f = math.max(0, math.min(1, f))
        shape[i] = { a[2] + (b[2] - a[2]) * f, a[3] + (b[3] - a[3]) * f, a[4] + (b[4] - a[4]) * f }
    end
    local pulled = math.max(0, math.min(1, distance(last, target) / .04))
    for i = 1, n do
        local node, r, q = nodes[i], rest[i], shape[i]
        local s = (i - 1) / (n - 1)
        local x = r.x + (target.x - last.x) * s
        local y = r.y + (target.y - last.y) * s
        local z = r.z + (target.z - last.z) * s
        node.x = x + (q[1] - x) * pulled
        node.y = y + (q[2] - y) * pulled
        node.z = z + (q[3] - z) * pulled
    end
    for iteration = 1, ITERATIONS + SETTLE do
        -- A USB lead is stiff: soften folds into rounded curves.
        if iteration <= ITERATIONS and iteration % 3 == 1 then
            for i = 2, n - 1 do
                local a, node, b = nodes[i-1], nodes[i], nodes[i+1]
                node.x = node.x * .84 + (a.x + b.x) * .08
                node.y = node.y * .84 + (a.y + b.y) * .08
                node.z = node.z * .84 + (a.z + b.z) * .08
            end
        end
        nodes[1] = point(root); nodes[n] = point(target)
        for i = 1, n - 1 do
            local a, b = nodes[i], nodes[i+1]; local d = distance(a, b)
            if d > .0000001 then
                local amount = (d - cable.lengths[i]) / d
                local aWeight = i == 1 and 0 or (i + 1 == n and 1 or .5)
                local bWeight = i + 1 == n and 0 or (i == 1 and 1 or .5)
                local dx, dy, dz = (b.x - a.x) * amount, (b.y - a.y) * amount, (b.z - a.z) * amount
                a.x, a.y, a.z = a.x + dx * aWeight, a.y + dy * aWeight, a.z + dz * aWeight
                b.x, b.y, b.z = b.x - dx * bWeight, b.y - dy * bWeight, b.z - dz * bWeight
            end
        end
    end
    nodes[1] = point(root); nodes[n] = point(target)
    return target
end
