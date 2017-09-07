modifier_pl_e_slow = class({})
local self = modifier_pl_e_slow

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function self:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function self:IsDebuff()
    return true
end

function self:GetStatusEffectName()
    return "particles/status_fx/status_effect_phantoml_slowlance.vpcf"
end

function self:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_target.vpcf"
end

function self:StatusEffectPriority()
    return 1
end

function self:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end