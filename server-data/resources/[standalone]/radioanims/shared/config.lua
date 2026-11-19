Config = {}

Config.Command = 'radioanim'

Config.Menu = {
    id = 'radioanim:menu',
    title = 'Radio Animations'
}

Config.Animations = {
    {
        id = 'handheld',
        label = 'Handheld Radio',
        dict = 'anim@male@holding_radio',
        clip = 'holding_radio_clip',
        flag = 49,
        prop = {
            model = 'prop_cs_hand_radio',
            bone = 28422,
            pos = vec3(0.0750, 0.0230, -0.0230),
            rot = vec3(-90.0000, 0.0, -59.9999)
        }
    },
    {
        id = 'shoulder',
        label = 'Shoulder Mic',
        dict = 'random@arrests',
        clip = 'generic_radio_chatter',
        flag = 49,
        prop = nil
    },
    {
        id = 'cop_pose',
        label = 'LEO Radio Pose',
        dict = 'anim@cop_mic_pose_002',
        clip = 'chest_mic',
        flag = 49,
        prop = nil
    },
    {
        id = 'ear_piece',
        label = 'LEO Ear Piece',
        dict = 'cellphone@',
        clip = 'cellphone_call_listen_base',
        flag = 49,
        prop = nil
    },
}

Config.Default = 'handheld'
