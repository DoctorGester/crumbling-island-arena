modifier_tiny_a = class({})

function modifier_tiny_a:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_tiny_a:GetModifierMoveSpeedBonus_Percentage()
    return -20
end

function modifier_tiny_a:IsDebuff()
    return true
end

function modifier_tiny_a:GetStatusEffectName()
    return "particles/status_fx/status_effect_enchantress_enchant_slow.vpcf"
end

function modifier_tiny_a:StatusEffectPriority()
    return 1
end