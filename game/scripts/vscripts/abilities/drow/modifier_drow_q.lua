modifier_drow_q = class({})

function modifier_drow_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_drow_q:IsDebuff()
    return true
end

function modifier_drow_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -self:GetStackCount() * 10
end

function modifier_drow_q:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_drow_q:StatusEffectPriority()
    return 2
end

function modifier_drow_q:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_drow_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end