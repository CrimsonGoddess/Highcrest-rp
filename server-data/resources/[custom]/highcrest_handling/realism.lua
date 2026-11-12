-- Highcrest realism: every car's handling is scaled when someone drives it, by vehicle class.
-- 1.0 = unchanged, 0.8 = 20% less. Cars tuned in the Discord #handling channel are skipped.
-- Set Realism.enabled = false to turn it all off.

Realism = {}
Realism.enabled = true

-- Applied to every car class listed in Realism.classes.
Realism.base = {
    fBrakeForce = 0.80,               -- longer stopping distances
    fHandBrakeForce = 0.85,
    fTractionCurveMax = 0.90,          -- less cornering grip
    fTractionCurveMin = 0.90,          -- less grip when accelerating and braking hard
    fInitialDriveForce = 0.92,         -- a bit less punch off the line
    fAntiRollBarForce = 0.80,          -- more body roll
    fSteeringLock = 0.92,              -- slightly less steering angle
    fCollisionDamageMult = 1.30,       -- crashes hurt
    fDeformationDamageMult = 1.20,
    fEngineDamageMult = 1.25,
}

-- Extra multipliers on top of the base, by GTA vehicle class. Classes not listed are untouched.
--  0 Compacts  1 Sedans  2 SUVs  3 Coupes  4 Muscle  5 Sports Classics  6 Sports  7 Super
--  9 Off-road  10 Industrial  11 Utility  12 Vans  17 Service  18 Emergency  19 Military  20 Commercial
--  (8 Motorcycles, 13 Cycles, 14 Boats, 15 Helicopters, 16 Planes, 21 Trains are left alone)
Realism.classes = {
    [0] = {},
    [1] = {},
    [2] = { fAntiRollBarForce = 0.85, fBrakeForce = 0.92, fTractionCurveMax = 0.97 },
    [3] = {},
    [4] = { fTractionCurveMin = 0.88, fLowSpeedTractionLossMult = 1.25, fBrakeForce = 0.92 },
    [5] = { fTractionCurveMax = 0.95, fBrakeForce = 0.92 },
    [6] = { fTractionCurveMax = 1.04 },
    [7] = { fTractionCurveMax = 1.05, fInitialDriveForce = 1.02 },
    [9] = { fTractionLossMult = 0.70, fAntiRollBarForce = 0.90 },
    [10] = { fBrakeForce = 0.90 },
    [11] = { fBrakeForce = 0.92 },
    [12] = { fAntiRollBarForce = 0.85, fBrakeForce = 0.92 },
    [17] = { fBrakeForce = 0.92 },
    [18] = { fBrakeForce = 1.10, fTractionCurveMax = 1.05, fInitialDriveForce = 1.05 }, -- police and EMS still catch people
    [19] = {},
    [20] = { fBrakeForce = 0.90, fAntiRollBarForce = 0.85 },
}
