modifier_cm_frozen = class({})

function modifier_cm_frozen:IsDebuff()
    return true
end

function modifier_cm_frozen:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_cm_frozen:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_cm_frozen:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end