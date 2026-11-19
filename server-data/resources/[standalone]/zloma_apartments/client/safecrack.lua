-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Safe cracking minigame: turn the dial with A / D until a pin drops (you hear
-- it), press W to set it, then turn the other way for the next number.
-- Based on pd-safe by Victor Hall (https://github.com/VHall1/pd-safe, MIT License,
-- Copyright (c) 2021 Victor Hall), itself a port of TimothyDexter's
-- FiveM-SafeCrackingMiniGame. Changed here: no globals, movement is blocked
-- while cracking, on-screen help, and a clean reset between attempts.
--
-- MIT License
-- 
-- Copyright (c) 2021 Victor Hall
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local activeScene
local TEXTURES = 'MPSafeCracking'
local ANIM_DICT, ANIM = 'mini@safe_cracking', 'idle_base'
local DEGREES_PER_NUMBER = 3.6
local KEY = { anticlockwise = 34, clockwise = 35, release = 32, quit = 33 } -- A, D, W, S

local function dialNumber(rotation)
    local number = math.floor(100 * (rotation / 360))
    if number > 0 then number = 100 - number end
    return math.abs(number) % 100
end

local function draw(state)
    if activeScene then
        local s=activeScene
        if SafeProps.entities[s.safe.key]~=s.safe or not DoesEntityExist(s.safe.dial) then return end
        SafeProps.pose(s.safe,0,state.rotation)
        SetEntityLocallyInvisible(PlayerPedId())
        if IsDisabledControlJustPressed(0,15) then s.fov=math.max(24.0,s.fov-2.0)end
        if IsDisabledControlJustPressed(0,14) then s.fov=math.min(55.0,s.fov+2.0)end
        SetCamFov(s.cam,s.fov)
        return
    end
    local aspect = GetAspectRatio(true)
    DrawSprite(TEXTURES, 'Dial_BG', 0.48, 0.3, 0.3, aspect * 0.3, 0, 255, 255, 255, 255)
    DrawSprite(TEXTURES, 'Dial', 0.48, 0.3, 0.3 * 0.5, aspect * 0.3 * 0.5, state.rotation, 255, 255, 255, 255)
    local y = 0.3 * 0.5 + 0.035
    for i = 1, #state.locked do
        DrawSprite(TEXTURES, state.locked[i] and 'lock_closed' or 'lock_open', 0.6, y, 0.025, aspect * 0.015, 0, 231, 194, 81, 255)
        y = y + 0.05
    end
end

local function blockControls()
    DisableAllControlActions(0)
    DisableAllControlActions(1)
    DisableAllControlActions(2)
    EnableControlAction(0, 1, true)   -- look
    EnableControlAction(0, 2, true)
    EnableControlAction(0, 249, true) -- push to talk
end

local function clearScene()
    local s=activeScene;if not s then return end
    activeScene=nil
    RenderScriptCams(false,true,250,true,true);DestroyCam(s.cam,false)
    if SafeProps.entities[s.safe.key]==s.safe and DoesEntityExist(s.safe.dial) then SafeProps.pose(s.safe,0,0)end
    if DoesEntityExist(s.ped)then FreezeEntityPosition(s.ped,s.wasFrozen==true)end
end
AddEventHandler('onResourceStop',function(name)if name==GetCurrentResourceName()then clearScene()end end)
local function finish(opened)
    clearScene()
    PlaySoundFrontend(-1, opened and 'SAFE_DOOR_OPEN' or 'SAFE_DOOR_CLOSE', 'SAFE_CRACK_SOUNDSET', true)
    lib.hideTextUI()
    ClearPedTasks(PlayerPedId())
    RemoveAnimDict(ANIM_DICT)
    SetStreamedTextureDictAsNoLongerNeeded(TEXTURES)
    return opened
end

