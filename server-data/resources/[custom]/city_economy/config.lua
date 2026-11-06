Config = {
    -- Share of each paycheck taken as income tax. 0.10 is 10%; 0 turns tax off.
    taxRate = 0.10,

    -- Bank account that receives tax. Renewed-Banking creates one account per job,
    -- so this is the "government" job's account and its boss grade can manage it.
    treasuryAccount = 'government',

    -- Jobs that pay no income tax.
    exemptJobs = {
        unemployed = true,
    },
}
