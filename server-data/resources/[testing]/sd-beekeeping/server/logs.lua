return {
    logs = {
        -- What logging service do you want to use?
        -- Available options: 'fivemanage', 'fivemerr', 'discord', 'loki', 'grafana' & 'none'
        service     = 'none',

        -- Do you want to include screenshots with your logs?
        -- This is only applicable to Fivemanage and Fivemerr
        screenshots = false,

        -- You can enable (true) or disable (false) specific events to log here
        events = {
            -- Player shop interactions
            buy_product         = true,  -- when a player buys a product
            sell_product        = true,  -- when a player sells a product
        
            -- Object spawning/removal
            remove_item         = true,  -- when a player removes a hive/house item
            create_object       = true,  -- when a new hive/house record is created
            delete_object       = true,  -- when a hive/house is deleted
        
            -- Data queries & persistence
            request_objects     = true,  -- when a player requests cached objects
        
            -- Collaborator management
            add_collaborator    = true,  -- when a collaborator is added to a hive/house
            remove_collaborator = true,  -- when a collaborator is removed
        
            -- Hive/House state changes
            toggle_blip         = true,  -- when a blip is toggled on/off
            repair_facility     = true,  -- when a facility is repaired
            treat_hive          = true,  -- when a hive infection is treated
            purchase_shield     = true,  -- when a shield is purchased
        
            -- Withdrawals
            withdraw_bee        = true,  -- when bees/queens/workers are withdrawn
            withdraw_product    = true,  -- when honey/wax is withdrawn
        
            -- Insertions
            insert_queen        = true,  -- when a queen is inserted into a hive
            insert_worker       = true,  -- when workers are inserted into a hive
        },

        -- If service = 'discord', you can customize the webhook data here
        -- If not using Discord, this section can be ignored
        discord = {
            -- The name of the webhook
            name   = 'Beekeeping Logs',
            -- The webhook URL
            link   = '',
            -- The webhook avatar image
            image  = '',
            -- The webhook footer icon
            footer = '',
        },

        -- If service = 'loki', provide your Loki push settings
        loki = {
            -- Base URL (without trailing slash), e.g. 'https://loki.example.com'
            endpoint = '',
            -- (Optional) Basic auth username
            user     = '',
            -- (Optional) Basic auth password or API key
            password = '',
            -- (Optional) X-Scope-OrgID header value
            tenant   = ''
        },

        -- If service = 'grafana', provide your Grafana Cloud Logs settings
        grafana = {
            -- Base URL (without trailing slash), e.g. 'https://logs-prod.grafana.net'
            endpoint = '',
            -- Your Grafana API key (prefixed with 'Bearer ')
            apiKey   = '',
            -- (Optional) X-Scope-OrgID header value
            tenant   = ''
        }
    },
}
