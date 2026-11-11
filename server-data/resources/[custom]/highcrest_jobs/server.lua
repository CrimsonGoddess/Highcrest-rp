-- Highcrest jobs. Jobs made or changed with /jobs are kept in the database and loaded into
-- qbx_core on start (the shared/jobs.lua file is never rewritten). Spots for clocking in,
-- stashes and the boss menu are placed in-game and sent to everyone through GlobalState.

local points = {}   -- id -> point
local loaded = false

local KINDS = { duty = true, stash = true, boss = true }

local function isAdmin(source)
    return IsPlayerAceAllowed(source, Config.adminAce)
end

local function getPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

local function staffName(source)
    return GetPlayerName(source) or ('id %s'):format(source)
end

-- Wait for highcrest_sql to create our tables on a first boot.
local function query(sql, params)
    for _ = 1, 20 do
        local ok, result = pcall(MySQL.query.await, sql, params)
        if ok then return result end
        Wait(1500)
    end
    error(('highcrest_jobs: query failed: %s'):format(sql))
end

---------------------------------------------------------------------------
-- Jobs
---------------------------------------------------------------------------

-- Grades are stored as a list ({ grade = 0, name = ... }) because JSON can't key a table by 0.
local function toStored(job)
    local grades = {}
    for grade, data in pairs(job.grades or {}) do
        grades[#grades + 1] = {
            grade = tonumber(grade), name = data.name, payment = data.payment,
            isboss = data.isboss or nil, bankAuth = data.bankAuth or nil,
        }
    end
    table.sort(grades, function(a, b) return a.grade < b.grade end)
    return {
        label = job.label, type = job.type, defaultDuty = job.defaultDuty,
        offDutyPay = job.offDutyPay, grades = grades,
    }
end

local function fromStored(data)
    local grades = {}
    for _, g in ipairs(data.grades or {}) do
        grades[g.grade] = { name = g.name, payment = g.payment, isboss = g.isboss or nil, bankAuth = g.bankAuth or nil }
    end
    return {
        label = data.label, type = data.type ~= '' and data.type or nil,
        defaultDuty = data.defaultDuty == true, offDutyPay = data.offDutyPay == true, grades = grades,
    }
end

-- Check a job sent from the editor. Returns the stored form or nil, error.
local function cleanJob(input)
    if type(input) ~= 'table' then return nil, 'Bad job data.' end
    local label = type(input.label) == 'string' and input.label:gsub('^%s+', ''):gsub('%s+$', '') or ''
    if #label < 2 or #label > 40 then return nil, 'The job name must be 2 to 40 characters.' end
    local jobType = ''
    for _, t in ipairs(Config.jobTypes) do if t.value == input.type then jobType = t.value end end

    local grades, seen = {}, {}
    for _, g in ipairs(type(input.grades) == 'table' and input.grades or {}) do
        local grade = tonumber(g.grade)
        local name = type(g.name) == 'string' and g.name:gsub('^%s+', ''):gsub('%s+$', '') or ''
        local pay = tonumber(g.payment)
        if not grade or grade ~= math.floor(grade) or grade < 0 or grade >= Config.maxGrades then
            return nil, ('Rank numbers go from 0 to %d.'):format(Config.maxGrades - 1)
        end
        if seen[grade] then return nil, ('Rank %d is listed twice.'):format(grade) end
        if #name < 1 or #name > 40 then return nil, ('Rank %d needs a name.'):format(grade) end
        if not pay or pay < 0 or pay > Config.maxPayment then
            return nil, ('Pay for %s must be between $0 and $%d.'):format(name, Config.maxPayment)
        end
        seen[grade] = true
        grades[#grades + 1] = {
            grade = math.floor(grade), name = name, payment = math.floor(pay),
            isboss = g.isboss == true or nil, bankAuth = (g.isboss == true and g.bankAuth == true) or nil,
        }
    end
    if #grades == 0 then return nil, 'A job needs at least one rank.' end
    if not seen[0] then return nil, 'A job needs a rank 0 (the starting rank).' end
    table.sort(grades, function(a, b) return a.grade < b.grade end)
    return {
        label = label, type = jobType, defaultDuty = input.defaultDuty == true,
        offDutyPay = input.offDutyPay == true, grades = grades,
    }
