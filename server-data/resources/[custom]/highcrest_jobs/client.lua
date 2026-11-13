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
                if ok then notify(onDuty and 'You clocked in.' or 'You clocked out.', 'success')
                elseif type(onDuty) == 'string' then notify(onDuty, 'error') end
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

local KIND_LABEL = { duty = 'Clock in / out', stash = 'Stash', boss = 'Boss menu', bay = 'Work bay', area = 'Work area' }
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

-- Spots are interaction zones, so they sit about 1 m above the ground (body height).
-- The coords tool works at feet height, so convert both ways.
local ZONE_HEIGHT = 1.0

-- Work bays are stored at feet + 0.6 m (what highcrest_mechanic expects); areas at feet height.
local KIND_HEIGHT = { bay = 0.6, area = 0.0 }
local BAY_RADIUS = 4.0 -- highcrest_mechanic's bayRadius, for the preview circle

-- Choose a spot with the /coords tool (raycast, nudging, preview). Falls back to where you stand.
-- kind changes the stored height and the preview; start may carry a heading (w).
local function chooseSpot(title, start, kind, radius)
    local height = KIND_HEIGHT[kind] or ZONE_HEIGHT
    if GetResourceState('highcrest_coords') ~= 'started' then
        local c = GetEntityCoords(cache.ped)
        return { x = c.x, y = c.y, z = c.z - 1.0 + height, w = GetEntityHeading(cache.ped) }
    end
    local spot = exports.highcrest_coords:pick({
        title = title,
        start = start and vec4(start.x, start.y, start.z - height, start.w or GetEntityHeading(cache.ped)) or nil,
        radius = radius or (kind == 'bay' and BAY_RADIUS) or 0.9, -- the zone size players interact with
        preview = kind == 'bay' and 'vehicle' or nil,
        model = kind == 'bay' and 'sultan' or nil, -- shows which way a car faces in the stall
    })
    if not spot then return nil end
    return { x = spot.x, y = spot.y, z = spot.z + height, w = spot.h }
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
    elseif kind == 'area' then
        local input = lib.inputDialog('New work area', {
            { type = 'input', label = 'Name', placeholder = 'Building and parking lot', max = 40 },
            { type = 'number', label = 'Radius (m) from the middle', default = 40, min = 5, max = 300 },
        })
        if not input then return openPlaces(data.name) end
        opts = { label = input[1], radius = input[2] }
    elseif kind == 'bay' then
        opts = { shop = 'vinewood' } -- highcrest_mechanic's only shop for now
    end
    local spot = chooseSpot(('Place %s: %s'):format(KIND_LABEL[kind]:lower(), data.job.label), nil, kind, opts.radius)
    if not spot then return openPlaces(data.name) end
    opts.coords = spot
    local ok, message = lib.callback.await('highcrest_jobs:addPoint', false, data.name, kind, opts)
    notify(message or 'Could not place it.', ok and 'success' or 'error')
    openPlaces(data.name)
end

