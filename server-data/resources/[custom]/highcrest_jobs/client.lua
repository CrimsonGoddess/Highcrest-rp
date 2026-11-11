-- Highcrest jobs: target spots for clocking in, stashes and the boss menu, and the /jobs editor.

local zones = {}

local function notify(text, kind)
    lib.notify({ title = 'Jobs', description = text, type = kind or 'inform' })
end

local function myJob()
    return QBX.PlayerData and QBX.PlayerData.job or {}
end

---------------------------------------------------------------------------
-- Spots in the world
---------------------------------------------------------------------------

local function optionsFor(point)
    local function isMine()
        local job = myJob()
        return job.name == point.job and (job.grade and job.grade.level or 0) >= (point.minGrade or 0)
    end
    if point.kind == 'duty' then
        return { {
            name = ('hcjob_duty_%d'):format(point.id), icon = 'fa-solid fa-clock', distance = Config.useDistance,
            label = 'Clock in / out',
            canInteract = isMine,
            onSelect = function()
                local ok, onDuty = lib.callback.await('highcrest_jobs:toggleDuty', false, point.id)
                if ok then notify(onDuty and 'You clocked in.' or 'You clocked out.', 'success') end
            end,
        } }
    elseif point.kind == 'stash' then
        return { {
            name = ('hcjob_stash_%d'):format(point.id), icon = 'fa-solid fa-box-open', distance = Config.useDistance,
            label = point.label or 'Open stash',
            canInteract = isMine,
            onSelect = function() exports.ox_inventory:openInventory('stash', point.stash) end,
        } }
    elseif point.kind == 'boss' then
        return { {
            name = ('hcjob_boss_%d'):format(point.id), icon = 'fa-solid fa-briefcase', distance = Config.useDistance,
            label = 'Boss menu',
            canInteract = function() local job = myJob() return job.name == point.job and job.isboss == true end,
            onSelect = function() exports.qbx_management:OpenBossMenu('job') end,
        } }
    end
end

local function buildZones(list)
    for _, id in ipairs(zones) do exports.ox_target:removeZone(id) end
    zones = {}
    for _, point in ipairs(list or {}) do
        local options = optionsFor(point)
        if options then
            zones[#zones + 1] = exports.ox_target:addSphereZone({
                coords = point.coords, radius = 0.9, debug = false, options = options,
            })
        end
    end
end

AddStateBagChangeHandler('hcJobPoints', 'global', function(_, _, value)
    buildZones(value)
end)

CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do Wait(250) end
    buildZones(GlobalState.hcJobPoints)
end)

---------------------------------------------------------------------------
-- /jobs editor
---------------------------------------------------------------------------

local KIND_LABEL = { duty = 'Clock in / out', stash = 'Stash', boss = 'Boss menu' }
local openEditor, openJob, openRanks, openPlaces

