modifier_slark_q = class({})

function modifier_slark_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_slark_q:IsDebuff()
    return true
end

function modifier_slark_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function modifier_slark_q:GetEffectName()
    return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end

function modifier_slark_q:StatusEffectPriority()
    return 2
end

function modifier_slark_q:GetStatusEffectName()
    return "particles/status_fx/status_effect_naga_riptide.vpcf"
end

function modifier_slark_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end