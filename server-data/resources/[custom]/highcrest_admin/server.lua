-- Admin helper commands for testing and staff use.

-- Marked bills keep their value in the item's metadata, which /giveitem can't set.
lib.addCommand('givedirty', {
    help = 'Give marked bills (dirty money) worth an amount',
    params = {
        { name = 'target', type = 'playerId', help = 'Player id' },
        { name = 'amount', type = 'number', help = 'Value in dollars' },
    },
    restricted = 'group.admin',
}, function(source, args)
    local amount = math.floor(args.amount)
    if amount < 1 or amount > 10000000 then
        return lib.notify(source, { type = 'error', description = 'Enter an amount between $1 and $10,000,000.' })
    end
    local ok = exports.ox_inventory:AddItem(args.target, 'markedbills', 1, {
        worth = amount,
        description = ('Value: $%d'):format(amount),
    })
    if source > 0 then
        lib.notify(source, ok
            and { type = 'success', description = ('Gave $%d in marked bills.'):format(amount) }
            or { type = 'error', description = 'Their inventory is full.' })
    end
end)
