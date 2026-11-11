Config.ItemCarrying = {
    -- { 
    --     item = item name, 
    --     carrying = carrying prop data, if you don't need this set it to false
    -- }

    { item = "bonnet", carrying = {
        prop = 'imp_prop_impexp_bonnet_05a',
        boneIndex = 28422,
        anim = "idle",
        animDict = "anim@heists@box_carry@",
        disableSprint = true,
        disableJump = true,
        disableFight = true,
        offsets = { 0.0, -0.1, 1.5, -80.0, 0.0, 0.0 }
    }},

    { item = "door", carrying = {
        prop = 'imp_prop_impexp_car_door_02a',
        boneIndex = 28422,
        anim = "idle",
        animDict = "anim@heists@box_carry@",
        disableSprint = true,
        disableJump = true,
        disableFight = true,
        offsets = { -0.5, -0.15, 0.25, 0.0, 0.0, 90.0 }
    }},

    { item = "boot", carrying = {
        prop = 'imp_prop_impexp_trunk_01a',
        boneIndex = 28422,
        anim = "idle",
        animDict = "anim@heists@box_carry@",
        disableSprint = true,
        disableJump = true,
        disableFight = true,
        offsets = { 0.0, 0.0, 0.55, 90.0, 0.0, -180.0 }
    }},

    { item = "wheel", carrying = {
        prop = 'prop_wheel_01',
        boneIndex = 28422,
        anim = "idle",
        animDict = "anim@heists@box_carry@",
        disableSprint = true,
        disableJump = true,
        disableFight = true,
        offsets = { 0.0, -0.1, 0.10, 0.0, 0.0, 0.0 }
    }},

    { item = "engine", carrying = {
        prop = 'imp_prop_impexp_engine_part_01a',
        boneIndex = 28422,
        anim = "idle",
        animDict = "anim@heists@box_carry@",
        disableSprint = true,
        disableJump = true,
        disableFight = true,
        offsets = { 0.0, -0.1, -0.15, 0.0, 0.0, -180.0 }
    }},
}