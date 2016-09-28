modifier_tusk_w = class({})

function modifier_tusk_w:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_tusk_w:StatusEffectPriority()
    return 1
end

function modifier_tusk_w:GetProjectileSpeedModifier()
    return 0.3
end

function modifier_tusk_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_tusk_w:IsDebuff()
    return true
end

function modifier_tusk_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end
