-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Rotation maths for the door lockpick's props and camera.
-- From tr_core/modules/math (TR Scripts, GPL-3.0), trimmed to what the lockpick uses.
-- A rotation is { x = vec3, y = vec3, z = vec3 }: its local axes in the parent space. Angles in degrees.
local Mat, Vec = {}, {}

function Mat.identity()
    return { x = vec3(1.0, 0.0, 0.0), y = vec3(0.0, 1.0, 0.0), z = vec3(0.0, 0.0, 1.0) }
end

-- Rotation around one local axis ('x' | 'y' | 'z').
function Mat.axis(axis, degrees)
    local r = math.rad(degrees)
    local c, s = math.cos(r), math.sin(r)
    if axis == 'x' then
        return { x = vec3(1.0, 0.0, 0.0), y = vec3(0.0, c, s), z = vec3(0.0, -s, c) }
    elseif axis == 'y' then
        return { x = vec3(c, 0.0, -s), y = vec3(0.0, 1.0, 0.0), z = vec3(s, 0.0, c) }
    end
    return { x = vec3(c, s, 0.0), y = vec3(-s, c, 0.0), z = vec3(0.0, 0.0, 1.0) }
end

function Mat.apply(m, v)
    return m.x * v.x + m.y * v.y + m.z * v.z
end

-- a then b in a's space (a * b).
function Mat.mul(a, b, ...)
    local m = { x = Mat.apply(a, b.x), y = Mat.apply(a, b.y), z = Mat.apply(a, b.z) }
    if ... then return Mat.mul(m, ...) end
    return m
end

-- From GTA euler angles (rotation order 2), e.g. GetEntityRotation(entity, 2).
function Mat.fromEuler(rot)
    return Mat.mul(Mat.axis('z', rot.z), Mat.axis('x', rot.x), Mat.axis('y', rot.y))
end

-- +Y along `forward`, +Z as close to `up` as possible.
function Mat.look(forward, up)
    local y = Vec.normalize(forward)
    local x = Vec.normalize(Vec.cross(y, up or vec3(0.0, 0.0, 1.0)))
    return { x = x, y = y, z = Vec.cross(x, y) }
end

-- Euler angles for SetCamRot with rotation order 2.
function Mat.toEuler(m)
    local pitch = math.asin(math.max(-1.0, math.min(1.0, m.y.z)))
    local roll = math.atan(-m.x.z, m.z.z)
    local yaw = math.atan(-m.y.x, m.y.y)
    return vec3(math.deg(pitch), math.deg(roll), math.deg(yaw))
end

function Vec.dot(a, b) return a.x * b.x + a.y * b.y + a.z * b.z end

function Vec.cross(a, b)
    return vec3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

function Vec.length(v) return math.sqrt(Vec.dot(v, v)) end

function Vec.normalize(v)
    local length = Vec.length(v)
    if length < 1e-9 then return vec3(0.0, 1.0, 0.0) end
    return v * (1.0 / length)
end

function Vec.lerp(a, b, t) return a + (b - a) * t end

-- Inverse of a rotation applied to v.
function Vec.unrotate(m, v)
    return vec3(Vec.dot(v, m.x), Vec.dot(v, m.y), Vec.dot(v, m.z))
end

DoorPickMath = {
    Mat = Mat,
    Vec = Vec,
    lerp = function(a, b, t) return a + (b - a) * t end,
    clamp = function(v, lo, hi) return math.max(lo, math.min(hi, v)) end,
}
