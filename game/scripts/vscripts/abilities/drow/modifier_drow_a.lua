modifier_drow_a = class({})

function modifier_drow_a:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_drow_a:IsDebuff()
    return true
end

function modifier_drow_a:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_drow_a:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_drow_a:StatusEffectPriority()
    return 2
end

function modifier_drow_a:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_drow_a:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end