openPlaces = function(name)
    local data = lib.callback.await('highcrest_jobs:editorJob', false, name)
    if not data then return openEditor() end
    local options = {
        { title = 'Add a clock in / out spot', description = 'Opens the coords tool to place it', icon = 'clock', onSelect = function() addPoint(data, 'duty') end },
        { title = 'Add a stash', description = 'Opens the coords tool to place it', icon = 'box-open', onSelect = function() addPoint(data, 'stash') end },
        { title = 'Add a boss menu', description = 'Opens the coords tool to place it', icon = 'briefcase', onSelect = function() addPoint(data, 'boss') end },
        { title = 'Add a work area', description = 'On duty only inside it; leaving clocks you out after 60 s', icon = 'draw-polygon', onSelect = function() addPoint(data, 'area') end },
    }
    if data.job.type == 'mechanic' then
        table.insert(options, 4, { title = 'Add a work bay', description = 'A stall where cars are worked on (car preview shows the facing)', icon = 'car', onSelect = function() addPoint(data, 'bay') end })
    end
    local here = GetEntityCoords(cache.ped)
    for _, p in ipairs(data.points) do
        local pos = vec3(p.coords.x, p.coords.y, p.coords.z)
        local start = vec4(pos.x, pos.y, pos.z, p.data.heading or GetEntityHeading(cache.ped))
        local extra = p.kind == 'stash' and (p.data.personal and ' · personal lockers' or ' · shared')
            or p.kind == 'area' and (' · %d m radius'):format(p.data.radius or 40) or ''
        options[#options + 1] = {
            title = ('%s%s'):format(KIND_LABEL[p.kind] or p.kind, p.data.label and (': ' .. p.data.label) or ''),
            description = ('%.0f m away%s · /tp %.2f %.2f %.2f'):format(#(here - pos), extra, pos.x, pos.y, pos.z),
            icon = 'location-dot', arrow = true,
            onSelect = function()
                local placeOptions = {
                    { title = 'Move this spot', description = 'Opens the coords tool at the spot', icon = 'up-down-left-right', onSelect = function()
                        local spot = chooseSpot(('Move %s'):format((KIND_LABEL[p.kind] or p.kind):lower()), start, p.kind, p.data.radius)
                        if spot then
                            local ok, message = lib.callback.await('highcrest_jobs:movePoint', false, p.id, spot)
                            notify(message or (ok and 'Spot moved.' or 'Could not move it.'), ok and 'success' or 'error')
                        end
                        openPlaces(name)
                    end },
                    { title = 'Go there', icon = 'person-walking-arrow-right', onSelect = function()
                        SetEntityCoords(cache.ped, pos.x, pos.y, pos.z, false, false, false, false)
                    end },
                    { title = 'Remove this spot', icon = 'trash', onSelect = function()
                        local ok = lib.callback.await('highcrest_jobs:deletePoint', false, p.id)
                        notify(ok and 'Spot removed.' or 'Could not remove it.', ok and 'success' or 'error')
                        openPlaces(name)
                    end },
                }
                if p.kind == 'area' then
                    table.insert(placeOptions, 2, { title = 'Change the radius', description = ('Now %d m'):format(p.data.radius or 40), icon = 'expand', onSelect = function()
                        local input = lib.inputDialog('Work area radius', {
                            { type = 'number', label = 'Radius (m) from the middle', default = p.data.radius or 40, min = 5, max = 300 },
                        })
                        if input then
                            local ok, message = lib.callback.await('highcrest_jobs:setRadius', false, p.id, input[1])
                            notify(message or 'Could not change it.', ok and 'success' or 'error')
                        end
                        openPlaces(name)
                    end })
                end
                lib.registerContext({
                    id = 'hcjobs_place', title = KIND_LABEL[p.kind] or p.kind, menu = 'hcjobs_places',
                    options = placeOptions,
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

---------------------------------------------------------------------------
-- Boss menu: Ranks and pay
---------------------------------------------------------------------------

local function openBossRanks()
    local data = lib.callback.await('highcrest_jobs:bossRanks', false)
    if not data then return notify('Only bosses can change ranks.', 'error') end
    local options = {}
    for _, g in ipairs(data.grades) do
        local mine = g.grade >= data.myLevel
        options[#options + 1] = {
            title = ('%s · $%d'):format(g.name, g.payment or 0),
            description = mine and 'Your rank or above: only admins can change it' or 'Change name and pay',
            icon = g.isboss and 'crown' or 'user', disabled = mine,
            onSelect = function()
                local input = lib.inputDialog(('Rank: %s'):format(g.name), {
                    { type = 'input', label = 'Rank name', default = g.name, required = true, max = 40 },
                    { type = 'number', label = 'Pay per paycheck ($)', default = g.payment, min = 0, max = data.maxPayment, required = true },
                })
                if input then
                    local ok, message = lib.callback.await('highcrest_jobs:bossSetRank', false, g.grade, input[1], input[2])
                    notify(message or 'Could not save.', ok and 'success' or 'error')
                end
                openBossRanks()
            end,
        }
    end
    lib.registerContext({ id = 'hcjobs_boss_ranks', title = ('%s: ranks and pay'):format(data.label), menu = 'openBossMenu', options = options })
    lib.showContext('hcjobs_boss_ranks')
end

AddEventHandler('highcrest_jobs:client:bossRanks', openBossRanks)

CreateThread(function()
    while GetResourceState('qbx_management') ~= 'started' do Wait(500) end
    exports.qbx_management:AddBossMenuItem({
        title = 'Ranks and pay', description = 'Rename ranks and set their pay',
        icon = 'money-bill-wave', event = 'highcrest_jobs:client:bossRanks', args = { type = 'job' },
    })
end)

---------------------------------------------------------------------------
-- F10: my jobs (switch, clock out, quit). Players hold up to qbx:max_jobs_per_player jobs (2).
---------------------------------------------------------------------------

local openMyJobs

local function money(n) return ('$%s'):format(tostring(math.floor(n or 0)):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')) end

local function jobDetails(job)
    local status = job.active and (job.onDuty and 'Active · on duty' or 'Active · off duty') or 'Not active'
    local options = {}
    if not job.active then
        options[#options + 1] = { title = 'Use this job', description = 'Makes it your active job (you start off duty)', icon = 'right-left', onSelect = function()
            local ok, message = lib.callback.await('highcrest_jobs:switchJob', false, job.name)
            notify(ok and ('You are now working as %s.'):format(job.label) or (message or 'Could not switch.'), ok and 'success' or 'error')
            if ok then openMyJobs() end
        end }
    elseif job.onDuty then
        options[#options + 1] = { title = 'Clock out', description = 'Stop working (and stop getting paid)', icon = 'clock', onSelect = function()
            local ok = lib.callback.await('highcrest_jobs:clockOut', false)
            notify(ok and 'You clocked out.' or 'You are not clocked in.', ok and 'success' or 'error')
            openMyJobs()
        end }
    else
        options[#options + 1] = { title = 'Clock in at your workplace', description = job.hasArea and 'Only inside the work area' or 'Use the clock-in spot', icon = 'clock', disabled = true }
    end
    options[#options + 1] = { title = 'Quit this job', description = 'You lose this job and its rank', icon = 'door-open', iconColor = '#e03131', onSelect = function()
        local answer = lib.alertDialog({
            header = ('Quit %s?'):format(job.label),
            content = ('You will lose the job and your rank (%s). Someone would have to hire you again.'):format(job.rank),
            centered = true, cancel = true, labels = { confirm = 'Quit', cancel = 'Keep it' },
        })
        if answer ~= 'confirm' then return openMyJobs() end
        local ok, message = lib.callback.await('highcrest_jobs:quitJob', false, job.name)
        notify(ok and ('You quit %s.'):format(job.label) or (message or 'Could not quit.'), ok and 'success' or 'error')
        openMyJobs()
    end }
    lib.registerContext({ id = 'hcjobs_mine_job', title = ('%s · %s'):format(job.label, job.rank), menu = 'hcjobs_mine',
        options = { { title = status, description = ('Pay %s per paycheck%s'):format(money(job.pay), job.boss and ' · Boss' or ''), icon = 'circle-info', readOnly = true }, table.unpack(options) } })
    lib.showContext('hcjobs_mine_job')
end

openMyJobs = function()
    local data = lib.callback.await('highcrest_jobs:myJobs', false)
    if not data then return end
    local options = {}
    for _, job in ipairs(data.jobs) do
        options[#options + 1] = {
            title = job.label,
            description = ('%s · %s/paycheck%s'):format(job.rank, money(job.pay),
                job.active and (job.onDuty and ' · ACTIVE, on duty' or ' · ACTIVE, off duty') or ''),
            icon = job.active and 'briefcase' or 'suitcase', iconColor = job.active and '#C8102E' or nil,
            arrow = true,
            onSelect = function() jobDetails(job) end,
        }
    end
    if #data.jobs == 0 then
        options[#options + 1] = { title = 'No jobs yet', description = 'Get hired by a business, or apply at City Hall', icon = 'circle-info', readOnly = true }
    elseif data.active ~= 'unemployed' then
        options[#options + 1] = { title = 'Go off work (no active job)', description = 'Keeps your jobs, just stops using them', icon = 'bed', onSelect = function()
            local ok, message = lib.callback.await('highcrest_jobs:switchJob', false, 'unemployed')
            notify(ok and 'You are off work.' or (message or 'Could not switch.'), ok and 'success' or 'error')
            if ok then openMyJobs() end
        end }
    end
    lib.registerContext({ id = 'hcjobs_mine', title = ('My jobs (%d/%d)'):format(#data.jobs, data.max), options = options })
    lib.showContext('hcjobs_mine')
end

lib.addKeybind({
    name = 'myjobs',
    description = 'My jobs (switch, clock out, quit)',
    defaultKey = 'F10',
    onPressed = function()
        if IsPauseMenuActive() or IsNuiFocused() then return end
        openMyJobs()
    end,
})
RegisterCommand('myjobs', function() openMyJobs() end, false)
