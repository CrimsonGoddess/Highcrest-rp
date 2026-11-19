-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Panel geometry is independent of bookings; a panel only streams for an active
-- door alarm. Coordinates are closed-door coordinates, never a moving door bone.
AlarmPanel = {}

-- Keep the close-up upright in world space. A prop's tilted local Y/Z axes
-- must not pull the camera down into the floor or roll the horizon.
function AlarmPanel.sceneCamera(anchor, front, floorZ, viewer)
    local x,y=front.x,front.y
    local length=math.sqrt(x*x+y*y)
    if length ~= length or length == math.huge or length < .1 then
        x,y=viewer.x-anchor.x,viewer.y-anchor.y
        length=math.sqrt(x*x+y*y)
    end
    if length ~= length or length == math.huge or length < .001 then x,y,length=0,-1,1 end
    local minimum=(floorZ or anchor.z-1.3)+.65
    local height=math.max(anchor.z-.13,minimum)
    local position={x=anchor.x+x/length*.48,y=anchor.y+y/length*.48,z=height}
    local target={x=anchor.x,y=anchor.y,z=height}
    local dx,dy,dz=target.x-position.x,target.y-position.y,target.z-position.z
    return position,target,{x=math.deg(math.atan(dz,math.sqrt(dx*dx+dy*dy))),y=0,z=math.deg(math.atan(-dx,dy))}
end

-- Point-of-view close-up: the camera sits just under the player's chin (head
-- position, moved along the player's facing) and looks at the point between
-- the panel and the held device. view: { forward, down, side } in metres.
-- Returns position, target, rotation and the camera axes for cursor rays.
function AlarmPanel.headCamera(head, facing, anchor, device, view)
    local x,y=facing.x,facing.y
    local length=math.sqrt(x*x+y*y)
    if length ~= length or length == math.huge or length < .1 then x,y,length=0,1,1 end
    x,y=x/length,y/length
    local rx,ry=y,-x -- player's right
    local forward,down,side=view.forward or .10,view.down or .13,view.side or 0
    local position={x=head.x+x*forward+rx*side,y=head.y+y*forward+ry*side,z=head.z-down}
    local target={x=(anchor.x+device.x)*.5,y=(anchor.y+device.y)*.5,z=(anchor.z+device.z)*.5}
    local dx,dy,dz=target.x-position.x,target.y-position.y,target.z-position.z
    local d=math.sqrt(dx*dx+dy*dy+dz*dz)
    if d < .001 then dx,dy,dz,d=x*.3,y*.3,0,.3 end
    local f={x=dx/d,y=dy/d,z=dz/d}
    local h=math.max(.0001,math.sqrt(f.x^2+f.y^2))
    local right={x=f.y/h,y=-f.x/h,z=0}
    local camUp={x=right.y*f.z-right.z*f.y,y=right.z*f.x-right.x*f.z,z=right.x*f.y-right.y*f.x}
    local rotation={x=math.deg(math.atan(dz,math.sqrt(dx*dx+dy*dy))),y=0,z=math.deg(math.atan(-dx,dy))}
    return position,target,rotation,{forward=f,right=right,up=camUp,distance=d}
end

-- Where point (px, py) lies inside a quad seen in perspective, as u, v (0..1
-- inside). quad = { topLeft, topRight, bottomRight, bottomLeft }, each {x, y}.
-- A projective map (homography), so it is exact for a flat screen seen at any
-- angle, from any camera. Returns nil for a degenerate quad.
function AlarmPanel.quadUV(quad, px, py)
    local x0,y0,x1,y1=quad[1].x,quad[1].y,quad[2].x,quad[2].y
    local x2,y2,x3,y3=quad[3].x,quad[3].y,quad[4].x,quad[4].y
    local dx1,dx2,dx3=x1-x2,x3-x2,x0-x1+x2-x3
    local dy1,dy2,dy3=y1-y2,y3-y2,y0-y1+y2-y3
    local den=dx1*dy2-dx2*dy1
    if math.abs(den)<1e-12 then return nil end
    local g=(dx3*dy2-dx2*dy3)/den
    local h=(dx1*dy3-dx3*dy1)/den
    -- unit square -> quad: x=(a u+b v+c)/(g u+h v+1), y=(d u+e v+f)/(g u+h v+1)
    local a,b,c=x1-x0+g*x1,x3-x0+h*x3,x0
    local d,e,f=y1-y0+g*y1,y3-y0+h*y3,y0
    -- invert that 3x3 map and apply it to the point
    local A,B,C=e-f*h,f*g-d,d*h-e*g
    local D,E,F=c*h-b,a-c*g,b*g-a*h
    local G,H,I=b*f-c*e,c*d-a*f,a*e-b*d
    local w=C*px+F*py+I
    if math.abs(w)<1e-12 then return nil end
    return (A*px+D*py+G)/w,(B*px+E*py+H)/w
