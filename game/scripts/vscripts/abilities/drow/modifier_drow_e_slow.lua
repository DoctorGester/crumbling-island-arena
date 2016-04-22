modifier_drow_e_slow = class({})

function modifier_drow_e_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_drow_e_slow:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function modifier_drow_e_slow:IsDebuff()
    return true
end

function modifier_drow_e_slow:GetStatusEffectName()
    return "particles/units/heroes/hero_visage/status_effect_visage_chill_slow.vpcf"
end

function modifier_drow_e_slow:GetEffectName()
    return "particles/drow_e/drow_e_slow.vpcf"
end

function modifier_drow_e_slow:StatusEffectPriority()
    return 1
end

function modifier_drow_e_slow:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end