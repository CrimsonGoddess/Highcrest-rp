function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
	AddTextEntry("gstrh7pm1", "Elegy RH7 Pocket Missile")
end)
