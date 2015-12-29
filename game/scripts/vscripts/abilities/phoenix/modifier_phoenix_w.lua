modifier_phoenix_w = class({})

function modifier_phoenix_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_phoenix_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_phoenix_w:IsDebuff()
    return true
end

function modifier_phoenix_w:GetStatusEffectName()
    return "particles/status_fx/status_effect_phoenix_burning.vpcf"
end

function modifier_phoenix_w:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf"
end

function modifier_phoenix_w:StatusEffectPriority()
    return 1
end

function modifier_phoenix_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end