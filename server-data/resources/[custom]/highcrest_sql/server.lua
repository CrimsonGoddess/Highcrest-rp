-- Database setup for bought scripts. Each file in sql/ runs once, in this order, and is then
-- recorded so it never runs again (some files insert starting data). To add a script's SQL,
-- put the file in sql/ and add its name to the end of this list.
local FILES = {
    '001_codem_garbage.sql',
    '002_redutzu_ems.sql',
    '003_redutzu_ems_qbox.sql',
    '004_redutzu_ems_codes.sql',
    '005_redutzu_ems_invoices.sql',
    -- The EMS tables must match the players table's collation, or lookups fail.
    '006_redutzu_ems_collation.sql',
    '007_drc_moneywash.sql',
    '008_drc_moneywash_collation.sql',
    '009_moneywash_levels.sql',
    '010_peuren_gruppe6.sql',
    '011_peuren_chopshop.sql',
    '012_lation_detecting.sql',
    '013_pug_cokebusiness.sql',
    '014_highcrest_mechanic.sql',
    '015_highcrest_mechanic_prices.sql',
    '016_highcrest_jobs.sql',
}

local function statements(sql)
    local list = {}
    sql = sql:gsub('\r', '')
    -- Drop comment lines, then split on semicolons at the end of a line.
    local lines = {}
    for line in (sql .. '\n'):gmatch('(.-)\n') do
        if not line:match('^%s*%-%-') then lines[#lines + 1] = line end
    end
    for statement in (table.concat(lines, '\n') .. '\n'):gmatch('(.-);%s*\n') do
        if statement:match('%S') then list[#list + 1] = statement end
    end
    return list
end

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_sql_applied` (
            `file` VARCHAR(120) NOT NULL,
            `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`file`)
        )
    ]])

    for _, file in ipairs(FILES) do
        if not MySQL.scalar.await('SELECT 1 FROM highcrest_sql_applied WHERE file = ?', { file }) then
            local sql = LoadResourceFile(GetCurrentResourceName(), 'sql/' .. file)
            if not sql then
                print(('^1[highcrest_sql] Missing file sql/%s^0'):format(file))
                return
            end
            local ok, err = pcall(function()
                for _, statement in ipairs(statements(sql)) do
                    MySQL.query.await(statement)
                end
            end)
            if not ok then
                -- Stop here so later files don't run before this one is fixed.
                print(('^1[highcrest_sql] %s failed: %s^0'):format(file, err))
                return
            end
            MySQL.insert.await('INSERT INTO highcrest_sql_applied (file) VALUES (?)', { file })
            print(('[highcrest_sql] Applied %s'):format(file))
        end
    end
end)
