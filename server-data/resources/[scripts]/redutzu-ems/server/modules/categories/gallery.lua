gallery = {}

Framework.RegisterCallback("AddGalleryImage", function(source, callback, data)
    local insertId = MySQL.Sync.insert("INSERT INTO ems_gallery (identifier, type, value, description) VALUES (:identifier, :type, :value, :description)", {
        identifier = data.identifier,
        type = data.type,
        value = data.value,
        description = data.description
    })
    callback(insertId)
end)

function gallery.delete(id)
    return MySQL.Sync.execute("DELETE FROM ems_gallery WHERE id = ?", {id}) > 0
end
