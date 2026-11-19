---@type table
local Config = lib.load('config')

---@type table
local printers = {}

MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT * FROM `printers`', {}, function(result)
        for _, v in pairs(result) do
            printers[v.id] = { coords = json.decode(v.coords), printer = v.printer }
        end
    end)
end)

local updatePrinters = function()
    for _, v in pairs(GetPlayers()) do
        lib.callback.await('mt_printers:client:updatePrinters', v)
    end
end

---@param id number
local deletePrinter = function(id)
    for _, v in pairs(GetPlayers()) do
        lib.callback.await('mt_printers:client:delete', v, id)
    end
end

lib.callback.register('mt_printers:server:getPrinters', function(source)
    return printers
end)

---@param source number
---@param printer string
---@param action string
lib.callback.register('mt_printers:server:itemActions', function(source, printer, action)
    local src = source
    if action == 'remove' then
        exports.ox_inventory:RemoveItem(src, printer, 1)
    else
        exports.ox_inventory:AddItem(src, printer, 1)
    end
end)

---@param source number
---@param printer string
---@param coords any
---@param heading number
---@return boolean
lib.callback.register('mt_printers:server:place', function(source, printer, coords, heading)
    local src = source
    coords = vec4(coords.x, coords.y, coords.z, heading)
    MySQL.insert('INSERT INTO `printers` (printer, coords) VALUES (?, ?)', {
        printer, json.encode(coords)
    }, function(id)
        printers[id] = { id = id, coords = coords, printer = printer }
        updatePrinters()
    end)
    return true
end)

---@param source number
---@param data table
---@return boolean
lib.callback.register('mt_printers:server:printDocument', function(source, data)
    exports.ox_inventory:AddItem(source, 'print_document', tonumber(data[3]), { imageurl = data[2], label = data[1] })
    return true
end)

---@param source number
---@param id number
---@return boolean
lib.callback.register('mt_printers:server:delete', function(source, id)
    MySQL.Async.execute('DELETE FROM `printers` WHERE `id` = ?', { id }, function()
        printers[id] = nil
        deletePrinter(id)
    end)
    return true
end)

RegisterNetEvent("mt_printers:server:printDocument", function(docInfo)
    local src = source
    local text = ("Printed document: %s"):format(docInfo[2]) -- assuming input[2] is the image URL or name
    sendWebhook("Printer Used", text, src, 65280) -- green embed
end)
