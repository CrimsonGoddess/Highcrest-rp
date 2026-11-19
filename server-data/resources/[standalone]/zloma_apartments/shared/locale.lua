-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

Locales = Locales or {}

local function current()
    return Locales[Config.Locale] or Locales.en or {}
end

function _L(key, ...)
    local text = current()[key] or (Locales.en and Locales.en[key]) or key
    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, text, ...)
        return ok and formatted or text
    end
    return text
end

-- UI strings, English as fallback for keys a translation does not have yet.
function UiLocale()
    local result = {}
    for k, v in pairs((Locales.en and Locales.en.ui) or {}) do result[k] = v end
    for k, v in pairs(current().ui or {}) do result[k] = v end
    return result
end
