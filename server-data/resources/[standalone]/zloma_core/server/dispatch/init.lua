-- Public dispatch API. Provider-specific payloads live beside their adapter.

local function getDispatchSystem()
    local dispatch = ZlomaCore.Cache.Dispatch
    if dispatch and GetResourceState(dispatch) == 'started' then return dispatch end

    dispatch = ZlomaCore.DetectDispatch()
    ZlomaCore.Cache.Dispatch = dispatch
    return dispatch
end

local function buildPayload(source, data)
    local dispatch = ZlomaCore.Dispatch
    local coords = dispatch.GetCoords(source, data.coords)
    local jobs = dispatch.NormalizeJobs(data.job)
    local shortRange = data.blip and data.blip.short
    if shortRange == nil then shortRange = true end

    return coords, jobs, {
        title = data.title or 'Dispatch Alert',
        code = data.code or '10-00',
        icon = data.icon or 'fa-solid fa-bell',
        priority = data.priority or 'medium',
        maxOfficers = data.maxOfficers or 4,
        time = data.time or 10,
        notify = data.notify or 5000,
        street = data.street or dispatch.GetStreet(coords),
        description = data.description or ((data.code or '10-00') .. ' - ' .. (data.title or 'Dispatch Alert')),
        psCodeName = data.psCodeName
            or (ZlomaCore.Config.Dispatch and ZlomaCore.Config.Dispatch.PsCodeName)
            or 'customAlert',
        blip = {
            scale = data.blip and data.blip.scale or 1.2,
            sprite = data.blip and data.blip.sprite or 225,
            category = data.blip and data.blip.category or 1,
            color = data.blip and data.blip.color or 1,
            hidden = data.blip and data.blip.hidden or false,
            priority = data.blip and data.blip.priority or 5,
            short = shortRange,
            alpha = data.blip and data.blip.alpha or 200,
            name = data.blip and data.blip.name or (data.title or 'Dispatch Alert'),
        }
    }
end

local function sendDispatchAlert(source, data)
    if type(source) ~= 'number' or source <= 0 then
        print('^1[ZLOMA ERROR]^0 SendDispatchAlert requires a valid player source')
        return false
    end

    local provider = getDispatchSystem()
    if not provider then
        ZlomaCore.Warn('Dispatch', 'SendDispatchAlert')
        return false
    end

    local adapter = ZlomaCore.GetAdapter('server', 'Dispatch', provider)
    if not adapter or type(adapter.send) ~= 'function' then
        print(('^1[ZLOMA CORE ERROR]^0 No dispatch adapter is registered for %s'):format(provider))
        return false
    end

    data = type(data) == 'table' and data or {}
    local coords, jobs, payload = buildPayload(source, data)
    local sent, dispatchError = xpcall(function()
        adapter.send(source, coords, jobs, payload)
    end, debug.traceback)

    if not sent then
        print(('^1[ZLOMA CORE ERROR]^0 Dispatch through %s failed:\n%s'):format(provider, dispatchError))
        return false
    end

    ZlomaCore.Debug(('Dispatch sent via %s: %s'):format(provider, payload.title))
    return true
end

exports('GetDispatchSystem', getDispatchSystem)
exports('SendDispatchAlert', sendDispatchAlert)
