-- Compatibility-preserving provider detection backed by ProviderCatalog.
local function detect(feature)
    local manual = ZlomaCore.Config.Manual[feature]
    if feature == 'Dispatch' and manual == 'none' then return nil end
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(('Using manual %s: %s'):format(feature:lower(), manual))
        return manual
    end

    for _, provider in ipairs(ZlomaCore.ProviderCatalog[feature] or {}) do
        for _, resourceName in ipairs(provider.resources or { provider.id }) do
            if GetResourceState(resourceName) == 'started' then return provider.id end
        end
    end
    return nil
end

ZlomaCore.Detect = detect
function ZlomaCore.DetectFramework() return detect('Framework') end
function ZlomaCore.DetectInventory() return detect('Inventory') end
function ZlomaCore.DetectBilling() return detect('Billing') end
function ZlomaCore.DetectNotification() return detect('Notification') end
function ZlomaCore.DetectAppearance() return detect('Appearance') end
function ZlomaCore.DetectKeys() return detect('Keys') end
function ZlomaCore.DetectDispatch() return detect('Dispatch') end
function ZlomaCore.DetectTarget() return detect('Target') end
function ZlomaCore.DetectFuel() return detect('Fuel') end

-- Society funds must follow the framework's native source of truth when the
-- administrator has left the provider in auto mode. In particular, ESX
-- servers often run zloma_banking for its UI and billing, while their existing
-- job funds live in esx_addonaccount's society_<job> accounts. Selecting
-- zloma_banking first in that situation would create a second ledger.
function ZlomaCore.DetectSociety()
    local manual = ZlomaCore.Config.Manual.Society
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(('Using manual society: %s'):format(manual))
        return manual
    end

    local framework = ZlomaCore.Cache.Framework or ZlomaCore.DetectFramework()
    if framework == 'ESX' then
        if GetResourceState('esx_addonaccount') == 'started' then
            return 'esx_addonaccount'
        end

        -- Never fall back to another ledger on ESX. Returning nil preserves
        -- the normal "No society system detected" behaviour until the native
        -- addon-account resource is started.
        return nil
    end

    return detect('Society')
end
