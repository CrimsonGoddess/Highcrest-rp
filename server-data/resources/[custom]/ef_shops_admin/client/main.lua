-- ef_shops_admin client: opens the shop panel with /shopadmin. The server decides who may open it.

local open = false

local function close()
	if not open then return end
	open = false
	SetNuiFocus(false, false)
	LocalPlayer.state:set('hcBlockPause', false, false)
end

RegisterCommand('shopadmin', function()
	if open then return close() end

	if not lib.callback.await('ef_shops_admin:canOpen', false) then
		lib.notify({ description = 'You do not have permission to manage shops.', type = 'error' })
		return
	end

	open = true
	SetNuiFocus(true, true)
	LocalPlayer.state:set('hcBlockPause', true, false) -- highcrest_pause leaves Esc to this panel
	SendNUIMessage({ action = 'open' })
end, false)

-- The panel sends { action, data }. The server checks permission and runs the action.
RegisterNUICallback('request', function(body, cb)
	local res = lib.callback.await('ef_shops_admin:call', false, body.action, body.data)
	cb(res or { ok = false, error = 'No response from the server.' })
end)

RegisterNUICallback('close', function(_, cb)
	cb(1)
	close()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		SetNuiFocus(false, false)
	end
end)
