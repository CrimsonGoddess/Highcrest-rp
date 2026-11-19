-- Server-only integration policy. External resources are opt-in; never expose this through a net event.
ZlomaVehiclePolicy = {
    BindingCallers = {}, -- e.g. ['your_admin_resource'] = true
}
