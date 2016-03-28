modifier_sk_q = class({})

function modifier_sk_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_sk_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_sk_q:IsDebuff()
    return true
end

function modifier_sk_q:GetStatusEffectName()
    return "particles/status_fx/status_effect_earth_spirit_boulderslow.vpcf"
end

function modifier_sk_q:StatusEffectPriority()
    return 3
end