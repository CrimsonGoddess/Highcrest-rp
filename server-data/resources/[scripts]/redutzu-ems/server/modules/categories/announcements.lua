announcements = {}

function announcements.search(query)
    local authorSubquery = string.format("JSON_OBJECT('identifier', %s, 'name', %s)", string.format("%s.%s", citizens.table, citizens.identifier), citizens.name)
    
    return MySQL.Sync.fetchAll(string.format([[
        SELECT
            ems_announcements.id,
            ems_announcements.title,
            ems_announcements.content,
            ems_announcements.pinned,
            ems_announcements.createdAt,
            (SELECT %s FROM %s WHERE %s = ems_announcements.author) AS author
        FROM
            ems_announcements
        WHERE
            ems_announcements.id = :id
        OR
            ems_announcements.title LIKE :query
    ]], authorSubquery, citizens.table, string.format("%s.%s", citizens.table, citizens.identifier)), {
        id = query,
        query = "%" .. query .. "%"
    })
end

function announcements.single(id)
    local authorSubquery = string.format("JSON_OBJECT('identifier', %s, 'name', %s)", string.format("%s.%s", citizens.table, citizens.identifier), citizens.name)
    
    local result = MySQL.Sync.fetchSingle(string.format([[
        SELECT
            ems_announcements.id,
            ems_announcements.title,
            ems_announcements.content,
            ems_announcements.pinned,
            (SELECT %s FROM %s WHERE %s = ems_announcements.author) AS author
        FROM
            ems_announcements
        WHERE
            ems_announcements.id = ?
    ]], authorSubquery, citizens.table, string.format("%s.%s", citizens.table, citizens.identifier)), {id})
    
    result.author = json.decode(result.author)
    return result
end

exports("SearchAnnouncement", announcements.single)

function announcements.last()
    local authorSubquery = string.format("JSON_OBJECT('identifier', %s, 'name', %s)", string.format("%s.%s", citizens.table, citizens.identifier), citizens.name)
    
    local results = MySQL.Sync.fetchAll(string.format([[
        SELECT
            ems_announcements.id,
            ems_announcements.title,
            ems_announcements.content,
            ems_announcements.pinned,
            ems_announcements.createdAt,
            (SELECT %s FROM %s WHERE %s = ems_announcements.author) AS author
        FROM
            ems_announcements
        ORDER BY
            ems_announcements.createdAt DESC
        LIMIT
            1
    ]], authorSubquery, citizens.table, string.format("%s.%s", citizens.table, citizens.identifier)), {})
    
    if #results <= 0 then
        return nil
    end
    
    local result = results[1]
    result.author = json.decode(result.author)
    return result
end

function announcements.create(data, source)
    local identifier = Framework.GetPlayerIdentifier(source)
    
    return MySQL.Sync.insert([[
        INSERT INTO ems_announcements
            (title, content, author)
        VALUES
            (:title, :content, :author)
    ]], {
        title = data.title,
        content = json.encode(data.content),
        author = identifier
    })
end

exports("CreateAnnouncement", announcements.create)

function announcements.update(id, data)
    local clause = GenerateClause(data)
    data.id = id
    
    return MySQL.Sync.execute("UPDATE ems_announcements SET " .. clause .. " WHERE id = :id", data) > 0
end

exports("UpdateAnnouncement", announcements.update)

function announcements.delete(id)
    return MySQL.Sync.execute("DELETE FROM ems_announcements WHERE id = ?", {id}) > 0
end

exports("DeleteAnnouncement", announcements.delete)