end

-- Explicit scripted-camera projection, independent of gameplay-camera rays.
function AlarmPanel.cursorPlaneRay(x,y,position,front,side,up,fov,aspect)
    local scale=math.tan(math.rad(fov)*.5)
    local horizontal=(x*2-1)*scale*aspect
    local vertical=(1-y*2)*scale
    local direction={x=-front.x+side.x*horizontal+up.x*vertical,
        y=-front.y+side.y*horizontal+up.y*vertical,
        z=-front.z+side.z*horizontal+up.z*vertical}
    return position,direction
end

local function finite(v, limit)
    return type(v) == 'number' and v == v and math.abs(v) <= limit
end

function AlarmPanel.normalize(raw)
    if type(raw) ~= 'table' then return nil end
    if raw.mode == 'auto' then return { mode = 'auto' } end
    if raw.mode ~= 'manual' then return nil end
    local p, r = raw.position, raw.rotation
    if type(p) ~= 'table' or type(r) ~= 'table' then return nil end
    for _, k in ipairs({ 'x', 'y', 'z' }) do
        if not finite(p[k], k == 'z' and 5000 or 20000) or not finite(r[k], 3600) then return nil end
    end
    return { mode = 'manual', position = { x = p.x, y = p.y, z = p.z }, rotation = { x = r.x, y = r.y, z = r.z } }
end

function AlarmPanel.forRoom(def, number)
    local own = def.alarmPanels and def.alarmPanels[tostring(number)]
    if own then return Hotels.copy(own) end
    local floor, index = Hotels.split(number)
    for _, base in ipairs(def.rooms) do
        if base.index == index and base.alarmPanel then
            local p = Hotels.copy(base.alarmPanel)
            if p.position then p.position.z = p.position.z + (floor - 1) * def.floors.step end
            return p
        end
    end
    return { mode = 'auto' }
end

-- Copying one apartment's panel to the others, relative to each door.
-- A door frame: its origin and heading, and which face is outside (out = 1:
-- the door's +Y face, -1: its -Y face), told by the safe inside the room.
function AlarmPanel.doorFrame(origin, heading, safe)
    local out = 1
    if safe then
        local a = math.rad(heading)
        local side = (safe.x - origin.x) * -math.sin(a) + (safe.y - origin.y) * math.cos(a)
        out = side < 0 and 1 or -1
    end
    return { x = origin.x, y = origin.y, z = origin.z, heading = heading, out = out }
end

local function frameAxes(f)
    local a = math.rad(f.heading)
    -- along the door (hinge to handle), and out into the corridor
    return math.cos(a), math.sin(a), -math.sin(a) * f.out, math.cos(a) * f.out
end
local function outwardYaw(f) return f.heading + (f.out > 0 and 180 or 0) end

-- A placement as: metres along the door, metres out from it, height, and turn.
function AlarmPanel.relativeTo(frame, spec)
    local ax, ay, ox, oy = frameAxes(frame)
    local p, r = spec.position, spec.rotation
    local dx, dy = p.x - frame.x, p.y - frame.y
    return { along = dx * ax + dy * ay, out = dx * ox + dy * oy, up = p.z - frame.z,
        yaw = r.z - outwardYaw(frame), pitch = r.x, roll = r.y }
end

function AlarmPanel.fromRelative(frame, rel)
    local ax, ay, ox, oy = frameAxes(frame)
    return { mode = 'manual',
        position = { x = frame.x + ax * rel.along + ox * rel.out, y = frame.y + ay * rel.along + oy * rel.out, z = frame.z + rel.up },
        rotation = { x = rel.pitch % 360, y = rel.roll % 360, z = (outwardYaw(frame) + rel.yaw) % 360 } }
end

-- Pure math shared with isolated tests. Ray/plane intersection for dragging.
function AlarmPanel.rayPlane(origin, direction, point, normal)
    local d = direction.x * normal.x + direction.y * normal.y + direction.z * normal.z
    if math.abs(d) < 0.00001 then return nil end
    local t = ((point.x - origin.x) * normal.x + (point.y - origin.y) * normal.y + (point.z - origin.z) * normal.z) / d
    if t < 0 or t > 10 then return nil end
    return { x = origin.x + direction.x * t, y = origin.y + direction.y * t, z = origin.z + direction.z * t }
end
