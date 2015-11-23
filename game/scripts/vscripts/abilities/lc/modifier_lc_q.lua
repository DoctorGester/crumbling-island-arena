modifier_lc_q = class({})

function modifier_lc_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_lc_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_lc_q:GetStatusEffectName()
    return "particles/units/heroes/hero_bounty_hunter/status_effect_bounty_hunter_jinda_slow.vpcf"
end

function modifier_lc_q:GetEffectName()
    return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf"
end

function modifier_lc_q:StatusEffectPriority()
    return 1
end

function modifier_lc_q:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end