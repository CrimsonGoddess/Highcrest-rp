Config = {
    -- Businesses one character can own at once.
    maxOwnedBusinesses = 3,

    -- Staff limit per business, including the owner.
    maxStaff = 50,

    -- Share of the purchase price returned when an owner sells back to the market.
    sellBackShare = 0.5,

    -- Largest single deposit, withdrawal or wage.
    maxTransaction = 100000000,

    -- How long a job offer stays open, in seconds.
    offerLifetimeSeconds = 300,

    -- Used by /empirecreate. Later stages can give each type its own features.
    businessTypes = {
        restaurant = 'Restaurant',
        bar = 'Bar',
        nightclub = 'Nightclub',
        dealership = 'Dealership',
        mechanic = 'Mechanic',
        retail = 'Retail',
        security = 'Security',
        other = 'Other',
    },

    -- What a rank can be allowed to do. Owners can always do everything.
    permissions = {
        { id = 'hire', label = 'Hire staff' },
        { id = 'fire', label = 'Fire staff' },
        { id = 'promote', label = 'Change ranks' },
        { id = 'deposit', label = 'Deposit money' },
        { id = 'withdraw', label = 'Withdraw money' },
        { id = 'pay', label = 'Pay staff' },
        { id = 'ledger', label = 'See transactions' },
    },

    -- Created with every new business. Level decides who can manage whom.
    defaultRanks = {
        { name = 'Owner', level = 100, permissions = {} },
        { name = 'Manager', level = 50, permissions = { 'hire', 'fire', 'promote', 'deposit', 'ledger' } },
        { name = 'Employee', level = 10, permissions = {} },
    },

    ownerLevel = 100,
}
