Language = {}

function _L(key, ...)
    if key then
        local translation = Language[Config.Language] and Language[Config.Language][key]
        if translation then
            return string.format(translation, ...)
        else
            return "ERR_TRANSLATE_" .. key .. "_404"
        end
    else
        return "ERR_TRANSLATE_404"
    end
end
