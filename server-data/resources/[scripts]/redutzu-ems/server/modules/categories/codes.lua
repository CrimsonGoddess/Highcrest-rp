codes = {}

function codes.search(query)
    return MySQL.Sync.fetchAll("SELECT * FROM ems_codes WHERE name LIKE :query OR id = :id LIMIT :limit", {
        id = query,
        query = "%" .. query .. "%",
        limit = Config.Settings.MaximumResults
    })
end

function codes.single(id)
    return MySQL.Sync.fetchSingle("SELECT * FROM ems_codes WHERE id = ?", {id})
end

exports("SearchCode", codes.single)

function codes.create(data)
    return MySQL.Sync.insert([[
        INSERT INTO ems_codes
            (name, description, code)
        VALUES
            (:name, :description, :code)
        ON DUPLICATE KEY UPDATE
            ems_codes.id = id 
    ]], data)
end

exports("CreateCode", codes.create)

function codes.update(id, data)
    if table.isEmpty(data) then
        return false
    end
    
    local clause = GenerateClause(data)
    data.id = id
    
    return MySQL.Sync.execute("UPDATE ems_codes SET " .. clause .. " WHERE id = :id", data) > 0
end

exports("UpdateCode", codes.update)

function codes.delete(id)
    return MySQL.Sync.execute("DELETE FROM ems_codes WHERE id = ?", {id}) > 0
end

exports("DeleteCode", codes.delete)
