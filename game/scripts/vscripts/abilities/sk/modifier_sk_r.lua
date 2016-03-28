modifier_sk_r = class({})

function modifier_sk_r:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = true
    }

    return state
end

function modifier_sk_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

function modifier_sk_r:GetModifierMoveSpeedBonus_Percentage(params)
    return 30
end

function modifier_sk_r:GetModifierInvisibilityLevel(params)
    return 100
end