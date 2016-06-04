modifier_ld_w_sub = class({})

function modifier_ld_w_sub:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_ld_w_sub:IsDebuff()
    return true
end

function modifier_ld_w_sub:GetModifierMoveSpeedBonus_Percentage(params)
    return -60
end

function modifier_ld_w_sub:GetStatusEffectName()
    return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function modifier_ld_w_sub:GetStatusEffectPriority()
    return 2
end
