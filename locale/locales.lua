Locale = Locale or {}

function _L(key)
    local lang = Config.Locale
    if not Locale[lang] then
        lang = 'en'
    end
    local value = Locale[lang]
    for k in key:gmatch("[^.]+") do
        value = value[k]
        if not value then
            print('Missing locale for: ' .. key)
            return
        end
    end    
    return value
end