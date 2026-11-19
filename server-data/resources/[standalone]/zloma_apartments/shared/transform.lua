-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

FurnitureTransform = {}

function FurnitureTransform.world(anchor, offset)
    local angle = math.rad(anchor.heading or 0)
    local c, s = math.cos(angle), math.sin(angle)
    return { x = anchor.x + offset.x * c - offset.y * s, y = anchor.y + offset.x * s + offset.y * c, z = anchor.z + offset.z }
end

function FurnitureTransform.localOffset(anchor, world)
    local angle = math.rad(anchor.heading or 0)
    local c, s = math.cos(angle), math.sin(angle)
    local x, y = world.x - anchor.x, world.y - anchor.y
    return { x = x * c + y * s, y = -x * s + y * c, z = world.z - anchor.z }
end