end

local function applyJob(name, stored)
    local ok, err = exports.qbx_core:CreateJob(name, fromStored(stored), false)
    if not ok then lib.print.error(('highcrest_jobs: could not load job %s: %s'):format(name, err)) end
    return ok
end

---------------------------------------------------------------------------
-- Points
---------------------------------------------------------------------------

local function stashId(point) return ('hcjob_%d'):format(point.id) end

local function registerStash(point)
    local job = exports.qbx_core:GetJob(point.job)
    local data = point.data
    exports.ox_inventory:RegisterStash(stashId(point),
        data.label or ((job and job.label or point.job) .. ' Stash'),
        data.slots or Config.stashDefaults.slots, data.weight or Config.stashDefaults.weight,
        data.personal == true or nil, { [point.job] = data.minGrade or 0 }, point.coords)
end

local function publishPoints()
    local list = {}
    for _, p in pairs(points) do
        list[#list + 1] = {
            id = p.id, job = p.job, kind = p.kind, coords = p.coords,
            minGrade = p.data.minGrade or 0, label = p.data.label, stash = p.kind == 'stash' and stashId(p) or nil,
        }
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    GlobalState.hcJobPoints = list
end

local function addPointRow(row)
    local point = {
        id = row.id, job = row.job, kind = row.kind,
        coords = vec3(row.x, row.y, row.z), data = json.decode(row.data or '') or {},
    }
    points[point.id] = point
    if point.kind == 'stash' then registerStash(point) end
    return point
end

---------------------------------------------------------------------------
-- Start up
---------------------------------------------------------------------------

CreateThread(function()
    while GetResourceState('qbx_core') ~= 'started' do Wait(250) end
    for _, row in ipairs(query('SELECT name, data FROM highcrest_jobs') or {}) do
        local data = json.decode(row.data or '')
        if data then applyJob(row.name, data) end
    end
    for _, row in ipairs(query('SELECT * FROM highcrest_job_points') or {}) do
        if KINDS[row.kind] then addPointRow(row) end
    end
    publishPoints()
    loaded = true
end)

---------------------------------------------------------------------------
-- Player actions
---------------------------------------------------------------------------

local function nearPoint(source, id, kind)
    local point = points[tonumber(id) or 0]
    if not point or point.kind ~= kind then return nil end
    if #(GetEntityCoords(GetPlayerPed(source)) - point.coords) > Config.useDistance + 2.0 then return nil end
    local player = getPlayer(source)
    local job = player and player.PlayerData.job
    if not job or job.name ~= point.job then return nil end
    return point, player
end

lib.callback.register('highcrest_jobs:toggleDuty', function(source, id)
    local point, player = nearPoint(source, id, 'duty')
    if not point then return false end
    local onDuty = not player.PlayerData.job.onduty
    exports.qbx_core:SetJobDuty(source, onDuty)
    return true, onDuty
end)

---------------------------------------------------------------------------
-- Editor (admins)
---------------------------------------------------------------------------

