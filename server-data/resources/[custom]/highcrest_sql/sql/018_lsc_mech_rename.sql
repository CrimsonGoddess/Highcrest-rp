-- Highcrest: the mechanic job's id changes from 'mechanic' to 'lsc_mech' (label "LSC Mechanic").
-- qbx_core/shared/jobs.lua keeps a temporary 'mechanic' job for one restart so its start-up
-- cleanup doesn't delete these player_groups rows before this file moves them.

UPDATE `players` SET `job` = JSON_SET(`job`, '$.name', 'lsc_mech', '$.label', 'LSC Mechanic')
  WHERE JSON_VALUE(`job`, '$.name') = 'mechanic';

UPDATE IGNORE `player_groups` SET `group` = 'lsc_mech' WHERE `group` = 'mechanic' AND `type` = 'job';
DELETE FROM `player_groups` WHERE `group` = 'mechanic' AND `type` = 'job';

UPDATE `highcrest_job_points` SET `job` = 'lsc_mech' WHERE `job` = 'mechanic';

UPDATE IGNORE `highcrest_jobs` SET `name` = 'lsc_mech', `data` = JSON_SET(`data`, '$.label', 'LSC Mechanic') WHERE `name` = 'mechanic';

-- Shop bank account (Renewed-Banking). An empty lsc_mech account made at start-up gives way to the old one.
DELETE FROM `bank_accounts_new` WHERE `id` = 'lsc_mech' AND `amount` = 0;
UPDATE IGNORE `bank_accounts_new` SET `id` = 'lsc_mech' WHERE `id` = 'mechanic';

-- The six LSC work bays (were in highcrest_mechanic/config.lua), now movable in /jobs.
-- Heights are feet + 0.6 m, as before.
INSERT INTO `highcrest_job_points` (`job`, `kind`, `x`, `y`, `z`, `data`) VALUES
  ('lsc_mech', 'bay', -333.55, -132.96, 38.94, '{"heading":341.88,"shop":"vinewood"}'),
  ('lsc_mech', 'bay', -312.62, -134.5,  38.94, '{"heading":243.71,"shop":"vinewood"}'),
  ('lsc_mech', 'bay', -317.11, -145.25, 38.61, '{"heading":245.66,"shop":"vinewood"}'),
  ('lsc_mech', 'bay', -320.58, -156.42, 38.61, '{"heading":247.62,"shop":"vinewood"}'),
  ('lsc_mech', 'bay', -339.98, -160.82, 38.61, '{"heading":157.97,"shop":"vinewood"}'),
  ('lsc_mech', 'bay', -347.6,  -157.17, 38.61, '{"heading":158.78,"shop":"vinewood"}');

-- Work area: LSC building + parking lot. On duty only inside it (adjust in /jobs).
INSERT INTO `highcrest_job_points` (`job`, `kind`, `x`, `y`, `z`, `data`) VALUES
  ('lsc_mech', 'area', -335.0, -137.0, 38.6, '{"radius":45,"label":"LSC building and parking lot"}');
