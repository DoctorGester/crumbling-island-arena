modifier_wk_r_animation = class({})

function modifier_wk_r_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_wk_r_animation:GetActivityTranslationModifiers()
    return "wraith_spin"
end

function modifier_wk_r_animation:IsHidden()
    return true
end
