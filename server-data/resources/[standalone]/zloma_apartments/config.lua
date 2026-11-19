-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

Config = {}

-- Language for notifications and the UI. Shipped: 'en', 'hr'.
Config.Locale = 'en'
Config.Debug = false

-- =============================================
-- ADMIN
-- Players in these groups can use the in-game apartment creator and the
-- furniture editor. ESX: player group. QBCore/QBox: permission name.
-- =============================================
Config.AdminGroups = { 'admin', 'superadmin', 'god' }
Config.AdminCommand = 'apartmentadmin'

-- =============================================
-- BUILT-IN BUILDINGS
-- WiWang Hotel by Floky (free MLO, 20 floors x 19 rooms):
-- https://github.com/uFLOKY/wiwang_hotel
-- Set to false if you do not run that map. Buildings made with the in-game
-- creator are stored in the database and do not depend on this.
-- =============================================
Config.WiWang = true

-- =============================================
-- PAYMENTS (through zloma_core)
-- Daily rent is charged while the tenant is online. A day that cannot be
-- charged stays due. After GracePeriodDays of unpaid rent the tenant is evicted.
-- =============================================
Config.PaymentAccount = 'bank'
Config.PaymentCheckInterval = 60       -- seconds between rent checks
Config.GracePeriodDays = 3
Config.EvictOnNonPayment = true
Config.PaymentReminderHours = 2

-- =============================================
-- DOORS (FiveM native door system)
-- =============================================
Config.Doors = {
    InteractDistance = 2.0,
    AutoLockSeconds = 10,     -- 0 disables auto lock
    SearchRadius = 2.0,
    EnforceRadius = 35.0,
    EnforceInterval = 100,
    LockKey = 'E',
    BellKey = 'G',

    -- Break into a locked, occupied apartment. Works with both safe modes.
    Lockpick = {
        Enabled = true,
        Key = 'H',
        Item = 'lockpick',          -- nil = no item needed
        RemoveItemOnFail = true,    -- a failed attempt breaks the lockpick
        Cooldown = 30,              -- seconds between attempts per player
        -- Minigame when Config.Security is off. Names come from config_minigame.lua.
        Minigame = { game = 'tr_lockpick', difficulty = 'medium' },
    },
}

Config.Doorbell = {
    Sound = 'GENERIC_GAME_SHOW_PLINK',
    SoundSet = 'HUD_MINI_GAME_SOUNDSET',
    MaxKnocks = 2,
    Window = 60,              -- seconds
}

-- =============================================
-- ROOMMATE
-- =============================================
Config.Roommates = {
    Enabled = true,
    Distance = 10.0,          -- the roommate must stand this close when added
}

-- =============================================
-- SAFE (stash through zloma_core)
-- =============================================
Config.Safe = {
    Enabled = true,
    -- 'character': the safe belongs to the character. Contents, size and lock
    --              level move with them to their next apartment.
    -- 'apartment': the safe belongs to the room. Items stay in it when the
    --              tenant leaves; the next tenant sets a new PIN and finds them.
    Mode = 'character',
    -- Break into a safe without the PIN. Works with both modes.
    Lockpick = {
        Enabled = true,
        Item = 'lockpick',          -- nil = no item needed
        RemoveItemOnFail = true,
        Cooldown = 30,
        Minigame = { game = 'safecrack', difficulty = 'hard' },
    },
    PinLength = 4,
    MaxAttempts = 5,
    LockoutSeconds = 60,
    TargetDistance = 2.0,
    PropModel = 'zloma_safe',
    StreamDistance = 18.0,
    HeightOffset = 0.0,
    HeadingOffset = 0.0,
    AlarmMinCapacity = 2, -- medium safe is required to buy an alarm
    DoorSeconds = 1.2,
    CloseSeconds = 0.4, -- starts when the last stash viewer closes inventory
    Upgrades = {
        [1] = { label = 'Small safe',  price = 0,     slots = 10, weight = 50000 },
        [2] = { label = 'Medium safe', price = 15000, slots = 20, weight = 100000 },
        [3] = { label = 'Large safe',  price = 35000, slots = 35, weight = 200000 },
    },
}

