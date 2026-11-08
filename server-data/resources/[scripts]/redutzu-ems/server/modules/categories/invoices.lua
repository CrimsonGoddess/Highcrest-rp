invoices = {}

function invoices.search(query)
    local results = MySQL.Sync.fetchAll([[
        SELECT
            ems_invoices.id,
            ems_invoices.name,
            ems_invoices.amount,
            IF(tag = NULL, NULL, (
                SELECT
                    JSON_OBJECT('identifier', ems_tags.identifier, 'label', ems_tags.name, 'color', ems_tags.color)
                FROM
                    ems_tags
                WHERE
                    ems_tags.identifier = ems_invoices.tag AND ems_tags.type = 'invoice'
            )) AS tag
        FROM 
            ems_invoices
        WHERE
            ems_invoices.name LIKE :query
        ORDER BY
            createdAt DESC
        LIMIT
            :limit
    ]], {
        query = "%" .. query .. "%",
        limit = Config.Settings.MaximumResults
    })
    
    for i = 1, #results do
        results[i].tag = json.decode(results[i].tag)
    end
    
    return results
end

function invoices.single(id)
    local result = MySQL.Sync.fetchSingle([[
        SELECT
            ems_invoices.id,
            ems_invoices.name,
            ems_invoices.description,
            ems_invoices.amount,
            ems_invoices.createdAt,
            (
                SELECT
                    JSON_OBJECT('identifier', ems_tags.identifier, 'label', ems_tags.name, 'color', ems_tags.color)
                FROM
                    ems_tags
                WHERE
                    ems_invoices.tag = ems_tags.identifier
            ) as tag
        FROM
            ems_invoices
        WHERE
            ems_invoices.id = ?
    ]], {id})
    
    result.tag = json.decode(result.tag)
    return result
end

exports("SearchInvoice", invoices.single)

function invoices.create(data)
    return MySQL.Sync.insert("INSERT INTO ems_invoices (name, description, amount, tag) VALUES (:name, :description, :amount, :tag)", data)
end

exports("CreateInvoice", invoices.create)

function invoices.update(id, data)
    if table.isEmpty(data) then
        return false
    end
    
    local clause = GenerateClause(data)
    data.id = id
    
    return MySQL.Sync.execute("UPDATE ems_invoices SET " .. clause .. " WHERE id = :id", data) > 0
end

exports("UpdateInvoice", invoices.update)

function invoices.delete(id)
    return MySQL.Sync.execute("DELETE FROM ems_invoices WHERE id = ?", {id}) > 0
end

exports("DeleteInvoice", invoices.delete)
