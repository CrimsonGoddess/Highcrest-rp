Config = {}

-- Who can use /jobs (the job editor).
Config.adminAce = 'admin'

-- Job types qbx_core and other scripts understand ('' = none).
Config.jobTypes = {
    { value = '', label = 'None' },
    { value = 'leo', label = 'Police (leo)' },
    { value = 'ems', label = 'Medical (ems)' },
    { value = 'mechanic', label = 'Mechanic' },
}

-- Limits for the editor.
Config.maxGrades = 15
Config.maxPayment = 10000

-- New stashes start with these.
Config.stashDefaults = { slots = 50, weight = 200000 }

-- How close a player must be to use a spot.
Config.useDistance = 2.5
