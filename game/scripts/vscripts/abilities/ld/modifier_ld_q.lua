modifier_ld_q = class({})


function modifier_ld_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_ld_q:IsDebuff()
    return true
end

function modifier_ld_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_ld_q:GetStatusEffectName()
    return "particles/status_fx/status_effect_templar_slow.vpcf"
end

function modifier_ld_q:StatusEffectPriority()
    return 2
end