-- =============================================
-- SECURITY UPGRADES
-- Owners buy stronger locks in the "Security" tab. Each level picks a
-- minigame from config_minigame.lua; higher levels are harder to lockpick.
-- Door and safe are separate: 1 to 10 levels each. Level 1 comes with the
-- apartment. Prices here are defaults; admins can set prices per building.
-- Enabled = false hides the tab; lockpicking then uses the Lockpick.Minigame
-- settings above.
-- =============================================
Config.Security = {
    Enabled = true,
    -- Door and safe levels can have an alarm (alarm = true). Once a level has it,
    -- every higher level has it too and takes over its alarm_* settings unless it
    -- sets its own. When someone lockpicks an alarmed door or safe (whether it
    -- works or not) or fails to hack its alarm, the police get a dispatch
    -- (zloma_core) and the owner and roommate a notification. Hacking the alarm
    -- first keeps it quiet after the device stages succeed. With Panel.Enabled,
    -- doors and safes use a physical panel and USB connection; plugging in alone
    -- never disables an alarm. A safe also requires AlarmMinCapacity.
    -- Door and safe device stages/settings are independent.
    --   alarm_game / alarm_difficulty  minigame from config_minigame.lua
    --   alarm_item                     item needed to hack (nil = none). If the item
    --                                  does not exist in the inventory, the alarm
    --                                  of that level is off.
    Door = {
        [1] = { label = 'Standard lock',   game = 'tr_lockpick', difficulty = 'medium', price = 0 },
        [2] = { label = 'Reinforced lock', game = 'tr_lockpick', difficulty = 'expert', price = 15000 },
        [3] = { label = 'Electronic lock', game = 'tr_lockpick',      difficulty = 'expert',   price = 35000,
                alarm = true, alarm_game = 'device_hack', alarm_difficulty = 'hard', alarm_item = 'hacking_device' },
    },
    Safe = {
        [1] = { label = 'Standard dial',   game = 'safecrack', difficulty = 'hard',   price = 0 },
        [2] = { label = 'Hardened dial',   game = 'safecrack', difficulty = 'ultra',  price = 10000 },
        [3] = { label = 'Digital lock',    game = 'safecrack', difficulty = 'expert', price = 25000,
                alarm = true, alarm_game = 'safe_device_hack', alarm_difficulty = 'easy', alarm_item = 'hacking_device' },
    },

    Alarm = {
        Panel = {
            Enabled = true, -- physical alarm connection and hacking scene
            SafeEnabled = true,
            Model = 'zloma_alarm_panel',
            DisabledModel = 'zloma_alarm_panel_off', -- private screen material keeps other panels armed
            DeviceModel = 'zloma_hacking_device',
            ConnectorModel = 'zloma_hacking_connector',
            StreamDistance = 18.0, -- panel props exist only this close (same floor)
            ScreenDistance = 3.5,  -- live panel screens (DUI) run only this close; further away the
                                   -- panel shows its built-in texture and costs nothing
            AutoHeight = 0.18, -- above the centre of the closed door model
            ApproachDistance = 0.65,
            CableScale = 0.70, -- shortest USB cable (1.0 = factory). It is always lengthened to
                               -- leave some slack between the held device and the panel port.
            -- The hacker holds the device in both hands. Tune it live with
            -- /apartment_alarm_hold (Config.Debug), it prints the values to paste here.
            Hold = {
                dict = 'amb@code_human_wander_texting@male@base', anim = 'static', -- sd-phone typing pose (both hands)
                bone = 28422, -- SKEL_R_Hand (PH_R_Hand)
                offset = vec3(-0.008, 0.010, 0.012),
                rotation = vec3(-253.5, -3.0, -8.0),
                -- Where the cable socket of the held device should end up, from the panel
                -- centre (x right, y out of the wall, z up). The player is moved to match.
                socketTarget = vec3(-0.03, 0.22, -0.17),
            },
            -- Close-up camera just under the player's chin (from the head: forward along the
            -- player's facing, down, right), aimed between the panel and the device.
            -- Shallow depth of field blurs everything else.
            -- The camera leans towards the mouse (look: degrees at the screen edge, doubled
            -- when zoomed in) and the mouse wheel zooms from fov down to minFov.
            Camera = { forward = 0.10, down = 0.13, side = 0.0, fov = 80.0, minFov = 25.0,
                       look = { yaw = 14.0, pitch = 12.0 }, dof = true },
            ConnectSeconds = 4,
            SessionSeconds = 90,
            -- Connection alone never disables the alarm; the device stages must succeed.
        },
        -- The hack on the door alarm panel (after the cable is plugged in). Its
        -- stages and difficulty are device_hack in config_minigame.lua.
        Hack = {
            Strikes = 1,                -- mistakes allowed in one hack: a failed stage is played
                                        -- again with a new puzzle. One more and the hack fails.
            DispatchOnFail = true,      -- a failed hack can call the police
            FailsBeforeDispatch = 1,    -- failed hacks (same player, same door) before the police
                                        -- are called: 1 = the first, 2 = the second, ...
            FailMemorySeconds = 900,    -- how long failed hacks count towards that
            AllowCancel = true,         -- ESC stops the hack
            CancelCountsAsFail = false, -- stopping counts as a failed hack (police, item)
            RemoveItem = {              -- use up alarm_item (hacking_device)
                OnSuccess = false,
                OnFail = true,
                OnCancel = false,
            },
            -- Camera on the device screen while hacking: fov (smaller = from further
            -- away) and how much of the view the screen fills.
            Camera = { fov = 18.0, fill = 0.82 },
        },
        SafeHack = { Strikes = 2, DispatchOnFail = true }, -- overrides Hack for safes; stages: safe_device_hack
        Key = 'J',                 -- "Hack alarm" at a locked door (safes: target option)
        -- Tell the owner and roommate when their alarm goes off: true = ox_lib
        -- notification, false = none. Other resources can take this over (e.g.
        -- a phone notification): exports.zloma_apartments:RegisterAlarmNotifier
        -- or Customization.OnAlarmOwner, see README.
        NotifyOwner = true,
        DisableSeconds = 120,      -- legacy config compatibility; alarms now stay off until resident reactivation
        Cooldown = 30,             -- seconds between hacking attempts per player
        RemoveItemOnFail = false,  -- a failed hack breaks the alarm item
        DispatchOnHackFail = true, -- a failed hack on an alarmed door/safe calls the police
        Dispatch = {               -- sent through zloma_core (SendDispatchAlert)
            job = { 'police' },
            code = '10-90',
            priority = 'high',
            icon = 'fa-solid fa-house-lock',
            blip = { sprite = 40, color = 1, scale = 1.2 },
            time = 5,              -- minutes the alert stays
        },
    },
}

