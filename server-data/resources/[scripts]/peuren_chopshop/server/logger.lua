function LootLogger(playerId, item, amount)
    if not ApiKeys.Enabled then return end

    PerformHttpRequest(ApiKeys.LootLogs, function(err, text, header) end, 'POST', json.encode(
        {
            embeds = {
              {
                description = "",
                fields = {
                  {
                    name = "Username",
                    value = lib.Framework.GetCharName(playerId).full.." ("..playerId..")",
                    inline = false
                  },
                  {
                    name = "Identifier",
                    value = lib.Framework.GetIdentifier(playerId),
                    inline = false
                  },
                  {
                    name = "Item",
                    value = item,
                    inline = false
                  },
                  {
                    name = "Amount",
                    value = amount.."x",
                    inline = false
                  }
                },
                author = {
                  name = "peuren_chopshop"
                },
                title = "LOOTED",
                footer = {
                  text = "peuren.tebex.io"
                },
                color = 65420
              }
            },
          }
    ), {
        ['Content-Type'] = 'application/json'
    })
end

function JobLogger(playerId, dealer, shell)
    if not ApiKeys.Enabled then return end

    PerformHttpRequest(ApiKeys.JobLogs, function(err, text, header) end, 'POST', json.encode(
        {
            embeds = {
              {
                description = "",
                fields = {
                  {
                    name = "Username",
                    value = lib.Framework.GetCharName(playerId).full.." ("..playerId..")",
                    inline = false
                  },
                  {
                    name = "Identifier",
                    value = lib.Framework.GetIdentifier(playerId),
                    inline = false
                  },
                  {
                    name = "Dealer",
                    value = dealer,
                    inline = false
                  },
                  {
                    name = "Shell",
                    value = shell,
                    inline = false
                  }
                },
                author = {
                    name = "peuren_chopshop"
                },
                title = "RECEIVED JOB",
                footer = {
                  text = "peuren.tebex.io"
                },
                color = 14142976
              }
            },
          }
    ), {
        ['Content-Type'] = 'application/json'
    })
end