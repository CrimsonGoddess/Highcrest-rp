-- Usage: exports.highcrest_itemuses:consume(source, 'lockpick', amount?)
-- Returns uses left (0 = item removed), or nil if the player doesn't have the item or it has no uses set.

local function getSlot(src, item)
    return exports.ox_inventory:GetSlotWithItem(src, item)
end

local function consume(src, item, amount)
    local max = Config.Uses[item]
    if not max then return nil end

    local slot = getSlot(src, item)
    if not slot then return nil end

    local left = (slot.metadata and slot.metadata.uses or max) - (amount or 1)
    if left <= 0 then
        exports.ox_inventory:RemoveItem(src, item, 1, nil, slot.slot)
        return 0
    end

    exports.ox_inventory:SetMetadata(src, slot.slot, { uses = left, description = left .. ' uses left' })
    return left
end

local function getUses(src, item)
    local max = Config.Uses[item]
    if not max then return nil end
    local slot = getSlot(src, item)
    if not slot then return nil end
    return slot.metadata and slot.metadata.uses or max
end

exports('consume', consume)
exports('getUses', getUses)
