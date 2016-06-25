modifier_brew_beer = class({})

function modifier_brew_beer:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_brew_beer:IsDebuff()
    return true
end

function modifier_brew_beer:GetModifierMoveSpeedBonus_Percentage(params)
    return -10 * self:GetStackCount()
end

function modifier_brew_beer:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end

function modifier_brew_beer:StatusEffectPriority()
    return 2
end

function modifier_brew_beer:GetStatusEffectName()
    return "particles/status_fx/status_effect_brewmaster_drunken_haze.vpcf"
end

function modifier_brew_beer:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end