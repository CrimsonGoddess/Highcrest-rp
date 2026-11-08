incidents = {}

function incidents.search(query)
    local results = MySQL.Sync.fetchAll("SELECT * FROM ems_incidents WHERE id = :id OR name LIKE :query ORDER BY createdAt DESC LIMIT :limit", {
        id = query,
        query = "%" .. query .. "%",
        limit = Config.Settings.MaximumResults
    })
    
    for i = 1, #results do
        results[i].victims = json.decode(results[i].victims)
        results[i].doctors = json.decode(results[i].doctors)
        results[i].invoices = json.decode(results[i].invoices)
    end
    
    return results
end

function incidents.single(id)
    local selection = [[
        ems_incidents.id,
        ems_incidents.name,
        ems_incidents.description,
        ems_incidents.createdAt,
        ems_incidents.invoices AS invoice_data,
        (SELECT CONCAT('[', GROUP_CONCAT(JSON_OBJECT('id', ems_invoices.id, 'name', ems_invoices.name)), ']') FROM ems_invoices WHERE JSON_CONTAINS(JSON_EXTRACT(ems_incidents.invoices, '$.list'), ems_invoices.id)) AS invoice_list,
    ]]
    
    local victimsSubquery = "(SELECT CONCAT('[', GROUP_CONCAT(JSON_OBJECT('identifier', " .. string.format("%s.%s", citizens.table, citizens.identifier) .. ", 'name', " .. citizens.name .. ")), ']') FROM " .. citizens.table .. " WHERE JSON_CONTAINS(ems_incidents.victims, JSON_QUOTE(" .. string.format("%s.%s", citizens.table, citizens.identifier) .. "))) AS victims"
    local doctorsSubquery = "(SELECT CONCAT('[', GROUP_CONCAT(JSON_OBJECT('identifier', " .. string.format("%s.%s", citizens.table, citizens.identifier) .. ", 'name', " .. citizens.name .. ")), ']') FROM " .. citizens.table .. " WHERE JSON_CONTAINS(ems_incidents.doctors, JSON_QUOTE(" .. string.format("%s.%s", citizens.table, citizens.identifier) .. "))) AS doctors"
    local imagesSubquery = "(SELECT CONCAT('[', GROUP_CONCAT(JSON_OBJECT('id', ems_gallery.id, 'value', ems_gallery.value, 'description', ems_gallery.description)), ']') FROM ems_gallery WHERE JSON_CONTAINS(ems_incidents.images, ems_gallery.id)) AS images"
    
    selection = selection .. table.concat({victimsSubquery, doctorsSubquery, imagesSubquery}, ",\n")
    
    local result = MySQL.Sync.fetchSingle(string.format("SELECT %s FROM ems_incidents WHERE ems_incidents.id = ?", selection), {id})
    
    result.victims = json.decode(result.victims)
    result.doctors = json.decode(result.doctors)
    result.images = json.decode(result.images)
    
    local invoiceData = json.decode(result.invoice_data)
    local invoiceList = json.decode(result.invoice_list)
    
    result.invoices = {
        list = array.map(invoiceData.list, function(invoiceId)
            return array.find(invoiceList, function(invoice)
                return invoice.id == invoiceId
            end)
        end),
        reduction = invoiceData.reduction,
        amount = invoiceData.amount
    }
    
    return result
end

exports("SearchIncident", incidents.single)

function incidents.create(data, source)
    local insertId = MySQL.Sync.insert([[
        INSERT INTO ems_incidents
            (name, description, victims, doctors, invoices, images)
        VALUES
            (:name, :description, :victims, :doctors, :invoices, :images)
    ]], {
        name = data.name,
        description = json.encode(data.description),
        victims = json.encode(data.victims),
        doctors = json.encode(data.doctors),
        invoices = json.encode(data.invoices),
        images = json.encode(data.images)
    })
    
    local totalAmount = data.invoices.amount
    local reductionAmount = data.invoices.amount * (data.invoices.reduction / 100)
    totalAmount = totalAmount - reductionAmount
    
    if totalAmount > 0 then
        HandleSocietyInvoice(totalAmount, source)
    end
    
    for i = 1, #data.victims do
        if totalAmount > 0 then
            BillPlayer(data.victims[i], totalAmount, source)
        end
    end
    
    return insertId
end

exports("CreateIncident", incidents.create)

function incidents.update(id, data)
    local clause = GenerateClause(data)
    data.id = id
    
    data.description = json.encode(data.description)
    data.victims = json.encode(data.victims)
    data.doctors = json.encode(data.doctors)
    data.images = json.encode(data.images)
    
    return MySQL.Sync.execute("UPDATE ems_incidents SET " .. clause .. " WHERE id = :id", data) > 0
end

exports("UpdateIncident", incidents.update)

function incidents.delete(id)
    return MySQL.Sync.execute("DELETE FROM ems_incidents WHERE id = ?", {id}) > 0
end

exports("DeleteIncident", incidents.delete)
