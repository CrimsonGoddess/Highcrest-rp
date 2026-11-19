function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
	AddTextEntry("gstyxl1", "Yosemite XL")
	AddTextEntry("gstyxl1b", "Yosemite XL DRT")
end)
