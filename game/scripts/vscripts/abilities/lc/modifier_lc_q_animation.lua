modifier_lc_q_animation = class({})

function modifier_lc_q_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_lc_q_animation:GetActivityTranslationModifiers()
    return "duel_kill"
end

function modifier_lc_q_animation:IsHidden()
    return true
end