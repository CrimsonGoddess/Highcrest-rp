Config = {}

Config.Debug = false

-- How far away the player can be from an existing prop before it is despawned client-side.
Config.StreamDistance = 200.0

-- How far away from the player a placement raycast can hit.
Config.PlaceMaxDistance = 7.5

-- Limits per player (citizenid) to prevent spam.
Config.MaxPropsPerPlayer = 50

-- Rate limit placement requests.
Config.PlaceCooldownMs = 800

-- Items that can be used to place props.
-- item = ox_inventory item name
-- model = prop model name
-- label = shown in prompts
-- consume = remove item on successful placement
-- allowRotate = allow rotation (heading) changes
Config.PlaceableItems = {
    -- Example:
    ["pyogamat"] = { model = `prop_yoga_mat_03`, label = 'Yoga Mat', consume = true, allowRotate = true },
    ["byogamat"] = { model = `prop_yoga_mat_02`, label = 'Yoga Mat', consume = true, allowRotate = true },
    ["blyogamat"] = { model = `prop_yoga_mat_01`, label = 'Yoga Mat', consume = true, allowRotate = true },
}

-- Keybinds (ox_lib)
Config.Keybinds = {
    rotateLeft = { name = 'placeprops_rotate_left', defaultKey = 'LEFT', description = 'Rotate prop left' },
    rotateRight = { name = 'placeprops_rotate_right', defaultKey = 'RIGHT', description = 'Rotate prop right' },
    place = { name = 'placeprops_place', defaultKey = 'E', description = 'Place prop' },
    cancel = { name = 'placeprops_cancel', defaultKey = 'BACK', description = 'Cancel placement' },
}

-- Rotation step per key press while placing.
Config.RotationStep = 5.0

-- Target interaction
Config.Target = {
    enabled = true,
    icon = 'fa-solid fa-box',
    removeLabel = 'Pick up',
    removeDistance = 2.0,
}

-- Who can remove props:
-- 'owner' = only placer
-- 'any' = anyone
Config.RemovePermission = 'owner'

-- Resource-local storage file
Config.StorageFile = 'data/props.json'
