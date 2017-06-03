modifier_undying_w_sub = class({})

function modifier_undying_w_sub:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_undying_w_sub:IsStunDebuff()
    return true
end

function modifier_undying_w_sub:Airborne()
    return true
end

function modifier_undying_w_sub:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_undying_w_sub:GetActivityTranslationModifiers()
    return "forcestaff_friendly"
end