-- combination: numbers 0-99, one per pin. Returns true when every pin is set.
local function play(combination,safe)
    if safe and SafeProps and SafeProps.entities[safe.key]==safe and DoesEntityExist(safe.dial) and safe.angle<1 then
        local ped=PlayerPedId()
        local d=SafeModel.dialPivot
        local from=GetOffsetFromEntityInWorldCoords(safe.body,d.x+0.0,d.y-.43,d.z+.015)
        local at=GetEntityCoords(safe.dial)
        local cam=CreateCam('DEFAULT_SCRIPTED_CAMERA',true)
        activeScene={safe=safe,ped=ped,wasFrozen=IsEntityPositionFrozen(ped),cam=cam,fov=38.0}
        FreezeEntityPosition(ped,true)
        SetCamCoord(cam,from.x,from.y,from.z);PointCamAtCoord(cam,at.x,at.y,at.z);SetCamFov(cam,38.0)
        SetCamActive(cam,true);RenderScriptCams(true,false,0,true,true)
    else RequestStreamedTextureDict(TEXTURES, false) end
    RequestAmbientAudioBank('SAFE_CRACK', false)
    lib.requestAnimDict(ANIM_DICT)
    local deadline = GetGameTimer() + 3000
    while not activeScene and not HasStreamedTextureDictLoaded(TEXTURES) and GetGameTimer() < deadline do Wait(0) end

    local state = {
        rotation = DEGREES_PER_NUMBER * math.random(0, 99),
        locked = {},
        pin = 1,
        required = 'clockwise', -- the first number is dialled clockwise, then it alternates
        onSpot = false,
    }
    for i = 1, #combination do state.locked[i] = true end

    local ped = PlayerPedId()
    TaskPlayAnim(ped, ANIM_DICT, ANIM, 3.0, 3.0, -1, 1, 0, false, false, false)
    lib.showTextUI(_L('safecrack_help'), { position = 'left-center', icon = 'vault' })

    while true do
        blockControls()
        draw(state)
        if not IsEntityPlayingAnim(ped, ANIM_DICT, ANIM, 3) then
            TaskPlayAnim(ped, ANIM_DICT, ANIM, 3.0, 3.0, -1, 1, 0, false, false, false)
        end

        if (activeScene and (SafeProps.entities[activeScene.safe.key]~=activeScene.safe or activeScene.safe.stopped or activeScene.safe.angle>=1))
            or IsEntityDead(ped) or GetEntityHealth(ped) <= 101 or IsDisabledControlJustPressed(0, KEY.quit)
            or IsDisabledControlJustPressed(0,200) then
            return finish(false)
        end

        if IsDisabledControlJustPressed(0, KEY.release) then
            if not state.onSpot then return finish(false) end
            -- Set this pin; the next number turns the other way.
            state.locked[state.pin] = false
            state.pin = state.pin + 1
            state.onSpot = false
            state.required = state.required == 'clockwise' and 'anticlockwise' or 'clockwise'
            PlaySoundFrontend(-1, 'TUMBLER_PIN_FALL_FINAL', 'SAFE_CRACK_SOUNDSET', true)
            if state.locked[state.pin] == nil then return finish(true) end
        end

        local turned
        if IsDisabledControlJustPressed(0, KEY.anticlockwise) then
            turned = 'anticlockwise'
            state.rotation = state.rotation + DEGREES_PER_NUMBER
        elseif IsDisabledControlJustPressed(0, KEY.clockwise) then
            turned = 'clockwise'
            state.rotation = state.rotation - DEGREES_PER_NUMBER
        end
        if turned then
            PlaySoundFrontend(-1, 'TUMBLER_TURN', 'SAFE_CRACK_SOUNDSET', true)
            if turned ~= state.required then
                state.onSpot = false -- turning the wrong way loses the spot
            elseif dialNumber(state.rotation) == combination[state.pin] then
                state.onSpot = true
                PlaySoundFrontend(-1, 'TUMBLER_PIN_FALL', 'SAFE_CRACK_SOUNDSET', true)
            else
                state.onSpot = false
            end
        end

        Wait(0)
    end
end

function SafeCrack(combination,safe)
    local ok,result=xpcall(function()return play(combination,safe)end,debug.traceback)
    if not ok then
        clearScene();lib.hideTextUI();ClearPedTasks(PlayerPedId());RemoveAnimDict(ANIM_DICT)
        SetStreamedTextureDictAsNoLongerNeeded(TEXTURES)
        print('[zloma_apartments] physical safecrack: '..result)
        return false
    end
    return result
end
