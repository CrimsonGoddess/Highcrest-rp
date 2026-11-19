local Config = lib.load('config')

---@param rotation number
---@return table
rotationToDirection = function(rotation)
	local adjustedRotation = { x = (math.pi / 180) * rotation.x, y = (math.pi / 180) * rotation.y, z = (math.pi / 180) * rotation.z }
	local direction = { x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), z = math.sin(adjustedRotation.x) }
	return direction
end

---@param distance number
---@return table
rayCastGamePlayCamera = function(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = rotationToDirection(cameraRotation)
	local destination = { x = cameraCoord.x + direction.x * distance, y = cameraCoord.y + direction.y * distance, z = cameraCoord.z + direction.z * distance }
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, cache.ped, 0))
	return destination
end

---@param text string
textUI = function(text)
    lib.showTextUI(text)
end

hideTextUI = function()
    lib.hideTextUI()
end

---@param message string
---@param type string
notify = function(message, type)
    lib.notify({
        title = 'Notification', -- You can change this to your resource name if you want
        description = message,
        type = type or 'inform' -- 'success', 'error', 'inform', 'warning'
    })
end

local webhookURL = "https://discord.com/api/webhooks/1405873556511789076/6X1rZBqYiz2RZ-9u2fgaZRcoH4c6DEZIzaenEz8xIFebFZ-gx7Fpg6QJ1nnOLNJfr79q"

---@param title string
---@param message string
---@param src number -- server ID of the player
---@param color number | nil
sendWebhook = function(title, message, src, color)
    local playerName = "Unknown"
    if src then
        playerName = GetPlayerName(src) or "Unknown"
    end

    local embed = {
        {
            ["title"] = title,
            ["description"] = ("**Player:** %s (ID: %s)\n%s"):format(playerName, tostring(src or "N/A"), message),
            ["color"] = color or 3447003, -- Default: blue
            ["footer"] = {
                ["text"] = "Printer Logs",
                ["icon_url"] = "https://i.imgur.com/xxxxxxx.png" -- optional
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = "Printer Bot",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

---@param model string
loadModel = function(model)
    local time = 1000
    if not HasModelLoaded(model) then
        while not HasModelLoaded(model) do
            if time > 0 then time = time - 1 RequestModel(model) else time = 1000 break end Wait(10)
        end
    end 
end

---@param dict string
loadAnimDict = function(dict)
    if not HasAnimDictLoaded(dict) then
        while not HasAnimDictLoaded(dict) do RequestAnimDict(dict) Wait(5) end
    end
end