lib.callback.register('highcrest_jobs:editorJobs', function(source)
    if not isAdmin(source) then return false end
    local saved = {}
    for _, row in ipairs(MySQL.query.await('SELECT name, created_in_game FROM highcrest_jobs') or {}) do
        saved[row.name] = row.created_in_game == 1 and 'created' or 'edited'
    end
    local counts = {}
    for _, p in pairs(points) do counts[p.job] = (counts[p.job] or 0) + 1 end
    local list = {}
    for name, job in pairs(exports.qbx_core:GetJobs()) do
        local grades = 0
        for _ in pairs(job.grades or {}) do grades = grades + 1 end
        list[#list + 1] = { name = name, label = job.label or name, grades = grades, saved = saved[name], points = counts[name] or 0 }
    end
    table.sort(list, function(a, b) return a.label:lower() < b.label:lower() end)
    return list
end)

lib.callback.register('highcrest_jobs:editorJob', function(source, name)
    if not isAdmin(source) then return false end
    local job = exports.qbx_core:GetJob(name)
    if not job then return false end
    local row = MySQL.single.await('SELECT created_in_game FROM highcrest_jobs WHERE name = ?', { name })
    local list = {}
    for _, p in pairs(points) do
        if p.job == name then
            list[#list + 1] = { id = p.id, kind = p.kind, coords = p.coords, data = p.data }
        end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    local stored = toStored(job)
    stored.type = stored.type or ''
    return { name = name, job = stored, saved = row and (row.created_in_game == 1 and 'created' or 'edited') or nil, points = list }
end)

lib.callback.register('highcrest_jobs:saveJob', function(source, name, input, isNew)
    if not isAdmin(source) then return false, 'Admins only.' end
    if type(name) ~= 'string' or not name:match('^[a-z][a-z0-9_]+$') or #name > 30 then
        return false, 'The job id must be lowercase letters, numbers or _ (for example: burgershot).'
    end
    if isNew and exports.qbx_core:GetJob(name) then return false, ('A job called "%s" already exists.'):format(name) end
    if not isNew and not exports.qbx_core:GetJob(name) then return false, 'That job no longer exists.' end
    local stored, err = cleanJob(input)
    if not stored then return false, err end

    local existing = MySQL.single.await('SELECT created_in_game FROM highcrest_jobs WHERE name = ?', { name })
    local createdInGame = isNew and 1 or (existing and existing.created_in_game or 0)
    MySQL.query.await([[
        INSERT INTO highcrest_jobs (name, data, created_in_game, updated_by) VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE data = VALUES(data), updated_by = VALUES(updated_by)
    ]], { name, json.encode(stored), createdInGame, staffName(source) })
    if not applyJob(name, stored) then return false, 'qbx_core refused the job. Check the server console.' end
    lib.print.info(('%s saved job %s'):format(staffName(source), name))
    return true, isNew and ('Created %s. Use /setjob to hire someone.'):format(stored.label) or ('Saved %s.'):format(stored.label)
end)

-- Delete a job made in-game, or drop the in-game edits to a job from jobs.lua.
lib.callback.register('highcrest_jobs:deleteJob', function(source, name)
    if not isAdmin(source) then return false, 'Admins only.' end
    local row = MySQL.single.await('SELECT created_in_game FROM highcrest_jobs WHERE name = ?', { name })
    if not row then return false, 'This job has no in-game changes.' end
    MySQL.query.await('DELETE FROM highcrest_jobs WHERE name = ?', { name })
    if row.created_in_game == 1 then
        for id, p in pairs(points) do if p.job == name then points[id] = nil end end
        MySQL.query.await('DELETE FROM highcrest_job_points WHERE job = ?', { name })
        publishPoints()
        exports.qbx_core:RemoveJob(name, false)
        return true, 'Job deleted. Anyone who had it is unemployed next time they log in.'
    end
    return true, 'In-game edits removed. The original version comes back after the next server restart.'
end)

lib.callback.register('highcrest_jobs:addPoint', function(source, name, kind, opts)
    if not isAdmin(source) then return false, 'Admins only.' end
    if not KINDS[kind] or not exports.qbx_core:GetJob(name) then return false, 'Bad spot.' end
    opts = type(opts) == 'table' and opts or {}
    local data = {}
    if kind == 'stash' then
        data.label = type(opts.label) == 'string' and opts.label:sub(1, 40) or nil
        if data.label == '' then data.label = nil end
        data.slots = math.max(5, math.min(200, math.floor(tonumber(opts.slots) or Config.stashDefaults.slots)))
        data.weight = math.max(10000, math.min(2000000, math.floor(tonumber(opts.weight) or Config.stashDefaults.weight)))
        data.personal = opts.personal == true
    end
    data.minGrade = math.max(0, math.min(Config.maxGrades - 1, math.floor(tonumber(opts.minGrade) or 0)))

    local c = GetEntityCoords(GetPlayerPed(source))
    local id = MySQL.insert.await('INSERT INTO highcrest_job_points (job, kind, x, y, z, data) VALUES (?, ?, ?, ?, ?, ?)',
        { name, kind, c.x, c.y, c.z, json.encode(data) })
    addPointRow({ id = id, job = name, kind = kind, x = c.x, y = c.y, z = c.z, data = json.encode(data) })
    publishPoints()
    return true, 'Spot placed where you are standing.'
end)

lib.callback.register('highcrest_jobs:deletePoint', function(source, id)
    if not isAdmin(source) then return false end
    id = tonumber(id) or 0
    if not points[id] then return false end
    points[id] = nil
    MySQL.query.await('DELETE FROM highcrest_job_points WHERE id = ?', { id })
    publishPoints()
    return true
end)

---------------------------------------------------------------------------
-- Boss menu: Ranks and pay. A boss can rename and set the pay of ranks below their own
-- (up to Config.maxPayment). Boss powers stay with admins (/jobs).
---------------------------------------------------------------------------

local function bossJob(source)
    local player = getPlayer(source)
    local job = player and player.PlayerData.job
    if not job or not job.isboss or not exports.qbx_core:GetJob(job.name) then return nil end
    return job, player
end

lib.callback.register('highcrest_jobs:bossRanks', function(source)
    local job = bossJob(source)
    if not job then return false end
    local stored = toStored(exports.qbx_core:GetJob(job.name))
    return { label = stored.label, grades = stored.grades, myLevel = job.grade.level, maxPayment = Config.maxPayment }
end)

lib.callback.register('highcrest_jobs:bossSetRank', function(source, grade, name, payment)
    local job = bossJob(source)
    if not job then return false, 'Only bosses can change ranks.' end
    grade = tonumber(grade)
    if not grade or grade >= job.grade.level then return false, 'You can only change ranks below your own.' end
    local stored = toStored(exports.qbx_core:GetJob(job.name))
    local found
    for _, g in ipairs(stored.grades) do
        if g.grade == grade then
            g.name = type(name) == 'string' and name or g.name
            g.payment = tonumber(payment)
            found = true
        end
    end
    if not found then return false, 'That rank no longer exists.' end
    stored.type = stored.type or ''
    local clean, err = cleanJob(stored)
    if not clean then return false, err end
    MySQL.query.await([[
        INSERT INTO highcrest_jobs (name, data, updated_by) VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE data = VALUES(data), updated_by = VALUES(updated_by)
    ]], { job.name, json.encode(clean), staffName(source) })
    if not applyJob(job.name, clean) then return false, 'Could not save the rank.' end
    return true, 'Rank saved. The new pay starts from the next paycheck.'
end)

-- Bosses can rename ranks and change pay in the boss menu (qbx_management). qbx_core only keeps
-- that in memory, so save every job change here and it survives a restart.
AddEventHandler('qbx_core:server:onJobUpdate', function(name, job)
    if not loaded or type(name) ~= 'string' or type(job) ~= 'table' or not job.grades then return end
    local ok, stored = pcall(toStored, job)
    if not ok then return end
    MySQL.query('INSERT INTO highcrest_jobs (name, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = VALUES(data)',
        { name, json.encode(stored) })
end)

lib.addCommand('jobs', { help = 'Job editor: create jobs, ranks and pay, and place clock-in, stash and boss spots', restricted = 'group.admin' },
    function(source)
        if not loaded then return TriggerClientEvent('ox_lib:notify', source, { description = 'Jobs are still loading.', type = 'error' }) end
        TriggerClientEvent('highcrest_jobs:client:openEditor', source)
    end)