local function typeOptions()
    local out = {}
    for _, t in ipairs(Config.jobTypes) do out[#out + 1] = { value = t.value, label = t.label } end
    return out
end

local function save(name, job, isNew)
    local ok, message = lib.callback.await('highcrest_jobs:saveJob', false, name, job, isNew)
    notify(message or (ok and 'Saved.' or 'Could not save.'), ok and 'success' or 'error')
    return ok
end

local function nextGrade(job)
    local top = -1
    for _, g in ipairs(job.grades) do if g.grade > top then top = g.grade end end
    return top + 1
end

local function createJob()
    local input = lib.inputDialog('Create a job', {
        { type = 'input', label = 'Job id', description = 'Lowercase, no spaces. Used with /setjob (e.g. burgershot)', required = true, min = 2, max = 30 },
        { type = 'input', label = 'Name players see', description = 'e.g. Burger Shot', required = true, min = 2, max = 40 },
        { type = 'select', label = 'Type', options = typeOptions(), default = '' },
        { type = 'checkbox', label = 'Start on duty when they log in' },
        { type = 'checkbox', label = 'Get paid while clocked out' },
    })
    if not input then return openEditor() end
    local name = input[1]:lower():gsub('%s+', '')
    local job = {
        label = input[2], type = input[3] or '', defaultDuty = input[4] == true, offDutyPay = input[5] == true,
        grades = {
            { grade = 0, name = 'Employee', payment = 100 },
            { grade = 1, name = 'Boss', payment = 250, isboss = true, bankAuth = true },
        },
    }
    if save(name, job, true) then openJob(name) else openEditor() end
end

local function editDetails(data)
    local job = data.job
    local input = lib.inputDialog(('Edit %s'):format(job.label), {
        { type = 'input', label = 'Name players see', default = job.label, required = true, min = 2, max = 40 },
        { type = 'select', label = 'Type', options = typeOptions(), default = job.type or '' },
        { type = 'checkbox', label = 'Start on duty when they log in', checked = job.defaultDuty == true },
        { type = 'checkbox', label = 'Get paid while clocked out', checked = job.offDutyPay == true },
    })
    if input then
        job.label, job.type, job.defaultDuty, job.offDutyPay = input[1], input[2] or '', input[3] == true, input[4] == true
        save(data.name, job, false)
    end
    openJob(data.name)
end

local function editRank(data, index)
    local job = data.job
    local isNew = index == nil
    local rank = isNew and { grade = nextGrade(job), name = '', payment = 100 } or job.grades[index]
    local input = lib.inputDialog(isNew and 'Add a rank' or ('Rank %d: %s'):format(rank.grade, rank.name), {
        { type = 'input', label = 'Rank name', default = rank.name, required = true, max = 40 },
        { type = 'number', label = 'Pay per paycheck ($)', default = rank.payment, min = 0, max = Config.maxPayment, required = true },
        { type = 'checkbox', label = 'Boss (can hire, fire and use the boss menu)', checked = rank.isboss == true },
        { type = 'checkbox', label = 'Can use the business bank account (bosses only)', checked = rank.bankAuth == true },
    })
    if input then
        local updated = { grade = rank.grade, name = input[1], payment = input[2], isboss = input[3] == true, bankAuth = input[4] == true }
        if isNew then job.grades[#job.grades + 1] = updated else job.grades[index] = updated end
        save(data.name, job, false)
    end
    openRanks(data.name)
end

local function removeRank(data, index)
    local job = data.job
    local rank = job.grades[index]
    if rank.grade == 0 then
        notify('Rank 0 is the starting rank and cannot be removed.', 'error')
        return openRanks(data.name)
    end
    local answer = lib.alertDialog({
        header = ('Remove %s?'):format(rank.name),
        content = 'Anyone with this rank should be given a new one with /setjob.',
        centered = true, cancel = true,
    })
    if answer == 'confirm' then
        table.remove(job.grades, index)
        save(data.name, job, false)
    end
    openRanks(data.name)
end

openRanks = function(name)
    local data = lib.callback.await('highcrest_jobs:editorJob', false, name)
    if not data then return openEditor() end
    local options = {
        { title = 'Add a rank', icon = 'plus', onSelect = function() editRank(data, nil) end },
    }
    for index, g in ipairs(data.job.grades) do
        local tags = { ('$%d'):format(g.payment or 0) }
        if g.isboss then tags[#tags + 1] = 'Boss' end
        if g.bankAuth then tags[#tags + 1] = 'Bank' end
        options[#options + 1] = {
            title = ('%d · %s'):format(g.grade, g.name), description = table.concat(tags, ' · '),
            icon = g.isboss and 'crown' or 'user', arrow = true,
            onSelect = function()
                lib.registerContext({
                    id = 'hcjobs_rank', title = ('%d · %s'):format(g.grade, g.name), menu = 'hcjobs_ranks',
                    options = {
                        { title = 'Edit name and pay', icon = 'pen', onSelect = function() editRank(data, index) end },
                        { title = 'Remove rank', icon = 'trash', disabled = g.grade == 0, onSelect = function() removeRank(data, index) end },
                    },
                })
                lib.showContext('hcjobs_rank')
            end,
        }
    end
    lib.registerContext({ id = 'hcjobs_ranks', title = ('%s ranks'):format(data.job.label), menu = 'hcjobs_job', options = options })
    lib.showContext('hcjobs_ranks')
end

local function addPoint(data, kind)
    local opts = {}
    if kind == 'stash' then
        local input = lib.inputDialog('New stash', {
            { type = 'input', label = 'Stash name', placeholder = ('%s Stash'):format(data.job.label), max = 40 },
            { type = 'number', label = 'Slots', default = Config.stashDefaults.slots, min = 5, max = 200 },
            { type = 'number', label = 'Max weight (kg)', default = Config.stashDefaults.weight / 1000, min = 10, max = 2000 },
            { type = 'number', label = 'Lowest rank that can open it', default = 0, min = 0, max = Config.maxGrades - 1 },
            { type = 'checkbox', label = 'Personal lockers (each employee gets their own)' },
        })
        if not input then return openPlaces(data.name) end
        opts = { label = input[1], slots = input[2], weight = (input[3] or 200) * 1000, minGrade = input[4], personal = input[5] == true }
    elseif kind == 'duty' then
        local input = lib.inputDialog('New clock-in spot', {
            { type = 'number', label = 'Lowest rank that can use it', default = 0, min = 0, max = Config.maxGrades - 1 },
        })
        if not input then return openPlaces(data.name) end
        opts = { minGrade = input[1] }
    end
    local ok, message = lib.callback.await('highcrest_jobs:addPoint', false, data.name, kind, opts)
    notify(message or 'Could not place it.', ok and 'success' or 'error')
    openPlaces(data.name)
end

openPlaces = function(name)
    local data = lib.callback.await('highcrest_jobs:editorJob', false, name)
    if not data then return openEditor() end
    local options = {
        { title = 'Put a clock in / out spot here', icon = 'clock', onSelect = function() addPoint(data, 'duty') end },
        { title = 'Put a stash here', icon = 'box-open', onSelect = function() addPoint(data, 'stash') end },
        { title = 'Put a boss menu here', icon = 'briefcase', onSelect = function() addPoint(data, 'boss') end },
    }
    local here = GetEntityCoords(cache.ped)
    for _, p in ipairs(data.points) do
        local pos = vec3(p.coords.x, p.coords.y, p.coords.z)
        local extra = p.kind == 'stash' and (p.data.personal and ' · personal lockers' or ' · shared') or ''
        options[#options + 1] = {
            title = ('%s%s'):format(KIND_LABEL[p.kind] or p.kind, p.data.label and (': ' .. p.data.label) or ''),
            description = ('%.0f m away%s · /tp %.2f %.2f %.2f'):format(#(here - pos), extra, pos.x, pos.y, pos.z),
            icon = 'location-dot', arrow = true,
            onSelect = function()
                lib.registerContext({
                    id = 'hcjobs_place', title = KIND_LABEL[p.kind] or p.kind, menu = 'hcjobs_places',
                    options = {
                        { title = 'Go there', icon = 'person-walking-arrow-right', onSelect = function()
                            SetEntityCoords(cache.ped, pos.x, pos.y, pos.z, false, false, false, false)
                        end },
                        { title = 'Remove this spot', icon = 'trash', onSelect = function()
                            local ok = lib.callback.await('highcrest_jobs:deletePoint', false, p.id)
                            notify(ok and 'Spot removed.' or 'Could not remove it.', ok and 'success' or 'error')
                            openPlaces(name)
                        end },
                    },
                })
                lib.showContext('hcjobs_place')
            end,
        }
    end
    lib.registerContext({ id = 'hcjobs_places', title = ('%s spots'):format(data.job.label), menu = 'hcjobs_job', options = options })
    lib.showContext('hcjobs_places')
end

openJob = function(name)
    local data = lib.callback.await('highcrest_jobs:editorJob', false, name)
    if not data then return openEditor() end
    local job = data.job
    local typeLabel = 'None'
    for _, t in ipairs(Config.jobTypes) do if t.value == (job.type or '') then typeLabel = t.label end end
    local options = {
        {
            title = 'Details', icon = 'pen', arrow = true,
            description = ('Id: %s · Type: %s · %s · %s'):format(name, typeLabel,
                job.defaultDuty and 'starts on duty' or 'starts off duty', job.offDutyPay and 'paid off duty' or 'unpaid off duty'),
            onSelect = function() editDetails(data) end,
        },
        { title = ('Ranks and pay (%d)'):format(#job.grades), icon = 'users', arrow = true, onSelect = function() openRanks(name) end },
        { title = ('Clock in, stash and boss spots (%d)'):format(#data.points), icon = 'location-dot', arrow = true, onSelect = function() openPlaces(name) end },
    }
    if data.saved == 'created' then
        options[#options + 1] = { title = 'Delete this job', icon = 'trash', onSelect = function()
            local answer = lib.alertDialog({ header = ('Delete %s?'):format(job.label), content = 'This removes the job and all its spots.', centered = true, cancel = true })
            if answer ~= 'confirm' then return openJob(name) end
            local ok, message = lib.callback.await('highcrest_jobs:deleteJob', false, name)
            notify(message, ok and 'success' or 'error')
            openEditor()
        end }
    elseif data.saved == 'edited' then
        options[#options + 1] = { title = 'Undo my in-game edits', description = 'Goes back to the original after a restart', icon = 'rotate-left', onSelect = function()
            local ok, message = lib.callback.await('highcrest_jobs:deleteJob', false, name)
            notify(message, ok and 'success' or 'error')
            openJob(name)
        end }
    end
    lib.registerContext({ id = 'hcjobs_job', title = job.label, menu = 'hcjobs_list', options = options })
    lib.showContext('hcjobs_job')
end

openEditor = function()
    local list = lib.callback.await('highcrest_jobs:editorJobs', false)
    if not list then return notify('Admins only.', 'error') end
    local options = { { title = 'Create a new job', icon = 'plus', onSelect = createJob } }
    for _, job in ipairs(list) do
        local bits = { job.name, ('%d ranks'):format(job.grades), ('%d spots'):format(job.points) }
        if job.saved == 'created' then bits[#bits + 1] = 'made in-game' elseif job.saved == 'edited' then bits[#bits + 1] = 'edited' end
        options[#options + 1] = {
            title = job.label, description = table.concat(bits, ' · '), icon = 'briefcase', arrow = true,
            onSelect = function() openJob(job.name) end,
        }
    end
    lib.registerContext({ id = 'hcjobs_list', title = 'Jobs', options = options })
    lib.showContext('hcjobs_list')
end

RegisterNetEvent('highcrest_jobs:client:openEditor', function() openEditor() end)
