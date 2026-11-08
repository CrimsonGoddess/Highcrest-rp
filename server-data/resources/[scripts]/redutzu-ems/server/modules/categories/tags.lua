tags = {}

function tags.search(query, tagType)
    return MySQL.Sync.fetchAll([[
        SELECT
            ems_tags.identifier,
            ems_tags.color,
            ems_tags.name AS label
        FROM
            ems_tags
        WHERE
            ems_tags.name LIKE :query
        AND
            ems_tags.type = :type
        LIMIT :limit
    ]], {
        query = "%" .. query .. "%",
        type = tagType,
        limit = Config.Settings.MaximumResults
    })
end

exports("SearchTags", tags.search)

function tags.create(data)
    local identifier = GenerateUniqueId("ems_tags", "identifier", function()
        return GenerateRandomString(7)
    end)
    
    return MySQL.Sync.insert([[
        INSERT INTO ems_tags
            (identifier, name, type, description, color)
        VALUES
            (:identifier, :name, :type, :description, :color)
    ]], {
        identifier = identifier,
        name = data.label,
        type = data.type,
        description = data.description,
        color = data.color
    })
end

exports("CreateTag", tags.create)
