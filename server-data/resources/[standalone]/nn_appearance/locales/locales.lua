Locales = Locales or {}

local function activeLanguage()
    local lang = GetConvar("illenium-appearance:locale", "")
    if lang == "" then
        lang = Config and Config.Language or "en"
    end
    return Locales[lang] and lang or "en"
end

local function resolve(tree, key)
    local value = tree
    for k in key:gmatch("[^.]+") do
        if type(value) ~= "table" then return nil end
        value = value[k]
        if value == nil then return nil end
    end
    return value
end

function _L(key)
    local value = resolve(Locales[activeLanguage()], key)
    if value == nil then
        value = resolve(Locales["en"], key)
    end
    if value == nil then
        print("Missing locale for: " .. key)
        return ""
    end
    return value
end

-- English is the reference tree: any key a language file leaves out is filled in
-- from it, so a partial translation never reaches the UI as a raw key.
local function withFallback(base, override)
    local out = {}
    for k, v in pairs(base) do
        local o = override and override[k]
        if type(v) == "table" then
            out[k] = withFallback(v, type(o) == "table" and o or nil)
        elseif o ~= nil and type(o) ~= "table" then
            out[k] = o
        else
            out[k] = v
        end
    end
    return out
end

function GetUILocale()
    local en = (Locales["en"] or {}).UI or {}
    local active = (Locales[activeLanguage()] or {}).UI
    if not active or active == en then return en end
    return withFallback(en, active)
end
