modifier_wr_r = class({})

function modifier_wr_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_wr_r:GetActivityTranslationModifiers()
    return "lyreleis_breeze"
end

function modifier_wr_r:IsHidden()
    return true
end