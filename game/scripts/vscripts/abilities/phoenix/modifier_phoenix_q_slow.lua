modifier_phoenix_q_slow = class({})

function modifier_phoenix_q_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_phoenix_q_slow:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_phoenix_q_slow:IsDebuff()
    return true
end

function modifier_phoenix_q_slow:GetStatusEffectName()
    return "particles/status_fx/status_effect_phoenix_burning.vpcf"
end

function modifier_phoenix_q_slow:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf"
end

function modifier_phoenix_q_slow:StatusEffectPriority()
    return 1
end

function modifier_phoenix_q_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end