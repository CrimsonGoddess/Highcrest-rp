lib.Framework.RegisterCallback('peuren_gruppe6:viewRank', function(source, cb)
    cb(Ranks.Get(source).Level)
end)