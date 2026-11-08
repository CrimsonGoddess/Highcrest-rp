Messages = {}

Framework.RegisterCallback("GetChatMessages", function(source, callback)
    local identifier = Framework.GetPlayerIdentifier(source)
    local result = {}
    local maxMessages = math.min(#Messages, 100)
    
    for i = 1, maxMessages do
        local message = Messages[i]
        result[i] = {
            message = message.message,
            timestamp = message.timestamp,
            author = {
                self = message.author.identifier == identifier,
                name = message.author.name,
                image = message.author.image
            }
        }
    end
    callback(result)
end)

Framework.RegisterCallback("SendMessage", function(source, callback, data)
    local firstName, lastName = Framework.GetCharacterName(source)
    local identifier = Framework.GetPlayerIdentifier(source)
    
    local message = {
        message = data.message,
        timestamp = data.timestamp,
        author = {
            name = firstName .. " " .. lastName,
            identifier = identifier,
            image = nil
        }
    }
    
    Messages[#Messages + 1] = message
    
    for i = 1, #Config.WhitelistedJobs do
        local jobPlayers = Framework.GetJobPlayers(Config.WhitelistedJobs[i])
        for _, player in ipairs(jobPlayers) do
            TriggerClientEvent("redutzu-ems:client:addChatMessage", player.source, message)
        end
    end
    
    callback(message)
end)
