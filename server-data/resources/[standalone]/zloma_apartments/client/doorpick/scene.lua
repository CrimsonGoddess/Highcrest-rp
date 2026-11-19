-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Local props and a camera fixed to a door, for the door lockpick.
-- From tr_core/modules/scene (TR Scripts, GPL-3.0), trimmed to what the lockpick uses.
-- Everything is placed in rig space: a frame fixed to the door at `offset`
-- (door space), turned `yaw` degrees around the door's Z, tilted `pitch`
-- around its own X. +Y points away from the player, +Z up.
local M = DoorPickMath
local Mat, Vec, lerp, clamp = M.Mat, M.Vec, M.lerp, M.clamp

local Scene = {}
Scene.__index = Scene

local UP = vec3(0.0, 0.0, 1.0)
local STILL_POS, STILL_ROT = 0.0002, 0.00001
local live = {}

local function hold(self, name)
    local hash = joaat(name)
    if not self.hashes[hash] then
        if not lib.requestModel(hash, 5000) then error(('model %s did not load'):format(name), 0) end
        self.hashes[hash] = true
    end
    return hash
end

function Scene.new(entity, offset, pitch, yaw)
    local self = setmetatable({ entity = entity, parts = {}, hashes = {} }, Scene)
    live[self] = true
    self:setPlacement(offset, pitch, yaw)
    return self
end

function Scene:setPlacement(offset, pitch, yaw)
    self.offset, self.pitch, self.yaw = offset, pitch, yaw or 0.0
    self.placementChanged = true
    self:update()
end

function Scene:update()
    local coords, angles = GetEntityCoords(self.entity), GetEntityRotation(self.entity, 2)
    local last = self.entityAt
    if last and #(coords - last.coords) < STILL_POS and #(angles - last.angles) < STILL_ROT and not self.placementChanged then
        self.moved = false
    else
        local entityRot = Mat.fromEuler(angles)
        self.rot = Mat.mul(entityRot, Mat.axis('z', self.yaw), Mat.axis('x', self.pitch))
        self.pos = coords + Mat.apply(entityRot, self.offset)
        self.entityAt = { coords = coords, angles = angles }
        self.moved, self.placementChanged = true, false
    end

    for _, part in pairs(self.parts) do self:place(part) end
    if self.cam then self:updateCamera() end
end

function Scene:toWorld(p)
    return self.pos + Mat.apply(self.rot, p)
end

local function sameRot(a, b)
    return a == b or (a.x == b.x and a.y == b.y and a.z == b.z)
end

function Scene:place(part)
    local placed = part.placed
    if placed and not self.moved and placed.pos == part.pos and sameRot(placed.rot, part.rot) then return end
    part.placed = { pos = part.pos, rot = part.rot }

    local world = self:toWorld(part.pos)
    local rot = Mat.mul(self.rot, part.rot)
    SetEntityMatrix(part.entity, rot.y.x, rot.y.y, rot.y.z, rot.x.x, rot.x.y, rot.x.z, rot.z.x, rot.z.y, rot.z.z,
        world.x, world.y, world.z)
end

-- A local prop; pos/rot (rig space) can be changed on the returned part.
function Scene:spawn(id, model, pos, rot)
    self:remove(id)
    local hash = hold(self, model)
    local world = self:toWorld(pos or vec3(0.0, 0.0, 0.0))
    local entity = CreateObjectNoOffset(hash, world.x, world.y, world.z, false, false, false)

    SetEntityCollision(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetEntityLodDist(entity, 50)

    local part = { entity = entity, model = model, pos = pos or vec3(0.0, 0.0, 0.0), rot = rot or Mat.identity() }
    self.parts[id] = part
    self:place(part)
    return part
end

function Scene:get(id) return self.parts[id] end

function Scene:remove(id)
    local part = self.parts[id]
    if not part then return end
    if DoesEntityExist(part.entity) then DeleteEntity(part.entity) end
    self.parts[id] = nil
end

function Scene:preload(models)
    for _, model in ipairs(models) do hold(self, model) end
end

-- Starts at the gameplay camera and glides to the lock.
function Scene:createCamera(pos, target, fov)
    local from = GetGameplayCamCoord()
    local look = Mat.apply(Mat.fromEuler(GetGameplayCamRot(2)), vec3(0.0, 1.0, 0.0))

    self.camPos = Vec.unrotate(self.rot, from - self.pos)
    self.camTarget = self.camPos + Vec.unrotate(self.rot, look)
    self.fov = GetGameplayCamFov()
    self.camGoalPos, self.camGoalTarget, self.fovGoal = pos, target, fov
    self.camSpeed = 2.6
    self.cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    self.camSet = nil

    self:updateCamera()
    RenderScriptCams(true, false, 0, true, false)
end

function Scene:updateCamera()
    if #(self.camPos - self.camGoalPos) < 0.0001 and #(self.camTarget - self.camGoalTarget) < 0.0001
        and math.abs(self.fov - self.fovGoal) < 0.001 then
        self.camPos, self.camTarget, self.fov = self.camGoalPos, self.camGoalTarget, self.fovGoal
    else
        local k = clamp(GetFrameTime() * self.camSpeed, 0.0, 1.0)
        self.camPos = Vec.lerp(self.camPos, self.camGoalPos, k)
        self.camTarget = Vec.lerp(self.camTarget, self.camGoalTarget, k)
        self.fov = lerp(self.fov, self.fovGoal, k)
    end
    local set = self.camSet
    if set and set.pos == self.camPos and set.target == self.camTarget and set.fov == self.fov and not self.moved then return end
    self.camSet = { pos = self.camPos, target = self.camTarget, fov = self.fov }
    self.camRot = Mat.look(self.camTarget - self.camPos, UP)

    local world = self:toWorld(self.camPos)
    local rot = Mat.toEuler(Mat.mul(self.rot, self.camRot))
    SetCamCoord(self.cam, world.x, world.y, world.z)
    SetCamRot(self.cam, rot.x, rot.y, rot.z, 2)
    SetCamFov(self.cam, self.fov)
end

-- A torch from the camera so the lock is readable at night, for one frame.
function Scene:torch(brightness)
    if not self.cam or (brightness and brightness <= 0) then return end
    local from = self:toWorld(self.camPos + self.camRot.x * 0.05)
    local dir = Mat.apply(self.rot, Vec.normalize(self.camTarget - self.camPos))
    DrawSpotLight(from.x, from.y, from.z, dir.x, dir.y, dir.z, 245, 248, 255, 1.2, brightness or 4.0, 0.0, 55.0, 30.0)
end

function Scene:destroy()
    live[self] = nil
    for id in pairs(self.parts) do self:remove(id) end
    for hash in pairs(self.hashes) do SetModelAsNoLongerNeeded(hash) end
    self.hashes = {}
    if self.cam then
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(self.cam, false)
        self.cam = nil
    end
end

-- Props must go before the resource's streamed models are dropped.
AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    for scene in pairs(live) do scene:destroy() end
end)

DoorPickScene = Scene