-- =============================================
-- DOOR LOCKPICK (game 'tr_lockpick' in config_minigame.lua)
-- A real wafer lock on the door, picked with a Lishi-style pick. Made by
-- TR Scripts (tr_minigames). How hard each difficulty is: config_minigame.lua.
-- =============================================
Config.DoorPick = {
    devMode = false,  -- arrows / Q / E move the lock while picking + /apartment_doorpick_rig; off on a live server
    maxStrikes = 3,   -- bends before the pick snaps
    timeLimit = 180,  -- seconds
    minTime = 6,      -- seconds; faster is rejected as cheating
    reach = 3.0,      -- metres the player may be from the door while picking
    liftSensitivity = 1.0,
    volume = 0.8,     -- 0..1

    -- Where the lock sits on a door, measured from the door's model:
    --   inset  metres in from the door's free edge (away from the hinge)
    --   height metres above the bottom of the door
    --   out    metres the lock stands out of the door face
    -- Rough for most doors. Fit a model in devMode: every arrow / Q / E press
    -- prints the line for doorFits in F8.
    rig = { inset = 0.10, height = 0.98, out = 0.004 },
    doorFits = { -- by model name or hash
        -- [`v_ilev_fh_frontdoor`] = { inset = 0.09, height = 1.02, out = 0.004 },
    },

    camera = { pos = vec3(-0.136, -0.269, 0.071), target = vec3(0.0, -0.045, 0.002), fov = 46.0 },
    torch = 0.6, -- light on the lock; 0 turns it off
}

-- =============================================
-- DEFAULTS FOR NEW BUILDINGS
-- The creator starts every new building with these values.
-- =============================================
Config.BuildingDefaults = {
    pricing = {
        daily = 500,            -- prepaid daily rent
        contractDaily = 350,    -- contract rent per day, paid up front
        contractMinDays = 7,
        contractMaxDays = 30,
        buy = 150000,
    },
    enablePrepaid = true,
    enableContract = true,
    enableBuy = true,
    blip = { sprite = 475, color = 2, scale = 0.8 },
    receptionModel = 'a_m_m_business_01',
    receptionScenario = 'WORLD_HUMAN_CLIPBOARD',
    doorModel = nil,            -- captured from the first door you aim at
}

-- =============================================
-- FURNITURE EDITOR
-- =============================================
Config.Furniture = {
    MaxProps = 150,
    StreamDistance = 18.0,
    VerticalStreamDistance = 2.5,
    SpawnBatchSize = 3,
    MaxLocalOffset = 60.0,
    CameraDistance = 70.0,
}
